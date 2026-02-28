import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salon_app/screens/introduction/onboarding_screen.dart';
import 'package:salon_app/utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isAnimate = true;

  final width = 50;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), (() {
      setState(() {
        isAnimate = false;
      });
    }));

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: ((context) => const OnBoardingScreen())),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 150),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedPadding(
                padding: EdgeInsets.only(top: isAnimate ? 40 : 0),
                duration: const Duration(seconds: 3),
                curve: Curves.easeInOutCubicEmphasized,
                child: AnimatedOpacity(
                  opacity: isAnimate ? 0 : 1,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInCubic,
                  child: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    radius: 80,
                    child: Icon(
                      Icons.content_cut,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedPadding(
                padding: EdgeInsets.only(top: isAnimate ? 40 : 0),
                duration: const Duration(seconds: 3),
                curve: Curves.easeInOutCubicEmphasized,
                child: AnimatedOpacity(
                  opacity: isAnimate ? 0 : 1,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInCubic,
                  child: const Text(
                    "SalonEase",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 40,
                      letterSpacing: 1.3,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
