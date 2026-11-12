import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/challenge_catalog.dart';
import '../data/challenge_progress_repository.dart';
import '../domain/challenge_progress.dart';

class SustainableLivingChallengesScreen extends StatefulWidget {
  const SustainableLivingChallengesScreen({
    required this.catalog,
    required this.repository,
    super.key,
  });

  final ChallengeCatalog catalog;
  final ChallengeProgressRepository repository;

  @override
  State<SustainableLivingChallengesScreen> createState() =>
      _SustainableLivingChallengesScreenState();
}

class _SustainableLivingChallengesScreenState
    extends State<SustainableLivingChallengesScreen> {
  late final Stream<List<ChallengeProgress>> _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.repository.watchProgress();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.sustainableLivingChallenges,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: StreamBuilder<List<ChallengeProgress>>(
        stream: _progress,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _MessageState(message: l10n.challengeProgressLoadFailure);
          }
          final progress = snapshot.data;
          if (progress == null) {
            return Center(
              child: MotionAwareProgressIndicator(semanticsLabel: l10n.loading),
            );
          }
          final byId = {for (final item in progress) item.challengeId: item};
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              for (
                var index = 0;
                index < widget.catalog.challenges.length;
                index++
              ) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: DesignTokens.sectionCard(context),
                  child: _ChallengeRow(
                    challenge: widget.catalog.challenges[index],
                    progress: byId[widget.catalog.challenges[index].id],
                    onTap: () => _openChallenge(
                      context,
                      widget.catalog.challenges[index],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openChallenge(BuildContext context, SustainableChallenge challenge) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _ChallengeDetailScreen(
              challenge: challenge,
              repository: widget.repository,
            ),
        transitionDuration: ReducedMotion.duration(
          context,
          MotionSpec.optionalFade,
        ),
        reverseTransitionDuration: ReducedMotion.duration(
          context,
          MotionSpec.optionalFade,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: MotionSpec.optionalFadeCurve),
              ),
              child: child,
            ),
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({
    required this.challenge,
    required this.progress,
    required this.onTap,
  });

  final SustainableChallenge challenge;
  final ChallengeProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isComplete =
        progress != null && progress!.isCompleteFor(challenge.days);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: ClimateSpacing.space16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (isComplete)
                        Icon(
                          Icons.check_circle_rounded,
                          color: ClimateColors.positiveSaved,
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: verdant.tagBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          challenge.theme,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: verdant.forestGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ChallengeText('${challenge.days} days'),
                    ],
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    _ProgressSummary(
                      progress: progress!,
                      totalDays: challenge.days,
                      l10n: l10n,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: ClimateColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ChallengeDetailScreen extends StatelessWidget {
  const _ChallengeDetailScreen({
    required this.challenge,
    required this.repository,
  });

  final SustainableChallenge challenge;
  final ChallengeProgressRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          challenge.title,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: StreamBuilder<List<ChallengeProgress>>(
        stream: repository.watchProgress(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _MessageState(message: l10n.challengeProgressLoadFailure);
          }
          final allProgress = snapshot.data;
          if (allProgress == null) {
            return Center(
              child: MotionAwareProgressIndicator(semanticsLabel: l10n.loading),
            );
          }
          ChallengeProgress? progress;
          for (final item in allProgress) {
            if (item.challengeId == challenge.id) {
              progress = item;
              break;
            }
          }
          return _ChallengeDetailBody(
            challenge: challenge,
            repository: repository,
            progress: progress,
          );
        },
      ),
    );
  }
}

class _ChallengeDetailBody extends StatelessWidget {
  const _ChallengeDetailBody({
    required this.challenge,
    required this.repository,
    required this.progress,
  });

  final SustainableChallenge challenge;
  final ChallengeProgressRepository repository;
  final ChallengeProgress? progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    return ListView(
      key: const ValueKey('challengeDetailList'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Hero header
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [verdant.forestGreen, verdant.forestDeep],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      challenge.theme,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ChallengeText(
                    '${challenge.days} days',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Description card
        Container(
          decoration: DesignTokens.sectionCard(context),
          padding: const EdgeInsets.all(16),
          child: Text(
            challenge.description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
        const SizedBox(height: 12),
        // Progress / actions
        if (progress == null)
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => unawaited(
                  _performChallengeAction(
                    context,
                    () => repository.startChallenge(challenge.id),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: verdant.forestGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: Text(l10n.challengeStart),
              ),
            ),
          )
        else ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressSummary(
                  progress: progress!,
                  totalDays: challenge.days,
                  l10n: l10n,
                ),
                if (progress!.isCompleteFor(challenge.days)) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: ClimateColors.positiveSaved,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.challengeCompleted,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: ClimateColors.positiveSaved,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Day rows
          ..._dayRows(context, progress!),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => unawaited(
              _performChallengeAction(
                context,
                () => repository.resetChallenge(challenge.id),
              ),
            ),
            child: Text(l10n.challengeReset),
          ),
        ],
      ],
    );
  }

  List<Widget> _dayRows(BuildContext context, ChallengeProgress progress) {
    return [
      for (var dayNumber = 1; dayNumber <= challenge.days; dayNumber++) ...[
        _dayRow(context, progress, dayNumber),
        if (dayNumber < challenge.days)
          const Divider(height: 1),
      ],
    ];
  }

  Widget _dayRow(
    BuildContext context,
    ChallengeProgress progress,
    int dayNumber,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final completed = progress.completedDays.contains(dayNumber);
    return _ChallengeDayRow(
      key: ValueKey<int>(dayNumber),
      day: dayNumber,
      completed: completed,
      locked: !completed && !repository.isDayUnlocked(progress, dayNumber),
      lockedNote: l10n.challengeDayNotAvailableYet,
      onChanged: (completed) => unawaited(
        _performChallengeAction(
          context,
          () => repository.setDayCompleted(
            challengeId: challenge.id,
            totalDays: challenge.days,
            dayNumber: dayNumber,
            completed: completed,
          ),
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.progress,
    required this.totalDays,
    required this.l10n,
  });

  final ChallengeProgress progress;
  final int totalDays;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final completed = progress.completedDayCount;
    final fraction = progress.fractionFor(totalDays);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChallengeText('$completed / $totalDays days'),
        const SizedBox(height: ClimateSpacing.space8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            color: progress.isCompleteFor(totalDays)
                ? ClimateColors.positiveSaved
                : verdant.forestGreen,
            backgroundColor: verdant.forestLight,
            semanticsValue: fraction.toString(),
            semanticsLabel: l10n.challengeProgressSemanticsLabel(
              completed,
              totalDays,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChallengeDayRow extends StatelessWidget {
  const _ChallengeDayRow({
    super.key,
    required this.day,
    required this.completed,
    required this.locked,
    required this.lockedNote,
    required this.onChanged,
  });

  final int day;
  final bool completed;
  final bool locked;
  final String lockedNote;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: completed,
        onChanged: locked ? null : (value) => onChanged(value ?? false),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChallengeText(l10n.challengeDayLabel(day)),
            if (locked) ...[
              const SizedBox(height: ClimateSpacing.space8),
              Text(
                lockedNote,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: ClimateColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChallengeText extends StatelessWidget {
  const _ChallengeText(this.text);

  final String text;

  static final _numberPattern = RegExp(r'\d+(?:[.,]\d+)*');

  @override
  Widget build(BuildContext context) {
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _numberPattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: numberStyle));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(TextSpan(children: spans));
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(ClimateSpacing.space16),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

Future<void> _performChallengeAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } on Exception {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.challengeProgressSaveFailure,
        ),
      ),
    );
  }
}
