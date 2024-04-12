import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as paths;

// ```dart
// PriorityNetworkAssetLoader(
//         localeUrl: (locale) => APILinks.localizationFilesLink,
//         assetsPath: LocaleRepository.localesPath,
//         timeout: const Duration(seconds: 10),
//         localCacheDuration: const Duration(hours: 12),
//         networkFileCreationDate: serverFileLocalesDate,
//       )
// ```

/// Order logic for the localization loader
/// The [cache] option will load the locale file from cache taking in mind the duration of cache
/// The [internet] option will load the locale from internet if the cache duration is exceeded or no cached localization file
/// The [cacheWithNoDuration] option will load the localization cached file ignoring the cache duration
/// The [asset] option will load the localization file from assets
enum LocalizationLoadType { cache, internet, cacheWithNoDuration, asset }

class PriorityNetworkAssetLoader extends AssetLoader {
  /// URL for the project localizations on domain
  final Function localeUrl;

  /// Timeout duration for downloading the localizations file from server
  final Duration timeout;

  /// Localizations assets path
  final String assetsPath;

  /// cache time limit setting
  final Duration localCacheDuration;

  /// Sets the initial priority of asset loader order
  final LocalizationLoadType priorityLoadType;

  /// The date in which the locales file was created on server
  final DateTime? networkFileCreationDate;

  PriorityNetworkAssetLoader({
    required this.localeUrl,
    required this.assetsPath,
    this.timeout = const Duration(seconds: 30),
    this.localCacheDuration = const Duration(hours: 12),
    this.priorityLoadType = LocalizationLoadType.cache,
    this.networkFileCreationDate,
  });

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    String string = '';

    switch (priorityLoadType) {
      case LocalizationLoadType.cache:
        bool canLoadCache = await localTranslationExists(locale.toString());
        if (canLoadCache) {
          string = await loadFromLocalFile(locale.toString());
          if (string.isNotEmpty) {
            if (kDebugMode) {
              print('localization loader: loaded cached translations');
            }
            break;
          }
        }
        continue internet;
      internet:
      case LocalizationLoadType.internet:
        string = await loadFromNetwork(locale.toString());
        if (string.isNotEmpty) {
          if (kDebugMode) {
            print('localization loader: loaded from internet');
          }
          break;
        }
        continue cacheWithNoDuration;
      cacheWithNoDuration:
      case LocalizationLoadType.cacheWithNoDuration:
        bool canLoadCacheIgnoringDuration = await localTranslationExists(
          locale.toString(),
          ignoreCacheDuration: true,
        );
        if (canLoadCacheIgnoringDuration) {
          string = await loadFromLocalFile(locale.toString());
          if (string.isNotEmpty) {
            if (kDebugMode) {
              print('localization loader: loaded from cache');
            }
            break;
          }
        }
        continue asset;
      asset:
      case LocalizationLoadType.asset:
        string = await rootBundle.loadString('$assetsPath/$locale.json');
        if (kDebugMode) {
          print('localization loader: loaded from assets');
        }
    }

    /// Checks loaded translations for missing words from the assets
    String assetTranslations =
        await rootBundle.loadString('$assetsPath/$locale.json');
    int loadedFileLength =
        (json.decode(string) as Map<String, dynamic>).keys.length;
    int assetFileLength =
        (json.decode(assetTranslations) as Map<String, dynamic>).keys.length;

    /// Don't load the localization if its content is shorter than the one in app assets
    if (assetFileLength > loadedFileLength) {
      return json.decode(assetTranslations);
    }

    return json.decode(string);
  }

  Future<bool> localeExists(String localePath) => Future.value(true);

  /// Loads localizations from server then save it locally in cache
  Future<String> loadFromNetwork(String localeName) async {
    String url = '${localeUrl(localeName)}$localeName.json';

    try {
      /// load localization file from server
      Dio dio = Dio();
      final Response response = await dio.get(
        url,
        options: Options(
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );

      /// validate response to be a json
      var content = jsonEncode(response.data);

      /// save json on local cached file
      await saveTranslation(localeName, content);
      return content;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return '';
  }

  /// Check if cached localization file already exists on device
  Future<bool> localTranslationExists(String localeName,
      {bool ignoreCacheDuration = false}) async {
    DateTime? localesDate = await checkFileDate(localeName);
    if (localesDate == null) {
      return false;
    }

    if (networkFileCreationDate != null) {
      if (localesDate.isAfter(networkFileCreationDate!)) {
        return true;
      }
      return false;
    }

    /// Ignore the cache duration and check for existing one
    if (!ignoreCacheDuration) {
      var difference = DateTime.now().difference(localesDate);

      /// Cached file is older than the set duration
      if (difference > (localCacheDuration)) {
        return false;
      }
    }

    return true;
  }

  /// Returns the cached locales file modification date
  Future<DateTime?> checkFileDate(String localeName) async {
    var translationFile = await getFileForLocale(localeName);
    if (!await translationFile.exists()) {
      return null;
    }
    return await translationFile.lastModified();
  }

  /// Load the cached localization file
  Future<String> loadFromLocalFile(String localeName) async {
    File cachedFile = await getFileForLocale(localeName);
    return await cachedFile.readAsString();
  }

  /// Return cached localization file
  Future<File> getFileForLocale(String localeName) async {
    return File(await getFileNameForLocale(localeName));
  }

  /// Save localization in a cache file
  Future<void> saveTranslation(String localeName, String content) async {
    var file = File(await getFileNameForLocale(localeName));
    await file.create(recursive: true);
    await file.writeAsString(content);
    if (kDebugMode) {
      print('saved');
    }
  }

  /// Returns the full path with file name of the cached localization file
  Future<String> getFileNameForLocale(String localeName) async {
    return '${await _localPath}/translations/$localeName.json';
  }

  /// Returns the local cache path
  Future<String> get _localPath async {
    final directory = await paths.getTemporaryDirectory();
    return directory.path;
  }
}
