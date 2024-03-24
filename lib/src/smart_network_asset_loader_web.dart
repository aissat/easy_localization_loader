import 'dart:convert';
import 'dart:html';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SmartNetworkAssetLoader extends AssetLoader {
  final Function(String) localeUrl;
  final Duration timeout;
  final String assetsPath;
  final Duration localCacheDuration;

  SmartNetworkAssetLoader({
    required this.localeUrl,
    this.timeout = const Duration(seconds: 30),
    required this.assetsPath,
    this.localCacheDuration = const Duration(days: 1),
  });

  @override
  Future<Map<String, dynamic>> load(String localePath, ui.Locale locale) async {
    var string = '';

    if (await localTranslationExists(locale.toString())) {
      string = await loadFromLocalFile(locale.toString());
    }

    if (string == '' && await isInternetConnectionAvailable()) {
      string = await loadFromNetwork(locale.toString());
    }

    if (string == '' &&
        await localTranslationExists(locale.toString(),
            ignoreCacheDuration: true)) {
      string = await loadFromLocalFile(locale.toString());
    }

    if (string == '') {
      string = await rootBundle
          .loadString(assetsPath + '/' + locale.toString() + '.json');
    }

    return json.decode(string);
  }

  Future<bool> isInternetConnectionAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      try {
        final result = window.navigator.onLine ?? false;
        return result;
      } catch (_) {
        return false;
      }
    }
  }

  Future<String> loadFromNetwork(String localeName) async {
    String url = localeUrl(localeName);
    url = url + '' + localeName + '.json';

    try {
      final response =
          await Future.any([http.get(Uri.parse(url)), Future.delayed(timeout)]);

      if (response != null && response.statusCode == 200) {
        var content = utf8.decode(response.bodyBytes);
        if (json.decode(content) != null) {
          await saveTranslation(localeName, content);
          return content;
        }
      }
    } catch (e) {
      print(e.toString());
    }

    return '';
  }

  Future<bool> localTranslationExists(String localeName,
      {bool ignoreCacheDuration = false}) async {
    var translationFile = await getFileForLocale(localeName);

    if (translationFile != null) {
      return true;
    }

    return false;
  }

  Future<String> loadFromLocalFile(String localeName) async {
    return window.localStorage[localeName] ?? '';
  }

  Future<void> saveTranslation(String localeName, String content) async {
    window.localStorage[localeName] = content;
    print('saved');
  }

  Future<File?> getFileForLocale(String localeName) async {
    return null; // No file system access in Flutter web
  }
}
