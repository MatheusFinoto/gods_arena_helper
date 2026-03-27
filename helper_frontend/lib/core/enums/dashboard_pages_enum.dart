enum DashboardEnum { home, teams, monsters, runes, settings }

extension DashboardEnumExtension on DashboardEnum {
  String get name {
    switch (this) {
      case DashboardEnum.home:
        return 'home';
      case DashboardEnum.teams:
        return 'teams';
      case DashboardEnum.monsters:
        return 'monsters';
      case DashboardEnum.runes:
        return 'runes';
      case DashboardEnum.settings:
        return 'settings';
    }
  }
}
