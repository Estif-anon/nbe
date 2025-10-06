import 'package:nbe/libs.dart';

class CalculationDetails extends StatefulWidget {
  final Transaction transaction;
  final Setting setting;
  const CalculationDetails(
      {required this.transaction, required this.setting, super.key});
  @override
  State<CalculationDetails> createState() => _CalculationDetailsState();
}

class _CalculationDetailsState extends State<CalculationDetails> {
  final _remainingController = TextEditingController();
  late final double tax;
  late final double bonus;
  late final double bankFee;
  final immediatePayment = 0.95;
  bool isSaving = false;

  double taxValue = 0;
  double bonusValue = 0;
  double bankFeeValue = 0;
  double immediatePaymentValue = 0;
  double netValue = 0;
  double netCompleted = 0;

  void calculateValues() {
    final tran = widget.transaction;
    setState(() {
      immediatePaymentValue = immediatePayment * tran.totalAmount;
      taxValue = tax * tran.weight;
      bonusValue = bonus * tran.totalAmount;
      bankFeeValue = bankFee * tran.totalAmount;
      netValue =
          (immediatePaymentValue + bonusValue) - (taxValue + bankFeeValue);
      netCompleted =
          (tran.totalAmount + bonusValue) - (taxValue + bankFeeValue);
    });
  }

  void onSaveTapped() async {
    final db = NBEDatabase.constructor([
      SettingLocalProvider.createOrReplaceTableString(),
    ]);
    setState(() {
      isSaving = true;
    });
    await DataHandler.instance.ensureTableExists('Transactions');
    await DataHandler.instance.addTransactionToDb(widget.transaction);
    await SettingLocalProvider(db).insertSetting(widget.setting);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Saved Successfully'),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    tax = widget.setting.taxPerGram;
    bankFee = widget.setting.bankFeePercentage;
    bonus = widget.setting.excludePercentage;
    calculateValues();
    super.initState();
  }

  final TextStyle _labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    overflow: TextOverflow.visible,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculation Details')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      flex: 2, child: Text('Total of 95%', style: _labelStyle)),
                  Expanded(
                    flex: 1,
                    child: Text(
                      currencyFormatter(immediatePaymentValue),
                      style: _labelStyle,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                      flex: 2, child: Text('Bank Fee:', style: _labelStyle)),
                  Expanded(
                    flex: 1,
                    child: Text(
                      currencyFormatter(bankFeeValue),
                      style: _labelStyle,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: Text('Tax:', style: _labelStyle)),
                  Expanded(
                    flex: 1,
                    child: Text(
                      currencyFormatter(taxValue),
                      style: _labelStyle,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: Text('Net:', style: _labelStyle)),
                  Expanded(
                    flex: 1,
                    child: Text(
                      currencyFormatter(netValue),
                      style: _labelStyle,
                    ),
                  )
                ],
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CommonTextField(
                  controller: _remainingController,
                  errorMessage: "",
                  label: "Remaining",
                  onChanged: (val) {},
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('Net Completed:', style: _labelStyle)),
                  Expanded(
                    flex: 1,
                    child: Text(
                      currencyFormatter(netCompleted),
                      style: _labelStyle,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(
                    Size(double.infinity, 60),
                  ),
                ),
                onPressed: onSaveTapped,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
