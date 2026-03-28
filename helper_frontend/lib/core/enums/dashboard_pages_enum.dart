import 'package:flutter/material.dart';

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

  String get label {
    switch (this) {
      case DashboardEnum.home:
        return 'Home';
      case DashboardEnum.teams:
        return 'Teams';
      case DashboardEnum.monsters:
        return 'Monsters';
      case DashboardEnum.runes:
        return 'Runes';
      case DashboardEnum.settings:
        return 'Settings';
    }
  }

  String get description {
    switch (this) {
      case DashboardEnum.home:
        return 'Visao geral das contas conectadas';
      case DashboardEnum.teams:
        return 'Monte e organize composicoes';
      case DashboardEnum.monsters:
        return 'Gerencie criaturas e builds';
      case DashboardEnum.runes:
        return 'Acompanhe runas e combinacoes';
      case DashboardEnum.settings:
        return 'Ajustes e preferencias do helper';
    }
  }

  IconData get icon {
    switch (this) {
      case DashboardEnum.home:
        return Icons.home_rounded;
      case DashboardEnum.teams:
        return Icons.groups_rounded;
      case DashboardEnum.monsters:
        return Icons.pets_rounded;
      case DashboardEnum.runes:
        return Icons.auto_fix_high_rounded;
      case DashboardEnum.settings:
        return Icons.settings_rounded;
    }
  }
}
