import 'package:nbe/libs.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingLocalProvider provider;
  SettingsBloc(this.provider) : super(SettingsInit()) {
    on<SettingsLoadEvent>((event, emit) async {
      int offset = 0;
      int limit = 0;
      if (state is SellRecordLoaded) {
        offset = (state as SellRecordLoaded).records.length;
        limit = offset + 10;
      }
      final result = await provider.getRecentSettings(offset, limit);
      if (state is SellRecordLoaded) {
        final records = (state as SettingsLoaded).settings;
        result.forEach((el) {
          records.putIfAbsent(el.id, () {
            return el;
          });
        });
        emit(SettingsLoaded(records));
      } else {
        emit(SettingsLoaded(Map.fromIterable(
          result,
          key: (obj) => obj.id,
          value: (obj) => obj,
        )));
      }
    });
  }
}
