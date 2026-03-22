import 'package:flutter/material.dart';

enum TutorialTrack { player, admin }

enum TooltipPosition { top, bottom, left, right }

class TutorialStepData {
  final String id;
  final GlobalKey targetKey;
  final String title;
  final String description;
  final TooltipPosition tooltipPosition;

  const TutorialStepData({
    required this.id,
    required this.targetKey,
    required this.title,
    required this.description,
    this.tooltipPosition = TooltipPosition.bottom,
  });
}
