import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LocalizationService {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'sound': 'Enable Sound Effects',
      'vibration': 'Enable Vibration',
      'language': 'Language',
    },
    'fr': {
      'settings': 'Paramètres',
      'dark_mode': 'Mode Sombre',
      'sound': 'Activer les effets sonores',
      'vibration': 'Activer les vibrations',
      'language': 'Langue',
    },
  };

  static String currentLang = 'en';

  static Future<void> loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentLang = prefs.getString('lang') ?? 'en';
  }

  static Future<void> changeLanguage(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    currentLang = lang;
  }

  static String t(String key) {
    return _localizedValues[currentLang]?[key] ?? key;
  }
}
