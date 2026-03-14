import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.helpAndGuide),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _markdownData == null
          ? const Center(child: CircularProgressIndicator())
          : Markdown(data: _markdownData!),
    );
  }
}
