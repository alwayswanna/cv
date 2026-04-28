import 'dart:convert';
import 'package:cv_project/data/personal_data.dart';
import 'package:flutter/services.dart';

class ConfigService {

  static Future<PersonalData> loadConfiguration({bool russian = false}) async {
    final path = russian
        ? 'assets/data/main-data-ru.json'
        : 'assets/data/main-data.json';
    final String jsonString = await rootBundle.loadString(path);
    final jsonResponse = jsonDecode(jsonString);
    return PersonalData.fromJson(jsonResponse);
  }
}