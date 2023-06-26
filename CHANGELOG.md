## 2.0.0

- **BREAKING**: The local `AssetLoader` class deleted, now using the one from
  [easy_localization](https://pub.dev/documentation/easy_localization/latest/easy_localization/AssetLoader-class.html) itself.
- **BREAKING**: `JsonAssetLoader`, `XmlAssetLoader`, and `YamlAssetLoader` now use `_` instead of `-` when converting a locale to a file name.
- **BREAKING**: Depends on [connectivity_plus](https://pub.dev/packages/connectivity_plus) ^4.0.0
  and [http](https://pub.dev/packages/http) ^1.0.0.
- Const constructors in:
  - `FileAssetLoader`
  - `HttpAssetLoader`
  - `JsonAssetLoader`
  - `TestsAssetLoader`
  - `XmlAssetLoader`
  - `YamlAssetLoader`

## 0.0.1

- Initial release.
