import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  String _displayedText = '';
  final List<String> _textSegments = ['GLI', 'CE', 'RA'];
  int _currentSegment = 0;

  @override
  void initState() {
    super.initState();

    // Setup fade animation untuk seluruh screen
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Start text animation
    _startTextAnimation();

    // Navigate to onboarding after animation
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  void _startTextAnimation() {
    // Delay awal sebelum animasi text mulai
    Future.delayed(const Duration(milliseconds: 500), () {
      _animateNextSegment();
    });
  }

  void _animateNextSegment() {
    if (_currentSegment < _textSegments.length) {
      setState(() {
        _displayedText += _textSegments[_currentSegment];
      });
      
      _currentSegment++;
      
      // Delay antar segment (GLI -> CE -> RA)
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _animateNextSegment();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B6E), // Biru gelap (sama dengan Dashboard)
              Color(0xFF1A3A9F), // Biru sedang
              Color(0xFF2979FF), // Biru terang
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: const TextStyle(
                fontFamily: 'HammersmithOne',
                fontSize: 48,
                fontWeight: FontWeight.normal,
                color: AppColors.white,
                letterSpacing: 4,
              ),
              child: Text(_displayedText),
            ),
          ),
        ),
      ),
    );
  }
}