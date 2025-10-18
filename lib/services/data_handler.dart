// import 'package:nbe/database/database.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';

class DataHandler {
  DataHandler._privateConstructor();
  static final instance = DataHandler._privateConstructor();
  static const String transactionsTable = 'Transactions';

  static const String createTransactionsTable = '''
    CREATE TABLE Transactions (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      todays_rate REAL NOT NULL,
      weight REAL NOT NULL CHECK(weight >= 0),
      specific_gravity REAL NOT NULL CHECK(specific_gravity > 0),
      total_amount REAL NOT NULL CHECK(total_amount >= 0),
      is_completed INTEGER NOT NULL CHECK(is_completed IN (0,1)),
      setting_id TEXT NOT NULL,
      karat TEXT
    );
  ''';

  final NBEDatabase _nbeDb = NBEDatabase.constructor([createTransactionsTable]);
  Future<Database> get _database async => await _nbeDb.database;

  Future<void> ensureTableExists(String tableName) async {
    final db = await _database;

    // Check if the table exists
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?;",
      [tableName],
    );

    if (result.isEmpty) {
      // Table does not exist — create it
      await db.execute(createTransactionsTable);
      print('Table $tableName created successfully.');
    } else {
      print('Table $tableName already exists.');
    }
  }

  Future<void> addTransactionToDb(Transaction transaction) async {
    final db = await _database;
    print('Table created');
    await db.insert(
      'Transactions',
      {
        'id': transaction.id,
        'date': transaction.date.toIso8601String(),
        'todays_rate': transaction.todayRate,
        'weight': transaction.weight,
        'specific_gravity': transaction.specificGravity,
        'total_amount': transaction.totalAmount,
        'is_completed': transaction.isCompleted ? 1 : 0,
        'setting_id': transaction.settingId,
        'karat': transaction.karat,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> loadAllTransactions() async {
    final db = await _database;

    print('Database opened');
    final transactionData = await db.query('Transactions');
    print('data loaded');
    final List<Transaction> transactions = [];

    for (var tran in transactionData) {
      print('Data ${tran['date'] as String}');
      final transaction = Transaction(
        id: tran['id'] as String,
        date: DateTime.parse(tran['date'] as String),
        specificGravity: (tran['specific_gravity'] as num).toDouble(),
        todayRate: (tran['todays_rate'] as num).toDouble(),
        totalAmount: (tran['total_amount'] as num).toDouble(),
        weight: (tran['weight'] as num).toDouble(),
        isCompleted: tran['is_completed'] as int == 1,
        settingId: tran['setting_id'] as String,
        karat: tran['karat'] as String,
      );
      transactions.add(transaction);
      print('member ${transaction.id}');
    }
    return transactions;
  }
}

String currencyFormatter(double value) {
  final formatter = NumberFormat('#,##0.##');
  final formattedValue = formatter.format(value);
  return '$formattedValue ብር';
}

String currencyFormatterForPrint(double value) {
  final formatter = NumberFormat('#,##0.##');
  final formattedValue = formatter.format(value);
  return '$formattedValue Birr';
}
