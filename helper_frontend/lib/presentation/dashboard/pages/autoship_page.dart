import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helper_frontend/core/constants/dashboard_layout_constants.dart';
import 'package:helper_frontend/core/constants/theme_colors_constants.dart';
import 'package:helper_frontend/domain/entities/account.dart';
import 'package:helper_frontend/domain/entities/autoship_status.dart';
import 'package:helper_frontend/domain/usecases/autoship_usecase.dart';
import 'package:helper_frontend/main_state.dart';
import 'package:helper_frontend/presentation/dashboard/states/autoship_state.dart';
import 'package:provider/provider.dart';

class AutoShipPage extends StatelessWidget {
  const AutoShipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AutoShipState(autoShipUsecase: context.read<AutoShipUsecase>()),
      child: Consumer2<MainState, AutoShipState>(
        builder: (context, mainState, state, __) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: isDark
                ? ThemeColorsConstants.backgroundDark
                : ThemeColorsConstants.backgroundLight,
            body: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -60,
                  child: _BlurredAccent(
                    color: const Color(0xFF3EA7FF),
                    size: 320,
                  ),
                ),
                Positioned(
                  bottom: -140,
                  left: -90,
                  child: _BlurredAccent(
                    color: isDark
                        ? ThemeColorsConstants.heroMiddle
                        : ThemeColorsConstants.primarySoft,
                    size: 340,
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: DashboardLayoutConstants.pagePadding,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: DashboardLayoutConstants.contentMaxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AutoShipHero(
                              selectedCount: state.selectedCount,
                              readyCount: state.readyCount,
                              runState: state.runState,
                              currentStage: state.currentStage,
                              currentCycle: state.currentCycle,
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isCompact = constraints.maxWidth < 980;

                                if (isCompact) {
                                  return Column(
                                    children: [
                                      _SelectionPanel(
                                        mainState: mainState,
                                        state: state,
                                      ),
                                      const SizedBox(height: 18),
                                      _ExecutionPanel(
                                        state: state,
                                        mainState: mainState,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _SelectionPanel(
                                        mainState: mainState,
                                        state: state,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      flex: 2,
                                      child: _ExecutionPanel(
                                        state: state,
                                        mainState: mainState,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            _StatusPanel(
                              selectedAccounts: mainState.accounts
                                  .where(
                                    (account) =>
                                        state.isSelected(account.processId),
                                  )
                                  .toList(),
                              state: state,
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

class _AutoShipHero extends StatelessWidget {
  const _AutoShipHero({
    required this.selectedCount,
    required this.readyCount,
    required this.runState,
    required this.currentStage,
    required this.currentCycle,
  });

  final int selectedCount;
  final int readyCount;
  final AutoShipRunState runState;
  final AutoShipStage currentStage;
  final int currentCycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF091A34), Color(0xFF11427E), Color(0xFF1F88FF)],
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
          final isCompact = constraints.maxWidth < 780;

          final contentSection = Column(
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
                  'AutoShip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Execute o primeiro passo do ship com um clique.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nesta etapa o AutoShip esta no modo simples: selecione uma '
                'conta, clique em iniciar e o Python faz foco, search e Guild Quest.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.80),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          );

          final summarySection = ClipRRect(
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
                      'Lote atual',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SummaryLine(
                      label: 'Selecionadas',
                      value: '$selectedCount contas',
                    ),
                    const SizedBox(height: 8),
                    _SummaryLine(
                      label: 'Prontas',
                      value: '$readyCount selecionadas',
                    ),
                    const SizedBox(height: 8),
                    _SummaryLine(label: 'Status', value: runState.label),
                    const SizedBox(height: 8),
                    _SummaryLine(label: 'Etapa', value: currentStage.label),
                    const SizedBox(height: 8),
                    _SummaryLine(
                      label: 'Ciclo',
                      value: currentCycle == 0 ? '-' : '$currentCycle/3',
                    ),
                  ],
                ),
              ),
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                contentSection,
                const SizedBox(height: 24),
                summarySection,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: contentSection),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: summarySection),
            ],
          );
        },
      ),
    );
  }
}

