import 'package:nbe/libs.dart';

class SellRecordBloc extends Bloc<SellRecordEvent, SellRecordState> {
  final SellRecordLocalProvider provider;
  SellRecordBloc(this.provider) : super(SellRecordInit()) {
    on<SellRecordLoad>(
      (event, emit) async {
        int offset = 0;
        int limit = 0;
        if (state is SellRecordLoaded) {
          offset = (state as SellRecordLoaded).records.length;
          limit = offset + 10;
        }
        final result = await provider.getRecentSellRecord(offset, limit);
        if (result != null) {
          if (state is SellRecordLoaded) {
            final records = (state as SellRecordLoaded).records;
            result.forEach((el) {
              records.putIfAbsent(el.id, () {
                return el;
              });
            });
            emit(SellRecordLoaded(records));
          } else {
            emit(SellRecordLoaded(Map.fromIterable(
              result,
              key: (obj) => obj.id,
              value: (obj) => obj,
            )));
          }
        }
      },
    );
  }
}
