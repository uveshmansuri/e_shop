import 'dart:convert';

class CartModel{
  final int? id;
  final int product_id;
  final String name;
  Map<String,String> variants;
  final double price;
  final double tax;
  final String category;
  final String image;
  int quantity;
  double total_amount;

  CartModel({
    this.id,
    required this.product_id,
    required this.name,
    required this.variants,
    required this.price,
    required this.tax,
    required this.category,
    required this.image,
    required this.quantity,
    required this.total_amount,
  });

  Map<String, dynamic> toMap() => {
    'product_id': product_id,
    'name': name,
    'variants': jsonEncode(variants),
    'price': price,
    'tax': tax,
    'category': category,
    'image': image,
    'quantity': quantity,
    'total_amount': total_amount,
  };

  factory CartModel.fromMap(Map<String, dynamic> itm){
    return CartModel(
      id: itm['id'],
      product_id: itm['product_id'],
      name: itm['name'],
      variants: Map<String, String>.from(jsonDecode(itm['variants'])),
      price: itm['price'],
      tax: itm['tax'],
      category: itm['category'],
      image: itm['image'],
      quantity: itm["quantity"],
      total_amount: itm["total_amount"]
    );
  }
}
