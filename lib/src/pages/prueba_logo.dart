import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PruebaLogo extends StatefulWidget {
  const PruebaLogo({super.key});

  @override
  State<PruebaLogo> createState() => _PruebaLogoState();
}

class _PruebaLogoState extends State<PruebaLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 3500), // Cambia la duración para controlar la velocidad
    )..repeat();
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
        color: Colors.black,
        child: Center(
          child: Lottie.asset(
            'assets/logo-light.json',
            controller: _controller,
            width: 500,
            height: 400,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
