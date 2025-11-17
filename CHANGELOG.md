## 2.0.3
- Update Flutter SDK requirement to >=3.4.0
- Update connectivity_plus package to ^7.0.0
- Update easy_localization package to ^3.0.8 and other dependencies to the latest versions
- Update the linter from pedantic to flutter_lints

## 2.0.2
- Update connectivity_plus package to ^6.0.3
- Update easy_localization package to ^3.0.7

## 2.0.1

- Extend delimiters for csv loader

## 2.0.0

- **BREAKING**: The local `AssetLoader` class deleted, now using the one from
  [easy_localization](https://pub.dev/documentation/easy_localization/latest/easy_localization/AssetLoader-class.html) itself.
- **BREAKING**: Depends on [connectivity_plus](https://pub.dev/packages/connectivity_plus) ^4.0.0
  and [http](https://pub.dev/packages/http) ^1.0.0.
- Const constructors in:
  - `FileAssetLoader`
  - `HttpAssetLoader`
  - `JsonAssetLoader`
  - `TestsAssetLoader`
  - `XmlAssetLoader`
  - `YamlAssetLoader`
- Fixed deprecations

## 0.0.1

- Initial release.
