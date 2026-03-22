import 'package:tennis_tournament/features/tutorial/domain/tutorial_step.dart';
import 'package:tennis_tournament/features/tutorial/domain/tutorial_keys.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

List<TutorialStepData> getPlayerTutorialSteps(AppLocalizations loc) {
  return [
    TutorialStepData(
      id: 'tournaments_tab',
      targetKey: TutorialKeys.tournamentsTab,
      title: loc.tutorialTournamentsTabTitle,
      description: loc.tutorialTournamentsTabBody,
      tooltipPosition: TooltipPosition.top,
    ),
    TutorialStepData(
      id: 'schedule_tab',
      targetKey: TutorialKeys.scheduleTab,
      title: loc.tutorialScheduleTabTitle,
      description: loc.tutorialScheduleTabBody,
      tooltipPosition: TooltipPosition.top,
    ),
    TutorialStepData(
      id: 'profile_tab',
      targetKey: TutorialKeys.profileTab,
      title: loc.tutorialProfileTabTitle,
      description: loc.tutorialProfileTabBody,
      tooltipPosition: TooltipPosition.top,
    ),
    TutorialStepData(
      id: 'search_and_filter',
      targetKey: TutorialKeys.searchBar,
      title: loc.tutorialSearchTitle,
      description: loc.tutorialSearchBody,
      tooltipPosition: TooltipPosition.bottom,
    ),
    TutorialStepData(
      id: 'filter_button',
      targetKey: TutorialKeys.filterButton,
      title: loc.tutorialFilterTitle,
      description: loc.tutorialFilterBody,
      tooltipPosition: TooltipPosition.bottom,
    ),
    TutorialStepData(
      id: 'tournament_card',
      targetKey: TutorialKeys.firstTournamentCard,
      title: loc.tutorialTournamentCardTitle,
      description: loc.tutorialTournamentCardBody,
      tooltipPosition: TooltipPosition.bottom,
    ),
    TutorialStepData(
      id: 'create_tournament_fab',
      targetKey: TutorialKeys.createTournamentFab,
      title: loc.tutorialCreateTournamentTitle,
      description: loc.tutorialCreateTournamentBody,
      tooltipPosition: TooltipPosition.top,
    ),
  ];
}

List<TutorialStepData> getAdminTutorialSteps(AppLocalizations loc) {
  return [
    TutorialStepData(
      id: 'info_tab',
      targetKey: TutorialKeys.infoTab,
      title: loc.tutorialInfoTabTitle,
      description: loc.tutorialInfoTabBody,
      tooltipPosition: TooltipPosition.bottom,
    ),
    TutorialStepData(
      id: 'bracket_tab',
      targetKey: TutorialKeys.bracketTab,
      title: loc.tutorialBracketTabTitle,
      description: loc.tutorialBracketTabBody,
      tooltipPosition: TooltipPosition.bottom,
    ),
    TutorialStepData(
      id: 'calendar_tab',
      targetKey: TutorialKeys.calendarTab,
      title: loc.tutorialCalendarTabTitle,
      description: loc.tutorialCalendarTabBody,
      tooltipPosition: TooltipPosition.bottom,
    ),
    TutorialStepData(
      id: 'share_button',
      targetKey: TutorialKeys.shareButton,
      title: loc.tutorialShareTitle,
      description: loc.tutorialShareBody,
      tooltipPosition: TooltipPosition.bottom,
    ),
    TutorialStepData(
      id: 'admin_settings',
      targetKey: TutorialKeys.adminSettingsButton,
      title: loc.tutorialAdminSettingsTitle,
      description: loc.tutorialAdminSettingsBody,
      tooltipPosition: TooltipPosition.bottom,
    ),
  ];
}
