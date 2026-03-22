import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tutorialRepositoryProvider = Provider<TutorialRepository>((ref) {
  return TutorialRepository();
});

class TutorialRepository {
  static const _keyWelcomeSeen = 'tutorial_welcome_seen';
  static const _keyPlayerCompleted = 'tutorial_completed_player';
  static const _keyAdminCompleted = 'tutorial_completed_admin';
  static const _keyPlayerLastStep = 'tutorial_last_step_player';
  static const _keyAdminLastStep = 'tutorial_last_step_admin';

  Future<bool> isWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWelcomeSeen) ?? false;
  }

  Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWelcomeSeen, true);
  }

  Future<bool> isPlayerTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPlayerCompleted) ?? false;
  }

  Future<bool> isAdminTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAdminCompleted) ?? false;
  }

  Future<void> markPlayerTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPlayerCompleted, true);
  }

  Future<void> markAdminTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAdminCompleted, true);
  }

  Future<void> saveLastStep(String track, int stepIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = track == 'player' ? _keyPlayerLastStep : _keyAdminLastStep;
    await prefs.setInt(key, stepIndex);
  }

  Future<int> getLastStep(String track) async {
    final prefs = await SharedPreferences.getInstance();
    final key = track == 'player' ? _keyPlayerLastStep : _keyAdminLastStep;
    return prefs.getInt(key) ?? 0;
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyWelcomeSeen);
    await prefs.remove(_keyPlayerCompleted);
    await prefs.remove(_keyAdminCompleted);
    await prefs.remove(_keyPlayerLastStep);
    await prefs.remove(_keyAdminLastStep);
  }
}
