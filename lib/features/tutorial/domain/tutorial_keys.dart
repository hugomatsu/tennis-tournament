import 'package:flutter/material.dart';

class TutorialKeys {
  TutorialKeys._();

  // Bottom nav
  static final tournamentsTab = GlobalKey(debugLabel: 'tutorialTournamentsTab');
  static final scheduleTab = GlobalKey(debugLabel: 'tutorialScheduleTab');
  static final profileTab = GlobalKey(debugLabel: 'tutorialProfileTab');

  // Tournaments screen
  static final searchBar = GlobalKey(debugLabel: 'tutorialSearchBar');
  static final filterButton = GlobalKey(debugLabel: 'tutorialFilterButton');
  static final firstTournamentCard = GlobalKey(debugLabel: 'tutorialFirstTournamentCard');
  static final createTournamentFab = GlobalKey(debugLabel: 'tutorialCreateTournamentFab');

  // Tournament detail
  static final infoTab = GlobalKey(debugLabel: 'tutorialInfoTab');
  static final bracketTab = GlobalKey(debugLabel: 'tutorialBracketTab');
  static final calendarTab = GlobalKey(debugLabel: 'tutorialCalendarTab');
  static final shareButton = GlobalKey(debugLabel: 'tutorialShareButton');
  static final adminSettingsButton = GlobalKey(debugLabel: 'tutorialAdminSettingsButton');
}
