import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'asset_loader.dart';

class ArbAssetLoader extends AssetLoader {
  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${localeToString(locale, separator: "-")}.arb';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    log('easy localization loader: load arb file $localePath');

    return jsonDecode(await rootBundle.loadString(localePath));
  }
}

// Loader for single json file
class ArbSingleAssetLoader extends AssetLoader {
  Map? jsonData;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (jsonData == null) {
      log('easy localization loader: load arb file $path');
      jsonData = jsonDecode(await rootBundle.loadString(path));
    } else {
      log('easy localization loader: arb already loaded, read cache');
    }

    return jsonData![locale.toString()];
  }
}
