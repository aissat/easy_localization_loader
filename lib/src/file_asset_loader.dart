import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';

class FileAssetLoader extends AssetLoader {
  const FileAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    final file = File(localePath);
    log('easy localization loader: load file $localePath');

    return json.decode(await file.readAsString());
  }
}

class FileSingleAssetLoader extends AssetLoader {
  const FileSingleAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File(path);
    log('easy localization loader: load file $path');
    return json.decode(await file.readAsString());
  }
}
