import 'package:e_shop/Products/product_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Product_Catalog()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.cyanAccent.shade700,
              Colors.cyanAccent.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/e_comm_logo1.png",)
                .animate()
                .slideY(begin: -2.5, end: 0, curve: Curves.bounceOut, duration: 1000.ms,)
                .fadeIn(duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}