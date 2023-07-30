import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  Settings withChange(Settings Function(Settings s) v) {
    return v(this);
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
  Settings _settings = Settings.defaultSettings();

  Settings get settings => _settings;
  set settings(Settings newSettings) {
    print("settings");
    updateSettings(newSettings);
  }

  SettingsManager() {
    secureStorage.read(key: "settings").then((value) {
      if (value != null) {
        _settings = Settings.fromJson(jsonDecode(value));
        
      } else {
        _settings = Settings.defaultSettings();
        secureStorage.write(key: "settings", value: jsonEncode(_settings));
      }
      updatedController.add(_settings);
    });
  }

  void syncSettings() {
    secureStorage.write(key: "settings", value: jsonEncode(_settings));

    updatedController.add(_settings);
  }

  void updateSettings(Settings newSettings) {
    _settings = newSettings;
    secureStorage.write(key: "settings", value: jsonEncode(_settings));
    updatedController.add(_settings);
  }

  bool get darkMode => _settings.darkMode;
  bool get compactMode => _settings.compactMode;
}
