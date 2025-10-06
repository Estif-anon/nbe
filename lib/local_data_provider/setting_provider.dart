import 'package:nbe/libs.dart';
import 'package:sqflite/sqflite.dart';

class SettingLocalProvider {
  static const String tableName = "setting";
  static const String _idCol = "id";
  static const String _nbe24KaratRateCol = "nbe24KaratRate";
  static const String _taxPerGramCol = "taxPerGram";
  static const String _bankFeePercentageCol = "bankFeePercentage";
  static const String _excludePercentageCol = "excludePercentage";
  static const String _createdAtCol = "createdAt";

  final NBEDatabase wrapper;
  SettingLocalProvider(this.wrapper) : super();

  static String createOrReplaceTableString() {
    return """CREATE TABLE IF NOT EXISTS $tableName(
        $_idCol ${SQLLiteTypes.stringType} PRIMARY KEY,
        $_nbe24KaratRateCol ${SQLLiteTypes.doubleType} NOT NULL,
        $_taxPerGramCol ${SQLLiteTypes.doubleType} DEFAULT 0.0,
        $_bankFeePercentageCol ${SQLLiteTypes.doubleType} NOT NULL,
        $_excludePercentageCol ${SQLLiteTypes.doubleType} default 0.0 NOT NULL,
        $_createdAtCol ${SQLLiteTypes.intType} NOT NULL
      )""";
  }

  Future<int> insertSetting(Setting detail) async {
    final db = await wrapper.database;
    return db.insert(
      tableName,
      detail.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<bool> checkIfSettingExists(int id) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      where: "$_idCol= ?",
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<Setting>> getRecentSettings(int offset, int limit) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      orderBy: _createdAtCol,
      offset: offset,
      limit: limit,
    );
    return result.map((el) {
      return Setting.fromJson(
        el,
      );
    }).toList();
  }

  Future<List<Setting>> getAllSettings() async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      orderBy: _createdAtCol,
    );
    return result.map((el) {
      return Setting.fromJson(
        el,
      );
    }).toList();
  }

  Future<Setting?> getSettingByID(String id) async {
    final db = await wrapper.database;
    final result =
        await db.query(tableName, where: "$_idCol= ?", whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    return Setting.fromJson(result.first);
  }
}
