import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nbe/bloc/transaction_bloc.dart';
import 'package:nbe/libs.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _specificGravityController =
      TextEditingController();
  Map<String, String> pricesMap = {};
  final url = 'https://api.nbe.gov.et/api/filter-gold-rates';

  //to check if the day has changed
  bool areSameDates(DateTime day1, DateTime day2) {
    return day1.toIso8601String().substring(0, 10) ==
        day2.toIso8601String().substring(0, 10);
  }

  // to get the rates either from cache or from api
  Future<void> _getPurchasingRate() async {
    final cached = await SharedPreferences.getInstance();
    if (cached.getString('last_updated') != null) {}
    DateTime? lastUpdated = DateTime.tryParse(
      cached.getString('last_updated') ?? '',
    );
    DateTime latestDate = DateTime.now();
    if (latestDate.hour >= 0 && latestDate.hour < 8) {
      latestDate = latestDate.subtract(const Duration(days: 1));
    }

    if (lastUpdated == null || !areSameDates(lastUpdated, latestDate)) {
      final parsed = Uri.parse(url);
      try {
        final response = await http.get(parsed);

        if (response.statusCode == 200) {
          final Map<String, dynamic> document = jsonDecode(response.body);

          try {
            final List rates = document['data'];
            cached.setString(
                'last_updated', DateTime.now().toString().substring(0, 10));
            for (var rate in rates) {
              cached.setString(rate["gold_type"]["karat"], rate["price_birr"]);
              pricesMap[rate["gold_type"]["karat"]] = rate["price_birr"];
            }
            setState(() {});
          } catch (e) {
            print('Something wrong in caching');
          }
        } else {
          print('Failed to load page. Status Code:${response.statusCode}');
          if (context.mounted) {
            _showSnackBar(
                'Failed to load the purchasing rates. Server error: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar('Failed to load the purchasing rates');
        }
      }
    } else {
      final keys = cached.getKeys();
      for (var key in keys) {
        final value = cached.get(key);
        if (value != null) {
          pricesMap[key] = value as String;
        }
      }
      setState(() {});
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(days: 1),
        content: Text(message),
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _getPurchasingRate();
              // _getSettings();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            }),
      ),
    );
  }

  void _calculate() {
    final settingsBloc = context.read<SettingsBloc>();

    final settingsId =
        (settingsBloc.state as SettingsLoaded).settings.values.last.id;

    final weight = double.tryParse(_weightController.text);
    final specificGravity = double.tryParse(_specificGravityController.text);
    if (weight == null || specificGravity == null) {
      return null;
    }

    int estimatedCarat = 0;
    if (specificGravity <= 19.51 && specificGravity > 19.13) {
      estimatedCarat = 24;
    } else if (specificGravity <= 19.13 && specificGravity > 18.24) {
      estimatedCarat = 23;
    } else if (specificGravity <= 18.24 && specificGravity > 17.45) {
      estimatedCarat = 22;
    } else if (specificGravity <= 17.45 && specificGravity > 17.11) {
      estimatedCarat = 21;
    } else if (specificGravity <= 17.11 && specificGravity > 16.03) {
      estimatedCarat = 20;
    } else if (specificGravity <= 16.03 && specificGravity > 15.2) {
      estimatedCarat = 18;
    }

    final rate = pricesMap[estimatedCarat.toString()];
    final totalAmount = (double.tryParse(rate ?? '') ?? 0) * weight;
    final transaction = Transaction(
      id: uuid.v4(),
      date: DateTime.now(),
      specificGravity: specificGravity,
      todayRate: double.tryParse(rate ?? '') ?? 0,
      totalAmount: totalAmount,
      weight: weight,
      isCompleted: true,
      settingId: settingsId,
      karat: estimatedCarat.toString(),
    );
    context
        .read<TransactionBloc>()
        .add(AddTransaction(transaction: transaction));
  }

  @override
  void initState() {
    _getPurchasingRate();
    context.read<SettingsBloc>().add(SettingsLoadEvent());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final TextStyle _commonLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black.withOpacity(.5),
    overflow: TextOverflow.visible,
  );

  @override
  Widget build(BuildContext context) {
    final Container _tinyDivider = Container(
      color: Colors.amber.withOpacity(.1),
      width: MediaQuery.of(context).size.width * .5,
      height: 0.5,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculate',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .9,
              decoration: BoxDecoration(
                border: Border(
                  left: const BorderSide(color: Colors.orange),
                  right: const BorderSide(color: Colors.orange),
                  bottom: BorderSide(color: Colors.black.withOpacity(.05)),
                ),
              ),
              // padding: const EdgeInsets.symmetric(horizontal: 10.0),
              margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
              child: TitledContainer(
                'Today\'s National Bank Rate',
                ["24", "23", "22", "21", "20", "19"].map<Column>((k) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '$k Karrat',
                            textAlign: TextAlign.center,
                            style: k == "24"
                                ? TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black.withOpacity(.8),
                                    overflow: TextOverflow.visible,
                                  )
                                : _commonLabelStyle,
                          ),
                          Text(
                            '${currencyFormatter(double.tryParse(pricesMap[k] ?? '') ?? 0)}/ ግራም ',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      _tinyDivider,
                    ],
                  );
                }).toList(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: const BorderSide(color: Colors.orange),
                  right: const BorderSide(color: Colors.orange),
                  bottom: BorderSide(color: Colors.black.withOpacity(.05)),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              width: MediaQuery.of(context).size.width * .9,
              height: MediaQuery.of(context).size.height * .15,
              child: Stack(
                children: [
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      if (state is SettingsInit) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SettingsLoaded) {
                        return TitledContainer(
                          "Settings",
                          [
                            Row(children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Immediate Payment Amount ',
                                  style: _commonLabelStyle,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '95%',
                                  style: _commonLabelStyle,
                                ),
                              ),
                            ]),
                            Row(children: [
                              Expanded(
                                flex: 2,
                                child: Text('Tax per gram',
                                    style: _commonLabelStyle),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                    '${state.settings.values.last.taxPerGram} EtB',
                                    style: _commonLabelStyle),
                              ),
                            ]),
                            Row(children: [
                              Expanded(
                                flex: 2,
                                child: Text('Bank Fee in percent:',
                                    style: _commonLabelStyle),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                    '${state.settings.values.last.bankFeePercentage * 100}%',
                                    style: _commonLabelStyle),
                              ),
                            ]),
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text('Bonus by NBE:',
                                        style: _commonLabelStyle)),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${state.settings.values.last.excludePercentage * 100}%',
                                    style: _commonLabelStyle,
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      } else {
                        return const Text('Error');
                      }
                    },
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => SettingsScreen(
                                nbe24KaratRate:
                                    double.tryParse(pricesMap['24'] ?? '') ??
                                        0)));
                      },
                      splashColor: Theme.of(context).primaryColor,
                      icon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(.5)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.edit,
                              color: Theme.of(context).primaryColor,
                              size: 14,
                            )
                          ],
                        ),
                      ),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CommonTextField(
                controller: _weightController,
                label: "Weight in grams",
                errorMessage: "",
                onChanged: (val) {},
                keyboardType: const TextInputType.numberWithOptions(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: CommonTextField(
                label: "Specific gravity in cm^3",
                errorMessage: "",
                onChanged: (val) {},
                controller: _specificGravityController,
                keyboardType: const TextInputType.numberWithOptions(),
              ),
            ),
            const SizedBox(height: 10),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return FancyWideButton(
                  "Calculate",
                  () {
                    final transaction = _calculate();
                    // if (transaction == null) {
                    //   return;
                    // }
                    _specificGravityController.clear();
                    _weightController.clear();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const CalculationDetails(
                            // transaction: transaction,
                            ),
                      ),
                    );
                  },
                  enabled: state is SettingsLoaded,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
