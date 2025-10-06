import 'package:nbe/libs.dart';

class SettingsState {}

class SettingsInit extends SettingsState {}

class SettingsLoaded extends SettingsState {
  Map<String, Setting> settings;
  SettingsLoaded(this.settings);
}
