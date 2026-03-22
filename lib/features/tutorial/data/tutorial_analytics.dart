import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tutorialAnalyticsProvider = Provider<TutorialAnalytics>((ref) {
  return TutorialAnalytics();
});

class TutorialAnalytics {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> welcomeStarted({required String source}) async {
    await _log('tutorial_welcome_started', {'source': source});
  }

  Future<void> welcomeSlideViewed({
    required int slideIndex,
    required String slideTitle,
  }) async {
    await _log('tutorial_welcome_slide_viewed', {
      'slide_index': slideIndex,
      'slide_title': slideTitle,
    });
  }

  Future<void> welcomeCompleted({
    required String action,
    required int timeSpentMs,
  }) async {
    await _log('tutorial_welcome_completed', {
      'action': action,
      'time_spent_ms': timeSpentMs,
    });
  }

  Future<void> welcomeSkipped({
    required int skippedAtSlide,
    required int timeSpentMs,
  }) async {
    await _log('tutorial_welcome_skipped', {
      'skipped_at_slide': skippedAtSlide,
      'time_spent_ms': timeSpentMs,
    });
  }

  Future<void> tutorialStarted({
    required String track,
    required String source,
  }) async {
    await _log('tutorial_started', {
      'track': track,
      'source': source,
    });
  }

  Future<void> stepViewed({
    required String track,
    required int stepIndex,
    required String stepId,
    int? timeOnPreviousStepMs,
  }) async {
    await _log('tutorial_step_viewed', {
      'track': track,
      'step_index': stepIndex,
      'step_id': stepId,
      if (timeOnPreviousStepMs != null)
        'time_on_previous_step_ms': timeOnPreviousStepMs,
    });
  }

  Future<void> stepInteraction({
    required String track,
    required int stepIndex,
    required String stepId,
  }) async {
    await _log('tutorial_step_interaction', {
      'track': track,
      'step_index': stepIndex,
      'step_id': stepId,
    });
  }

  Future<void> tutorialSkipped({
    required String track,
    required int skippedAtStep,
    required String skippedAtStepId,
    required int totalSteps,
    required int timeSpentMs,
  }) async {
    await _log('tutorial_skipped', {
      'track': track,
      'skipped_at_step': skippedAtStep,
      'skipped_at_step_id': skippedAtStepId,
      'total_steps': totalSteps,
      'time_spent_ms': timeSpentMs,
    });
  }

  Future<void> tutorialCompleted({
    required String track,
    required int totalSteps,
    required int timeSpentMs,
  }) async {
    await _log('tutorial_completed', {
      'track': track,
      'total_steps': totalSteps,
      'time_spent_ms': timeSpentMs,
    });
  }

  Future<void> tutorialError({
    required String track,
    required int stepIndex,
    required String stepId,
    required String errorType,
    String? errorMessage,
  }) async {
    await _log('tutorial_error', {
      'track': track,
      'step_index': stepIndex,
      'step_id': stepId,
      'error_type': errorType,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  Future<void> replayTapped({required String track}) async {
    await _log('tutorial_replay_tapped', {'track': track});
  }

  Future<void> _log(String name, Map<String, Object> parameters) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('TutorialAnalytics error logging $name: $e');
    }
  }
}
