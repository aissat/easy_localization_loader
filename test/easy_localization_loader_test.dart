import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () {});

  group('test CSVParser', () {
    test('CSVParser autodetect', () {
      const localeName = 'ru_RU';
      const testTabLFString =
          'str\ten_US\t$localeName\nscreen_language\tInterface language\tЯзык интерфейса\n';
      const testTabCRLFString =
          'str\ten_US\t$localeName\r\nscreen_language\tInterface language\tЯзык интерфейса\r\n';
      const testCommaCRLFString =
          'str,en_US,$localeName\r\nscreen_language,Interface language,Язык интерфейса\r\n';

      Map<String, dynamic> getResult(
        String testString,
        String localeName, [
        bool useAutodetect = true,
      ]) =>
          CSVParser(testString, useAutodetect: useAutodetect)
              .getLanguageMap(localeName);
      void output(
        String name,
        Map<String, dynamic> expectedResult,
        Map<String, dynamic> result,
      ) {
        print('$name expectedResult: $expectedResult\nresult: $result');
        expect(result, expectedResult);
      }

      output(
        'testTabLFString'.toUpperCase(),
        {'screen_language': 'Язык интерфейса'},
        getResult(testTabLFString, localeName),
      );
      output(
        'testTabCRLFString'.toUpperCase(),
        {'screen_language': 'Язык интерфейса'},
        getResult(testTabCRLFString, localeName),
      );
      output(
        'testCommaCRLFString'.toUpperCase(),
        {'screen_language': 'Язык интерфейса'},
        getResult(testCommaCRLFString, localeName),
      );
      output(
        'testTabLFString, autodetect = false'.toUpperCase(),
        {},
        getResult(testTabLFString, localeName, false),
      );
    });
  });
}
