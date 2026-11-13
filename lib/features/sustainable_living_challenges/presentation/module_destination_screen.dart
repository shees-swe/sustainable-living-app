import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.sustainableLivingChallenges, maxLines: 2),
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
            padding: const EdgeInsets.symmetric(
              horizontal: ClimateSpacing.space16,
              vertical: ClimateSpacing.space16,
            ),
            children: [
              for (
                var index = 0;
                index < widget.catalog.challenges.length;
                index++
              ) ...[
                AppPanel(
                  padding: EdgeInsets.zero,
                  child: _ChallengeRow(
                    challenge: widget.catalog.challenges[index],
                    progress: byId[widget.catalog.challenges[index].id],
                    onTap: () => _openChallenge(
                      context,
                      widget.catalog.challenges[index],
                    ),
                  ),
                ),
                if (index < widget.catalog.challenges.length - 1)
                  const SizedBox(height: DesignTokens.space12),
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
    final l10n = AppLocalizations.of(context)!;
    final borderRadius = BorderRadius.circular(DesignTokens.radiusCard);
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppIconBadge(
              icon: Icons.flag_outlined,
              backgroundColor: DesignTokens.surfaceSun,
              foregroundColor: DesignTokens.sun,
              size: 52,
            ),
            const SizedBox(width: DesignTokens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: DesignTokens.space8),
                  _ChallengeText('${challenge.theme} · ${challenge.days} days'),
                  if (progress != null) ...[
                    const SizedBox(height: DesignTokens.space12),
                    _ProgressSummary(
                      progress: progress!,
                      totalDays: challenge.days,
                      l10n: l10n,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.space8),
            Icon(
              Icons.arrow_forward,
              size: DesignTokens.iconSmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(challenge.title, maxLines: 2),
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
    return ListView(
      key: const ValueKey('challengeDetailList'),
      padding: const EdgeInsets.symmetric(
        horizontal: ClimateSpacing.space16,
        vertical: ClimateSpacing.space16,
      ),
      children: [
        AppPanel(
          color: DesignTokens.surfaceSun,
          padding: const EdgeInsets.all(DesignTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(challenge.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: DesignTokens.space12),
              Wrap(
                spacing: DesignTokens.space16,
                runSpacing: DesignTokens.space8,
                children: [
                  _ChallengeText(
                    '${l10n.challengeThemeLabel}: ${challenge.theme}',
                  ),
                  _ChallengeText(
                    '${l10n.challengeDurationLabel}: ${challenge.days} days',
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(challenge.description),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        if (progress == null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton(
              onPressed: () => unawaited(
                _performChallengeAction(
                  context,
                  () => repository.startChallenge(challenge.id),
                ),
              ),
              child: Text(l10n.challengeStart),
            ),
          )
        else ...[
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressSummary(
                  progress: progress!,
                  totalDays: challenge.days,
                  l10n: l10n,
                ),
                if (progress!.isCompleteFor(challenge.days)) ...[
                  const SizedBox(height: DesignTokens.space12),
                  Text(
                    l10n.challengeCompleted,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ClimateColors.positiveSaved,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          ..._dayRows(context, progress!),
          const SizedBox(height: DesignTokens.space16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => unawaited(
                _performChallengeAction(
                  context,
                  () => repository.resetChallenge(challenge.id),
                ),
              ),
              child: Text(l10n.challengeReset),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _dayRows(BuildContext context, ChallengeProgress progress) {
    return [
      for (var dayNumber = 1; dayNumber <= challenge.days; dayNumber++) ...[
        _dayRow(context, progress, dayNumber),
        if (dayNumber < challenge.days) const Divider(height: 1),
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
    final completed = progress.completedDayCount;
    final fraction = progress.fractionFor(totalDays);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChallengeText('$completed / $totalDays days'),
        const SizedBox(height: ClimateSpacing.space8),
        LinearProgressIndicator(
          value: fraction,
          minHeight: 4,
          color: progress.isCompleteFor(totalDays)
              ? ClimateColors.positiveSaved
              : ClimateColors.cobalt,
          backgroundColor: ClimateColors.surfaceSecondary,
          semanticsValue: fraction.toString(),
          semanticsLabel: l10n.challengeProgressSemanticsLabel(
            completed,
            totalDays,
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
    return CheckboxListTile(
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
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
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
