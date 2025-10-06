import 'libs.dart';

final ThemeData theme = ThemeData(
  // scaffoldBackgroundColor: const Color.fromARGB(255, 3, 37, 65),
  listTileTheme: const ListTileThemeData(
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: 20,
      color: Colors.grey,
      fontStyle: FontStyle.italic,
    ),
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
        // foregroundColor: WidgetStatePropertyAll(
        //   Color.fromARGB(255, 3, 48, 85),
        // ),
        ),
  ),
  appBarTheme: const AppBarTheme(
    // backgroundColor: Color.fromARGB(255, 3, 37, 65),
    foregroundColor: Colors.amber,
    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  ),
);

void main() {
  // Giving the constructor a list of tables to create.
  NBEDatabase nbeDB = NBEDatabase.constructor([
    SettingLocalProvider.createOrReplaceTableString(),
    SellRecordLocalProvider.createOrReplaceTableString(),
  ]);

  final sellRecordProvider = SellRecordLocalProvider(nbeDB);
  final settingProvider = SettingLocalProvider(nbeDB);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<SettingsBloc>(create: (context) {
        return SettingsBloc(settingProvider);
      }),
      BlocProvider<SellRecordBloc>(create: (context) {
        return SellRecordBloc(sellRecordProvider);
      })
    ],
    child: const MyApp(),
  ));
}

MaterialColor ourMainThemeColor = MaterialColor(
  _mainThemeValue,
  <int, Color>{
    50: const Color(0xFF74C9F8),
    100: const Color(0xFF74C9F8),
    200: const Color(0xFF409dd6),
    300: const Color(0xFF248BC4),
    400: const Color(0xFF1a87da),
    500: Color(_mainThemeValue),
    600: const Color(0xFF055fab),
    700: const Color(0xFF055fab),
    800: const Color(0xFF055fab),
    900: const Color(0xFF055fab),
  },
);

int _mainThemeValue = 0xFF055fab;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColorLight: const Color(0xFF1a87da),
        primaryColor: Color(_mainThemeValue),
        primarySwatch: ourMainThemeColor,
        // canvasColor: Colors.black,
      ),
      title: 'Gold Purchasing Rate',
      home: const NavigationController(),
    );
  }
}

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _currentIndex = 0;
  static const List<Widget> widgetList = [
    CalculatorScreen(),
    ReportScreen(),
    Center(child: Text('Index 2')),
    Center(child: Text('Index 3')),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetList[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        fixedColor: Colors.amber,
        // backgroundColor: const Color.fromARGB(255, 1, 28, 49),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grading_sharp),
            label: 'Report',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
            //dispose the snackbar of one screen when moving to the next
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          });
        },
      ),
    );
  }
}
