import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import 'asset_loader.dart';

import 'package:easy_localization/src/easy_localization_app.dart' show localeToString;

//
//
//
//
class YamlAssetLoader extends AssetLoader {
  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${localeToString(locale, separator: "-")}.yaml';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    YamlMap yaml = loadYaml(await rootBundle.loadString(localePath));
    return _convertYamlMapToMap(yaml);
  }

  /// Convert YamlMap to Map
  Map<String, dynamic> _convertYamlMapToMap(YamlMap yamlMap) {
    final map = <String, dynamic>{};

    for (final entry in yamlMap.entries) {
      if (entry.value is YamlMap || entry.value is Map) {
        map[entry.key.toString()] = _convertYamlMapToMap(entry.value);
      } else {
        map[entry.key.toString()] = entry.value.toString();
      }
    }
    return map;
  }
}