import 'package:flutter/material.dart';
import 'package:helper_frontend/core/constants/dashboard_layout_constants.dart';
import 'package:helper_frontend/core/constants/theme_colors_constants.dart';
import 'package:helper_frontend/domain/entities/account.dart';
import 'package:helper_frontend/domain/entities/autorace_status.dart';
import 'package:helper_frontend/domain/usecases/autorace_usecase.dart';
import 'package:helper_frontend/main_state.dart';
import 'package:helper_frontend/presentation/dashboard/states/autorace_state.dart';
import 'package:provider/provider.dart';

class AutoRacePage extends StatelessWidget {
  const AutoRacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AutoRaceState(autoRaceUsecase: context.read<AutoRaceUsecase>()),
      child: Consumer2<MainState, AutoRaceState>(
        builder: (context, mainState, state, __) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: isDark
                ? ThemeColorsConstants.backgroundDark
                : ThemeColorsConstants.backgroundLight,
            body: SafeArea(
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
                        _AutoRaceHero(state: state),
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
                                  _RunPanel(
                                    mainState: mainState,
                                    state: state,
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
                                  child: _RunPanel(
                                    mainState: mainState,
                                    state: state,
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
          );
        },
      ),
    );
  }
}

class _AutoRaceHero extends StatelessWidget {
  const _AutoRaceHero({required this.state});

  final AutoRaceState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF092A32), Color(0xFF145D6D), Color(0xFF20A4B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26145D6D),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 780;
          final summary = _HeroSummary(state: state);

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroPill(label: 'AutoRace'),
              const SizedBox(height: 18),
              const Text(
                'Race diaria com retomada por manual.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selecione as contas, ajuste o manual atual de cada uma e acompanhe os eventos que o Python envia durante a execucao.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 24), summary],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: summary),
            ],
          );
        },
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({required this.state});

  final AutoRaceState state;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _SummaryLine(label: 'Selecionadas', value: '${state.selectedCount}'),
          const SizedBox(height: 8),
          _SummaryLine(label: 'Status', value: state.runState.label),
          const SizedBox(height: 8),
          _SummaryLine(label: 'Etapa', value: state.currentStage.label),
          const SizedBox(height: 8),
          _SummaryLine(
            label: 'Manual',
            value: state.currentManual == 0 ? '-' : '${state.currentManual}',
          ),
        ],
      ),
    );
  }
}

class _SelectionPanel extends StatelessWidget {
  const _SelectionPanel({required this.mainState, required this.state});

