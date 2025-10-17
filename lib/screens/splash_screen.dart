import 'dart:async';
import 'package:flutter/material.dart';
import 'package:feedly/screens/auth/login_screen.dart';
import 'package:feedly/widgets/styles/app_colors.dart'; // ⬅️ import your theme colors

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward(); // Start animation

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark, 
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Feedly',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppColors.white, 
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
