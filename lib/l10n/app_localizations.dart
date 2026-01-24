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
  /// **'Bracket'**
  String get bracket;

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

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

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
