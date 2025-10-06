import 'package:nbe/libs.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingLocalProvider provider;
  SettingsBloc(this.provider) : super(SettingsInit()) {
    on<SettingsLoadEvent>((event, emit) {});
  }
}
