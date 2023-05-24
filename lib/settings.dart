import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ulist/services.dart';

class Settings {
  bool darkMode = false;
  bool compactMode = false;

  Settings({this.darkMode = false, this.compactMode = false});

  factory Settings.defaultSettings() {
    return Settings(darkMode: false, compactMode: false);
  }

  factory Settings.fromJson(Map<String, dynamic> responseData) {
    return Settings(
        darkMode: responseData['darkMode'],
        compactMode: responseData['compactMode']);
  }

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'compactMode': compactMode,
      };
}

class SettingsManager {
  var secureStorage = getIt<FlutterSecureStorage>();

  StreamController updatedController = StreamController.broadcast();

  Stream get settingsUpdated => updatedController.stream;

  Settings settings = Settings.defaultSettings();

  SettingsManager() {
    secureStorage.read(key: "settings").then((value) {
      if (value != null) {
        settings = Settings.fromJson(jsonDecode(value));
      } else {
        settings = Settings.defaultSettings();
        secureStorage.write(key: "settings", value: jsonEncode(settings));
      }
      updatedController.add(settings);
    });
  }

  void updateSettings(Settings newSettings) {
    settings = newSettings;
    secureStorage.write(key: "settings", value: jsonEncode(settings));
    updatedController.add(settings);
  }

  bool get darkMode => settings.darkMode;
  bool get compactMode => settings.compactMode;

  void dispose() {
    updatedController.close();
  }
}
