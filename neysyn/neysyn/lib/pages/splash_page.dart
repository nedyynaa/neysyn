import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _dragPosition = 0.0;
  final double _maxDragWidth = 250.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'Neysyn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover vital statistics today.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    const Center(
                      child: Text(
                        'Slide to get started',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _dragPosition,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _dragPosition += details.delta.dx;
                            if (_dragPosition < 0) {
                              _dragPosition = 0;
                            } else if (_dragPosition >= _maxDragWidth) {
                              _dragPosition = _maxDragWidth;
                              Navigator.pushReplacementNamed(context, '/auth-choice');
                            }
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          if (_dragPosition < _maxDragWidth) {
                            setState(() {
                              _dragPosition = 0.0;
                            });
                          }
                        },
                        child: Container(
                          height: 52,
                          width: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}