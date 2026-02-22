import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/medical_result_model.dart';
import '../models/player_model.dart';
import '../services/medical_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bullet_list_card.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/warning_banner.dart';

class MedicalAnalysisScreen extends StatefulWidget {
  const MedicalAnalysisScreen({super.key, required this.player});

  final PlayerModel player;

  @override
  State<MedicalAnalysisScreen> createState() => _MedicalAnalysisScreenState();
}

class _MedicalAnalysisScreenState extends State<MedicalAnalysisScreen>
    with SingleTickerProviderStateMixin {
  final MedicalService _medicalService = MedicalService();

  bool _isLoading = false;
  MedicalResultModel? _result;
  String? _errorMessage;
  late final AnimationController _ballController;

  Future<void> _runAnalysis() async {
    final startedAt = DateTime.now();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _medicalService.analyze(
        playerId: widget.player.id,
        fatigue: 40,
        minutes: 60,
        load: 50,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      final elapsed = DateTime.now().difference(startedAt);
      const minVisible = Duration(milliseconds: 800);
      if (elapsed < minVisible) {
        await Future.delayed(minVisible - elapsed);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;

    return Scaffold(
      appBar: AppBar(title: const Text('Medical Dashboard')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlayerHeader(player: player),
                  const SizedBox(height: 16),
                  _ActionCard(isLoading: _isLoading, onRun: _runAnalysis),
                  if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InlineError(message: _errorMessage!),
                  ],
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _result == null ? 0 : 1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: _result == null
                        ? const SizedBox.shrink()
                        : _ResultBody(result: _result!, player: player),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: AppTheme.background.withValues(alpha: 0.88),
                  child: const Center(child: _LoadingOverlay()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ballController.dispose();
    super.dispose();
  }
}

class _FootballHero extends StatelessWidget {
  const _FootballHero({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = controller.value;
          final bob = math.sin(t * 2 * math.pi) * 6;
          final glow = 0.2 + (0.35 * t);
          final rotate = t * 2 * math.pi;

          return Transform.translate(
            offset: Offset(0, bob),
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentBlue.withValues(alpha: 0.18),
                          AppTheme.background.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: rotate,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.25),
                          width: 1.4,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentBlue.withValues(
                                  alpha: 0.6,
                                ),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentBlue.withValues(alpha: glow),
                          blurRadius: 26,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.card,
                      child: Icon(
                        Icons.sports_soccer,
                        color: AppTheme.accentBlue,
                        size: 42,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    child: Container(
                      width: 90,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.background.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FootballHero(controller: _controller),
        const SizedBox(height: 16),
        const Text(
          'Analyzing medical signals...',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          'AI engine running',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.isLoading, required this.onRun});

  final bool isLoading;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Run Medical Analysis',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Generate AI injury probability and recovery insights.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isLoading ? null : onRun,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Run',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.4)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result, required this.player});

  final MedicalResultModel result;
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    final probability = (result.injuryProbability * 100)
        .clamp(0, 100)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RiskIndicator(probability: result.injuryProbability),
        const SizedBox(height: 16),
        if (result.injured) ...[
          _SummaryCard(result: result, probability: probability),
          const SizedBox(height: 16),
          BulletListCard(
            title: 'Rehabilitation',
            items: result.rehabilitation,
            icon: Icons.fitness_center,
          ),
          const SizedBox(height: 12),
          BulletListCard(
            title: 'Prevention',
            items: result.prevention.isEmpty
                ? const ['Maintain balanced load and recovery routines.']
                : result.prevention,
            icon: Icons.shield,
          ),
          const SizedBox(height: 12),
          if (result.warning.trim().isNotEmpty)
            WarningBanner(message: result.warning),
        ] else ...[
          _HealthyStatusCard(probability: result.injuryProbability),
          const SizedBox(height: 16),
          BulletListCard(
            title: 'Prevention',
            items: result.prevention.isEmpty
                ? const ['Maintain balanced load and recovery routines.']
                : result.prevention,
            icon: Icons.shield,
          ),
          const SizedBox(height: 12),
          _HistoryStatCard(totalInjuries: player.injuryHistory),
        ],
      ],
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: AppTheme.accentBlue,
              size: 30,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  player.position,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Base fitness: ${player.baseFitness}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.12),
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
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result, required this.probability});

  final MedicalResultModel result;
  final double probability;

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(result.severity);
    final recoveryLabel = result.recoveryDays == 0
        ? 'TBD'
        : result.recoveryDays.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Medical Insight',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.severity,
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.injuryType,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monitor recovery and adjust training load based on AI guidance.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricTile(
                label: 'Probability',
                value: '${probability.toStringAsFixed(0)}%',
                accentColor: severityColor,
              ),
              const SizedBox(width: 12),
              _MetricTile(
                label: 'Recovery days',
                value: recoveryLabel,
                accentColor: AppTheme.accentBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return AppTheme.danger;
      case 'moderate':
        return AppTheme.warning;
      case 'mild':
      default:
        return AppTheme.success;
    }
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthyStatusCard extends StatelessWidget {
  const _HealthyStatusCard({required this.probability});

  final double probability;

  @override
  Widget build(BuildContext context) {
    final display = (probability * 100).clamp(0, 100).toDouble();
    final riskLabel = display < 30
        ? 'LOW RISK'
        : display < 60
        ? 'MODERATE RISK'
        : 'HIGH RISK';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Healthy',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                riskLabel,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Player is in good condition.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Training load is within safe limits.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HistoryStatCard extends StatelessWidget {
  const _HistoryStatCard({required this.totalInjuries});

  final int totalInjuries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Injury history',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            '$totalInjuries total',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