class _SelectionPanel extends StatelessWidget {
  const _SelectionPanel({required this.mainState, required this.state});

  final MainState mainState;
  final AutoShipState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Selecao de contas',
            subtitle:
                'Escolha a conta que vai executar o AutoShip simples. Nesta fase, a execucao acontece em apenas um PID por vez.',
            trailing: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: mainState.isLoadingAccounts
                      ? null
                      : () => mainState.loadAccounts(forceRefresh: true),
                  icon: mainState.isLoadingAccounts
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    mainState.isLoadingAccounts ? 'Buscando...' : 'Atualizar',
                  ),
                ),
                OutlinedButton(
                  onPressed: state.isRunning || state.isStopping
                      ? null
                      : () => state.selectAll(
                          mainState.accounts
                              .map((account) => account.processId)
                              .toList(),
                        ),
                  child: const Text('Selecionar todas'),
                ),
                OutlinedButton(
                  onPressed: state.isRunning || state.isStopping
                      ? null
                      : state.clearSelection,
                  child: const Text('Limpar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (mainState.accounts.isEmpty)
            _EmptySelectionState(isLoading: mainState.isLoadingAccounts)
          else
            Column(
              children: [
                for (final account in mainState.accounts) ...[
                  _AccountSelectionCard(
                    account: account,
                    isSelected: state.isSelected(account.processId),
                    isReadOnly: state.isRunning || state.isStopping,
                    onSelectionChanged: (value) =>
                        state.toggleSelection(account.processId, value),
                  ),
                  if (account != mainState.accounts.last)
                    const SizedBox(height: 14),
                ],
              ],
            ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? ThemeColorsConstants.infoSurfaceDark
                  : ThemeColorsConstants.infoSurfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? ThemeColorsConstants.infoBorderDark
                    : ThemeColorsConstants.infoBorderLight,
              ),
            ),
            child: Text(
              'Fluxo atual: focar a janela do processo, clicar no label de search e clicar no label Guild Quest.',
              style: TextStyle(
                color: isDark
                    ? ThemeColorsConstants.infoTextDark
                    : ThemeColorsConstants.infoTextLight,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
            child: Text(
              'Quando essa base estiver estavel, evoluimos o backend para os proximos passos do ship sem mudar o botao principal.',
              style: TextStyle(
                color: isDark
                    ? ThemeColorsConstants.mutedTextDark
                    : ThemeColorsConstants.mutedTextLight,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutionPanel extends StatelessWidget {
  const _ExecutionPanel({required this.state, required this.mainState});

  final AutoShipState state;
  final MainState mainState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            title: 'Execucao do lote',
            subtitle:
                'Dispare o AutoShip simples e aguarde o retorno final do Python.',
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricChip(
                label: 'Selecionadas',
                value: '${state.selectedCount}',
                color: ThemeColorsConstants.primary,
              ),
              _MetricChip(
                label: 'Prontas',
                value: '${state.readyCount}',
                color: ThemeColorsConstants.success,
              ),
              _MetricChip(
                label: 'Falhas',
                value: '${state.failedCount}',
                color: const Color(0xFFD64545),
              ),
              _MetricChip(
                label: 'Concluidas',
                value: '${state.completedCount}',
                color: const Color(0xFF117864),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? ThemeColorsConstants.panelInnerDark
                  : ThemeColorsConstants.panelInnerLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? ThemeColorsConstants.innerBorderDark
                    : ThemeColorsConstants.innerBorderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status da feature',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estado atual: ${state.runState.label}',
                  style: TextStyle(
                    color: isDark
                        ? ThemeColorsConstants.mutedTextDark
                        : ThemeColorsConstants.mutedTextLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.currentCycle == 0
                      ? 'Nenhum ciclo em andamento.'
                      : 'Ciclo atual: ${state.currentCycle}/3 em ${state.currentStage.label}.',
                  style: TextStyle(
                    color: isDark
                        ? ThemeColorsConstants.mutedTextDark
                        : ThemeColorsConstants.mutedTextLight,
                    height: 1.4,
                  ),
                ),
                if (state.feedbackMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ThemeColorsConstants.infoSurfaceDark
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? ThemeColorsConstants.infoBorderDark
                            : ThemeColorsConstants.infoBorderLight,
                      ),
                    ),
                    child: Text(
                      state.feedbackMessage!,
                      style: TextStyle(
                        color: isDark
                            ? ThemeColorsConstants.infoTextDark
                            : ThemeColorsConstants.infoTextLight,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isRunning ? null : state.startAutoShip,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                state.isRunning ? 'Iniciando...' : 'Iniciar AutoShip',
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: state.isRunning || state.isStopping
                  ? null
                  : state.resetExecution,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Limpar status da execucao'),
            ),
          ),
          const SizedBox(height: 18),
          _ChecklistLine(
            label: 'Ha exatamente um PID selecionado',
            isChecked: state.selectedCount == 1,
          ),
          const SizedBox(height: 10),
          _ChecklistLine(
            label: 'O Python retorna apenas sucesso ou falha no final',
            isChecked: true,
          ),
          const SizedBox(height: 10),
          _ChecklistLine(
            label: 'Lista de contas do jogo carregada',
            isChecked: mainState.accounts.isNotEmpty,
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.selectedAccounts, required this.state});

  final List<Account> selectedAccounts;
  final AutoShipState state;

  @override
  Widget build(BuildContext context) {
    Account? findAccount(int processId) {
      for (final account in selectedAccounts) {
        if (account.processId == processId) return account;
      }
      return null;
    }

    return _PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            title: 'Acompanhamento por conta',
            subtitle:
                'Cada PID mostra a etapa mais recente, o ciclo atual e o resultado da execucao.',
          ),
          const SizedBox(height: 22),
          if (state.accountStatuses.isEmpty)
            const _EmptyStatusState()
          else
            Column(
              children: [
                for (final status in state.accountStatuses) ...[
                  _AccountStatusCard(
                    status: status,
                    account: findAccount(status.processId),
                  ),
                  if (status != state.accountStatuses.last)
                    const SizedBox(height: 14),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _AccountSelectionCard extends StatelessWidget {
  const _AccountSelectionCard({
    required this.account,
    required this.isSelected,
    required this.isReadOnly,
    required this.onSelectionChanged,
  });

  final Account account;
  final bool isSelected;
  final bool isReadOnly;
  final ValueChanged<bool> onSelectionChanged;

  Color get _accentColor {
    switch (account.faction.name) {
      case 'athens':
        return const Color(0xFF2F6BFF);
      case 'sparta':
        return const Color(0xFF14917F);
      default:
        return const Color(0xFF64748B);
    }
  }

  String get _factionLabel {
    switch (account.faction.name) {
      case 'athens':
        return 'Athens';
      case 'sparta':
        return 'Sparta';
      default:
        return 'Desconhecida';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isSelected
            ? _accentColor.withOpacity(isDark ? 0.14 : 0.08)
            : (isDark
                  ? ThemeColorsConstants.panelCardDark
                  : ThemeColorsConstants.panelCardLight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? _accentColor.withOpacity(0.48)
              : (isDark
                    ? ThemeColorsConstants.cardBorderDark
                    : ThemeColorsConstants.cardBorderLight),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final infoSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: isReadOnly
                        ? null
                        : (value) => onSelectionChanged(value ?? false),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.nick,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _BadgePill(
                              label: 'PID ${account.processId}',
                              foregroundColor: isDark
                                  ? ThemeColorsConstants.infoTextDark
                                  : const Color(0xFF334155),
                              backgroundColor: isDark
                                  ? ThemeColorsConstants.infoSurfaceDark
                                  : const Color(0xFFF1F5F9),
                            ),
                            _BadgePill(
                              label: _factionLabel,
                              foregroundColor: _accentColor,
                              backgroundColor: _accentColor.withOpacity(0.12),
                            ),
                            _BadgePill(
                              label: 'Item final via bolsa',
                              foregroundColor: const Color(0xFF7C4D12),
                              backgroundColor: const Color(0xFFFFF1D6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );

          return infoSection;
        },
      ),
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({required this.status, required this.account});

  final AutoShipAccountStatus status;
  final Account? account;

  Color get _statusColor {
    switch (status.state) {
      case AutoShipAccountState.pending:
        return ThemeColorsConstants.primary;
      case AutoShipAccountState.running:
        return const Color(0xFF1D4ED8);
      case AutoShipAccountState.completed:
        return ThemeColorsConstants.success;
      case AutoShipAccountState.failed:
        return const Color(0xFFD64545);
      case AutoShipAccountState.stopped:
        return ThemeColorsConstants.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                account?.nick ?? 'PID ${status.processId}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              _BadgePill(
                label: 'PID ${status.processId}',
                foregroundColor: isDark
                    ? ThemeColorsConstants.infoTextDark
                    : const Color(0xFF334155),
                backgroundColor: isDark
                    ? ThemeColorsConstants.infoSurfaceDark
                    : const Color(0xFFF1F5F9),
              ),
              _BadgePill(
                label: status.state.label,
                foregroundColor: _statusColor,
                backgroundColor: _statusColor.withOpacity(0.12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoLine(
                icon: Icons.route_rounded,
                label: 'Etapa',
                value: status.stage.label,
              ),
              _InfoLine(
                icon: Icons.repeat_rounded,
                label: 'Ciclo',
                value: status.cycle == 0 ? '-' : '${status.cycle}/3',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            status.message,
            style: TextStyle(
              color: isDark
                  ? ThemeColorsConstants.mutedTextDark
                  : ThemeColorsConstants.mutedTextLight,
              height: 1.45,
            ),
          ),
          if (status.error != null) ...[
            const SizedBox(height: 10),
            Text(
              status.error!,
              style: const TextStyle(
                color: Color(0xFFD64545),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PanelShell extends StatelessWidget {
  const _PanelShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? ThemeColorsConstants.panelContainerDark.withOpacity(0.94)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? ThemeColorsConstants.borderDark
              : ThemeColorsConstants.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x55000000) : const Color(0x120F172A),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760 || trailing == null;

        final description = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
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
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              description,
              if (trailing != null) ...[const SizedBox(height: 16), trailing!],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: description),
            const SizedBox(width: 16),
            trailing!,
          ],
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ChecklistLine extends StatelessWidget {
  const _ChecklistLine({required this.label, required this.isChecked});

  final String label;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    final color = isChecked
        ? ThemeColorsConstants.success
        : ThemeColorsConstants.warning;

    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? ThemeColorsConstants.infoSurfaceDark
            : ThemeColorsConstants.infoSurfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? ThemeColorsConstants.infoTextDark
                : ThemeColorsConstants.infoTextLight,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              color: isDark
                  ? ThemeColorsConstants.infoTextDark
                  : ThemeColorsConstants.infoTextLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySelectionState extends StatelessWidget {
  const _EmptySelectionState({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: isDark
            ? ThemeColorsConstants.panelInnerDark
            : ThemeColorsConstants.panelInnerLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? ThemeColorsConstants.innerBorderDark
              : ThemeColorsConstants.innerBorderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isLoading ? Icons.hourglass_top_rounded : Icons.groups_rounded,
            size: 34,
            color: ThemeColorsConstants.primary,
          ),
          const SizedBox(height: 14),
          Text(
            isLoading
                ? 'Buscando contas no jogo...'
                : 'Nenhuma conta disponivel para o AutoShip.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyStatusState extends StatelessWidget {
  const _EmptyStatusState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: isDark
            ? ThemeColorsConstants.panelInnerDark
            : ThemeColorsConstants.panelInnerLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? ThemeColorsConstants.innerBorderDark
              : ThemeColorsConstants.innerBorderLight,
        ),
      ),
      child: Text(
        'Os cards de acompanhamento vao aparecer assim que voce selecionar contas ou iniciar um lote.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.5,
          color: isDark
              ? ThemeColorsConstants.mutedTextDark
              : ThemeColorsConstants.mutedTextLight,
        ),
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
