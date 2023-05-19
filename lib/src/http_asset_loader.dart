import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;

class HttpAssetLoader extends AssetLoader {
  const HttpAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    log('easy localization loader: load http $path');
    try {
      var url = Uri.parse('$path/${locale.toLanguageTag()}.json');
      return http
          .get(url)
          .then((response) => json.decode(utf8.decode(response.bodyBytes)));
    } catch (e) {
      //Catch network exceptions
      return {};
    }
  }
}
