import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:tennis_tournament/features/tutorial/data/tutorial_repository.dart';
import 'package:tennis_tournament/features/tutorial/data/tutorial_analytics.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _pageController = PageController();
  final _sessionStopwatch = Stopwatch();
  int _currentPage = 0;
  static const _totalSlides = 4;

  @override
  void initState() {
    super.initState();
    _sessionStopwatch.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tutorialAnalyticsProvider).welcomeStarted(source: 'first_login');
      _logSlideViewed(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sessionStopwatch.stop();
    super.dispose();
  }

  void _logSlideViewed(int index) {
    final titles = ['welcome', 'find_tournaments', 'track_matches', 'ready'];
    if (index < titles.length) {
      ref.read(tutorialAnalyticsProvider).welcomeSlideViewed(
        slideIndex: index,
        slideTitle: titles[index],
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _logSlideViewed(page);
  }

  void _nextPage() {
    if (_currentPage < _totalSlides - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    _sessionStopwatch.stop();
    ref.read(tutorialAnalyticsProvider).welcomeSkipped(
      skippedAtSlide: _currentPage,
      timeSpentMs: _sessionStopwatch.elapsedMilliseconds,
    );
    ref.read(tutorialRepositoryProvider).markWelcomeSeen();
    context.go('/tournaments');
  }

  void _startTour() {
    _sessionStopwatch.stop();
    ref.read(tutorialAnalyticsProvider).welcomeCompleted(
      action: 'start_tour',
      timeSpentMs: _sessionStopwatch.elapsedMilliseconds,
    );
    ref.read(tutorialRepositoryProvider).markWelcomeSeen();
    context.go('/tournaments', extra: {'startTutorial': true});
  }

  void _skipToApp() {
    _sessionStopwatch.stop();
    ref.read(tutorialAnalyticsProvider).welcomeCompleted(
      action: 'skip',
      timeSpentMs: _sessionStopwatch.elapsedMilliseconds,
    );
    ref.read(tutorialRepositoryProvider).markWelcomeSeen();
    context.go('/tournaments');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top-right, hidden on last slide)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: AnimatedOpacity(
                  opacity: _currentPage < _totalSlides - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _currentPage < _totalSlides - 1 ? _skip : null,
                    child: Text(loc.tutorialSkip),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _WelcomeSlide(
                    icon: Icons.sports_tennis,
                    iconColor: theme.colorScheme.primary,
                    title: loc.tutorialWelcomeTitle,
                    subtitle: loc.tutorialWelcomeSubtitle,
                    onTap: _nextPage,
                  ),
                  _WelcomeSlide(
                    icon: Icons.emoji_events,
                    iconColor: Colors.amber,
                    title: loc.tutorialFindTournamentsTitle,
                    subtitle: loc.tutorialFindTournamentsSubtitle,
                    onTap: _nextPage,
                  ),
                  _WelcomeSlide(
                    icon: Icons.calendar_month,
                    iconColor: Colors.teal,
                    title: loc.tutorialTrackMatchesTitle,
                    subtitle: loc.tutorialTrackMatchesSubtitle,
                    onTap: _nextPage,
                  ),
                  // Last slide with CTA buttons
                  _LastSlide(
                    theme: theme,
                    loc: loc,
                    onStartTour: _startTour,
                    onSkip: _skipToApp,
                  ),
                ],
              ),
            ),
            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _totalSlides,
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: theme.colorScheme.primary,
                  dotColor: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WelcomeSlide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: iconColor),
            ),
            const SizedBox(height: 40),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class _LastSlide extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations loc;
  final VoidCallback onStartTour;
  final VoidCallback onSkip;

  const _LastSlide({
    required this.theme,
    required this.loc,
    required this.onStartTour,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            loc.tutorialReadyTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartTour,
              icon: const Icon(Icons.play_arrow),
              label: Text(loc.tutorialStartTour),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSkip,
              child: Text(loc.tutorialSkipLetMeIn),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
