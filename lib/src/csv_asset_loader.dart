import 'dart:developer';
import 'dart:ui';

import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

//
// load example/resources/langs/langs.csv
//
class CsvAssetLoader extends AssetLoader {
  CSVParser? csvParser;
  final bool useAutodetect;

  CsvAssetLoader({
    this.useAutodetect = true,
  });

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (csvParser == null) {
      log('easy localization loader: load csv file $path');
      csvParser = CSVParser(
        await rootBundle.loadString(path),
        useAutodetect: useAutodetect,
      );
    } else {
      log('easy localization loader: CSV parser already loaded, read cache');
    }
    return csvParser!.getLanguageMap(locale.toString());
  }
}

/// Parses [csvString] into [lines]
///
/// (Copied from [CsvToListConverter])
///
/// The default values for [fieldDelimiter], [eol] are consistent with
/// [rfc4180](http://tools.ietf.org/html/rfc4180).
///
/// Note that by default invalid values are allowed and no exceptions are
/// thrown.
class CSVParser {
  final String csvString;
  final List<List<dynamic>> lines;
  final String? fieldDelimiter;
  final String? eol;

  /// Enables automatic detection of the following
  ///
  /// [eols]: '\r\n' '\n'
  ///
  /// [fieldDelimiters]: ',' '\t'
  ///
  /// corresponding arguments must be [null]
  final bool useAutodetect;

  CSVParser(
    this.csvString, {
    this.fieldDelimiter,
    this.eol,
    this.useAutodetect = true,
  }) : lines = _convertN(
          CsvToListConverter().convert(
            csvString,
            fieldDelimiter: fieldDelimiter,
            eol: eol,
            csvSettingsDetector:
                useAutodetect && fieldDelimiter == null && eol == null
                    ? FirstOccurrenceSettingsDetector(
                        fieldDelimiters: [',', ';', '\t'],
                        textDelimiters: ['"', "'", '”'],
                        textEndDelimiters: ['"', "'", '”'],
                        eols: ['\r\n', '\n'],
                      )
                    : null,
          ),
        );

  static List<List<dynamic>> _convertN(List<List<dynamic>> lines) {
    // converts //n to /n
    lines.forEach((lineList) {
      lineList.asMap().forEach((key, value) {
        if ((value is String) && value.contains('\\n')) {
          lineList[key] = value.replaceAll('\\n', '\n');
        }
      });
    });
    return lines;
  }

  List getLanguages() {
    return lines.first.sublist(1, lines.first.length);
  }

  Map<String, dynamic> getLanguageMap(String localeName) {
    final indexLocale = lines.first.indexOf(localeName);

    var translations = <String, dynamic>{};
    for (var i = 1; i < lines.length; i++) {
      translations.addAll({lines[i][0]: lines[i][indexLocale]});
    }
    return translations;
  }
}
