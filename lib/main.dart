import 'package:e_shop/Controller/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Controller/Conectivity_Check_Controller.dart';
import 'Controller/product_controller.dart';
import 'Splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ProductsController());
  Get.put(CartController());
  Get.put(InternetController(),permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      title: 'E-Shop',
      home: Splash(),
    );
  }
}