import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Conectivity_Check_Controller.dart';
import 'Products/product_controller.dart';
import 'Splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ProductsController());
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