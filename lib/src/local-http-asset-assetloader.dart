import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'asset_loader.dart';

/// if you are in need of particular type of requirement such as:

/// your translations in asset are not complete  so that you want to use the remote translations but want to make available for offilne use
/// this makes app useable if there is no internet connection to fetch the new transaltions everytime.

///if there is translation file locally(cached) then

///1. merge the local translation file with the asset-bundler translation file but give priority to the local translation.
///2. if the local localization is older than [one day] then fetch the new localization from backend and save in local(cache) and perform 1st step.
class HttpLocalAssetLoader extends AssetLoader {
  final String httpPathBase;

  /// path where the transaltion file is stored
  /// use as such
  // final applicationDirectory = await getApplicationSupportDirectory(); using path_provider pacakge
  final String localFilePath;

  /// base path to the localization in remote http
  HttpLocalAssetLoader(
      {required this.httpPathBase, required this.localFilePath});

  /// here asset path is the path to the assetbundle file
  @override
  Future<Map<String, dynamic>> load(String assetPath, Locale locale) async {
    try {
      final localeFromLocal = await _getJsonFromLocaleFile(locale);
      final localeFromAsset = await _getJsonFromAsset(assetPath, locale);

      if (localeFromLocal != null) {
        if (localeFromAsset != null) {
          localeFromAsset.addAll(localeFromLocal);
          return localeFromAsset;
        } else {
          return localeFromLocal;
        }
      } else {
        final localeFromHtpp = await _getFromHttp(httpPathBase, locale);

        if (localeFromHtpp != null) {
          if (localeFromAsset != null) {
            localeFromAsset.addAll(localeFromHtpp);
            return localeFromAsset;
          } else {
            return localeFromHtpp;
          }
        } else {
          if (localeFromAsset != null) {
            return localeFromAsset;
          } else {
            return Future.value({'error': 'no translation'});
          }
        }
      }
    } catch (e) {
      return Future.value({'error_${locale.countryCode}': '$e'});
    }
  }

  String _getAssetBundleLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  Future<String> _getLocalLocalePath(Locale locale) async {
    return "$localFilePath/${locale.toStringWithSeparator(separator: "-")}.json";
  }

  String _getHttpPath(String base, Locale local) {
    return '$base/${local.languageCode}';
  }

  Future<Map<String, dynamic>?> _getJsonFromAsset(
      String path, Locale locale) async {
    try {
      var localePath = _getAssetBundleLocalePath(path, locale);
      log('Load asset from $path');
      return json.decode(await rootBundle.loadString(localePath));
    } catch (e) {
      log('Load asset failed from $path $e');

      return Future.value();
    }
  }

  Future<Map<String, dynamic>?> _getJsonFromLocaleFile(Locale locale) async {
    try {
      log('getting transalation from local file');
      var localePath = await _getLocalLocalePath(locale);
      final localFile = File(localePath);
      if (await localFile.exists()) {
        log(' transalation in local file found');
        final lastModified = await localFile.lastModified();
        if (lastModified.difference(DateTime.now()).abs().inHours > 24) {
          log(' transalation in local file is older than 24hr');
          return Future.value();
        }

        final translation = json.decode(await localFile.readAsString());
        log('Load asset from $localePath');
        return translation;
      }
      log(' no transalation found in local file ');

      return Future.value();
    } catch (e) {
      log('Load asset failed from local file $e');

      return Future.value();
    }
  }

  Future<Map<String, dynamic>?> _getFromHttp(String path, Locale locale) async {
    try {
      log('Loading asset from http');

      var url = Uri.parse(_getHttpPath(path, locale));
      final localeResponse = await http.get(url);
      if (localeResponse.statusCode != 200) {
        log('Loading asset from ${url.toString()} failed ${localeResponse.body}');
        return Future.value();
      }

      try {
        log('Writing the translation json in local');
        final file = File(await _getLocalLocalePath(locale));
        await file.create(recursive: true);
        await file.writeAsString(localeResponse.body, flush: true);
      } catch (e) {
        log('Failed to cache the remote translation in cache $e');
      }

      return jsonDecode(localeResponse.body);
    } catch (e) {
      log('easy localization loader: load http $path error: $e');
      //Catch network exceptions
      return Future.value();
    }
  }
}

extension LocaleToStringHelper on Locale {
  /// Convert [locale] to String with custom separator
  String toStringWithSeparator({String separator = '_'}) {
    return toString().split('_').join(separator);
  }
}
