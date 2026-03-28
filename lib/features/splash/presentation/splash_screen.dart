import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/auth/data/auth_repository.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _initialized = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/entre-sets-intro.mp4')
      ..initialize().then((_) {
        // Mute to allow autoplay on web
        _controller.setVolume(0.0);
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    _controller.addListener(_checkVideoEnd);
  }
  
  void _checkVideoEnd() {
    if (_controller.value.isInitialized && 
        !_controller.value.isPlaying &&
        _controller.value.position >= _controller.value.duration) {
      _controller.removeListener(_checkVideoEnd);
      _startFadeOut();
    }
  }

  Future<void> _startFadeOut() async {
    if (_isNavigating) return;
    _isNavigating = true;
    _controller.removeListener(_checkVideoEnd);
    await _fadeController.forward();
    if (mounted) {
      context.go('/tournaments');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8F2),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: _initialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(
              child: TextButton(
                onPressed: _startFadeOut,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black26,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(loc.skipIntro),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
