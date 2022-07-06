//
//
//
//
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:http/http.dart' as http;

import 'asset_loader.dart';

class HttpAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    log('easy localization loader: load http $path');
    try {
      var url = Uri.parse(path);
      return http.get(url).then(
            (response) => jsonDecode(utf8.decode(response.bodyBytes)),
          );
    } catch (e) {
      //Catch network exceptions
      return Future.value();
    }
  }
}
