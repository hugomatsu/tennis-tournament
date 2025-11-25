import 'package:flutter/material.dart';
import 'package:tennis_tournament/features/matches/domain/match.dart';

class BracketPainter extends CustomPainter {
  final List<TennisMatch> matches;
  final double cardHeight;
  final double cardWidth;
  final double gap;
  final double margin;

  BracketPainter({
    required this.matches,
    required this.cardHeight,
    required this.cardWidth,
    required this.gap,
    required this.margin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final highlightPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Map matches by ID for easy lookup
    final matchMap = {for (var m in matches) m.id: m};

    for (var match in matches) {
      if (match.nextMatchId == null) continue;

      final nextMatch = matchMap[match.nextMatchId];
      if (nextMatch == null) continue;

      // Calculate positions
      // We assume the canvas covers the entire scrollable area of the column
      // But actually, this painter is likely used per-column or for the whole view.
      // Let's assume this painter is used between two columns (Round N and Round N+1).
      // Wait, if we use a single CustomPaint for the whole view, we need absolute coordinates.
      
      // Better approach for the Plan:
      // The BracketView will have a Row of Columns.
      // We can put a CustomPaint *behind* the Row (using Stack) to draw lines.
      // OR we can put CustomPaint in between columns.
      
      // Let's go with: CustomPaint covers the entire area.
      // We need to know the layout logic to calculate coordinates.
      
      // Layout Logic (replicated from BracketView):
      // X position: roundIndex * (cardWidth + gap)
      // Y position: 
      //   Round 1: index * (cardHeight + margin)
      //   Round N: offset + index * (cardHeight + margin) * 2^(N-1)
      
      final r = int.parse(match.round);
      final index = match.matchIndex;
      
      // Current Match Position (Right side center)
      final startX = (r - 1) * (cardWidth + gap) + cardWidth;
      final startY = _calculateY(r, index) + cardHeight / 2;

      // Next Match Position (Left side center)
      final nextR = int.parse(nextMatch.round);
      final nextIndex = nextMatch.matchIndex;
      final endX = (nextR - 1) * (cardWidth + gap);
      final endY = _calculateY(nextR, nextIndex) + cardHeight / 2;

      // Draw path
      final path = Path();
      path.moveTo(startX, startY);
      path.cubicTo(
        startX + gap / 2, startY, // Control point 1
        endX - gap / 2, endY,     // Control point 2
        endX, endY,               // End point
      );

      // Determine if this path should be highlighted
      // Highlight if this match is completed and the winner is one of the players in the next match
      bool isHighlighted = false;
      if (match.status == 'Completed' && match.winner != null) {
        // Check if the winner is propagated to next match
        if (nextMatch.player1Name == match.winner || nextMatch.player2Name == match.winner) {
           isHighlighted = true;
        }
      }

      canvas.drawPath(path, isHighlighted ? highlightPaint : paint);
    }
  }

  double _calculateY(int round, int index) {
    // Formula from plan:
    // gap(r) = (cardHeight + margin) * 2^r - cardHeight (This is vertical gap between matches)
    // But we need absolute Y.
    
    // Height of a "slot" in Round 1 is (cardHeight + margin).
    // In Round r, a match consumes 2^(r-1) slots of Round 1.
    // The center of the match in Round r should align with the center of the group of slots it covers.
    
    final slotHeight = cardHeight + margin;
    final slotsPerMatch = 1 << (round - 1); // 2^(r-1)
    
    // The match is centered in the block of slots it represents.
    // Top of the block: index * slotsPerMatch * slotHeight
    // Height of the block: slotsPerMatch * slotHeight
    // Center of the block: Top + Height / 2
    // Top of the card: Center - cardHeight / 2
    
    final blockTop = index * slotsPerMatch * slotHeight;
    final blockHeight = slotsPerMatch * slotHeight;
    final center = blockTop + blockHeight / 2;
    
    return center - cardHeight / 2;
  }

  @override
  bool shouldRepaint(covariant BracketPainter oldDelegate) {
    return oldDelegate.matches != matches;
  }
}
