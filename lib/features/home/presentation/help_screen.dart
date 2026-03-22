import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';
import 'package:tennis_tournament/features/tutorial/data/tutorial_analytics.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String? _markdownData;

  @override
  void initState() {
    super.initState();
    _loadHelpFile();
  }

  Future<void> _loadHelpFile() async {
    try {
      final data = await rootBundle.loadString('docs/howto.md');
      if (mounted) {
        setState(() {
          _markdownData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _markdownData = '# Error loading help file\n\n$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.helpAndGuide),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Replay tutorial section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.tutorialReplayTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(tutorialAnalyticsProvider).replayTapped(track: 'player');
                          context.go('/tournaments', extra: {'startTutorial': true});
                        },
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: Text(loc.tutorialReplayPlayer),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(tutorialAnalyticsProvider).replayTapped(track: 'welcome');
                          context.go('/welcome');
                        },
                        icon: const Icon(Icons.restart_alt, size: 18),
                        label: Text(loc.tutorialReplayWelcome),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Help content
          Expanded(
            child: _markdownData == null
                ? const Center(child: CircularProgressIndicator())
                : Markdown(data: _markdownData!),
          ),
        ],
      ),
    );
  }
}
