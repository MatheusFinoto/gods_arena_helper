import '../constants/assets_constants.dart';

enum FactionEnum { unknown, athens, sparta }

extension FactionEnumExtension on FactionEnum {
  String get name {
    switch (this) {
      case FactionEnum.athens:
        return 'athens';
      case FactionEnum.sparta:
        return 'sparta';
      case FactionEnum.unknown:
        return 'unknown';
    }
  }

  static FactionEnum fromString(String value) {
    switch (value.toLowerCase()) {
      case 'athens':
        return FactionEnum.athens;
      case 'sparta':
        return FactionEnum.sparta;
      default:
        return FactionEnum.unknown;
    }
  }

  String get assetPath {
    switch (this) {
      case FactionEnum.athens:
        return AssetsConstants.athens;
      case FactionEnum.sparta:
        return AssetsConstants.sparta;
      case FactionEnum.unknown:
        return AssetsConstants.athens;
    }
  }
}
