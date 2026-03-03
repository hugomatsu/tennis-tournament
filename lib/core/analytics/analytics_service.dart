import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

@riverpod
AnalyticsService analyticsService(Ref ref) {
  return AnalyticsService();
}

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  Future<void> logViewTournamentList() async {
    await _analytics.logEvent(name: 'view_tournament_list');
  }

  Future<void> logViewTournamentDetail({
    required String tournamentName,
    required String tournamentType,
  }) async {
    await _analytics.logEvent(
      name: 'view_tournament_detail',
      parameters: {
        'tournament_name': tournamentName,
        'tournament_type': tournamentType,
      },
    );
  }

  Future<void> logShareTournament({required String tournamentName}) async {
    await _analytics.logEvent(
      name: 'share_tournament',
      parameters: {'tournament_name': tournamentName},
    );
  }

  Future<void> logShareMatch({
    required String matchId,
    required String tournamentName,
  }) async {
    await _analytics.logEvent(
      name: 'share_match',
      parameters: {
        'match_id': matchId,
        'tournament_name': tournamentName,
      },
    );
  }

  Future<void> logShareBracket({
    required String tournamentName,
  }) async {
    await _analytics.logEvent(
      name: 'share_bracket',
      parameters: {
        'tournament_name': tournamentName,
      },
    );
  }

  Future<void> logJoinTournamentRequest({
    required String tournamentName,
    required String categoryName,
  }) async {
    await _analytics.logEvent(
      name: 'join_tournament_request',
      parameters: {
        'tournament_name': tournamentName,
        'category_name': categoryName,
      },
    );
  }

  Future<void> logViewMatchDetail() async {
    await _analytics.logEvent(name: 'view_match_detail');
  }

  Future<void> logFollowMatch() async {
    await _analytics.logEvent(name: 'follow_match');
  }

  Future<void> logSubmitMatchScore({
    required String matchId,
    required String tournamentName,
  }) async {
    await _analytics.logEvent(
      name: 'submit_match_score',
      parameters: {
        'match_id': matchId,
        'tournament_name': tournamentName,
      },
    );
  }

  Future<void> logCreateTournament({required String tournamentType}) async {
    await _analytics.logEvent(
      name: 'create_tournament',
      parameters: {'tournament_type': tournamentType},
    );
  }

  Future<void> logGenerateBracket({required String generationMethod}) async {
    await _analytics.logEvent(
      name: 'generate_bracket',
      parameters: {'generation_method': generationMethod},
    );
  }

  Future<void> logViewPremiumOffer() async {
    await _analytics.logEvent(name: 'view_premium_offer');
  }

  Future<void> logPurchasePremium() async {
    await _analytics.logEvent(name: 'purchase_premium');
  }

  Future<void> logUpdateProfile() async {
    await _analytics.logEvent(name: 'update_profile');
  }
}
