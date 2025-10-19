import 'package:flutter/material.dart';
import 'package:home_page/animations/progress_ring_widget.dart';

class startingAnimation extends StatefulWidget {
  const startingAnimation({super.key});

  @override
  State<startingAnimation> createState() => _startingAnimationState();
}

class _startingAnimationState extends State<startingAnimation> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  height: screenHeight * 0.20,
                  child: Image.asset(
                    'assets/images/agu_kilit_ekrani.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.4,
                ),
                const ProgressRing(
                  size: 60,
                  strokeWidth: 6,
                  duration: Duration(milliseconds: 1200),
                  ringColor: Colors.teal,
                  label: '',
                  labelColor: Colors.white,
                  autostart: true,
                  loop: true,
                ),
                const SizedBox(height: 20),
                const Text(
                  "     Yükleniyor...",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
