import 'package:e_shop/Cart/edit_cart_item.dart';
import 'package:e_shop/Check%20Out/CheckOutService.dart';
import 'package:e_shop/Controller/cart_controller.dart';
import 'package:e_shop/Controller/product_controller.dart';
import 'package:e_shop/DBHelper.dart';
import 'package:e_shop/Model Classes/cart_model.dart';
import 'package:e_shop/Model%20Classes/products_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  final CartController cartController = Get.find();
  final DBHelper db = DBHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE3FFF5),
                Color(0xFFF8FFFD),
                Color(0xFFE3FFF5),
              ],
            ),
          ),
        ),
        title: Text("Your Cart"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.remove_shopping_cart),
            tooltip: "Clear the cart",
            onPressed: () async{
              if(cartController.cartItems.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your cart is empty")));
                return;
              }
              showDialog(
                context: context,
                builder: (_)=>AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    'E-Shop',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Text("Are you sure to clear cart?"),
                  actions: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("No",style: TextStyle(color: Colors.blue),),
                    ),
                    TextButton(onPressed: () async {
                      Navigator.pop(context);
                      int res=await db.emptyCart();
                      await cartController.onClear();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Total $res items removed from cart")));
                    }, child: Text("Clear",style: TextStyle(color: Colors.red),)),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Obx(() {
          if (cartController.isLoading==true) {
            return Center(child: CircularProgressIndicator());
          }
          if (cartController.cartItems.isEmpty) {
            return Center(child: Text("Your Cart is Empty"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: cartController.cartItems.length,
            itemBuilder: (context, i) {
              CartModel cartItem = cartController.cartItems[i];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                color: Color(0xFFf0f9f0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_red_eye_rounded, color: Colors.blue),
                            onPressed: () {
                              ProductsController pc=Get.find();
                              Product product=pc.products.firstWhere((item)=>item.id==cartItem.product_id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context)=>EditCartItem(cartItem: cartItem, index:i, product: product,),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await db.delete_by_id(cartItem.id!);
                              await cartController.on_delete(cartItem);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item is removed from cart")));
                            },
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              cartItem.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          productDetailsWidget(cartItem),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,color: Colors.red,),
                                onPressed: () async {
                                  await cartController.decrement_quntity(i);
                                },
                              ),
                              Text('${cartItem.quantity}', style: TextStyle(fontSize: 16)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,color: Colors.green,),
                                onPressed: () async {
                                  var res=await cartController.increment_quntity(i);
                                  if(res==-1)
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("You can only order 3 Units of this product"),
                                    ),);
                                },
                              ),

                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () async{
          cartController.cartItems.isEmpty
              ?
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your cart is empty")))
              :
          CheckOutService.showConfirmAndEditDetailsDialog(context: context);
        },
        icon: Icon(Icons.shopping_cart_checkout_rounded,color:Colors.white,),
        label: Text("CheckOut",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal.shade500,         // your preferred color
        elevation: 4.0,
        shape: RoundedRectangleBorder(        // optional: for rounded corners
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget productDetailsWidget(CartModel cartItem){
    double totalPrice = double.parse((cartItem.price + ((cartItem.price * cartItem.tax) / 100)).toStringAsFixed(2));
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            cartItem.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: 6),

          // Price per Unit & Tax
          Row(
            children: [
              Text(
                "Unit Price: ",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              Text(
                "₹${cartItem.price.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.green.shade700,fontWeight: FontWeight.w400,),
              ),
              SizedBox(width: 16),
              Text(
                "Tax: ",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              Text(
                "${cartItem.tax}%",
                style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w400,),
              ),
            ],
          ),
          SizedBox(height: 6),

          // Total Price Calculation
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Total Amount: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800),
                ),
                TextSpan(
                  text: "₹$totalPrice × ${cartItem.quantity}\n",
                  style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                ),
                TextSpan(
                  text: "=₹${cartItem.total_amount.toStringAsFixed(2)}",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.green.shade800),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          Text.rich(
            TextSpan(
              children: cartItem.variants.entries.map((e) {
                return TextSpan(
                  children: [
                    TextSpan(
                      text: "${e.key}: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    TextSpan(
                      text: "${e.value}\n",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}