import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helper_frontend/core/constants/theme_colors_constants.dart';
import 'package:helper_frontend/presentation/dashboard/states/settings_state.dart';
import 'package:provider/provider.dart';

import '../../../domain/usecases/settings_usecase.dart';
import '../../../main_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsState(
        settingsUsecase: context.read<SettingsUsecase>(),
        mainState: context.read<MainState>(),
      ),
      child: Consumer<SettingsState>(
        builder: (_, state, __) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final pageBackground = isDark
              ? ThemeColorsConstants.backgroundDark
              : ThemeColorsConstants.backgroundLight;
          final panelBackground = isDark
              ? ThemeColorsConstants.panelContainerDark.withOpacity(0.94)
              : Colors.white.withOpacity(0.92);
          final panelBorder = isDark
              ? ThemeColorsConstants.borderDark
              : ThemeColorsConstants.borderLight;
          final subduedTextColor = isDark
              ? ThemeColorsConstants.mutedTextDark
              : ThemeColorsConstants.mutedTextLight;

          return Scaffold(
            backgroundColor: pageBackground,
            body: Stack(
              children: [
                Positioned(
                  top: -110,
                  right: -20,
                  child: _BlurredAccent(
                    color: ThemeColorsConstants.primary,
                    size: 280,
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -80,
                  child: _BlurredAccent(
                    color: isDark
                        ? ThemeColorsConstants.heroMiddle
                        : ThemeColorsConstants.primarySoft,
                    size: 320,
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SettingsHero(
                              hasConfiguredGamePath:
                                  state.hasConfiguredGamePath,
                              isDarkThemeEnabled: state.isDarkThemeEnabled,
                              isBetterSearchEnabled:
                                  state.isBetterSearchEnabled,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: panelBackground,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: panelBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? const Color(0x55000000)
                                        : const Color(0x120F172A),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Configuracoes do helper',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Centralize preferencias locais e deixe o '
                                    'projeto preparado para as proximas '
                                    'automacoes.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: subduedTextColor,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _SectionCard(
                                    title: 'Path do jogo',
                                    subtitle:
                                        'Informe onde o Gods Arena esta instalado. '
                                        'Esse caminho sera usado nas futuras '
                                        'alteracoes de arquivos do jogo.',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          controller: state.gamePathController,
                                          enabled: !state.isLoading,
                                          onSubmitted: (_) =>
                                              state.saveGamePath(),
                                          decoration: InputDecoration(
                                            labelText: 'Pasta do jogo',
                                            hintText: r'C:\Games\GodsArena',
                                            prefixIcon: const Icon(
                                              Icons.folder_open_rounded,
                                            ),
                                            suffixIconConstraints:
                                                const BoxConstraints(
                                                  minWidth: 150,
                                                  minHeight: 56,
                                                ),
                                            suffixIcon: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: FilledButton(
                                                onPressed:
                                                    state.isLoading ||
                                                        state
                                                            .isSavingGamePath ||
                                                        !state
                                                            .hasUnsavedGamePath
                                                    ? null
                                                    : state.saveGamePath,
                                                child: Text(
                                                  state.isSavingGamePath
                                                      ? 'Salvando...'
                                                      : 'Salvar path',
                                                ),
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            _StatusBadge(
                                              label: state.hasConfiguredGamePath
                                                  ? 'Path configurado'
                                                  : 'Path pendente',
                                              color: state.hasConfiguredGamePath
                                                  ? ThemeColorsConstants.success
                                                  : ThemeColorsConstants
                                                        .primary,
                                            ),
                                            if (state.hasUnsavedGamePath)
                                              const _StatusBadge(
                                                label: 'Alteracoes nao salvas',
                                                color: ThemeColorsConstants
                                                    .warning,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _SectionCard(
                                    title: 'Tema',
                                    subtitle:
                                        'Ative o tema escuro para alterar a '
                                        'aparencia principal da aplicacao.',
                                    child: _SettingToggleTile(
                                      icon: state.isDarkThemeEnabled
                                          ? Icons.dark_mode_rounded
                                          : Icons.light_mode_rounded,
                                      title: 'Modo escuro',
                                      description: state.isDarkThemeEnabled
                                          ? 'Tema escuro ativo e salvo localmente.'
                                          : 'Tema claro ativo e salvo localmente.',
                                      value: state.isDarkThemeEnabled,
                                      onChanged: state.toggleDarkTheme,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _SectionCard(
                                    title: 'BetterSearch',
                                    subtitle:
                                        'Controle a preferencia da funcionalidade '
                                        'que futuramente alterara arquivos do jogo.',
                                    child: _SettingToggleTile(
                                      icon: Icons.travel_explore_rounded,
                                      title: 'Ativar BetterSearch',
                                      description:
                                          'Nenhuma alteracao real no jogo sera '
                                          'feita agora. Esta chave apenas salva a '
                                          'preferencia do usuario.',
                                      value: state.isBetterSearchEnabled,
                                      onChanged: state.toggleBetterSearch,
                                    ),
                                  ),
                                  if (state.feedbackMessage != null) ...[
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? ThemeColorsConstants
                                                  .infoSurfaceDark
                                            : ThemeColorsConstants
                                                  .infoSurfaceLight,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isDark
                                              ? ThemeColorsConstants
                                                    .infoBorderDark
                                              : ThemeColorsConstants
                                                    .infoBorderLight,
                                        ),
                                      ),
                                      child: Text(
                                        state.feedbackMessage!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: isDark
                                                  ? ThemeColorsConstants
                                                        .infoTextDark
                                                  : ThemeColorsConstants
                                                        .infoTextLight,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.hasConfiguredGamePath,
    required this.isDarkThemeEnabled,
    required this.isBetterSearchEnabled,
  });

  final bool hasConfiguredGamePath;
  final bool isDarkThemeEnabled;
  final bool isBetterSearchEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            ThemeColorsConstants.heroStart,
            ThemeColorsConstants.heroMiddle,
            ThemeColorsConstants.heroEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26163D78),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 800;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.16)),
                ),
                child: const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Configure o helper sem sair do painel.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Defina o path do jogo, mantenha a preferencia de tema e '
                'prepare o terreno para futuras alteracoes locais com '
                'seguranca.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          );

          final summary = ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo rapido',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SummaryLine(
                      label: 'Path do jogo',
                      value: hasConfiguredGamePath ? 'Configurado' : 'Pendente',
                    ),
                    const SizedBox(height: 8),
                    _SummaryLine(
                      label: 'Tema',
                      value: isDarkThemeEnabled ? 'Escuro' : 'Claro',
                    ),
                    const SizedBox(height: 8),
                    _SummaryLine(
                      label: 'BetterSearch',
                      value: isBetterSearchEnabled ? 'Ativo' : 'Inativo',
                    ),
                  ],
                ),
              ),
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 24), summary],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: content),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: summary),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? ThemeColorsConstants.panelCardDark
            : ThemeColorsConstants.panelCardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? ThemeColorsConstants.cardBorderDark
              : ThemeColorsConstants.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? ThemeColorsConstants.mutedTextDark
                  : ThemeColorsConstants.mutedTextLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SettingToggleTile extends StatelessWidget {
  const _SettingToggleTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? ThemeColorsConstants.panelInnerDark
            : ThemeColorsConstants.panelInnerLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ThemeColorsConstants.innerBorderDark
              : ThemeColorsConstants.innerBorderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThemeColorsConstants.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: ThemeColorsConstants.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? ThemeColorsConstants.mutedTextDark
                        : ThemeColorsConstants.mutedTextLight,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BlurredAccent extends StatelessWidget {
  const _BlurredAccent({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.30), color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}
