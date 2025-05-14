import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_shop/Model Classes/products_model.dart';

class ProductsController extends GetxController {
  var products = <Product>[].obs;

  final filteredProducts = <Product>[].obs;

  var displayedProducts = <Product>[].obs;

  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var errorMessage = ''.obs;

  var searchText = ''.obs;
  var selectedCategories = <String>[].obs;
  var selectedSort = ''.obs;
  var minPrice = 350.0.obs;
  var maxPrice = 350000.0.obs;
  var priceRange = RangeValues(350, 300000).obs;
  var ratingRange = RangeValues(0, 5).obs;

  var page = 1.obs;
  final int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    fetchInitialProducts();
  }

  //  Load JSON & setup price bounds, then apply filters + initial page
  Future<void> fetchInitialProducts() async {
    try {
      isLoading.value = true;
      final jsonString =
      await rootBundle.loadString('assets/Product_Catalog.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      products.value =
          jsonList.map((e) => Product.fromJson(e)).toList();

      if (products.isNotEmpty) {
        final prices = products.map((p) => p.price).toList();
        minPrice.value = prices.reduce((a, b) => a < b ? a : b);
        maxPrice.value = prices.reduce((a, b) => a > b ? a : b);
      }
      priceRange.value = RangeValues(minPrice.value, maxPrice.value);

      // Create full filtered list
      _applyAllFilters();

      _loadPage(reset: true);
    } catch (e) {
      errorMessage.value = 'Failed to load products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Called by scroll listener to load next page slice
  Future<void> fetchMoreProducts() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    await Future.delayed(const Duration(seconds: 1)); // simulate delay
    _loadPage();
    isLoadingMore.value = false;
  }

  // Apply search/categories/price/rating/sort to entire `products`
  void _applyAllFilters() {
    final filtered = products.where((p) {
      final matchesSearch = p.name.toLowerCase()
          .contains(searchText.value.toLowerCase());
      final inCategory = selectedCategories.isEmpty ||
          selectedCategories.contains(p.category ?? 'Uncategorized');
      final inPrice = p.price >= priceRange.value.start &&
          p.price <= priceRange.value.end;
      final inRating = p.ratings >= ratingRange.value.start &&
          p.ratings <= ratingRange.value.end;
      return matchesSearch && inCategory && inPrice && inRating;
    }).toList();

    switch (selectedSort.value) {
      case 'Price ↑':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price ↓':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Popularity':
        filtered.sort((a, b) => b.ratings.compareTo(a.ratings));
        break;
      case 'Newest':
        filtered.sort((a, b) => b.arrivalDate.compareTo(a.arrivalDate));
        break;
      default:
        break;
    }

    filteredProducts.value = filtered;
  }

  // Builds the next page slice into `displayedProducts`.
  void _loadPage({bool reset = false}) {
    if (reset) {
      page.value = 1;
      displayedProducts.clear();
      hasMore.value = true;
    }

    final start = (page.value - 1) * pageSize;
    final end = start + pageSize;
    if (start >= filteredProducts.length) {
      hasMore.value = false;
      return;
    }

    final slice = filteredProducts.sublist(
      start,
      end > filteredProducts.length ? filteredProducts.length : end,
    );
    displayedProducts.addAll(slice);

    // More pages?
    hasMore.value = end < filteredProducts.length;
    if (hasMore.value) page.value++;
  }

  // Trigger re-applying filters + resetting pages
  Future<void> applyFilters() async {
    _applyAllFilters();
    _loadPage(reset: true);
  }

  void clearFilters() {
    searchText.value = '';
    selectedCategories.clear();
    selectedSort.value = '';
    priceRange.value = RangeValues(minPrice.value, maxPrice.value);
    ratingRange.value = RangeValues(0, 5);
    applyFilters();
  }

  Future<List<Product>> find(String query) async {
    if (products.isEmpty) await fetchInitialProducts();
    return products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<String> getCategories() {
    final cats = products
        .map((p) => p.category ?? 'Uncategorized')
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    applyFilters();
  }

  void updateSort(String sortOption) {
    selectedSort.value = sortOption;
    applyFilters();
  }

  void updateSearch(String text) {
    searchText.value = text;
    applyFilters();
  }
}