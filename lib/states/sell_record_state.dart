import 'package:nbe/types/sell_types.dart';

class SellRecordState {}

class SellRecordInit extends SellRecordState {}

class SellRecordLoaded extends SellRecordState {
  Map<int, SellRecord> records;

  SellRecordLoaded(this.records);
}
