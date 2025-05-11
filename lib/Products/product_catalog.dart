import 'package:e_shop/Cart/cart_screen.dart';
import 'package:e_shop/Controller/product_controller.dart';
import 'package:e_shop/Products/product_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Product_Catalog extends StatelessWidget {
  Product_Catalog({super.key});
  final ProductsController pc = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/e_comm_logo2.png"),
        title: Text("Welcome to E-Shop",style: TextStyle(color: Colors.cyanAccent.shade700,fontSize: 25,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CartScreen()));
            },
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.cyanAccent.shade700,
              size: 25,
            ),
          ),
        ],
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
            ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: pc.products.length,
              itemBuilder: (context,i){
                var product=pc.products[i];
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
        );
      }),
    );
  }
}