  final MainState mainState;
  final AutoRaceState state;

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: 'Contas e manual inicial',
            subtitle:
                'Escolha as contas e ajuste o manual que cada uma tem antes de iniciar. Use sem manual para comecar do zero.',
            trailing: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: mainState.isLoadingAccounts || state.isRunning
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
                    initialManual: state.initialManualFor(account.processId),
                    onSelectionChanged: (value) =>
                        state.toggleSelection(account.processId, value),
                    onManualChanged: (manual) =>
                        state.setInitialManual(account.processId, manual),
                  ),
                  if (account != mainState.accounts.last)
                    const SizedBox(height: 14),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _RunPanel extends StatelessWidget {
  const _RunPanel({required this.mainState, required this.state});

  final MainState mainState;
  final AutoRaceState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            title: 'Execucao',
            subtitle:
                'O frontend mantem uma sessao Python aberta e atualiza a tela com eventos recebidos em tempo real.',
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
                label: 'Concluidas',
                value: '${state.completedCount}',
                color: ThemeColorsConstants.success,
              ),
              _MetricChip(
                label: 'Falhas',
                value: '${state.failedCount}',
                color: const Color(0xFFD64545),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? ThemeColorsConstants.panelInnerDark
                  : ThemeColorsConstants.panelInnerLight,
              borderRadius: BorderRadius.circular(22),
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
                  'Status: ${state.runState.label}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.feedbackMessage ??
                      'Aguardando selecao de contas para iniciar.',
                  style: TextStyle(
                    color: isDark
                        ? ThemeColorsConstants.mutedTextDark
                        : ThemeColorsConstants.mutedTextLight,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isRunning || !state.hasSelection
                  ? null
                  : state.startAutoRace,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(state.isRunning ? 'Executando...' : 'Iniciar AutoRace'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.isRunning ? state.stopAutoRace : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Parar execucao'),
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
              label: const Text('Limpar status'),
            ),
          ),
          const SizedBox(height: 18),
          _ChecklistLine(
            label: 'Backend envia eventos periodicos por stdout',
            isChecked: true,
          ),
          const SizedBox(height: 10),
          _ChecklistLine(
            label: 'Execucao em lote sequencial',
            isChecked: true,
          ),
          const SizedBox(height: 10),
          _ChecklistLine(
            label: 'Contas carregadas',
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
  final AutoRaceState state;

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
                'Veja o manual escolhido, o manual atual reportado pelo backend e a etapa mais recente.',
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
    required this.initialManual,
    required this.onSelectionChanged,
    required this.onManualChanged,
  });

  final Account account;
  final bool isSelected;
  final bool isReadOnly;
  final int initialManual;
  final ValueChanged<bool> onSelectionChanged;
  final ValueChanged<int> onManualChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = account.faction.name == 'sparta'
        ? ThemeColorsConstants.success
        : ThemeColorsConstants.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isSelected
            ? accent.withOpacity(isDark ? 0.14 : 0.08)
            : (isDark
                  ? ThemeColorsConstants.panelCardDark
                  : ThemeColorsConstants.panelCardLight),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected
              ? accent.withOpacity(0.48)
              : (isDark
                    ? ThemeColorsConstants.cardBorderDark
                    : ThemeColorsConstants.cardBorderLight),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;

          final accountInfo = Row(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _BadgePill(
                          label: 'PID ${account.processId}',
                          color: ThemeColorsConstants.primary,
                        ),
                        _BadgePill(
                          label: account.faction.name,
                          color: accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final manualSelector = DropdownButtonFormField<int>(
            value: initialManual,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Manual inicial',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(
                value: 0,
                child: Text('Sem manual / Comecar do zero'),
              ),
              for (var manual = 1; manual <= 17; manual++)
                DropdownMenuItem(
                  value: manual,
                  child: Text('Manual $manual'),
                ),
            ],
            onChanged: isReadOnly || !isSelected
                ? null
                : (value) => onManualChanged(value ?? 0),
          );

          if (isCompact) {
            return Column(
              children: [
                accountInfo,
                const SizedBox(height: 14),
                manualSelector,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: accountInfo),
              const SizedBox(width: 16),
              SizedBox(width: 260, child: manualSelector),
            ],
          );
        },
      ),
    );
  }
}

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({required this.status, required this.account});

  final AutoRaceAccountStatus status;
  final Account? account;

  Color get _statusColor {
    switch (status.state) {
      case AutoRaceAccountState.completed:
        return ThemeColorsConstants.success;
      case AutoRaceAccountState.failed:
        return const Color(0xFFD64545);
      case AutoRaceAccountState.stopped:
        return ThemeColorsConstants.warning;
      case AutoRaceAccountState.running:
        return ThemeColorsConstants.primary;
      case AutoRaceAccountState.pending:
        return const Color(0xFF64748B);
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
        borderRadius: BorderRadius.circular(22),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              _BadgePill(label: status.state.label, color: _statusColor),
              _BadgePill(
                label: 'PID ${status.processId}',
                color: ThemeColorsConstants.primary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoLine(
                icon: Icons.flag_rounded,
                label: 'Manual inicial',
                value: status.initialManual == 0
                    ? 'Sem manual'
                    : '${status.initialManual}',
              ),
              _InfoLine(
                icon: Icons.inventory_2_rounded,
                label: 'Manual atual',
                value: status.currentManual == 0
                    ? 'Sem manual'
                    : '${status.currentManual}',
              ),
              _InfoLine(
                icon: Icons.route_rounded,
                label: 'Etapa',
                value: status.stage.label,
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
        final description = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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

        if (trailing == null || constraints.maxWidth < 760) {
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
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

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            isLoading ? Icons.hourglass_top_rounded : Icons.directions_run,
            size: 34,
            color: ThemeColorsConstants.primary,
          ),
          const SizedBox(height: 14),
          Text(
            isLoading
                ? 'Buscando contas no jogo...'
                : 'Nenhuma conta disponivel para o AutoRace.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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
        'Os eventos do AutoRace vao aparecer aqui assim que uma conta for selecionada ou iniciada.',
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
