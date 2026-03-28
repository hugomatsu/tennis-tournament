import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tennis Tournaments'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @tournaments.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tournaments;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @noMatchesScheduled.
  ///
  /// In en, this message translates to:
  /// **'No matches scheduled yet.'**
  String get noMatchesScheduled;

  /// No description provided for @locationTBD.
  ///
  /// In en, this message translates to:
  /// **'Location TBD'**
  String get locationTBD;

  /// No description provided for @youSuffix.
  ///
  /// In en, this message translates to:
  /// **' (You)'**
  String get youSuffix;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get statusLive;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @matchDetails.
  ///
  /// In en, this message translates to:
  /// **'Match Details'**
  String get matchDetails;

  /// No description provided for @adminControls.
  ///
  /// In en, this message translates to:
  /// **'Admin Controls'**
  String get adminControls;

  /// No description provided for @confirmAttendance.
  ///
  /// In en, this message translates to:
  /// **'Confirm Attendance'**
  String get confirmAttendance;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @runnerUp.
  ///
  /// In en, this message translates to:
  /// **'Runner-Up'**
  String get runnerUp;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @player1Present.
  ///
  /// In en, this message translates to:
  /// **'Player 1 Present'**
  String get player1Present;

  /// No description provided for @player2Present.
  ///
  /// In en, this message translates to:
  /// **'Player 2 Present'**
  String get player2Present;

  /// No description provided for @youHaveConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You have confirmed attendance.'**
  String get youHaveConfirmed;

  /// No description provided for @pleaseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your attendance.'**
  String get pleaseConfirm;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @playingSince.
  ///
  /// In en, this message translates to:
  /// **'Playing Since'**
  String get playingSince;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @bracket.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get bracket;

  /// No description provided for @playoff.
  ///
  /// In en, this message translates to:
  /// **'Playoff'**
  String get playoff;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @generateBracket.
  ///
  /// In en, this message translates to:
  /// **'Generate Bracket'**
  String get generateBracket;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @generationMethod.
  ///
  /// In en, this message translates to:
  /// **'Generation Method'**
  String get generationMethod;

  /// No description provided for @randomlyShuffle.
  ///
  /// In en, this message translates to:
  /// **'Randomly shuffle players'**
  String get randomlyShuffle;

  /// No description provided for @reorderManually.
  ///
  /// In en, this message translates to:
  /// **'Reorder players manually'**
  String get reorderManually;

  /// No description provided for @deleteBracket.
  ///
  /// In en, this message translates to:
  /// **'Delete Bracket'**
  String get deleteBracket;

  /// No description provided for @deleteBracketConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the bracket? This will wipe all generated matches.'**
  String get deleteBracketConfirm;

  /// No description provided for @managePlayers.
  ///
  /// In en, this message translates to:
  /// **'Manage Players'**
  String get managePlayers;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get pendingRequests;

  /// No description provided for @approvedPlayers.
  ///
  /// In en, this message translates to:
  /// **'Approved Players'**
  String get approvedPlayers;

  /// No description provided for @noApprovedPlayers.
  ///
  /// In en, this message translates to:
  /// **'No approved players yet.'**
  String get noApprovedPlayers;

  /// No description provided for @addParticipant.
  ///
  /// In en, this message translates to:
  /// **'Add Participant'**
  String get addParticipant;

  /// No description provided for @myMediaLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Media Library'**
  String get myMediaLibrary;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get myLibrary;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage used'**
  String get storageUsed;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images in library'**
  String get noImages;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogIn;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @uploadedAt.
  ///
  /// In en, this message translates to:
  /// **'Uploaded At'**
  String get uploadedAt;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @loses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get loses;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @createTournament.
  ///
  /// In en, this message translates to:
  /// **'Create Tournament'**
  String get createTournament;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @manageLocations.
  ///
  /// In en, this message translates to:
  /// **'Manage Locations'**
  String get manageLocations;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @tournamentName.
  ///
  /// In en, this message translates to:
  /// **'Tournament Name'**
  String get tournamentName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @titleBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get titleBeginner;

  /// No description provided for @titleNovice.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get titleNovice;

  /// No description provided for @titleIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get titleIntermediate;

  /// No description provided for @titleClubPlayer.
  ///
  /// In en, this message translates to:
  /// **'Club Player'**
  String get titleClubPlayer;

  /// No description provided for @titleAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get titleAdvanced;

  /// No description provided for @titleSemiPro.
  ///
  /// In en, this message translates to:
  /// **'Semi-Pro'**
  String get titleSemiPro;

  /// No description provided for @titlePro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get titlePro;

  /// No description provided for @titleCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get titleCoach;

  /// No description provided for @titleEnthusiast.
  ///
  /// In en, this message translates to:
  /// **'Enthusiast'**
  String get titleEnthusiast;

  /// No description provided for @titleWeekendWarrior.
  ///
  /// In en, this message translates to:
  /// **'Weekend Warrior'**
  String get titleWeekendWarrior;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Please select or enter a title'**
  String get pleaseSelectTitle;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @findPlayers.
  ///
  /// In en, this message translates to:
  /// **'Find Players'**
  String get findPlayers;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @noPlayersFound.
  ///
  /// In en, this message translates to:
  /// **'No players found'**
  String get noPlayersFound;

  /// No description provided for @playerProfile.
  ///
  /// In en, this message translates to:
  /// **'Player Profile'**
  String get playerProfile;

  /// No description provided for @playerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Player not found'**
  String get playerNotFound;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @unknownPlayer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Player'**
  String get unknownPlayer;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @notFollowingAnyone.
  ///
  /// In en, this message translates to:
  /// **'Not following anyone yet.'**
  String get notFollowingAnyone;

  /// No description provided for @simulationDebug.
  ///
  /// In en, this message translates to:
  /// **'Simulation & Debug'**
  String get simulationDebug;

  /// No description provided for @matchNotFound.
  ///
  /// In en, this message translates to:
  /// **'Match not found'**
  String get matchNotFound;

  /// No description provided for @reasonForUnavailability.
  ///
  /// In en, this message translates to:
  /// **'Reason for unavailability'**
  String get reasonForUnavailability;

  /// No description provided for @declineJustify.
  ///
  /// In en, this message translates to:
  /// **'Decline & Justify'**
  String get declineJustify;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @responseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Response submitted. Admin notified.'**
  String get responseSubmitted;

  /// No description provided for @attendanceConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Attendance confirmed!'**
  String get attendanceConfirmed;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @viewLocation.
  ///
  /// In en, this message translates to:
  /// **'View Location'**
  String get viewLocation;

  /// No description provided for @vs.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get vs;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumBenefits.
  ///
  /// In en, this message translates to:
  /// **'Create unlimited tournaments and access exclusive features.'**
  String get premiumBenefits;

  /// No description provided for @freeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free Limit Reached'**
  String get freeLimitReached;

  /// No description provided for @freeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit of 2 free tournaments. Upgrade to Premium to create more!'**
  String get freeLimitMessage;

  /// No description provided for @manageAdmins.
  ///
  /// In en, this message translates to:
  /// **'Manage Admins'**
  String get manageAdmins;

  /// No description provided for @addAdmin.
  ///
  /// In en, this message translates to:
  /// **'Add Admin'**
  String get addAdmin;

  /// No description provided for @adminAdded.
  ///
  /// In en, this message translates to:
  /// **'Admin added successfully'**
  String get adminAdded;

  /// No description provided for @adminRemoved.
  ///
  /// In en, this message translates to:
  /// **'Admin removed successfully'**
  String get adminRemoved;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscribedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subscribed successfully!'**
  String get subscribedSuccessfully;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @removeAdminConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this admin?'**
  String get removeAdminConfirm;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// No description provided for @subscriptionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled'**
  String get subscriptionCancelled;

  /// No description provided for @freeTournamentsUsed.
  ///
  /// In en, this message translates to:
  /// **'Free Tournaments: {count}/{limit}'**
  String freeTournamentsUsed(Object count, Object limit);

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limitReached;

  /// No description provided for @createdUnderFreePlan.
  ///
  /// In en, this message translates to:
  /// **'This tournament was created under Free plan'**
  String get createdUnderFreePlan;

  /// No description provided for @premiumPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting at R\$ 29,99/month'**
  String get premiumPrice;

  /// No description provided for @premiumSupportDev.
  ///
  /// In en, this message translates to:
  /// **'Contributions support development!'**
  String get premiumSupportDev;

  /// No description provided for @organizers.
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get organizers;

  /// No description provided for @noOrganizersListed.
  ///
  /// In en, this message translates to:
  /// **'No organizers listed.'**
  String get noOrganizersListed;

  /// No description provided for @failedToLoadOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load organizers.'**
  String get failedToLoadOrganizers;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found.'**
  String get noCategoriesFound;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// No description provided for @myPlan.
  ///
  /// In en, this message translates to:
  /// **'My Plan'**
  String get myPlan;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @appAndSettings.
  ///
  /// In en, this message translates to:
  /// **'App & Settings'**
  String get appAndSettings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @evaluateApp.
  ///
  /// In en, this message translates to:
  /// **'Evaluate App'**
  String get evaluateApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 17, 2026'**
  String get privacyPolicyUpdated;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @madeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by'**
  String get madeBy;

  /// No description provided for @editTournament.
  ///
  /// In en, this message translates to:
  /// **'Edit Tournament'**
  String get editTournament;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @matchDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Match Duration (minutes)'**
  String get matchDurationMinutes;

  /// No description provided for @selectPartner.
  ///
  /// In en, this message translates to:
  /// **'Select Partner'**
  String get selectPartner;

  /// No description provided for @leaveTournament.
  ///
  /// In en, this message translates to:
  /// **'Leave Tournament?'**
  String get leaveTournament;

  /// No description provided for @leaveTournamentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the tournament completely? This will remove you from all categories.'**
  String get leaveTournamentConfirm;

  /// No description provided for @leaveParticipation.
  ///
  /// In en, this message translates to:
  /// **'Leave Participation'**
  String get leaveParticipation;

  /// No description provided for @joinTournament.
  ///
  /// In en, this message translates to:
  /// **'Join Tournament'**
  String get joinTournament;

  /// No description provided for @registrationClosed.
  ///
  /// In en, this message translates to:
  /// **'Registration Closed'**
  String get registrationClosed;

  /// No description provided for @editParticipation.
  ///
  /// In en, this message translates to:
  /// **'Edit Participation'**
  String get editParticipation;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friend;

  /// No description provided for @searchLocations.
  ///
  /// In en, this message translates to:
  /// **'Search locations...'**
  String get searchLocations;

  /// No description provided for @noLocationsFound.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocationsFound;

  /// No description provided for @courtsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Courts available'**
  String get courtsAvailable;

  /// No description provided for @addNewLocation.
  ///
  /// In en, this message translates to:
  /// **'Add New Location'**
  String get addNewLocation;

  /// No description provided for @selectCategories.
  ///
  /// In en, this message translates to:
  /// **'Select Categories'**
  String get selectCategories;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Categories Available'**
  String get noCategoriesAvailable;

  /// No description provided for @partnerRequired.
  ///
  /// In en, this message translates to:
  /// **'Partner required for {category}. Skipped.'**
  String partnerRequired(Object category);

  /// No description provided for @participationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Participation updated successfully'**
  String get participationUpdated;

  /// No description provided for @errorUpdatingParticipation.
  ///
  /// In en, this message translates to:
  /// **'Error updating participation: {error}'**
  String errorUpdatingParticipation(Object error);

  /// No description provided for @youHaveLeftTournament.
  ///
  /// In en, this message translates to:
  /// **'You have left the tournament'**
  String get youHaveLeftTournament;

  /// No description provided for @errorLeavingTournament.
  ///
  /// In en, this message translates to:
  /// **'Error leaving tournament: {error}'**
  String errorLeavingTournament(Object error);

  /// No description provided for @reorderPlayers.
  ///
  /// In en, this message translates to:
  /// **'Order Players - {category}'**
  String reorderPlayers(Object category);

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Players are paired from top to bottom (1 vs 2, 3 vs 4, etc.)'**
  String get dragToReorder;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get enterName;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @selectDates.
  ///
  /// In en, this message translates to:
  /// **'Select Dates'**
  String get selectDates;

  /// No description provided for @coverImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Cover Image URL'**
  String get coverImageUrl;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @selectFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Select from Library'**
  String get selectFromLibrary;

  /// No description provided for @tournamentCreated.
  ///
  /// In en, this message translates to:
  /// **'Tournament Created!'**
  String get tournamentCreated;

  /// No description provided for @pleaseSelectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Please select a date range'**
  String get pleaseSelectDateRange;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a location'**
  String get pleaseSelectLocation;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @mine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mine;

  /// No description provided for @participating.
  ///
  /// In en, this message translates to:
  /// **'Participating'**
  String get participating;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @yours.
  ///
  /// In en, this message translates to:
  /// **'YOURS'**
  String get yours;

  /// No description provided for @hostedBy.
  ///
  /// In en, this message translates to:
  /// **'Hosted by {name}'**
  String hostedBy(String name);

  /// No description provided for @mensSingles.
  ///
  /// In en, this message translates to:
  /// **'Men\'s Singles'**
  String get mensSingles;

  /// No description provided for @womensSingles.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Singles'**
  String get womensSingles;

  /// No description provided for @doubles.
  ///
  /// In en, this message translates to:
  /// **'Doubles'**
  String get doubles;

  /// No description provided for @noTournamentsFound.
  ///
  /// In en, this message translates to:
  /// **'No tournaments found'**
  String get noTournamentsFound;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get purchasesRestored;

  /// No description provided for @confirmCancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get confirmCancelSubscription;

  /// No description provided for @cancelSubscriptionWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? Used features will be lost.'**
  String get cancelSubscriptionWarning;

  /// No description provided for @simulation.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get simulation;

  /// No description provided for @sharePreview.
  ///
  /// In en, this message translates to:
  /// **'Share Preview'**
  String get sharePreview;

  /// No description provided for @backgroundBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get backgroundBlue;

  /// No description provided for @backgroundRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get backgroundRed;

  /// No description provided for @backgroundYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get backgroundYellow;

  /// No description provided for @backgroundNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get backgroundNone;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @noParticipantsYet.
  ///
  /// In en, this message translates to:
  /// **'No participants yet.'**
  String get noParticipantsYet;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(Object error);

  /// No description provided for @playersJoined.
  ///
  /// In en, this message translates to:
  /// **'{count} Players joined'**
  String playersJoined(Object count);

  /// No description provided for @shareBracket.
  ///
  /// In en, this message translates to:
  /// **'Share Bracket'**
  String get shareBracket;

  /// No description provided for @shareMatch.
  ///
  /// In en, this message translates to:
  /// **'Check out this match!'**
  String get shareMatch;

  /// No description provided for @tournamentBracket.
  ///
  /// In en, this message translates to:
  /// **'Tournament Bracket'**
  String get tournamentBracket;

  /// No description provided for @tbd.
  ///
  /// In en, this message translates to:
  /// **'TBD'**
  String get tbd;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @noCategoriesCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'No categories found. Please create a category first.'**
  String get noCategoriesCreateFirst;

  /// No description provided for @noMatchesForDay.
  ///
  /// In en, this message translates to:
  /// **'No matches for this day'**
  String get noMatchesForDay;

  /// No description provided for @addExistingUsers.
  ///
  /// In en, this message translates to:
  /// **'Add Existing Users'**
  String get addExistingUsers;

  /// No description provided for @selectFromRegisteredUsers.
  ///
  /// In en, this message translates to:
  /// **'Select from registered users'**
  String get selectFromRegisteredUsers;

  /// No description provided for @addManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Manual Entry'**
  String get addManualEntry;

  /// No description provided for @forGuestsOrNonAppUsers.
  ///
  /// In en, this message translates to:
  /// **'For guests or non-app users'**
  String get forGuestsOrNonAppUsers;

  /// No description provided for @addParticipants.
  ///
  /// In en, this message translates to:
  /// **'Add Participants'**
  String get addParticipants;

  /// No description provided for @selectCategoriesColon.
  ///
  /// In en, this message translates to:
  /// **'Select Categories:'**
  String get selectCategoriesColon;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// No description provided for @addCount.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String addCount(Object count);

  /// No description provided for @addedParticipants.
  ///
  /// In en, this message translates to:
  /// **'Added {count} participants'**
  String addedParticipants(Object count);

  /// No description provided for @alreadyInCategories.
  ///
  /// In en, this message translates to:
  /// **'Selected participants are already in selected categories'**
  String get alreadyInCategories;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @addDate.
  ///
  /// In en, this message translates to:
  /// **'Add Date'**
  String get addDate;

  /// No description provided for @selectDateToMarkAvailability.
  ///
  /// In en, this message translates to:
  /// **'Select a date to mark availability'**
  String get selectDateToMarkAvailability;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get editLocation;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @storageLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Storage Limit Reached'**
  String get storageLimitReached;

  /// No description provided for @storageLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You have reached the 15 MB storage limit. Please delete some files to upload more.'**
  String get storageLimitMessage;

  /// No description provided for @storageUsedOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit}'**
  String storageUsedOfLimit(Object limit, Object used);

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(Object current, Object total);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @myAvailability.
  ///
  /// In en, this message translates to:
  /// **'My Availability'**
  String get myAvailability;

  /// No description provided for @noLocationsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No locations added yet.'**
  String get noLocationsAddedYet;

  /// No description provided for @deleteLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Location?'**
  String get deleteLocationTitle;

  /// No description provided for @deleteLocationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteLocationConfirm(Object name);

  /// No description provided for @scheduleSettings.
  ///
  /// In en, this message translates to:
  /// **'Schedule Settings'**
  String get scheduleSettings;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @bulkApply.
  ///
  /// In en, this message translates to:
  /// **'Bulk Apply'**
  String get bulkApply;

  /// No description provided for @bulkApplySettings.
  ///
  /// In en, this message translates to:
  /// **'Bulk Apply Settings'**
  String get bulkApplySettings;

  /// No description provided for @applySettingsToAllDays.
  ///
  /// In en, this message translates to:
  /// **'Apply these settings to ALL days:'**
  String get applySettingsToAllDays;

  /// No description provided for @applyAll.
  ///
  /// In en, this message translates to:
  /// **'Apply All'**
  String get applyAll;

  /// No description provided for @dateAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Date already exists'**
  String get dateAlreadyExists;

  /// No description provided for @scheduleSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Schedule settings saved'**
  String get scheduleSettingsSaved;

  /// No description provided for @notEnoughParticipants.
  ///
  /// In en, this message translates to:
  /// **'Not enough approved participants'**
  String get notEnoughParticipants;

  /// No description provided for @generatedMatches.
  ///
  /// In en, this message translates to:
  /// **'Generated {count} matches!'**
  String generatedMatches(Object count);

  /// No description provided for @bracketDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bracket deleted'**
  String get bracketDeleted;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @invitePlayers.
  ///
  /// In en, this message translates to:
  /// **'Invite Players'**
  String get invitePlayers;

  /// No description provided for @tournamentOptions.
  ///
  /// In en, this message translates to:
  /// **'Tournament Options'**
  String get tournamentOptions;

  /// No description provided for @tournamentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Tournament not found'**
  String get tournamentNotFound;

  /// No description provided for @metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get metadata;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @mataMataElimination.
  ///
  /// In en, this message translates to:
  /// **'Mata-Mata (Elimination)'**
  String get mataMataElimination;

  /// No description provided for @openTennisGroups.
  ///
  /// In en, this message translates to:
  /// **'Open Tennis (Groups)'**
  String get openTennisGroups;

  /// No description provided for @openTennisMode.
  ///
  /// In en, this message translates to:
  /// **'Open Tennis Mode'**
  String get openTennisMode;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @errorAddingParticipants.
  ///
  /// In en, this message translates to:
  /// **'Error adding participants: {error}'**
  String errorAddingParticipants(Object error);

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit {date}'**
  String editSchedule(Object date);

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @numberOfCourts.
  ///
  /// In en, this message translates to:
  /// **'Number of Courts'**
  String get numberOfCourts;

  /// No description provided for @tournamentMode.
  ///
  /// In en, this message translates to:
  /// **'Tournament Mode'**
  String get tournamentMode;

  /// No description provided for @mataMataDescription.
  ///
  /// In en, this message translates to:
  /// **'Direct elimination: lose once and you\'re out'**
  String get mataMataDescription;

  /// No description provided for @openTennisDescription.
  ///
  /// In en, this message translates to:
  /// **'Round-robin groups + playoff bracket'**
  String get openTennisDescription;

  /// No description provided for @openTennisExplanation.
  ///
  /// In en, this message translates to:
  /// **'Players are divided into groups. Each player plays against all others in their group. Points are awarded for wins. Top players from each group advance to the playoff bracket.'**
  String get openTennisExplanation;

  /// No description provided for @numberOfGroups.
  ///
  /// In en, this message translates to:
  /// **'Max Players per Group'**
  String get numberOfGroups;

  /// No description provided for @autoGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'Recommended: 3–4 players per group'**
  String get autoGroupsHint;

  /// No description provided for @pointsPerWin.
  ///
  /// In en, this message translates to:
  /// **'Points per Win'**
  String get pointsPerWin;

  /// No description provided for @pointsPerWinHint.
  ///
  /// In en, this message translates to:
  /// **'Points awarded for each victory'**
  String get pointsPerWinHint;

  /// No description provided for @noMatchesGenerated.
  ///
  /// In en, this message translates to:
  /// **'No matches generated yet.'**
  String get noMatchesGenerated;

  /// No description provided for @noMatchesNoPlayers.
  ///
  /// In en, this message translates to:
  /// **'No matches generated and no players in this category yet.'**
  String get noMatchesNoPlayers;

  /// No description provided for @errorLoadingPlayers.
  ///
  /// In en, this message translates to:
  /// **'Error loading players: {error}'**
  String errorLoadingPlayers(Object error);

  /// No description provided for @editInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Info'**
  String get editInfo;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @clearBracket.
  ///
  /// In en, this message translates to:
  /// **'Clear Bracket'**
  String get clearBracket;

  /// No description provided for @deleteTournamentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Tournament'**
  String get deleteTournamentTitle;

  /// No description provided for @deleteBracketTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Bracket?'**
  String get deleteBracketTitle;

  /// No description provided for @deleteTournamentWarning.
  ///
  /// In en, this message translates to:
  /// **'This will delete everything. Cannot be undone.'**
  String get deleteTournamentWarning;

  /// No description provided for @deleteBracketWarning.
  ///
  /// In en, this message translates to:
  /// **'This will delete all matches. Cannot be undone.'**
  String get deleteBracketWarning;

  /// No description provided for @singles.
  ///
  /// In en, this message translates to:
  /// **'Singles'**
  String get singles;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @pointsPerWinLabel.
  ///
  /// In en, this message translates to:
  /// **'Points per win: {count}'**
  String pointsPerWinLabel(Object count);

  /// No description provided for @generatePlayoffBracket.
  ///
  /// In en, this message translates to:
  /// **'Generate Playoff Bracket'**
  String get generatePlayoffBracket;

  /// No description provided for @playoffBracketGenerated.
  ///
  /// In en, this message translates to:
  /// **'Playoff bracket generated! Group stage complete.'**
  String get playoffBracketGenerated;

  /// No description provided for @noStandingsYet.
  ///
  /// In en, this message translates to:
  /// **'No standings yet. Generate bracket to create groups.'**
  String get noStandingsYet;

  /// No description provided for @groupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group {id}'**
  String groupLabel(Object id);

  /// No description provided for @standings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get standings;

  /// No description provided for @winsShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get winsShort;

  /// No description provided for @lossesShort.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get lossesShort;

  /// No description provided for @playedShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get playedShort;

  /// No description provided for @pointsShort.
  ///
  /// In en, this message translates to:
  /// **'Pts'**
  String get pointsShort;

  /// No description provided for @generatingPlayoffBracket.
  ///
  /// In en, this message translates to:
  /// **'Generating playoff bracket...'**
  String get generatingPlayoffBracket;

  /// No description provided for @playoffBracketCreated.
  ///
  /// In en, this message translates to:
  /// **'Playoff bracket created with {count} matches!'**
  String playoffBracketCreated(Object count);

  /// No description provided for @errorGeneratingPlayoff.
  ///
  /// In en, this message translates to:
  /// **'Error generating playoff: {error}'**
  String errorGeneratingPlayoff(Object error);

  /// No description provided for @shareGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Share Group {id}'**
  String shareGroupLabel(Object id);

  /// No description provided for @advanceFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Advance from Group'**
  String get advanceFromGroup;

  /// No description provided for @advanceFromGroupHint.
  ///
  /// In en, this message translates to:
  /// **'How many players from each group advance to playoff'**
  String get advanceFromGroupHint;

  /// No description provided for @playersInCategory.
  ///
  /// In en, this message translates to:
  /// **'Players in this category ({count}):'**
  String playersInCategory(Object count);

  /// No description provided for @tournamentInProgress.
  ///
  /// In en, this message translates to:
  /// **'Tournament is in progress. Participation changes are locked.'**
  String get tournamentInProgress;

  /// No description provided for @tournamentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tournament is completed. Participation changes are locked.'**
  String get tournamentCompleted;

  /// No description provided for @freePlanTournament.
  ///
  /// In en, this message translates to:
  /// **'Free Plan Tournament'**
  String get freePlanTournament;

  /// No description provided for @searchTournament.
  ///
  /// In en, this message translates to:
  /// **'Search tournaments...'**
  String get searchTournament;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filter;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @matchNotifications.
  ///
  /// In en, this message translates to:
  /// **'Match Notifications'**
  String get matchNotifications;

  /// No description provided for @matchScheduleChanges.
  ///
  /// In en, this message translates to:
  /// **'Schedule Changes'**
  String get matchScheduleChanges;

  /// No description provided for @matchScheduleChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'When a match date or time changes'**
  String get matchScheduleChangesDesc;

  /// No description provided for @matchResultsNotif.
  ///
  /// In en, this message translates to:
  /// **'Match Results'**
  String get matchResultsNotif;

  /// No description provided for @matchResultsNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'When a match you\'re in is completed'**
  String get matchResultsNotifDesc;

  /// No description provided for @socialNotifications.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get socialNotifications;

  /// No description provided for @followedUpdatesNotif.
  ///
  /// In en, this message translates to:
  /// **'Followed Updates'**
  String get followedUpdatesNotif;

  /// No description provided for @followedUpdatesNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Updates on matches and players you follow'**
  String get followedUpdatesNotifDesc;

  /// No description provided for @otherNotifications.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherNotifications;

  /// No description provided for @generalAnnouncementsNotif.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get generalAnnouncementsNotif;

  /// No description provided for @generalAnnouncementsNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Tournament news and general updates'**
  String get generalAnnouncementsNotifDesc;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @ptsPerWin.
  ///
  /// In en, this message translates to:
  /// **'Pts/Win'**
  String get ptsPerWin;

  /// No description provided for @defaultSchedule.
  ///
  /// In en, this message translates to:
  /// **'Default Schedule'**
  String get defaultSchedule;

  /// No description provided for @selectWeekdayTimes.
  ///
  /// In en, this message translates to:
  /// **'Select default days and times'**
  String get selectWeekdayTimes;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @shareOnTwitter.
  ///
  /// In en, this message translates to:
  /// **'Share on X (Twitter)'**
  String get shareOnTwitter;

  /// No description provided for @shareOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get shareOnWhatsApp;

  /// No description provided for @downloadImage.
  ///
  /// In en, this message translates to:
  /// **'Download Image'**
  String get downloadImage;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully!'**
  String get imageSaved;

  /// No description provided for @errorSavingImage.
  ///
  /// In en, this message translates to:
  /// **'Error saving image: {error}'**
  String errorSavingImage(Object error);

  /// No description provided for @imageDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Image downloaded!'**
  String get imageDownloaded;

  /// No description provided for @imageCopied.
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard!'**
  String get imageCopied;

  /// No description provided for @errorCopying.
  ///
  /// In en, this message translates to:
  /// **'Error copying: {error}'**
  String errorCopying(Object error);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @helpAndGuide.
  ///
  /// In en, this message translates to:
  /// **'Help & Guide'**
  String get helpAndGuide;

  /// No description provided for @selectCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Select Custom Color'**
  String get selectCustomColor;

  /// No description provided for @joinTournamentShare.
  ///
  /// In en, this message translates to:
  /// **'Join {name} on EntreSets!'**
  String joinTournamentShare(Object name);

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category Name (e.g. Men\'s A)'**
  String get categoryNameHint;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @configureAvailableTimes.
  ///
  /// In en, this message translates to:
  /// **'Configure available times.'**
  String get configureAvailableTimes;

  /// No description provided for @metadataJson.
  ///
  /// In en, this message translates to:
  /// **'Metadata (JSON)'**
  String get metadataJson;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image: {error}'**
  String errorUploadingImage(Object error);

  /// No description provided for @errorDeletingImage.
  ///
  /// In en, this message translates to:
  /// **'Error deleting image: {error}'**
  String errorDeletingImage(Object error);

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get changeStatus;

  /// No description provided for @nSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String nSelected(Object count);

  /// No description provided for @updatedMatchesStatus.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} matches to {status}'**
  String updatedMatchesStatus(Object count, Object status);

  /// No description provided for @errorUpdatingMatches.
  ///
  /// In en, this message translates to:
  /// **'Error updating matches: {error}'**
  String errorUpdatingMatches(Object error);

  /// No description provided for @markScheduled.
  ///
  /// In en, this message translates to:
  /// **'Mark Scheduled'**
  String get markScheduled;

  /// No description provided for @markConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Mark Confirmed'**
  String get markConfirmed;

  /// No description provided for @markStarted.
  ///
  /// In en, this message translates to:
  /// **'Mark Started'**
  String get markStarted;

  /// No description provided for @markFinished.
  ///
  /// In en, this message translates to:
  /// **'Mark Finished'**
  String get markFinished;

  /// No description provided for @markCancelled.
  ///
  /// In en, this message translates to:
  /// **'Mark Cancelled'**
  String get markCancelled;

  /// No description provided for @tournamentScenarios.
  ///
  /// In en, this message translates to:
  /// **'Tournament Scenarios'**
  String get tournamentScenarios;

  /// No description provided for @tournamentScenariosDesc.
  ///
  /// In en, this message translates to:
  /// **'Create tournaments with pre-filled data to test bracket generation and user flows.'**
  String get tournamentScenariosDesc;

  /// No description provided for @openTennisRoundRobinDesc.
  ///
  /// In en, this message translates to:
  /// **'Round-robin groups with playoff bracket for group winners.'**
  String get openTennisRoundRobinDesc;

  /// No description provided for @simulationCreated.
  ///
  /// In en, this message translates to:
  /// **'Simulation \"{name}\" created successfully!'**
  String simulationCreated(Object name);

  /// No description provided for @openTennisCreated.
  ///
  /// In en, this message translates to:
  /// **'Open Tennis \"{name}\" created successfully!'**
  String openTennisCreated(Object name);

  /// No description provided for @simSmallTitle.
  ///
  /// In en, this message translates to:
  /// **'Small Tournament'**
  String get simSmallTitle;

  /// No description provided for @simSmallDesc.
  ///
  /// In en, this message translates to:
  /// **'4 Players, 1 Category. Simple bracket.'**
  String get simSmallDesc;

  /// No description provided for @simStandardTitle.
  ///
  /// In en, this message translates to:
  /// **'Standard Tournament'**
  String get simStandardTitle;

  /// No description provided for @simStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'8 Players, 1 Category. Quarter-finals start.'**
  String get simStandardDesc;

  /// No description provided for @simLargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Large Tournament'**
  String get simLargeTitle;

  /// No description provided for @simLargeDesc.
  ///
  /// In en, this message translates to:
  /// **'16 Players, 1 Category. Round of 16.'**
  String get simLargeDesc;

  /// No description provided for @simOddTitle.
  ///
  /// In en, this message translates to:
  /// **'Odd Players (Byes)'**
  String get simOddTitle;

  /// No description provided for @simOddDesc.
  ///
  /// In en, this message translates to:
  /// **'5 Players. Tests bye generation logic.'**
  String get simOddDesc;

  /// No description provided for @simMultiTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-Category'**
  String get simMultiTitle;

  /// No description provided for @simMultiDesc.
  ///
  /// In en, this message translates to:
  /// **'2 Categories, 4 Players each (Total 8).'**
  String get simMultiDesc;

  /// No description provided for @simOT4Title.
  ///
  /// In en, this message translates to:
  /// **'Open Tennis - 4 Players'**
  String get simOT4Title;

  /// No description provided for @simOT4Desc.
  ///
  /// In en, this message translates to:
  /// **'2 Groups, 3 points/win. Round-robin groups.'**
  String get simOT4Desc;

  /// No description provided for @simOT6Title.
  ///
  /// In en, this message translates to:
  /// **'Open Tennis - 6 Players'**
  String get simOT6Title;

  /// No description provided for @simOT6Desc.
  ///
  /// In en, this message translates to:
  /// **'2 Groups, 3 points/win. 3 players per group.'**
  String get simOT6Desc;

  /// No description provided for @simOT8_2gTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Tennis - 8 Players (2 Groups)'**
  String get simOT8_2gTitle;

  /// No description provided for @simOT8_2gDesc.
  ///
  /// In en, this message translates to:
  /// **'2 Groups, 3 points/win. 4 players per group.'**
  String get simOT8_2gDesc;

  /// No description provided for @simOT8_4gTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Tennis - 8 Players (4 Groups)'**
  String get simOT8_4gTitle;

  /// No description provided for @simOT8_4gDesc.
  ///
  /// In en, this message translates to:
  /// **'4 Groups, 3 points/win. 2 players per group.'**
  String get simOT8_4gDesc;

  /// No description provided for @americanoCreated.
  ///
  /// In en, this message translates to:
  /// **'Americano \"{name}\" created successfully!'**
  String americanoCreated(String name);

  /// No description provided for @americanoRoundRobinDesc.
  ///
  /// In en, this message translates to:
  /// **'Players play guaranteed cross-group rounds. Top 2 per group play a decider match.'**
  String get americanoRoundRobinDesc;

  /// No description provided for @simAm8Title.
  ///
  /// In en, this message translates to:
  /// **'Americano - 8 Players'**
  String get simAm8Title;

  /// No description provided for @simAm8Desc.
  ///
  /// In en, this message translates to:
  /// **'2 groups of 4, 5 guaranteed matches. Deciders + final bracket.'**
  String get simAm8Desc;

  /// No description provided for @simAm16Title.
  ///
  /// In en, this message translates to:
  /// **'Americano - 16 Players'**
  String get simAm16Title;

  /// No description provided for @simAm16Desc.
  ///
  /// In en, this message translates to:
  /// **'4 groups of 4, 5 guaranteed matches. Deciders + final bracket.'**
  String get simAm16Desc;

  /// No description provided for @simAm12Title.
  ///
  /// In en, this message translates to:
  /// **'Americano - 12 Players'**
  String get simAm12Title;

  /// No description provided for @simAm12Desc.
  ///
  /// In en, this message translates to:
  /// **'3 groups of 4, 5 guaranteed matches. Deciders + final bracket.'**
  String get simAm12Desc;

  /// No description provided for @addResults.
  ///
  /// In en, this message translates to:
  /// **'Add Results'**
  String get addResults;

  /// No description provided for @selectWinner.
  ///
  /// In en, this message translates to:
  /// **'Select Winner'**
  String get selectWinner;

  /// No description provided for @resultsAdded.
  ///
  /// In en, this message translates to:
  /// **'Results added successfully!'**
  String get resultsAdded;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// No description provided for @tutorialDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tutorialDone;

  /// No description provided for @tutorialWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Entre Sets'**
  String get tutorialWelcomeTitle;

  /// No description provided for @tutorialWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize and join tennis tournaments with ease.'**
  String get tutorialWelcomeSubtitle;

  /// No description provided for @tutorialFindTournamentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Tournaments'**
  String get tutorialFindTournamentsTitle;

  /// No description provided for @tutorialFindTournamentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse, filter, and register for tournaments near you.'**
  String get tutorialFindTournamentsSubtitle;

  /// No description provided for @tutorialTrackMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Matches'**
  String get tutorialTrackMatchesTitle;

  /// No description provided for @tutorialTrackMatchesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get your schedule, confirm attendance, and follow results live.'**
  String get tutorialTrackMatchesSubtitle;

  /// No description provided for @tutorialReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Play?'**
  String get tutorialReadyTitle;

  /// No description provided for @tutorialStartTour.
  ///
  /// In en, this message translates to:
  /// **'Start Tour'**
  String get tutorialStartTour;

  /// No description provided for @tutorialSkipLetMeIn.
  ///
  /// In en, this message translates to:
  /// **'Skip, let me in'**
  String get tutorialSkipLetMeIn;

  /// No description provided for @tutorialReplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay Tutorial'**
  String get tutorialReplayTitle;

  /// No description provided for @tutorialReplayPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player Tour'**
  String get tutorialReplayPlayer;

  /// No description provided for @tutorialReplayWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get tutorialReplayWelcome;

  /// No description provided for @tutorialTournamentsTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tutorialTournamentsTabTitle;

  /// No description provided for @tutorialTournamentsTabBody.
  ///
  /// In en, this message translates to:
  /// **'Your home base. Browse all available tournaments, filter by status, and find your next match.'**
  String get tutorialTournamentsTabBody;

  /// No description provided for @tutorialScheduleTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get tutorialScheduleTabTitle;

  /// No description provided for @tutorialScheduleTabBody.
  ///
  /// In en, this message translates to:
  /// **'Your personal match calendar. See upcoming matches you\'re in or following, organized by date.'**
  String get tutorialScheduleTabBody;

  /// No description provided for @tutorialProfileTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tutorialProfileTabTitle;

  /// No description provided for @tutorialProfileTabBody.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile, set your playing level, check your stats, and adjust preferences.'**
  String get tutorialProfileTabBody;

  /// No description provided for @tutorialSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tutorialSearchTitle;

  /// No description provided for @tutorialSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Search tournaments by name to quickly find what you\'re looking for.'**
  String get tutorialSearchBody;

  /// No description provided for @tutorialFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get tutorialFilterTitle;

  /// No description provided for @tutorialFilterBody.
  ///
  /// In en, this message translates to:
  /// **'Narrow results by status: your tournaments, participating, singles, doubles, or open registration.'**
  String get tutorialFilterBody;

  /// No description provided for @tutorialTournamentCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Tournament Card'**
  String get tutorialTournamentCardTitle;

  /// No description provided for @tutorialTournamentCardBody.
  ///
  /// In en, this message translates to:
  /// **'Each card shows name, cover image, status, player count, and dates. Tap to see full details.'**
  String get tutorialTournamentCardBody;

  /// No description provided for @tutorialCreateTournamentTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Tournament'**
  String get tutorialCreateTournamentTitle;

  /// No description provided for @tutorialCreateTournamentBody.
  ///
  /// In en, this message translates to:
  /// **'Tap here to create and organize your own tournament.'**
  String get tutorialCreateTournamentBody;

  /// No description provided for @tutorialInfoTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get tutorialInfoTabTitle;

  /// No description provided for @tutorialInfoTabBody.
  ///
  /// In en, this message translates to:
  /// **'Tournament description, format, categories, location, and participants list.'**
  String get tutorialInfoTabBody;

  /// No description provided for @tutorialBracketTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Bracket'**
  String get tutorialBracketTabTitle;

  /// No description provided for @tutorialBracketTabBody.
  ///
  /// In en, this message translates to:
  /// **'Once generated, view the full match bracket here. Tap any match for details.'**
  String get tutorialBracketTabBody;

  /// No description provided for @tutorialCalendarTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tutorialCalendarTabTitle;

  /// No description provided for @tutorialCalendarTabBody.
  ///
  /// In en, this message translates to:
  /// **'See all scheduled matches on a calendar. Dates with matches are marked.'**
  String get tutorialCalendarTabBody;

  /// No description provided for @tutorialShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get tutorialShareTitle;

  /// No description provided for @tutorialShareBody.
  ///
  /// In en, this message translates to:
  /// **'Share a link so players can find and register. Opens directly in the app if installed.'**
  String get tutorialShareBody;

  /// No description provided for @tutorialAdminSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Settings'**
  String get tutorialAdminSettingsTitle;

  /// No description provided for @tutorialAdminSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Manage your tournament: edit info, participants, categories, schedule, brackets, and co-admins.'**
  String get tutorialAdminSettingsBody;

  /// No description provided for @matchRules.
  ///
  /// In en, this message translates to:
  /// **'Match Rules'**
  String get matchRules;

  /// No description provided for @matchRulesPreset.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get matchRulesPreset;

  /// No description provided for @presetQuickMatch.
  ///
  /// In en, this message translates to:
  /// **'Quick Match'**
  String get presetQuickMatch;

  /// No description provided for @presetStandardAmateur.
  ///
  /// In en, this message translates to:
  /// **'Standard Amateur'**
  String get presetStandardAmateur;

  /// No description provided for @presetFullMatch.
  ///
  /// In en, this message translates to:
  /// **'Full Match'**
  String get presetFullMatch;

  /// No description provided for @presetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get presetCustom;

  /// No description provided for @scoringFormat.
  ///
  /// In en, this message translates to:
  /// **'Scoring'**
  String get scoringFormat;

  /// No description provided for @setsToWin.
  ///
  /// In en, this message translates to:
  /// **'Sets to win'**
  String get setsToWin;

  /// No description provided for @gamesPerSet.
  ///
  /// In en, this message translates to:
  /// **'Games per set'**
  String get gamesPerSet;

  /// No description provided for @advantage.
  ///
  /// In en, this message translates to:
  /// **'Advantage (deuce)'**
  String get advantage;

  /// No description provided for @tiebreakAtSetEnd.
  ///
  /// In en, this message translates to:
  /// **'Tiebreak at set end'**
  String get tiebreakAtSetEnd;

  /// No description provided for @tiebreakPoints.
  ///
  /// In en, this message translates to:
  /// **'Tiebreak points'**
  String get tiebreakPoints;

  /// No description provided for @finalSetMatchTiebreak.
  ///
  /// In en, this message translates to:
  /// **'Final set is match tiebreak'**
  String get finalSetMatchTiebreak;

  /// No description provided for @matchTiebreakPoints.
  ///
  /// In en, this message translates to:
  /// **'Match tiebreak points'**
  String get matchTiebreakPoints;

  /// No description provided for @timeRules.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeRules;

  /// No description provided for @matchDurationLimit.
  ///
  /// In en, this message translates to:
  /// **'Duration limit'**
  String get matchDurationLimit;

  /// No description provided for @matchDurationMinutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String matchDurationMinutesValue(int minutes);

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @warmupTime.
  ///
  /// In en, this message translates to:
  /// **'Warm-up'**
  String get warmupTime;

  /// No description provided for @restBetweenSets.
  ///
  /// In en, this message translates to:
  /// **'Rest between sets'**
  String get restBetweenSets;

  /// No description provided for @changeoverTime.
  ///
  /// In en, this message translates to:
  /// **'Changeover'**
  String get changeoverTime;

  /// No description provided for @changeoverSecondsValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String changeoverSecondsValue(int seconds);

  /// No description provided for @courtAndConduct.
  ///
  /// In en, this message translates to:
  /// **'Court & Conduct'**
  String get courtAndConduct;

  /// No description provided for @selfRefereeing.
  ///
  /// In en, this message translates to:
  /// **'Self-refereeing'**
  String get selfRefereeing;

  /// No description provided for @letServeReplayed.
  ///
  /// In en, this message translates to:
  /// **'Let serve replayed'**
  String get letServeReplayed;

  /// No description provided for @codeOfConduct.
  ///
  /// In en, this message translates to:
  /// **'Code of conduct'**
  String get codeOfConduct;

  /// No description provided for @conductEnforce.
  ///
  /// In en, this message translates to:
  /// **'Enforce'**
  String get conductEnforce;

  /// No description provided for @conductRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get conductRelaxed;

  /// No description provided for @ballType.
  ///
  /// In en, this message translates to:
  /// **'Ball type'**
  String get ballType;

  /// No description provided for @walkoverAndNoShow.
  ///
  /// In en, this message translates to:
  /// **'Walkover & No-Show'**
  String get walkoverAndNoShow;

  /// No description provided for @confirmationDeadline.
  ///
  /// In en, this message translates to:
  /// **'Confirmation deadline'**
  String get confirmationDeadline;

  /// No description provided for @confirmationHoursBefore.
  ///
  /// In en, this message translates to:
  /// **'{hours}h before'**
  String confirmationHoursBefore(int hours);

  /// No description provided for @noShowGracePeriod.
  ///
  /// In en, this message translates to:
  /// **'No-show grace period'**
  String get noShowGracePeriod;

  /// No description provided for @noShowResult.
  ///
  /// In en, this message translates to:
  /// **'No-show result'**
  String get noShowResult;

  /// No description provided for @noShowWalkover.
  ///
  /// In en, this message translates to:
  /// **'Walkover (W.O.)'**
  String get noShowWalkover;

  /// No description provided for @noShowReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get noShowReschedule;

  /// No description provided for @rulesScoringSummary.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets to {games} games'**
  String rulesScoringSummary(int sets, int games);

  /// No description provided for @rulesNoAdvantage.
  ///
  /// In en, this message translates to:
  /// **'No advantage'**
  String get rulesNoAdvantage;

  /// No description provided for @rulesAdvantage.
  ///
  /// In en, this message translates to:
  /// **'Advantage'**
  String get rulesAdvantage;

  /// No description provided for @rulesTiebreakTo.
  ///
  /// In en, this message translates to:
  /// **'Tiebreak to {points}'**
  String rulesTiebreakTo(int points);

  /// No description provided for @rulesFinalSetTiebreak.
  ///
  /// In en, this message translates to:
  /// **'Final set: Match tiebreak to {points}'**
  String rulesFinalSetTiebreak(int points);

  /// No description provided for @rulesMatchLimit.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min limit'**
  String rulesMatchLimit(int minutes);

  /// No description provided for @rulesWarmup.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min warm-up'**
  String rulesWarmup(int minutes);

  /// No description provided for @rulesRestBetweenSets.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min rest between sets'**
  String rulesRestBetweenSets(int minutes);

  /// No description provided for @rulesConfirmBefore.
  ///
  /// In en, this message translates to:
  /// **'Confirm {hours}h before'**
  String rulesConfirmBefore(int hours);

  /// No description provided for @rulesGracePeriod.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min grace'**
  String rulesGracePeriod(int minutes);

  /// No description provided for @rulesWalkoverOnNoShow.
  ///
  /// In en, this message translates to:
  /// **'Walkover on no-show'**
  String get rulesWalkoverOnNoShow;

  /// No description provided for @rulesRescheduleOnNoShow.
  ///
  /// In en, this message translates to:
  /// **'Reschedule on no-show'**
  String get rulesRescheduleOnNoShow;

  /// No description provided for @rulesSelfRefereeing.
  ///
  /// In en, this message translates to:
  /// **'Self-refereeing'**
  String get rulesSelfRefereeing;

  /// No description provided for @rulesLetReplayed.
  ///
  /// In en, this message translates to:
  /// **'Let replayed'**
  String get rulesLetReplayed;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @scoringMode.
  ///
  /// In en, this message translates to:
  /// **'Scoring Mode'**
  String get scoringMode;

  /// No description provided for @flatScoring.
  ///
  /// In en, this message translates to:
  /// **'Flat Scoring'**
  String get flatScoring;

  /// No description provided for @flatScoringDesc.
  ///
  /// In en, this message translates to:
  /// **'Fixed points per win (e.g., 3 pts)'**
  String get flatScoringDesc;

  /// No description provided for @variableScoring.
  ///
  /// In en, this message translates to:
  /// **'Variable Scoring'**
  String get variableScoring;

  /// No description provided for @variableScoringDesc.
  ///
  /// In en, this message translates to:
  /// **'Points vary by set result (2×0, 2×1, W.O.)'**
  String get variableScoringDesc;

  /// No description provided for @matchFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Match Format'**
  String get matchFormatLabel;

  /// No description provided for @roundRobinFormat.
  ///
  /// In en, this message translates to:
  /// **'Round-Robin'**
  String get roundRobinFormat;

  /// No description provided for @roundRobinFormatDesc.
  ///
  /// In en, this message translates to:
  /// **'Each player plays all others in same group'**
  String get roundRobinFormatDesc;

  /// No description provided for @crossGroupFormat.
  ///
  /// In en, this message translates to:
  /// **'Cross-Group'**
  String get crossGroupFormat;

  /// No description provided for @crossGroupFormatDesc.
  ///
  /// In en, this message translates to:
  /// **'Players face opponents from other groups'**
  String get crossGroupFormatDesc;

  /// No description provided for @crossGroupMatches.
  ///
  /// In en, this message translates to:
  /// **'Cross-Group Matches'**
  String get crossGroupMatches;

  /// No description provided for @matchesPerPlayer.
  ///
  /// In en, this message translates to:
  /// **'Cross-group matches per player'**
  String get matchesPerPlayer;

  /// No description provided for @matchesPerPlayerHint.
  ///
  /// In en, this message translates to:
  /// **'Extra matches against opponents from other groups (on top of round-robin within own group)'**
  String get matchesPerPlayerHint;

  /// No description provided for @pointsWin2_0Label.
  ///
  /// In en, this message translates to:
  /// **'Win 2×0'**
  String get pointsWin2_0Label;

  /// No description provided for @pointsWin2_1Label.
  ///
  /// In en, this message translates to:
  /// **'Win 2×1'**
  String get pointsWin2_1Label;

  /// No description provided for @pointsWinWOLabel.
  ///
  /// In en, this message translates to:
  /// **'Win W.O.'**
  String get pointsWinWOLabel;

  /// No description provided for @pointsLoss1_2Label.
  ///
  /// In en, this message translates to:
  /// **'Loss 1×2'**
  String get pointsLoss1_2Label;

  /// No description provided for @pointsLoss0_2Label.
  ///
  /// In en, this message translates to:
  /// **'Loss 0×2'**
  String get pointsLoss0_2Label;

  /// No description provided for @pointsLossWOLabel.
  ///
  /// In en, this message translates to:
  /// **'Loss W.O.'**
  String get pointsLossWOLabel;

  /// No description provided for @pointsAbbrev.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pointsAbbrev;

  /// No description provided for @markAsWalkover.
  ///
  /// In en, this message translates to:
  /// **'Mark as W.O.'**
  String get markAsWalkover;

  /// No description provided for @variableScoringTable.
  ///
  /// In en, this message translates to:
  /// **'W 2×0: {p1} · W 2×1: {p2} · W W.O.: {p3} · L 1×2: {p4}'**
  String variableScoringTable(int p1, int p2, int p3, int p4);

  /// No description provided for @categoryPresetMasculino.
  ///
  /// In en, this message translates to:
  /// **'Men\'s {n}'**
  String categoryPresetMasculino(int n);

  /// No description provided for @categoryPresetFeminino.
  ///
  /// In en, this message translates to:
  /// **'Women\'s {n}'**
  String categoryPresetFeminino(int n);

  /// No description provided for @categoryPresetMista.
  ///
  /// In en, this message translates to:
  /// **'Mixed {n}'**
  String categoryPresetMista(int n);

  /// No description provided for @categoryPresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get categoryPresetCustom;

  /// No description provided for @addCategoriesQuick.
  ///
  /// In en, this message translates to:
  /// **'Add Categories'**
  String get addCategoriesQuick;

  /// No description provided for @categoryPresetHint.
  ///
  /// In en, this message translates to:
  /// **'Select categories to add in bulk'**
  String get categoryPresetHint;

  /// No description provided for @masculine.
  ///
  /// In en, this message translates to:
  /// **'Men\'s'**
  String get masculine;

  /// No description provided for @feminine.
  ///
  /// In en, this message translates to:
  /// **'Women\'s'**
  String get feminine;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixed;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @simulateAndDebug.
  ///
  /// In en, this message translates to:
  /// **'Simulate & Debug'**
  String get simulateAndDebug;

  /// No description provided for @simulateCrossGroup.
  ///
  /// In en, this message translates to:
  /// **'Simulate Cross-Group'**
  String get simulateCrossGroup;

  /// No description provided for @addBotsAndGenerate.
  ///
  /// In en, this message translates to:
  /// **'Add bots and generate matches'**
  String get addBotsAndGenerate;

  /// No description provided for @botCount.
  ///
  /// In en, this message translates to:
  /// **'Number of bots'**
  String get botCount;

  /// No description provided for @simulationStarted.
  ///
  /// In en, this message translates to:
  /// **'Simulation started!'**
  String get simulationStarted;

  /// No description provided for @simulationComplete.
  ///
  /// In en, this message translates to:
  /// **'Simulation complete! {count} matches created.'**
  String simulationComplete(int count);

  /// No description provided for @simulationError.
  ///
  /// In en, this message translates to:
  /// **'Simulation error: {error}'**
  String simulationError(String error);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @deleteBracketBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all matches. Cannot be undone.'**
  String get deleteBracketBody;

  /// No description provided for @deleteTournamentConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will delete everything. Cannot be undone.'**
  String get deleteTournamentConfirm;

  /// No description provided for @americanoMode.
  ///
  /// In en, this message translates to:
  /// **'Americano'**
  String get americanoMode;

  /// No description provided for @americanoGroups.
  ///
  /// In en, this message translates to:
  /// **'Americano (Cross-Group)'**
  String get americanoGroups;

  /// No description provided for @americanoDescription.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed cross-group rounds + group decider + bracket'**
  String get americanoDescription;

  /// No description provided for @americanoExplanation.
  ///
  /// In en, this message translates to:
  /// **'Players are divided into groups and play {matches} guaranteed matches against opponents from other groups. The top 2 from each group play a decider; the winner advances to the final bracket.'**
  String americanoExplanation(int matches);

  /// No description provided for @guaranteedMatches.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed Matches per Player'**
  String get guaranteedMatches;

  /// No description provided for @guaranteedMatchesHint.
  ///
  /// In en, this message translates to:
  /// **'Each player will play exactly this many matches in the group phase'**
  String get guaranteedMatchesHint;

  /// No description provided for @opponentSelectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Opponent Selection'**
  String get opponentSelectionLabel;

  /// No description provided for @randomOpponents.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get randomOpponents;

  /// No description provided for @rankedOpponents.
  ///
  /// In en, this message translates to:
  /// **'By Ranking (Mexicano)'**
  String get rankedOpponents;

  /// No description provided for @generateGroupDeciders.
  ///
  /// In en, this message translates to:
  /// **'Generate Group Deciders'**
  String get generateGroupDeciders;

  /// No description provided for @generateAmericanoPlayoff.
  ///
  /// In en, this message translates to:
  /// **'Generate Final Bracket'**
  String get generateAmericanoPlayoff;

  /// No description provided for @americanoMatchesPhase.
  ///
  /// In en, this message translates to:
  /// **'Americano Phase'**
  String get americanoMatchesPhase;

  /// No description provided for @deciderPhase.
  ///
  /// In en, this message translates to:
  /// **'Group Deciders'**
  String get deciderPhase;

  /// No description provided for @deciderRound.
  ///
  /// In en, this message translates to:
  /// **'Decider Group {id}'**
  String deciderRound(String id);

  /// No description provided for @playoffBracketGeneratedAmericano.
  ///
  /// In en, this message translates to:
  /// **'Final bracket generated! See the Bracket tab.'**
  String get playoffBracketGeneratedAmericano;

  /// No description provided for @groupDecidersGenerated.
  ///
  /// In en, this message translates to:
  /// **'Group deciders generated! {count} matches created.'**
  String groupDecidersGenerated(int count);

  /// No description provided for @errorGeneratingDeciders.
  ///
  /// In en, this message translates to:
  /// **'Error generating deciders: {error}'**
  String errorGeneratingDeciders(String error);

  /// No description provided for @guaranteedMatchesShort.
  ///
  /// In en, this message translates to:
  /// **'guar. matches'**
  String get guaranteedMatchesShort;

  /// No description provided for @ptsPerWinShort.
  ///
  /// In en, this message translates to:
  /// **'pts/win'**
  String get ptsPerWinShort;

  /// No description provided for @skipIntro.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipIntro;

  /// No description provided for @fillRandomResults.
  ///
  /// In en, this message translates to:
  /// **'Random results'**
  String get fillRandomResults;

  /// No description provided for @randomResultsFilled.
  ///
  /// In en, this message translates to:
  /// **'{count} matches filled with random results!'**
  String randomResultsFilled(int count);

  /// No description provided for @youSuffix2.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youSuffix2;

  /// No description provided for @advancingPosition.
  ///
  /// In en, this message translates to:
  /// **'Advancing'**
  String get advancingPosition;

  /// No description provided for @tournamentPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get tournamentPrivate;

  /// No description provided for @tournamentPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get tournamentPublic;

  /// No description provided for @tournamentPrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'Private tournament — not shown in the public list'**
  String get tournamentPrivateDesc;

  /// No description provided for @tournamentPublicDesc.
  ///
  /// In en, this message translates to:
  /// **'Public tournament — visible to everyone'**
  String get tournamentPublicDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
