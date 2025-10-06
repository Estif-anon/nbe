import 'package:nbe/libs.dart';
import 'package:sqflite/sqflite.dart';

class SellRecordLocalProvider {
  static const String tableName = "sell_record";
  static const String _idCol = "id";
  static const String _gramCol = "gram";
  static const String _specificGravityCol = "specificGravity";
  static const String _subTotalCol = "subTotal";
  static const String _remainingCol = "remaining";
  static const String _netCol = "net";
  static const String _createdAtCol = "createdAt";
  static const String _settingIDCol = "setting_id";

  final NBEDatabase wrapper;
  SellRecordLocalProvider(this.wrapper) : super();

  static String createOrReplaceTableString() {
    return """CREATE TABLE IF NOT EXISTS $tableName(
        $_idCol ${SQLLiteTypes.intType} PRIMARY KEY,
        $_gramCol ${SQLLiteTypes.doubleType} NOT NULL,
        $_specificGravityCol ${SQLLiteTypes.doubleType} NOT NULL,
        $_subTotalCol ${SQLLiteTypes.doubleType} NOT NULL,
        $_remainingCol ${SQLLiteTypes.doubleType} default 0.0 NOT NULL,
        $_netCol ${SQLLiteTypes.doubleType} default 0.0,
        $_settingIDCol ${SQLLiteTypes.intType} NOT NULL,
        $_createdAtCol ${SQLLiteTypes.intType} NOT NULL,
      )""";
  }

  Future<int> insertSellRecord(SellRecord detail) async {
    final db = await wrapper.database;
    return db.insert(
      tableName,
      detail.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<bool> checkIfSellRecordExists(int id) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      where: "$_idCol=$id",
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<SellRecord>?> getRecentSellRecord(int offset, int limit) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      orderBy: _createdAtCol,
      offset: offset,
      limit: limit,
    );
    result.map((el) {
      return SellRecord.fromJson(
        el,
      );
    }).toList();
  }

  Future<SellRecord?> getSellRecordByID(int id) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      where: "$_idCol=$id",
    );
    if (result.isEmpty) {
      return null;
    }
    return SellRecord.fromJson(result.first);
  }
}
