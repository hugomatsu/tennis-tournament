// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tennis Tournaments';

  @override
  String get home => 'Home';

  @override
  String get schedule => 'Schedule';

  @override
  String get tournaments => 'Tournaments';

  @override
  String get matches => 'Matches';

  @override
  String get noMatchesScheduled => 'No matches scheduled yet.';

  @override
  String get locationTBD => 'Location TBD';

  @override
  String get timeTBD => 'Time TBD';

  @override
  String get youSuffix => ' (You)';

  @override
  String get profile => 'Profile';

  @override
  String get mySchedule => 'My Schedule';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusLive => 'Live';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get matchDetails => 'Match Details';

  @override
  String get adminControls => 'Admin Controls';

  @override
  String get confirmAttendance => 'Confirm Attendance';

  @override
  String get decline => 'Decline';

  @override
  String get confirm => 'Confirm';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get score => 'Score';

  @override
  String get winner => 'Winner';

  @override
  String get runnerUp => 'Runner-Up';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get player1Present => 'Player 1 Present';

  @override
  String get player2Present => 'Player 2 Present';

  @override
  String get youHaveConfirmed => 'You have confirmed attendance.';

  @override
  String get pleaseConfirm => 'Please confirm your attendance.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get name => 'Name';

  @override
  String get title => 'Title';

  @override
  String get bio => 'Bio';

  @override
  String get category => 'Category';

  @override
  String get playingSince => 'Playing Since';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get bracket => 'Progress';

  @override
  String get playoff => 'Playoff';

  @override
  String get calendar => 'Calendar';

  @override
  String get participants => 'Participants';

  @override
  String get info => 'Info';

  @override
  String get generateBracket => 'Generate Bracket';

  @override
  String get automatic => 'Automatic';

  @override
  String get manual => 'Manual';

  @override
  String get generationMethod => 'Generation Method';

  @override
  String get randomlyShuffle => 'Randomly shuffle players';

  @override
  String get reorderManually => 'Reorder players manually';

  @override
  String get deleteBracket => 'Delete Bracket';

  @override
  String get deleteBracketConfirm =>
      'Are you sure you want to delete the bracket? This will wipe all generated matches.';

  @override
  String get managePlayers => 'Manage Players';

  @override
  String get pendingRequests => 'Pending Requests';

  @override
  String get approvedPlayers => 'Approved Players';

  @override
  String get noApprovedPlayers => 'No approved players yet.';

  @override
  String get addParticipant => 'Add Participant';

  @override
  String get myMediaLibrary => 'My Media Library';

  @override
  String get myLibrary => 'My Library';

  @override
  String get storageUsed => 'Storage used';

  @override
  String get upload => 'Upload';

  @override
  String get noImages => 'No images in library';

  @override
  String get pleaseLogIn => 'Please log in';

  @override
  String get joined => 'Joined';

  @override
  String get accept => 'Accept';

  @override
  String get deny => 'Deny';

  @override
  String get remove => 'Remove';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get fileName => 'File Name';

  @override
  String get uploadedAt => 'Uploaded At';

  @override
  String get size => 'Size';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get register => 'Register';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get player => 'Player';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get rank => 'Rank';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get loses => 'Losses';

  @override
  String get points => 'Points';

  @override
  String get createTournament => 'Create Tournament';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get manageLocations => 'Manage Locations';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get description => 'Description';

  @override
  String get tournamentName => 'Tournament Name';

  @override
  String get location => 'Location';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get titleBeginner => 'Beginner';

  @override
  String get titleNovice => 'Novice';

  @override
  String get titleIntermediate => 'Intermediate';

  @override
  String get titleClubPlayer => 'Club Player';

  @override
  String get titleAdvanced => 'Advanced';

  @override
  String get titleSemiPro => 'Semi-Pro';

  @override
  String get titlePro => 'Pro';

  @override
  String get titleCoach => 'Coach';

  @override
  String get titleEnthusiast => 'Enthusiast';

  @override
  String get titleWeekendWarrior => 'Weekend Warrior';

  @override
  String errorOccurred(Object error) {
    return 'Error: $error';
  }

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get pleaseSelectTitle => 'Please select or enter a title';

  @override
  String get round => 'Round';

  @override
  String get create => 'Create';

  @override
  String get findPlayers => 'Find Players';

  @override
  String get searchByName => 'Search by name';

  @override
  String get noPlayersFound => 'No players found';

  @override
  String get playerProfile => 'Player Profile';

  @override
  String get playerNotFound => 'Player not found';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get following => 'Following';

  @override
  String get unknownPlayer => 'Unknown Player';

  @override
  String get about => 'About';

  @override
  String get stats => 'Stats';

  @override
  String get notFollowingAnyone => 'Not following anyone yet.';

  @override
  String get simulationDebug => 'Simulation & Debug';

  @override
  String get matchNotFound => 'Match not found';

  @override
  String get reasonForUnavailability => 'Reason for unavailability';

  @override
  String get declineJustify => 'Decline & Justify';

  @override
  String get submit => 'Submit';

  @override
  String get responseSubmitted => 'Response submitted. Admin notified.';

  @override
  String get attendanceConfirmed => 'Attendance confirmed!';

  @override
  String get status => 'Status';

  @override
  String get viewLocation => 'View Location';

  @override
  String get vs => 'VS';

  @override
  String get loading => 'Loading...';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumBenefits =>
      'Create unlimited tournaments and access exclusive features.';

  @override
  String get freeLimitReached => 'Free Limit Reached';

  @override
  String get freeLimitMessage =>
      'You have reached the limit of 2 free tournaments. Upgrade to Premium to create more!';

  @override
  String get manageAdmins => 'Manage Admins';

  @override
  String get addAdmin => 'Add Admin';

  @override
  String get adminAdded => 'Admin added successfully';

  @override
  String get adminRemoved => 'Admin removed successfully';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribedSuccessfully => 'Subscribed successfully!';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get admins => 'Admins';

  @override
  String get owner => 'Owner';

  @override
  String get removeAdminConfirm =>
      'Are you sure you want to remove this admin?';

  @override
  String get premium => 'Premium';

  @override
  String get free => 'Free';

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get subscriptionCancelled => 'Subscription cancelled';

  @override
  String freeTournamentsUsed(Object count, Object limit) {
    return 'Free Tournaments: $count/$limit';
  }

  @override
  String get limitReached => 'Limit Reached';

  @override
  String get createdUnderFreePlan =>
      'This tournament was created under Free plan';

  @override
  String get premiumPrice => 'Starting at R\$ 29,99/month';

  @override
  String get premiumSupportDev => 'Contributions support development!';

  @override
  String get organizers => 'Organizers';

  @override
  String get noOrganizersListed => 'No organizers listed.';

  @override
  String get failedToLoadOrganizers => 'Failed to load organizers.';

  @override
  String get noCategoriesFound => 'No categories found.';

  @override
  String get errorLoadingCategories => 'Error loading categories';

  @override
  String get myPlan => 'My Plan';

  @override
  String get content => 'Content';

  @override
  String get appAndSettings => 'App & Settings';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get evaluateApp => 'Evaluate App';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyUpdated => 'Last updated: March 17, 2026';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get madeBy => 'Made by';

  @override
  String get editTournament => 'Edit Tournament';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get matchDurationMinutes => 'Match Duration (minutes)';

  @override
  String get selectPartner => 'Select Partner';

  @override
  String get leaveTournament => 'Leave Tournament?';

  @override
  String get leaveTournamentConfirm =>
      'Are you sure you want to leave the tournament completely? This will remove you from all categories.';

  @override
  String get leaveParticipation => 'Leave Participation';

  @override
  String get joinTournament => 'Join Tournament';

  @override
  String get registrationClosed => 'Registration Closed';

  @override
  String get editParticipation => 'Edit Participation';

  @override
  String get leave => 'Leave';

  @override
  String get friend => 'Friend';

  @override
  String get searchLocations => 'Search locations...';

  @override
  String get noLocationsFound => 'No locations found';

  @override
  String get courtsAvailable => 'Courts available';

  @override
  String get addNewLocation => 'Add New Location';

  @override
  String get selectCategories => 'Select Categories';

  @override
  String get noCategoriesAvailable => 'No Categories Available';

  @override
  String partnerRequired(Object category) {
    return 'Partner required for $category. Skipped.';
  }

  @override
  String get participationUpdated => 'Participation updated successfully';

  @override
  String errorUpdatingParticipation(Object error) {
    return 'Error updating participation: $error';
  }

  @override
  String get youHaveLeftTournament => 'You have left the tournament';

  @override
  String errorLeavingTournament(Object error) {
    return 'Error leaving tournament: $error';
  }

  @override
  String reorderPlayers(Object category) {
    return 'Order Players - $category';
  }

  @override
  String get dragToReorder =>
      'Drag to reorder. Players are paired from top to bottom (1 vs 2, 3 vs 4, etc.)';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get enterName => 'Please enter a name';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get dateRange => 'Date Range';

  @override
  String get selectDates => 'Select Dates';

  @override
  String get coverImageUrl => 'Cover Image URL';

  @override
  String get selectImage => 'Select Image';

  @override
  String get selectFromLibrary => 'Select from Library';

  @override
  String get tournamentCreated => 'Tournament Created!';

  @override
  String get pleaseSelectDateRange => 'Please select a date range';

  @override
  String get pleaseSelectLocation => 'Please select a location';

  @override
  String get all => 'All';

  @override
  String get mine => 'Mine';

  @override
  String get participating => 'Participating';

  @override
  String get open => 'Open';

  @override
  String get yours => 'YOURS';

  @override
  String hostedBy(String name) {
    return 'Hosted by $name';
  }

  @override
  String get mensSingles => 'Men\'s Singles';

  @override
  String get womensSingles => 'Women\'s Singles';

  @override
  String get doubles => 'Doubles';

  @override
  String get noTournamentsFound => 'No tournaments found';

  @override
  String get purchasesRestored => 'Purchases restored';

  @override
  String get confirmCancelSubscription => 'Confirm Cancellation';

  @override
  String get cancelSubscriptionWarning =>
      'Are you sure? Used features will be lost.';

  @override
  String get simulation => 'Simulation';

  @override
  String get sharePreview => 'Share Preview';

  @override
  String get backgroundBlue => 'Blue';

  @override
  String get backgroundRed => 'Red';

  @override
  String get backgroundYellow => 'Yellow';

  @override
  String get backgroundNone => 'None';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get copiedToClipboard => 'Copied to clipboard!';

  @override
  String get noParticipantsYet => 'No participants yet.';

  @override
  String errorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String playersJoined(Object count) {
    return '$count Players joined';
  }

  @override
  String get shareBracket => 'Share Bracket';

  @override
  String get shareMatch => 'Check out this match!';

  @override
  String get tournamentBracket => 'Tournament Bracket';

  @override
  String get tbd => 'TBD';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get noCategoriesCreateFirst =>
      'No categories found. Please create a category first.';

  @override
  String get noMatchesForDay => 'No matches for this day';

  @override
  String get addExistingUsers => 'Add Existing Users';

  @override
  String get selectFromRegisteredUsers => 'Select from registered users';

  @override
  String get addManualEntry => 'Add Manual Entry';

  @override
  String get forGuestsOrNonAppUsers => 'For guests or non-app users';

  @override
  String get addParticipants => 'Add Participants';

  @override
  String get participantNamesHint =>
      'One name per line, e.g.:\nHugo Matsumoto\nArthur Fukushima\nRoberto Carlos';

  @override
  String participantsAddedCount(int count) {
    return '$count participant(s) added';
  }

  @override
  String get selectCategoriesColon => 'Select Categories:';

  @override
  String get searchUsers => 'Search Users';

  @override
  String addCount(Object count) {
    return 'Add ($count)';
  }

  @override
  String addedParticipants(Object count) {
    return 'Added $count participants';
  }

  @override
  String get alreadyInCategories =>
      'Selected participants are already in selected categories';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get addDate => 'Add Date';

  @override
  String get selectDateToMarkAvailability =>
      'Select a date to mark availability';

  @override
  String get editLocation => 'Edit Location';

  @override
  String get addLocation => 'Add Location';

  @override
  String get unknown => 'Unknown';

  @override
  String get storageLimitReached => 'Storage Limit Reached';

  @override
  String get storageLimitMessage =>
      'You have reached the 15 MB storage limit. Please delete some files to upload more.';

  @override
  String storageUsedOfLimit(Object limit, Object used) {
    return '$used of $limit';
  }

  @override
  String get single => 'Single';

  @override
  String get team => 'Team';

  @override
  String pageOf(Object current, Object total) {
    return 'Page $current of $total';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get ok => 'OK';

  @override
  String get myAvailability => 'My Availability';

  @override
  String get noLocationsAddedYet => 'No locations added yet.';

  @override
  String get deleteLocationTitle => 'Delete Location?';

  @override
  String deleteLocationConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get scheduleSettings => 'Schedule Settings';

  @override
  String get list => 'List';

  @override
  String get bulkApply => 'Bulk Apply';

  @override
  String get bulkApplySettings => 'Bulk Apply Settings';

  @override
  String get applySettingsToAllDays => 'Apply these settings to ALL days:';

  @override
  String get applyAll => 'Apply All';

  @override
  String get dateAlreadyExists => 'Date already exists';

  @override
  String get scheduleSettingsSaved => 'Schedule settings saved';

  @override
  String get notEnoughParticipants => 'Not enough approved participants';

  @override
  String generatedMatches(Object count) {
    return 'Generated $count matches!';
  }

  @override
  String get bracketDeleted => 'Bracket deleted';

  @override
  String get refresh => 'Refresh';

  @override
  String get invitePlayers => 'Invite Players';

  @override
  String get tournamentOptions => 'Tournament Options';

  @override
  String get tournamentNotFound => 'Tournament not found';

  @override
  String get metadata => 'Metadata';

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get mataMataElimination => 'Mata-Mata (Elimination)';

  @override
  String get openTennisGroups => 'Group + Mata-Mata';

  @override
  String get openTennisMode => 'Group + Mata-Mata Mode';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get notAvailable => 'N/A';

  @override
  String errorAddingParticipants(Object error) {
    return 'Error adding participants: $error';
  }

  @override
  String editSchedule(Object date) {
    return 'Edit $date';
  }

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get numberOfCourts => 'Number of Courts';

  @override
  String get tournamentMode => 'Tournament Mode';

  @override
  String get mataMataDescription =>
      'Direct elimination: lose once and you\'re out';

  @override
  String get openTennisDescription => 'Round-robin groups + playoff bracket';

  @override
  String get openTennisExplanation =>
      'Players are divided into groups. Each player plays against all others in their group. Points are awarded for wins. Top players from each group advance to the playoff bracket.';

  @override
  String get numberOfGroups => 'Max Players per Group';

  @override
  String get autoGroupsHint => 'Recommended: 3–4 players per group';

  @override
  String get pointsPerWin => 'Points per Win';

  @override
  String get pointsPerWinHint => 'Points awarded for each victory';

  @override
  String get noMatchesGenerated => 'No matches generated yet.';

  @override
  String get noMatchesNoPlayers =>
      'No matches generated and no players in this category yet.';

  @override
  String errorLoadingPlayers(Object error) {
    return 'Error loading players: $error';
  }

  @override
  String get editInfo => 'Edit Info';

  @override
  String get categories => 'Categories';

  @override
  String get clearBracket => 'Clear Bracket';

  @override
  String get deleteTournamentTitle => 'Delete Tournament';

  @override
  String get deleteBracketTitle => 'Delete Bracket?';

  @override
  String get deleteTournamentWarning =>
      'This will delete everything. Cannot be undone.';

  @override
  String get deleteBracketWarning =>
      'This will delete all matches. Cannot be undone.';

  @override
  String get singles => 'Singles';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFinished => 'Finished';

  @override
  String pointsPerWinLabel(Object count) {
    return 'Points per win: $count';
  }

  @override
  String get generatePlayoffBracket => 'Generate Playoff Bracket';

  @override
  String get playoffBracketGenerated =>
      'Playoff bracket generated! Group stage complete.';

  @override
  String get noStandingsYet =>
      'No standings yet. Generate bracket to create groups.';

  @override
  String groupLabel(Object id) {
    return 'Group $id';
  }

  @override
  String get standings => 'Standings';

  @override
  String get winsShort => 'W';

  @override
  String get lossesShort => 'L';

  @override
  String get playedShort => 'P';

  @override
  String get pointsShort => 'Pts';

  @override
  String get generatingPlayoffBracket => 'Generating playoff bracket...';

  @override
  String playoffBracketCreated(Object count) {
    return 'Playoff bracket created with $count matches!';
  }

  @override
  String errorGeneratingPlayoff(Object error) {
    return 'Error generating playoff: $error';
  }

  @override
  String shareGroupLabel(Object id) {
    return 'Share Group $id';
  }

  @override
  String get advanceFromGroup => 'Advance from Group';

  @override
  String get advanceFromGroupHint =>
      'How many players from each group advance to playoff';

  @override
  String playersInCategory(Object count) {
    return 'Players in this category ($count):';
  }

  @override
  String get tournamentInProgress =>
      'Tournament is in progress. Participation changes are locked.';

  @override
  String get tournamentCompleted =>
      'Tournament is completed. Participation changes are locked.';

  @override
  String get freePlanTournament => 'Free Plan Tournament';

  @override
  String get searchTournament => 'Search tournaments...';

  @override
  String get filter => 'Filters';

  @override
  String get clearAll => 'Clear all';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet.';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get matchNotifications => 'Match Notifications';

  @override
  String get matchScheduleChanges => 'Schedule Changes';

  @override
  String get matchScheduleChangesDesc => 'When a match date or time changes';

  @override
  String get matchResultsNotif => 'Match Results';

  @override
  String get matchResultsNotifDesc => 'When a match you\'re in is completed';

  @override
  String get socialNotifications => 'Social';

  @override
  String get followedUpdatesNotif => 'Followed Updates';

  @override
  String get followedUpdatesNotifDesc =>
      'Updates on matches and players you follow';

  @override
  String get otherNotifications => 'Other';

  @override
  String get generalAnnouncementsNotif => 'Announcements';

  @override
  String get generalAnnouncementsNotifDesc =>
      'Tournament news and general updates';

  @override
  String get groups => 'Groups';

  @override
  String get ptsPerWin => 'Pts/Win';

  @override
  String get defaultSchedule => 'Default Schedule';

  @override
  String get selectWeekdayTimes => 'Select default days and times';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get shareOnTwitter => 'Share on X (Twitter)';

  @override
  String get shareOnWhatsApp => 'Share on WhatsApp';

  @override
  String get downloadImage => 'Download Image';

  @override
  String get imageSaved => 'Image saved successfully!';

  @override
  String errorSavingImage(Object error) {
    return 'Error saving image: $error';
  }

  @override
  String get imageDownloaded => 'Image downloaded!';

  @override
  String get imageCopied => 'Image copied to clipboard!';

  @override
  String errorCopying(Object error) {
    return 'Error copying: $error';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUp => 'Sign Up';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get helpAndGuide => 'Help & Guide';

  @override
  String get selectCustomColor => 'Select Custom Color';

  @override
  String joinTournamentShare(Object name) {
    return 'Join $name on EntreSets!';
  }

  @override
  String get categoryNameHint => 'Category Name (e.g. Men\'s A)';

  @override
  String get typeLabel => 'Type';

  @override
  String get configureAvailableTimes => 'Configure available times.';

  @override
  String get metadataJson => 'Metadata (JSON)';

  @override
  String errorUploadingImage(Object error) {
    return 'Error uploading image: $error';
  }

  @override
  String errorDeletingImage(Object error) {
    return 'Error deleting image: $error';
  }

  @override
  String get changeStatus => 'Change Status';

  @override
  String nSelected(Object count) {
    return '$count selected';
  }

  @override
  String updatedMatchesStatus(Object count, Object status) {
    return 'Updated $count matches to $status';
  }

  @override
  String errorUpdatingMatches(Object error) {
    return 'Error updating matches: $error';
  }

  @override
  String get markScheduled => 'Mark Scheduled';

  @override
  String get markConfirmed => 'Mark Confirmed';

  @override
  String get markStarted => 'Mark Started';

  @override
  String get markFinished => 'Mark Finished';

  @override
  String get markCancelled => 'Mark Cancelled';

  @override
  String get tournamentScenarios => 'Tournament Scenarios';

  @override
  String get tournamentScenariosDesc =>
      'Create tournaments with pre-filled data to test bracket generation and user flows.';

  @override
  String get openTennisRoundRobinDesc =>
      'Round-robin groups with playoff bracket for group winners.';

  @override
  String simulationCreated(Object name) {
    return 'Simulation \"$name\" created successfully!';
  }

  @override
  String openTennisCreated(Object name) {
    return 'Group + Mata-Mata \"$name\" created successfully!';
  }

  @override
  String get simSmallTitle => 'Small Tournament';

  @override
  String get simSmallDesc => '4 Players, 1 Category. Simple bracket.';

  @override
  String get simStandardTitle => 'Standard Tournament';

  @override
  String get simStandardDesc => '8 Players, 1 Category. Quarter-finals start.';

  @override
  String get simLargeTitle => 'Large Tournament';

  @override
  String get simLargeDesc => '16 Players, 1 Category. Round of 16.';

  @override
  String get simOddTitle => 'Odd Players (Byes)';

  @override
  String get simOddDesc => '5 Players. Tests bye generation logic.';

  @override
  String get simMultiTitle => 'Multi-Category';

  @override
  String get simMultiDesc => '2 Categories, 4 Players each (Total 8).';

  @override
  String get simOT4Title => 'Open Tennis - 4 Players';

  @override
  String get simOT4Desc => '2 Groups, 3 points/win. Round-robin groups.';

  @override
  String get simOT6Title => 'Open Tennis - 6 Players';

  @override
  String get simOT6Desc => '2 Groups, 3 points/win. 3 players per group.';

  @override
  String get simOT8_2gTitle => 'Open Tennis - 8 Players (2 Groups)';

  @override
  String get simOT8_2gDesc => '2 Groups, 3 points/win. 4 players per group.';

  @override
  String get simOT8_4gTitle => 'Open Tennis - 8 Players (4 Groups)';

  @override
  String get simOT8_4gDesc => '4 Groups, 3 points/win. 2 players per group.';

  @override
  String americanoCreated(String name) {
    return 'Americano \"$name\" created successfully!';
  }

  @override
  String get americanoRoundRobinDesc =>
      'Players play guaranteed cross-group rounds. Top 2 per group play a decider match.';

  @override
  String get simAm8Title => 'Americano - 8 Players';

  @override
  String get simAm8Desc =>
      '2 groups of 4, 5 guaranteed matches. Deciders + final bracket.';

  @override
  String get simAm16Title => 'Americano - 16 Players';

  @override
  String get simAm16Desc =>
      '4 groups of 4, 5 guaranteed matches. Deciders + final bracket.';

  @override
  String get simAm12Title => 'Americano - 12 Players';

  @override
  String get simAm12Desc =>
      '3 groups of 4, 5 guaranteed matches. Deciders + final bracket.';

  @override
  String get addResults => 'Add Results';

  @override
  String get selectWinner => 'Select Winner';

  @override
  String get resultsAdded => 'Results added successfully!';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialDone => 'Done';

  @override
  String get tutorialWelcomeTitle => 'Welcome to Entre Sets';

  @override
  String get tutorialWelcomeSubtitle =>
      'Organize and join tennis tournaments with ease.';

  @override
  String get tutorialFindTournamentsTitle => 'Find Tournaments';

  @override
  String get tutorialFindTournamentsSubtitle =>
      'Browse, filter, and register for tournaments near you.';

  @override
  String get tutorialTrackMatchesTitle => 'Track Your Matches';

  @override
  String get tutorialTrackMatchesSubtitle =>
      'Get your schedule, confirm attendance, and follow results live.';

  @override
  String get tutorialReadyTitle => 'Ready to Play?';

  @override
  String get tutorialStartTour => 'Start Tour';

  @override
  String get tutorialSkipLetMeIn => 'Skip, let me in';

  @override
  String get tutorialReplayTitle => 'Replay Tutorial';

  @override
  String get tutorialReplayPlayer => 'Player Tour';

  @override
  String get tutorialReplayWelcome => 'Welcome';

  @override
  String get tutorialTournamentsTabTitle => 'Tournaments';

  @override
  String get tutorialTournamentsTabBody =>
      'Your home base. Browse all available tournaments, filter by status, and find your next match.';

  @override
  String get tutorialScheduleTabTitle => 'Schedule';

  @override
  String get tutorialScheduleTabBody =>
      'Your personal match calendar. See upcoming matches you\'re in or following, organized by date.';

  @override
  String get tutorialProfileTabTitle => 'Profile';

  @override
  String get tutorialProfileTabBody =>
      'Manage your profile, set your playing level, check your stats, and adjust preferences.';

  @override
  String get tutorialSearchTitle => 'Search';

  @override
  String get tutorialSearchBody =>
      'Search tournaments by name to quickly find what you\'re looking for.';

  @override
  String get tutorialFilterTitle => 'Filters';

  @override
  String get tutorialFilterBody =>
      'Narrow results by status: your tournaments, participating, singles, doubles, or open registration.';

  @override
  String get tutorialTournamentCardTitle => 'Tournament Card';

  @override
  String get tutorialTournamentCardBody =>
      'Each card shows name, cover image, status, player count, and dates. Tap to see full details.';

  @override
  String get tutorialCreateTournamentTitle => 'Create Tournament';

  @override
  String get tutorialCreateTournamentBody =>
      'Tap here to create and organize your own tournament.';

  @override
  String get tutorialInfoTabTitle => 'Info';

  @override
  String get tutorialInfoTabBody =>
      'Tournament description, format, categories, location, and participants list.';

  @override
  String get tutorialBracketTabTitle => 'Bracket';

  @override
  String get tutorialBracketTabBody =>
      'Once generated, view the full match bracket here. Tap any match for details.';

  @override
  String get tutorialCalendarTabTitle => 'Calendar';

  @override
  String get tutorialCalendarTabBody =>
      'See all scheduled matches on a calendar. Dates with matches are marked.';

  @override
  String get tutorialShareTitle => 'Share';

  @override
  String get tutorialShareBody =>
      'Share a link so players can find and register. Opens directly in the app if installed.';

  @override
  String get tutorialAdminSettingsTitle => 'Admin Settings';

  @override
  String get tutorialAdminSettingsBody =>
      'Manage your tournament: edit info, participants, categories, schedule, brackets, and co-admins.';

  @override
  String get matchRules => 'Match Rules';

  @override
  String get matchRulesPreset => 'Preset';

  @override
  String get presetQuickMatch => 'Quick Match';

  @override
  String get presetStandardAmateur => 'Standard Amateur';

  @override
  String get presetFullMatch => 'Full Match';

  @override
  String get presetCustom => 'Custom';

  @override
  String get scoringFormat => 'Scoring';

  @override
  String get setsToWin => 'Sets';

  @override
  String get gamesPerSet => 'Games per set';

  @override
  String get advantage => 'Advantage (deuce)';

  @override
  String get tiebreakAtSetEnd => 'Tiebreak at set end';

  @override
  String get tiebreakPoints => 'Tiebreak points';

  @override
  String get finalSetMatchTiebreak => 'Final set is match tiebreak';

  @override
  String get matchTiebreakPoints => 'Match tiebreak points';

  @override
  String get timeRules => 'Time';

  @override
  String get matchDurationLimit => 'Duration limit';

  @override
  String matchDurationMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get noLimit => 'No limit';

  @override
  String get warmupTime => 'Warm-up';

  @override
  String get restBetweenSets => 'Rest between sets';

  @override
  String get changeoverTime => 'Changeover';

  @override
  String changeoverSecondsValue(int seconds) {
    return '${seconds}s';
  }

  @override
  String get courtAndConduct => 'Court & Conduct';

  @override
  String get selfRefereeing => 'Self-refereeing';

  @override
  String get letServeReplayed => 'Let serve replayed';

  @override
  String get codeOfConduct => 'Code of conduct';

  @override
  String get conductEnforce => 'Enforce';

  @override
  String get conductRelaxed => 'Relaxed';

  @override
  String get ballType => 'Ball type';

  @override
  String get walkoverAndNoShow => 'Walkover & No-Show';

  @override
  String get confirmationDeadline => 'Confirmation deadline';

  @override
  String confirmationHoursBefore(int hours) {
    return '${hours}h before';
  }

  @override
  String get noShowGracePeriod => 'No-show grace period';

  @override
  String get noShowResult => 'No-show result';

  @override
  String get noShowWalkover => 'Walkover (W.O.)';

  @override
  String get noShowReschedule => 'Reschedule';

  @override
  String rulesScoringSummary(int sets, int games) {
    return '$sets sets to $games games';
  }

  @override
  String get rulesNoAdvantage => 'No advantage';

  @override
  String get rulesAdvantage => 'Advantage';

  @override
  String rulesTiebreakTo(int points) {
    return 'Tiebreak to $points';
  }

  @override
  String rulesFinalSetTiebreak(int points) {
    return 'Final set: Match tiebreak to $points';
  }

  @override
  String rulesMatchLimit(int minutes) {
    return '$minutes min limit';
  }

  @override
  String rulesWarmup(int minutes) {
    return '$minutes min warm-up';
  }

  @override
  String rulesRestBetweenSets(int minutes) {
    return '$minutes min rest between sets';
  }

  @override
  String rulesConfirmBefore(int hours) {
    return 'Confirm ${hours}h before';
  }

  @override
  String rulesGracePeriod(int minutes) {
    return '$minutes min grace';
  }

  @override
  String get rulesWalkoverOnNoShow => 'Walkover on no-show';

  @override
  String get rulesRescheduleOnNoShow => 'Reschedule on no-show';

  @override
  String get rulesSelfRefereeing => 'Self-refereeing';

  @override
  String get rulesLetReplayed => 'Let replayed';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get scoringMode => 'Scoring Mode';

  @override
  String get flatScoring => 'Flat Scoring';

  @override
  String get flatScoringDesc => 'Fixed points per win (e.g., 3 pts)';

  @override
  String get variableScoring => 'Variable Scoring';

  @override
  String get variableScoringDesc =>
      'Points vary by set result (2×0, 2×1, W.O.)';

  @override
  String get matchFormatLabel => 'Match Format';

  @override
  String get roundRobinFormat => 'Round-Robin';

  @override
  String get roundRobinFormatDesc =>
      'Each player plays all others in same group';

  @override
  String get crossGroupFormat => 'Cross-Group';

  @override
  String get crossGroupFormatDesc => 'Players face opponents from other groups';

  @override
  String get crossGroupMatches => 'Cross-Group Matches';

  @override
  String get matchesPerPlayer => 'Cross-group matches per player';

  @override
  String get matchesPerPlayerHint =>
      'Extra matches against opponents from other groups (on top of round-robin within own group)';

  @override
  String get pointsWin2_0Label => 'Win 2×0';

  @override
  String get pointsWin2_1Label => 'Win 2×1';

  @override
  String get pointsWinWOLabel => 'Win W.O.';

  @override
  String get pointsLoss1_2Label => 'Loss 1×2';

  @override
  String get pointsLoss0_2Label => 'Loss 0×2';

  @override
  String get pointsLossWOLabel => 'Loss W.O.';

  @override
  String get pointsAbbrev => 'pts';

  @override
  String get markAsWalkover => 'Mark as W.O.';

  @override
  String tiebreakSectionTitle(int s1, int s2) {
    return 'Tiebreak (tie $s1×$s2)';
  }

  @override
  String get initialServerQuestion => 'Who serves first?';

  @override
  String servingNow(String name) {
    return 'Serving: $name';
  }

  @override
  String get set => 'Set';

  @override
  String get variablePointsShort => 'Var.';

  @override
  String variableScoringTable(int p1, int p2, int p3, int p4) {
    return 'W 2×0: $p1 · W 2×1: $p2 · W W.O.: $p3 · L 1×2: $p4';
  }

  @override
  String categoryPresetMasculino(int n) {
    return 'Men\'s $n';
  }

  @override
  String categoryPresetFeminino(int n) {
    return 'Women\'s $n';
  }

  @override
  String categoryPresetMista(int n) {
    return 'Mixed $n';
  }

  @override
  String get categoryPresetCustom => 'Custom';

  @override
  String get addCategoriesQuick => 'Add Categories';

  @override
  String get categoryPresetHint => 'Select categories to add in bulk';

  @override
  String get masculine => 'Men\'s';

  @override
  String get feminine => 'Women\'s';

  @override
  String get mixed => 'Mixed';

  @override
  String get custom => 'Custom';

  @override
  String get simulateAndDebug => 'Simulate & Debug';

  @override
  String get simulateCrossGroup => 'Simulate Cross-Group';

  @override
  String get addBotsAndGenerate => 'Add bots and generate matches';

  @override
  String get botCount => 'Number of bots';

  @override
  String get simulationStarted => 'Simulation started!';

  @override
  String simulationComplete(int count) {
    return 'Simulation complete! $count matches created.';
  }

  @override
  String simulationError(String error) {
    return 'Simulation error: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get deleteBracketBody =>
      'This will delete all matches. Cannot be undone.';

  @override
  String get deleteTournamentConfirm =>
      'This will delete everything. Cannot be undone.';

  @override
  String get americanoMode => 'Americano';

  @override
  String get americanoGroups => 'Americano (Cross-Group)';

  @override
  String get americanoDescription =>
      'Guaranteed cross-group rounds + group decider + bracket';

  @override
  String americanoExplanation(int matches) {
    return 'Players are divided into groups and play $matches guaranteed matches against opponents from other groups. The top 2 from each group play a decider; the winner advances to the final bracket.';
  }

  @override
  String get guaranteedMatches => 'Guaranteed Matches per Player';

  @override
  String get guaranteedMatchesHint =>
      'Each player will play exactly this many matches in the group phase';

  @override
  String get opponentSelectionLabel => 'Opponent Selection';

  @override
  String get randomOpponents => 'Random';

  @override
  String get rankedOpponents => 'By Ranking (Mexicano)';

  @override
  String get generateGroupDeciders => 'Generate Group Deciders';

  @override
  String get generateAmericanoPlayoff => 'Generate Final Bracket';

  @override
  String get americanoMatchesPhase => 'Americano Phase';

  @override
  String playerMatchesTitle(String name) {
    return 'Matches of $name';
  }

  @override
  String get noMatchesForPlayer => 'No matches found for this player';

  @override
  String get followMatchHint =>
      'Follow to receive notifications and see in calendar';

  @override
  String get deciderPhase => 'Group Deciders';

  @override
  String deciderRound(String id) {
    return 'Decider Group $id';
  }

  @override
  String get playoffBracketGeneratedAmericano =>
      'Final bracket generated! See the Bracket tab.';

  @override
  String groupDecidersGenerated(int count) {
    return 'Group deciders generated! $count matches created.';
  }

  @override
  String errorGeneratingDeciders(String error) {
    return 'Error generating deciders: $error';
  }

  @override
  String get guaranteedMatchesShort => 'guar. matches';

  @override
  String get ptsPerWinShort => 'pts/win';

  @override
  String get skipIntro => 'Skip';

  @override
  String get fillRandomResults => 'Random results';

  @override
  String randomResultsFilled(int count) {
    return '$count matches filled with random results!';
  }

  @override
  String get youSuffix2 => 'You';

  @override
  String get advancingPosition => 'Advancing';

  @override
  String get tournamentPrivate => 'Private';

  @override
  String get tournamentPublic => 'Public';

  @override
  String get tournamentPrivateDesc =>
      'Private tournament — not shown in the public list';

  @override
  String get tournamentPublicDesc => 'Public tournament — visible to everyone';

  @override
  String get undo => 'Undo';

  @override
  String get editPlayers => 'Edit players';

  @override
  String get resetMatch => 'Reset match';

  @override
  String get resetMatchConfirm => 'Are you sure? The score will be cleared.';

  @override
  String get matchSettings => 'Match settings';

  @override
  String get finalSetTiebreak => 'Final set tiebreak (to 10)';

  @override
  String get whoServes => 'Who serves first?';

  @override
  String get apply => 'Apply';

  @override
  String get matchWinner => 'Match winner';

  @override
  String get copyResult => 'Copy result';

  @override
  String get resultCopied => 'Result copied!';

  @override
  String get newMatch => 'New match';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get startMatch => 'Start Match';

  @override
  String get playerLeftHint => 'Name (left)';

  @override
  String get playerRightHint => 'Name (right)';

  @override
  String get tapToStartHint => 'Names are optional';

  @override
  String get swapSides => 'Swap Sides';

  @override
  String get scoreLog => 'Score Log';

  @override
  String get noPointsYet => 'No points scored yet';

  @override
  String setLabel(int n) {
    return 'Set $n';
  }

  @override
  String gameLabel(int n) {
    return 'Game $n';
  }

  @override
  String gameWonBy(String name) {
    return 'Game — $name';
  }

  @override
  String setWonBy(String name) {
    return 'Set — $name';
  }

  @override
  String matchWonBy(String name) {
    return 'Match — $name';
  }

  @override
  String get scoreCounterHowItWorks => 'How to use';

  @override
  String get scoreCounterFeatureTap => 'Tap a player\'s panel to score a point';

  @override
  String get scoreCounterFeatureLongPress =>
      'Long-press to edit names or reset the match';

  @override
  String get scoreCounterFeatureToolbar =>
      'Use the top bar to undo, swap sides, and view the score log';

  @override
  String get scoreCounterFeatureFullscreen =>
      'Fullscreen mode — great for tablets or TV display';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get or => 'or';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get guestBannerTitle => 'You\'re browsing as a Guest';

  @override
  String get guestBannerDesc =>
      'Create an account to save your progress and join tournaments.';

  @override
  String get guestCannotCreateTournamentTitle => 'Account required';

  @override
  String get guestCannotCreateTournamentBody =>
      'Only registered players can create tournaments. This ensures participants can find and join your tournament, and that you can manage it securely.';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get linkWithGoogle => 'Link with Google';

  @override
  String get linkWithApple => 'Link with Apple';

  @override
  String get back => 'Back';

  @override
  String get advance => 'Next';

  @override
  String get stepVisao => 'Identity';

  @override
  String get stepLogistica => 'Logistics';

  @override
  String get stepRegras => 'Rules';

  @override
  String get stepRevisao => 'Review';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get reviewIdentity => 'Identity & Mode';

  @override
  String get reviewLogistics => 'Where & When';

  @override
  String get mataMataExplanation =>
      'Pure single-elimination bracket. Every loss knocks the player out — no second chances. Matches are high-stakes and direct. Perfect for crowning a champion quickly or running the final stages of a larger event.';

  @override
  String get categoryPriorityTitle => 'Category Priority';

  @override
  String get categoryPrioritySubtitle =>
      'Set the order in which categories are scheduled. The first category takes the best time slots.';

  @override
  String get categoryPriorityAlphabetical => 'Alphabetical (A → Z)';

  @override
  String get categoryPriorityAlphabeticalDesc =>
      'Categories scheduled in A → Z name order';

  @override
  String get categoryPriorityInverted => 'Inverted (Z → A)';

  @override
  String get categoryPriorityInvertedDesc =>
      'Categories scheduled in Z → A name order';

  @override
  String get categoryPriorityMixed => 'Mixed (Interleaved)';

  @override
  String get categoryPriorityMixedDesc =>
      'Matches are interleaved round-robin across categories';

  @override
  String get autoScheduleDates => 'Automatically assign Date and Time';

  @override
  String get processingBracket => 'Generating bracket…';

  @override
  String get processingBracketSubtitle => 'Please wait';

  @override
  String get filterAll => 'All';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterByCategory => 'Category';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportCsvSuccess => 'CSV exported successfully';

  @override
  String exportCsvError(String error) {
    return 'Error exporting CSV: $error';
  }
}
