import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_tournament/features/auth/data/auth_repository.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFFEF8F2),
      body: FadeTransition(
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
    );
  }
}
