import 'package:flutter/material.dart';

class TechyLoadingScreen extends StatelessWidget {
  const TechyLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B1B1B), Color(0xFF003153)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Color(0xFF00BFFF),
                ), // cyan-blue accent
                strokeWidth: 6,
              ),
              SizedBox(height: 20),
              Text(
                'Loading ...',
                style: TextStyle(
                  color: Color(0xFF00BFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
