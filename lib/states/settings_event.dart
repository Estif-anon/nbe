import 'package:nbe/types/setting_types.dart';

class SettingsEvent {}

class SettingsLoadEvent extends SettingsEvent {}

class AddSettingEvent extends SettingsEvent {
  final Setting setting;

  AddSettingEvent({required this.setting});
}
