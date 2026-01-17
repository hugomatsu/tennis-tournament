import 'package:shared_preferences/shared_preferences.dart';

class TournamentFilterPreferences {
  static const String _keyFilterMine = 'tournament_filter_mine';
  static const String _keyFilterSingle = 'tournament_filter_single';
  static const String _keyFilterTeam = 'tournament_filter_team';
  static const String _keyFilterOpen = 'tournament_filter_open';

  static Future<Map<String, bool>> loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mine': prefs.getBool(_keyFilterMine) ?? false,
      'single': prefs.getBool(_keyFilterSingle) ?? false,
      'team': prefs.getBool(_keyFilterTeam) ?? false,
      'open': prefs.getBool(_keyFilterOpen) ?? false,
    };
  }

  static Future<void> saveFilters({
    required bool mine,
    required bool single,
    required bool team,
    required bool open,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFilterMine, mine);
    await prefs.setBool(_keyFilterSingle, single);
    await prefs.setBool(_keyFilterTeam, team);
    await prefs.setBool(_keyFilterOpen, open);
  }
}
