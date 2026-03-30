class AppSettings {
  final String gamePath;
  final bool isDarkThemeEnabled;
  final bool isBetterSearchEnabled;

  const AppSettings({
    required this.gamePath,
    required this.isDarkThemeEnabled,
    required this.isBetterSearchEnabled,
  });

  AppSettings copyWith({
    String? gamePath,
    bool? isDarkThemeEnabled,
    bool? isBetterSearchEnabled,
  }) {
    return AppSettings(
      gamePath: gamePath ?? this.gamePath,
      isDarkThemeEnabled: isDarkThemeEnabled ?? this.isDarkThemeEnabled,
      isBetterSearchEnabled:
          isBetterSearchEnabled ?? this.isBetterSearchEnabled,
    );
  }
}
