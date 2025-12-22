import 'dart:math';
import 'dart:ui';
import 'package:BSA/Features/Home/Screens/home_screen.dart';
import 'package:BSA/core/services/local_data_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);
    final entered = _passwordCtrl.text.trim();
    bool ok = await LocalStorageService.validatePassword(entered);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect Password"),
          backgroundColor: Colors.red,
        ),
      );
    }
    _passwordCtrl.clear();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated wave background
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(_waveController.value),
                size: size,
              );
            },
          ),

          // Glass login container
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  width: size.width * 0.85,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 0, 0, 0).withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 90,
                        backgroundImage: const AssetImage("assets/images/bsa.png"),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        child: TextField(
                          controller: _passwordCtrl,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,

                          obscureText: _obscure,
                          onChanged: (value) {
                            if (value.length == 4) {
                              _login();
                            }
                          },
                          onSubmitted: (value) {
                            _isLoading ? null : _login();
                          },

                          maxLength: 4,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            letterSpacing: 8,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: "Enter PIN",
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(
                                255,
                                86,
                                85,
                                85,
                              ).withOpacity(0.7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;

  WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final waves = [
      {
        'color': Colors.cyanAccent.withOpacity(0.3),
        'height': 100.0,
        'speed': 1.0,
      },
      {
        'color': const Color.fromARGB(255, 24, 41, 48).withOpacity(0.2),
        'height': 150.0,
        'speed': 0.8,
      },
      {
        'color': Colors.tealAccent.withOpacity(0.15),
        'height': 80.0,
        'speed': 1.3,
      },
    ];

    for (var wave in waves) {
      final paint = Paint()
        ..color = wave['color'] as Color
        ..style = PaintingStyle.fill;

      final path = Path();
      double waveHeight = wave['height'] as double;
      double waveLength = size.width;
      double yOffset = size.height / 2;
      double speed = wave['speed'] as double;

      path.moveTo(0, yOffset);

      for (double x = 0; x <= waveLength; x++) {
        double y =
            sin((x / waveLength * 2 * pi * speed) + (progress * 2 * pi)) *
                waveHeight +
            yOffset;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}
