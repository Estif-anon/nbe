import 'package:nbe/libs.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingLocalProvider provider;
  SettingsBloc(this.provider) : super(SettingsInit()) {
    on<SettingsLoadEvent>((event, emit) async {
      int offset = 0;
      int limit = 10;
      // if (state is SettingsLoaded) {
      //   offset = (state as SettingsLoaded).settings.length;
      //   limit = offset + 10;
      // }
      if (state is SettingsInit) {
        final result = await provider.getRecentSettings(offset, limit);
        // if (state is SettingsLoaded) {
        //   final records = (state as SettingsLoaded).settings;
        //   result.forEach((el) {
        //     records.putIfAbsent(el.id, () {
        //       return el;
        //     });
        //   });
        //   emit(SettingsLoaded(records));
        // }
        print('Loading for the bloc');
        if (result.isNotEmpty) {
          emit(SettingsLoaded(Map.fromIterable(
            result,
            key: (obj) => obj.id as String,
            value: (obj) => obj as Setting,
          )));
        } else {
          final newSetting = Setting(uuid.v4(), 0, 5000, 0.0001, 0.1);
          emit(SettingsLoaded({newSetting.id: newSetting}));
        }
      }
    });
    on<AddSettingEvent>(
      (event, emit) {
        if (state is SettingsInit) {
          emit(SettingsLoaded({event.setting.id: event.setting}));
        } else if (state is SettingsLoaded) {
          final updatedSettings =
              Map<String, Setting>.from((state as SettingsLoaded).settings);
          updatedSettings[event.setting.id] = event.setting;

          emit(SettingsLoaded(updatedSettings));
        }
      },
    );
  }
}
