import 'dart:convert';
import 'package:e_shop/Products/products_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProductsController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Load JSON string from assets
      final jsonString = await rootBundle
          .loadString('assets/Product_Catalog.json');

      // 2. Decode & parse
      final List<dynamic> jsonList = json.decode(jsonString);
      products.value = jsonList
          .map((jsonItem) => Product.fromJson(jsonItem))
          .toList();
    } catch (e) {
      errorMessage.value = 'Failed to load products: $e';
      print(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
}