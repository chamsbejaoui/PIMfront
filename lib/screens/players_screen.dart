import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import 'medical_analysis_screen.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen>
    with TickerProviderStateMixin {
  final PlayerService _playerService = PlayerService();

  late Future<List<PlayerModel>> _playersFuture;
  late final AnimationController _listController;
  late final AnimationController _bgController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _playersFuture = _playerService.fetchPlayers();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _listController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical AI')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select a player',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IgnorePointer(
                            child: _WorldCupCenterpiece(
                              controller: _bgController,
                            ),
                          ),
                          FutureBuilder<List<PlayerModel>>(
                            future: _playersFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.accentBlue,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return _ErrorState(
                                  message: 'Unable to load players.',
                                  onRetry: () {
                                    setState(() {
                                      _playersFuture = _playerService
                                          .fetchPlayers();
                                    });
                                  },
                                );
                              }

                              final players = snapshot.data ?? [];
                              if (players.isEmpty) {
                                return const _EmptyState();
                              }

                              if (!_hasAnimated) {
                                _hasAnimated = true;
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    _listController.forward();
                                  }
                                });
                              }

                              return ListView.builder(
                                itemCount: players.length,
                                itemBuilder: (context, index) {
                                  final player = players[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _AnimatedPlayerCard(
                                      index: index,
                                      controller: _listController,
                                      child: _PlayerCard(
                                        player: player,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MedicalAnalysisScreen(
                                                    player: player,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player, required this.onTap});

  final PlayerModel player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasInjuries = player.injuryHistory > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.surfaceAlt.withValues(alpha: 0.95),
              AppTheme.card.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.35),
                    AppTheme.accentBlue.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.blueGlow.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: AppTheme.accentBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Tag(label: player.position, icon: Icons.place),
                      _Tag(
                        label: 'Base ${player.baseFitness}',
                        icon: Icons.speed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasInjuries)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${player.injuryHistory} injuries',
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppTheme.textMuted.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPlayerCard extends StatelessWidget {
  const _AnimatedPlayerCard({
    required this.index,
    required this.controller,
    required this.child,
  });

  final int index;
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.08).clamp(0.0, 0.6);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.accentBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPlayerGlow extends StatelessWidget {
  const _BackgroundPlayerGlow({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final bob = math.sin(t * 2 * math.pi) * 18;
        final pulse = 0.18 + (0.12 * math.sin(t * 2 * math.pi));
        final tilt = math.sin(t * 2 * math.pi) * 0.06;

        return Stack(
          children: [
            Positioned(
              right: -40,
              top: 80 + bob,
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.blueGlow.withValues(alpha: pulse),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 120 + bob,
              child: Opacity(
                opacity: 0.28,
                child: Transform.rotate(
                  angle: tilt,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentBlue.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: AppTheme.accentBlue.withValues(alpha: 0.22),
                        width: 1.6,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_run_rounded,
                        size: 86,
                        color: AppTheme.accentBlue.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WorldCupCenterpiece extends StatelessWidget {
  const _WorldCupCenterpiece({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final glow = 0.18 + (0.18 * math.sin(t * 2 * math.pi));
        final scale = 0.98 + (0.03 * math.sin(t * 2 * math.pi));

        return SizedBox.expand(
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 520,
                    height: 520,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.blueGlow.withValues(alpha: glow),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.22,
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 320,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                  Opacity(
                    opacity: 0.12,
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 420,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No players found.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentBlue,
              side: const BorderSide(color: AppTheme.accentBlue),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
