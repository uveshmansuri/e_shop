import 'package:e_shop/Cart/cart_screen.dart';
import 'package:e_shop/Controller/product_controller.dart';
import 'package:e_shop/Products/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../Model Classes/products_model.dart';

class Product_Catalog extends StatefulWidget {
  Product_Catalog({super.key});

  @override
  State<Product_Catalog> createState() => _Product_CatalogState();
}

class _Product_CatalogState extends State<Product_Catalog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ProductsController pc = Get.find();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initial fetch
    pc.fetchInitialProducts();

    // Listen for scroll to implement lazy loading
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !pc.isLoadingMore.value &&
          pc.hasMore.value) {
        pc.fetchMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      appBar: AppBar(
        leading: Image.asset("assets/images/e_comm_logo2.png"),
        title: Text(
          "Welcome to E-Shop",
          style: TextStyle(
            color: Colors.cyanAccent.shade700,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.cyanAccent.shade700),
            onPressed: () {
              // 3) Open the end drawer via the key:
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),

      endDrawer: Drawer(
        child: SafeArea(
          child: Obx(() {
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Center(
                  child: Text(
                    'Filters & Sorting',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                Divider(height: 32),

                /// — CATEGORIES as an ExpansionTile —
                ExpansionTile(
                  title: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: pc.getCategories().map((cat) {
                    return CheckboxListTile(
                      title: Text(cat),
                      value: pc.selectedCategories.contains(cat),
                      onChanged: (_) => pc.toggleCategory(cat),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),

                // — Sort as Radio Buttons —
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ...[
                  'Price ↑',
                  'Price ↓',
                  'Popularity',
                  'Newest',
                ].map((opt) {
                  return RadioListTile<String>(
                    title: Text(opt),
                    value: opt,
                    groupValue: pc.selectedSort.value,
                    onChanged: (val)=>pc.updateSort(val!),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
                SizedBox(height: 24),

                // — Price RangeSlider —
                Text(
                  'Price: Rs ${pc.priceRange.value.start.toInt()} – ${pc.priceRange.value.end.toInt()}',
                ),
                RangeSlider(
                  values: pc.priceRange.value,
                  min: pc.minPrice.value,
                  max: pc.maxPrice.value,
                  divisions: 20,
                  labels: RangeLabels(
                    '${pc.priceRange.value.start.toInt()}',
                    '${pc.priceRange.value.end.toInt()}',
                  ),
                  onChanged: (r) => pc.priceRange.value = r,
                  onChangeEnd: (_) => pc.applyFilters(),
                ),
                SizedBox(height: 24),

                // — Rating RangeSlider —
                Text(
                  'Rating: ${pc.ratingRange.value.start.toStringAsFixed(1)} – ${pc.ratingRange.value.end.toStringAsFixed(1)}',
                ),
                RangeSlider(
                  values: pc.ratingRange.value,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  labels: RangeLabels(
                    pc.ratingRange.value.start.toStringAsFixed(1),
                    pc.ratingRange.value.end.toStringAsFixed(1),
                  ),
                  onChanged: (r) => pc.ratingRange.value = r,
                  onChangeEnd: (_) => pc.applyFilters(),
                ),
                SizedBox(height: 32),

                // — Buttons —
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          pc.clearFilters();
                          Navigator.pop(context);
                        },
                        child: Text('Clear'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),

      body: Obx((){
        return Container(
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
          child: Center(
            child: pc.isLoading==true
                ?
            CircularProgressIndicator()
                :
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TypeAheadField<Product>(
                    suggestionsCallback: (String pattern) {
                      return pc.find(pattern);
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            labelText: 'Search',
                            suffixIcon: IconButton(
                              onPressed: (){
                                controller.clear();
                                focusNode.unfocus();
                              },
                              icon: Icon(Icons.close,),
                            ),
                          )
                      );
                    },
                    itemBuilder: (context, Product product) {
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${product.category}'),
                            Text('₹${product.price.toStringAsFixed(2)}'),
                          ],
                        ),
                      );
                    },
                    onSelected: (Product value) {
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>Product_Details(product: value,),),);
                    },
                  ),
                ),
                Expanded(
                  child: pc.filteredProducts.length==0?
                  Text("No Data Found",)
                      :
                  ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: pc.filteredProducts.length,
                    itemBuilder: (context,i){
                      var product=pc.filteredProducts[i];
                      return InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Product_Details(product: product)));
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Image.network(
                                  product.images[0],
                                  height: 180,
                                  width: double.maxFinite,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade900,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  product.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "R.s.${(product.price).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>CartScreen()));
        },
        backgroundColor:Colors.cyanAccent.shade100,
        child: Icon(
          Icons.shopping_cart_outlined,
          color: Colors.blue,
          size: 25,
        ),
      ),
    );
  }
}
