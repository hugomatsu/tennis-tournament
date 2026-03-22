import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:tennis_tournament/features/tutorial/domain/tutorial_step.dart';
import 'package:tennis_tournament/features/tutorial/data/tutorial_repository.dart';
import 'package:tennis_tournament/features/tutorial/data/tutorial_analytics.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

final tutorialControllerProvider = Provider<TutorialController>((ref) {
  return TutorialController(
    repository: ref.watch(tutorialRepositoryProvider),
    analytics: ref.watch(tutorialAnalyticsProvider),
  );
});

class TutorialController {
  final TutorialRepository repository;
  final TutorialAnalytics analytics;

  TutorialCoachMark? _activeTutorial;
  int _currentStepIndex = 0;
  int _consecutiveErrors = 0;
  final Stopwatch _sessionStopwatch = Stopwatch();
  final Stopwatch _stepStopwatch = Stopwatch();
  String _currentTrack = '';
  List<TutorialStepData> _currentSteps = [];

  TutorialController({
    required this.repository,
    required this.analytics,
  });

  bool get isActive => _activeTutorial != null;

  Future<void> startPlayerTutorial({
    required BuildContext context,
    required List<TutorialStepData> steps,
    required String source,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) async {
    await _startTutorial(
      context: context,
      steps: steps,
      track: 'player',
      source: source,
      onFinish: () {
        repository.markPlayerTutorialCompleted();
        onFinish?.call();
      },
      onSkip: () {
        repository.markPlayerTutorialCompleted();
        onSkip?.call();
      },
    );
  }

  Future<void> startAdminTutorial({
    required BuildContext context,
    required List<TutorialStepData> steps,
    required String source,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) async {
    await _startTutorial(
      context: context,
      steps: steps,
      track: 'admin',
      source: source,
      onFinish: () {
        repository.markAdminTutorialCompleted();
        onFinish?.call();
      },
      onSkip: () {
        repository.markAdminTutorialCompleted();
        onSkip?.call();
      },
    );
  }

  Future<void> _startTutorial({
    required BuildContext context,
    required List<TutorialStepData> steps,
    required String track,
    required String source,
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) async {
    if (isActive) return;

    _currentSteps = steps;
    _currentTrack = track;
    _currentStepIndex = 0;
    _consecutiveErrors = 0;
    _sessionStopwatch
      ..reset()
      ..start();
    _stepStopwatch
      ..reset()
      ..start();

    analytics.tutorialStarted(track: track, source: source);

    final targets = _buildTargets(steps, context);

    if (targets.isEmpty) {
      debugPrint('TutorialController: No valid targets found for $track tutorial');
      return;
    }

    _activeTutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.75,
      paddingFocus: 10,
      pulseEnable: true,
      hideSkip: false,
      textSkip: '', // We use custom skip in the content
      onClickTarget: (target) {
        final stepIndex = targets.indexOf(target);
        if (stepIndex >= 0 && stepIndex < _currentSteps.length) {
          analytics.stepInteraction(
            track: _currentTrack,
            stepIndex: stepIndex,
            stepId: _currentSteps[stepIndex].id,
          );
          repository.saveLastStep(_currentTrack, stepIndex);
        }
        _onStepChanged(stepIndex + 1);
      },
      onClickOverlay: (target) {
        final stepIndex = targets.indexOf(target);
        if (stepIndex >= 0 && stepIndex < _currentSteps.length) {
          analytics.stepInteraction(
            track: _currentTrack,
            stepIndex: stepIndex,
            stepId: _currentSteps[stepIndex].id,
          );
        }
        _onStepChanged(stepIndex + 1);
      },
      onFinish: () {
        _sessionStopwatch.stop();
        analytics.tutorialCompleted(
          track: _currentTrack,
          totalSteps: _currentSteps.length,
          timeSpentMs: _sessionStopwatch.elapsedMilliseconds,
        );
        _activeTutorial = null;
        onFinish();
      },
      onSkip: () {
        _sessionStopwatch.stop();
        final stepId = _currentStepIndex < _currentSteps.length
            ? _currentSteps[_currentStepIndex].id
            : 'unknown';
        analytics.tutorialSkipped(
          track: _currentTrack,
          skippedAtStep: _currentStepIndex,
          skippedAtStepId: stepId,
          totalSteps: _currentSteps.length,
          timeSpentMs: _sessionStopwatch.elapsedMilliseconds,
        );
        _activeTutorial = null;
        onSkip();
        return true;
      },
    );

    // Delay slightly to ensure widgets are rendered
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      _activeTutorial?.show(context: context);
      _logStepViewed(0);
    }
  }

  void _onStepChanged(int newIndex) {
    final previousStepTime = _stepStopwatch.elapsedMilliseconds;
    _stepStopwatch
      ..reset()
      ..start();
    _currentStepIndex = newIndex;

    if (newIndex < _currentSteps.length) {
      _logStepViewed(newIndex, timeOnPreviousStepMs: previousStepTime);
    }
  }

  void _logStepViewed(int index, {int? timeOnPreviousStepMs}) {
    if (index >= _currentSteps.length) return;
    analytics.stepViewed(
      track: _currentTrack,
      stepIndex: index,
      stepId: _currentSteps[index].id,
      timeOnPreviousStepMs: timeOnPreviousStepMs,
    );
  }

  List<TargetFocus> _buildTargets(
    List<TutorialStepData> steps,
    BuildContext context,
  ) {
    final targets = <TargetFocus>[];
    final theme = Theme.of(context);

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];

      // Verify the key has a valid context
      if (step.targetKey.currentContext == null) {
        analytics.tutorialError(
          track: _currentTrack,
          stepIndex: i,
          stepId: step.id,
          errorType: 'key_not_found',
          errorMessage: 'GlobalKey ${step.id} has no current context',
        );
        _consecutiveErrors++;
        if (_consecutiveErrors >= 3) {
          debugPrint('TutorialController: 3 consecutive errors, aborting');
          break;
        }
        continue;
      }

      _consecutiveErrors = 0;

      final contentAlign = switch (step.tooltipPosition) {
        TooltipPosition.top => ContentAlign.top,
        TooltipPosition.bottom => ContentAlign.bottom,
        TooltipPosition.left => ContentAlign.left,
        TooltipPosition.right => ContentAlign.right,
      };

      targets.add(
        TargetFocus(
          identify: step.id,
          keyTarget: step.targetKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          enableTargetTab: true,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: contentAlign,
              builder: (context, controller) {
                return _TutorialTooltip(
                  title: step.title,
                  description: step.description,
                  stepIndex: i,
                  totalSteps: steps.length,
                  theme: theme,
                  onNext: () => controller.next(),
                  onSkip: () => controller.skip(),
                );
              },
            ),
          ],
        ),
      );
    }

    return targets;
  }

  void dismiss() {
    _activeTutorial?.skip();
    _activeTutorial = null;
  }
}

class _TutorialTooltip extends StatelessWidget {
  final String title;
  final String description;
  final int stepIndex;
  final int totalSteps;
  final ThemeData theme;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TutorialTooltip({
    required this.title,
    required this.description,
    required this.stepIndex,
    required this.totalSteps,
    required this.theme,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isLast = stepIndex == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${stepIndex + 1}/$totalSteps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: onSkip,
                child: Text(
                  loc.tutorialSkip,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              FilledButton(
                onPressed: onNext,
                child: Text(isLast ? loc.tutorialDone : loc.tutorialNext),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
