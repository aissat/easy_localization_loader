import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class JsonAssetLoader extends AssetLoader {
  const JsonAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    log('easy localization loader: load json file $localePath');

    return jsonDecode(await rootBundle.loadString(localePath));
  }
}

// Loader for single json file
class JsonSingleAssetLoader extends AssetLoader {
  Map? jsonData;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (jsonData == null) {
      log('easy localization loader: load json file $path');
      jsonData = jsonDecode(await rootBundle.loadString(path));
    } else {
      log('easy localization loader: json already loaded, read cache');
    }

    return jsonData![locale.toString()];
  }
}
