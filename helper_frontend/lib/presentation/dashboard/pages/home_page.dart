import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/entities/account.dart';
import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';
import 'package:provider/provider.dart';

import '../../../core/enums/faction_enum.dart';
import '../states/home_page_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          HomePageState(accountsUsecase: ctx.read<AccountsUsecase>()),
      child: Consumer<HomePageState>(
        builder: (_, state, __) {
          final athensCount = state.accounts
              .where((account) => account.faction == FactionEnum.athens)
              .length;
          final spartaCount = state.accounts
              .where((account) => account.faction == FactionEnum.sparta)
              .length;

          return Scaffold(
            backgroundColor: const Color(0xFFF3F7FB),
            body: Stack(
              children: [
                const Positioned(
                  top: -120,
                  right: -40,
                  child: _BlurredAccent(color: Color(0xFF4F7CFF), size: 300),
                ),
                const Positioned(
                  bottom: -120,
                  left: -80,
                  child: _BlurredAccent(color: Color(0xFF73C8FF), size: 280),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 900;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1180),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _HeroSection(
                                  totalAccounts: state.accounts.length,
                                  isLoading: state.isLoading,
                                  onRefresh: state.loadAccounts,
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    _StatCard(
                                      width: isCompact
                                          ? constraints.maxWidth - 48
                                          : 230,
                                      title: 'Contas conectadas',
                                      value: '${state.accounts.length}',
                                      subtitle: 'Janelas prontas para foco',
                                      icon: Icons.groups_rounded,
                                      iconColor: const Color(0xFF1E6BFF),
                                      backgroundColor: Colors.white,
                                    ),
                                    _StatCard(
                                      width: isCompact
                                          ? constraints.maxWidth - 48
                                          : 230,
                                      title: 'Athens',
                                      value: '$athensCount',
                                      subtitle: 'Personagens dessa faccao',
                                      icon: Icons.shield_moon_rounded,
                                      iconColor: const Color(0xFF3F8CFF),
                                      backgroundColor: Colors.white,
                                    ),
                                    _StatCard(
                                      width: isCompact
                                          ? constraints.maxWidth - 48
                                          : 230,
                                      title: 'Sparta',
                                      value: '$spartaCount',
                                      subtitle: 'Personagens dessa faccao',
                                      icon: Icons.gpp_good_rounded,
                                      iconColor: const Color(0xFF1E9B8A),
                                      backgroundColor: Colors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _AccountsPanel(
                                  state: state,
                                  isCompact: isCompact,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.totalAccounts,
    required this.isLoading,
    required this.onRefresh,
  });

  final int totalAccounts;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1D3D), Color(0xFF163D78), Color(0xFF1E6BFF)],
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
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Gerencie suas contas do Gods Arena com mais clareza.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Veja quem esta online, identifique a faccao rapidamente e '
                'traga qualquer janela para frente com um clique.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
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
                      'Resumo rapido',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalAccounts contas detectadas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: isLoading ? null : onRefresh,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF163D78),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(
                        isLoading ? 'Atualizando...' : 'Atualizar lista',
                      ),
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

class _AccountsPanel extends StatelessWidget {
  const _AccountsPanel({required this.state, required this.isCompact});

  final HomePageState state;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE4ECF7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact) ...[
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contas logadas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Acesse rapidamente qualquer personagem ativo.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AvailabilityBadge(total: state.accounts.length),
          ] else
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contas logadas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Acesse rapidamente qualquer personagem ativo.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _AvailabilityBadge(total: state.accounts.length),
              ],
            ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: state.accounts.isEmpty
                ? _EmptyAccountsState(
                    isLoading: state.isLoading,
                    onRefresh: state.loadAccounts,
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 520),
                    child: ListView.separated(
                      itemCount: state.accounts.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final account = state.accounts[index];

                        return _AccountCard(
                          account: account,
                          onOpen: () =>
                              state.focusAccountWindow(account.processId),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAccountsState extends StatelessWidget {
  const _EmptyAccountsState({required this.isLoading, required this.onRefresh});

  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty-accounts'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5EEF9)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              size: 34,
              color: Color(0xFF1E6BFF),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Nenhuma conta encontrada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Atualize a lista quando o jogo estiver aberto para localizar '
            'suas janelas automaticamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onRefresh,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            label: Text(isLoading ? 'Buscando...' : 'Buscar contas'),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onOpen});

  final Account account;
  final VoidCallback onOpen;

  Color get _accentColor {
    switch (account.faction) {
      case FactionEnum.athens:
        return const Color(0xFF2F6BFF);
      case FactionEnum.sparta:
        return const Color(0xFF14917F);
      case FactionEnum.unknown:
        return const Color(0xFF64748B);
    }
  }

  String get _displayFaction {
    switch (account.faction) {
      case FactionEnum.athens:
        return 'Athens';
      case FactionEnum.sparta:
        return 'Sparta';
      case FactionEnum.unknown:
        return 'Desconhecida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;

        return Container(
          key: ValueKey(account.processId),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFEFF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE6EDF7)),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _AccountAvatar(
                          accentColor: _accentColor,
                          assetPath: account.faction.assetPath,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            account.nick,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.badge_outlined,
                          label: 'PID ${account.processId}',
                          foregroundColor: const Color(0xFF334155),
                          backgroundColor: const Color(0xFFF1F5F9),
                        ),
                        _InfoChip(
                          icon: Icons.shield_outlined,
                          label: _displayFaction,
                          foregroundColor: _accentColor,
                          backgroundColor: _accentColor.withOpacity(0.10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onOpen,
                        style: FilledButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text('Abrir'),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _AccountAvatar(
                      accentColor: _accentColor,
                      assetPath: account.faction.assetPath,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.nick,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.badge_outlined,
                                label: 'PID ${account.processId}',
                                foregroundColor: const Color(0xFF334155),
                                backgroundColor: const Color(0xFFF1F5F9),
                              ),
                              _InfoChip(
                                icon: Icons.shield_outlined,
                                label: _displayFaction,
                                foregroundColor: _accentColor,
                                backgroundColor: _accentColor.withOpacity(0.10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: onOpen,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Abrir'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$total disponiveis',
        style: const TextStyle(
          color: Color(0xFF1E40AF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.accentColor, required this.assetPath});

  final Color accentColor;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Image.asset(assetPath, width: 38, height: 38),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final IconData icon;
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4ECF7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
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
