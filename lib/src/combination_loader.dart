import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class CombinationLoader extends AssetLoader {
  const CombinationLoader({required this.loaders});

  final List<AssetLoader> loaders;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final resultFutures = loaders.map((loader) async {
      try {
        return loader.load(path, locale);
      } catch (error) {
        debugPrint(error.toString());
        return {};
      }
    });

    try {
      final results = await Future.wait(resultFutures);
      return results.fold<Map<String, dynamic>>(
        {},
        (prev, e) => {...prev, ...(e ?? {})},
      );
    } catch (error) {
      debugPrint(error.toString());
      return {};
    }
  }
}
