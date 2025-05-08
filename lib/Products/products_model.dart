import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String description;
  final Variants variants;
  final double price;
  final double ratings;
  final double tax;
  final double shipping;
  final String arrivalDate;
  final List<Review> reviews;
  final String? category;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.variants,
    required this.price,
    required this.ratings,
    required this.tax,
    required this.shipping,
    required this.arrivalDate,
    required this.reviews,
    this.category,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      variants: Variants.fromJson(json['variants'] as Map<String, dynamic>),
      price: (json['price'] as num).toDouble(),
      ratings: (json['ratings'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      arrivalDate: json['arrival_date'] as String,
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: json['category'] as String?,
      images: List<String>.from(json['images'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'variants': variants.toJson(),
      'price': price,
      'ratings': ratings,
      'arrival_date': arrivalDate,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'category': category,
      'images': images,
    };
  }
}

class Variants {
  final List<String>? colors;
  final List<String>? storages;
  final List<String>? rams;
  final List<String>? sizes;
  final List<String>? capacities;
  final List<String>? voltages;
  final List<String>? wattages;
  final List<String>? types;
  final List<String>? tonnages;
  final List<String>? connectivity;

  Variants({
    this.colors,
    this.storages,
    this.rams,
    this.sizes,
    this.capacities,
    this.voltages,
    this.wattages,
    this.types,
    this.tonnages,
    this.connectivity,
  });

  factory Variants.fromJson(Map<String, dynamic> json) {
    return Variants(
      colors: json['colors'] != null ? List<String>.from(json['colors']) : null,
      storages: json['storages'] != null ? List<String>.from(json['storages']) : null,
      rams: json['rams'] != null ? List<String>.from(json['rams']) : null,
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : null,
      capacities: json['capacities'] != null ? List<String>.from(json['capacities']) : null,
      voltages:
      json['voltages'] != null ? List<String>.from(json['voltages']) : null,
      wattages:
      json['wattages'] != null ? List<String>.from(json['wattages']) : null,
      types: json['types'] != null ? List<String>.from(json['types']) : null,
      tonnages:
      json['tonnages'] != null ? List<String>.from(json['tonnages']) : null,
      connectivity:
      json['connectivity'] != null ? List<String>.from(json['connectivity']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (colors != null) data['colors'] = colors;
    if (storages != null) data['storages'] = storages;
    if (rams != null) data['rams'] = rams;
    if (sizes != null) data['sizes'] = sizes;
    if (capacities != null) data['capacities'] = capacities;
    if (voltages != null) data['voltages'] = voltages;
    if (wattages != null) data['wattages'] = wattages;
    if (types != null) data['types'] = types;
    if (tonnages != null) data['tonnages'] = tonnages;
    if (connectivity != null) data['connectivity'] = connectivity;
    return data;
  }
}

class Review {
  final String user;
  final double rating;
  final String comment;

  Review({
    required this.user,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      user: json['user'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'rating': rating,
      'comment': comment,
    };
  }
}

// Utility functions for encoding/decoding
List<Product> productsFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productsToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));