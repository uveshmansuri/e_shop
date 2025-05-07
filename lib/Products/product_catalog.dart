import 'package:flutter/material.dart';

class Product_Catalog extends StatelessWidget {
  const Product_Catalog({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/e_comm_logo2.png"),
        title: Text("Welcome to E-Shop",style: TextStyle(color: Colors.cyanAccent.shade700,fontSize: 25,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FFFD),
              Color(0xFFE3FFF5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
