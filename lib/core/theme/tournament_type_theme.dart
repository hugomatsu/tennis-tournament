import 'package:flutter/material.dart';

/// Canonical visual identity for each tournament type.
///
/// Use this as the single source of truth for icons and colors whenever
/// a tournament type needs to be represented in the UI — badges, cards,
/// headers, charts, etc.
///
/// Usage:
/// ```dart
/// final theme = TournamentTypeTheme.of('americano');
/// Icon(theme.icon, color: theme.color)
/// ```
class TournamentTypeTheme {
  const TournamentTypeTheme._({
    required this.color,
    required this.icon,
  });

  /// Solid foreground color — use for icons, text, and borders.
  final Color color;

  /// Representative icon for the tournament mode.
  final IconData icon;

  /// Background fill at low opacity — use for card/chip backgrounds.
  Color get background => color.withValues(alpha: 0.12);

  /// Border color at medium opacity — use for outlined containers.
  Color get border => color.withValues(alpha: 0.35);

  // ── Canonical definitions ────────────────────────────────────────────────

  /// Mata-Mata — Single elimination.
  /// Red: conveys intensity and the "lose once, you're out" nature.
  static const mataMata = TournamentTypeTheme._(
    color: Color(0xFFE53935), // Red 600
    icon: Icons.emoji_events,
  );

  /// Open Tennis — Round-robin group stage + single-elimination playoff.
  /// Blue: conveys structure, organisation, and multiple rounds.
  static const openTennis = TournamentTypeTheme._(
    color: Color(0xFF1E88E5), // Blue 600
    icon: Icons.groups,
  );

  /// Americano — Cross-group rotation + group decider + bracket.
  /// Orange: conveys energy, movement, and the mixing/rotation format.
  static const americano = TournamentTypeTheme._(
    color: Color(0xFFFF8F00), // Amber 700
    icon: Icons.shuffle,
  );

  // ── Lookup ───────────────────────────────────────────────────────────────

  /// Returns the theme for [tournamentType]. Falls back to [mataMata]
  /// for unknown values so the UI never breaks.
  static TournamentTypeTheme of(String tournamentType) {
    switch (tournamentType) {
      case 'openTennis':
        return openTennis;
      case 'americano':
        return americano;
      default:
        return mataMata;
    }
  }
}
