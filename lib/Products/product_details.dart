import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_shop/Check%20Out/User_Details_Form.dart';
import 'package:e_shop/Controller/cart_controller.dart';
import 'package:e_shop/DBHelper.dart';
import 'package:e_shop/Model%20Classes/cart_model.dart';
import 'package:e_shop/Model%20Classes/products_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Check Out/CheckOutService.dart';

class Product_Details extends StatefulWidget {
  final Product product;
  const Product_Details({super.key,required this.product});

  @override
  State<Product_Details> createState() => _Product_DetailsState();
}

class _Product_DetailsState extends State<Product_Details> {

  int _currentImage = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  String? selectedColor;
  String? selectedStorage;
  String? selectedRam;
  String? selectedSize;
  String? selectedCapacitie;
  String? selectedVoltage;
  String? selectedWattage;
  String? selectedType;
  String? selectedTonnage;
  String? selectedConnectivity;

  int quantity=1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
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
        title: Text("E-Shop"),
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
        child: _build_Detail(),
      ),

      bottomNavigationBar: _buildBottomBar(),
    );
  }

  //Product Details
  Widget _build_Detail(){
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage_Slider(widget.product.images),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildTitleSection(),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildDescriptionSection(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildVariantsSection(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildQuantity(),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildShippingSection(),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPolicySection(),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildReviewsSection(),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }

  //Image gallery of Product's images with slider
  Widget _buildImage_Slider(List<String> images) {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: images.length,
          itemBuilder: (ctx, i, real) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(images[i], width: double.infinity, fit: BoxFit.cover),
            );
          },
          options: CarouselOptions(
            height: 300,
            enableInfiniteScroll: false,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            onPageChanged: (idx, reason) {
              setState(() => _currentImage = idx);
            },
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((e) {
            return GestureDetector(
              child: Container(
                width: _currentImage == e.key ? 12 : 8,
                height: _currentImage == e.key ? 12 : 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImage == e.key
                      ? Color(0xFF00AD42)
                      : Colors.grey[400],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  //Design of Product Name ratting price and tax related details
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.product.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Row(
          children: [
            Text("₹${widget.product.price}", style: TextStyle(fontSize: 22, color: Colors.green[700])),
            SizedBox(width: 16),
            Text("Tax: ${widget.product.tax}%", style: TextStyle(fontSize: 16, color: Colors.blue)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            StarRating(
              rating: widget.product.ratings.toDouble(),
              size: 22,
              allowHalfRating: true,
              starCount: 5,
            ),
            SizedBox(width: 8),
            Text("(${widget.product.reviews.length} reviews)", style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  //Design of Products Description
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text(widget.product.description, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  //Design of Shipping Charge detail
  Widget _buildShippingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Shipping: 2% of your final amount\nDelivery in 7 working days",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  //Design of policy
  Widget _buildPolicySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.cached, size: 20),
                    Icon(Icons.block, size: 28, color: Colors.red),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  "No Replacement",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.money_outlined, size: 28),
                SizedBox(height: 4),
                Text(
                  "Cash on Delivery",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline_outlined, size: 28, color: Colors.greenAccent),
                SizedBox(height: 4),
                Text(
                  "Verified Dealer",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Quentity
  Widget _buildQuantity(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16,),
      child: Row(
        children: [
          Text("Quantity: ",style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,color: quantity==1?Colors.grey:Colors.red,),
                    onPressed: () async {
                      setState(() {
                        if(quantity==1)
                          return;
                        quantity--;
                      });
                    },
                  ),
                  Text('$quantity', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline,color: quantity==3?Colors.grey:Colors.green,),
                    onPressed: () async {
                      setState(() {
                        if(quantity==3){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("You can only order 3 Units of this product"),
                          ),);
                          return;
                        }
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Customer Review of particular Product
  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        ...widget.product.reviews.map((r) => _buildSingleReview(r)).toList(),
      ],
    );
  }

  Widget _buildSingleReview(Review review) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(review.user[0])),
        title: Text(review.user, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(review.comment),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StarRating(
              rating: review.rating.toDouble(),
              size: 15,
              allowHalfRating: true,
            ),
          ],
        ),
      ),
    );
  }

  //Products variates selection section for all avillable variants
  Widget _buildVariantsSection() {

    selectedColor ??= widget.product.variants.colors?.isNotEmpty == true ? widget.product.variants.colors!.first : null;
    selectedStorage ??= widget.product.variants.storages?.isNotEmpty == true ? widget.product.variants.storages!.first : null;
    selectedRam ??= widget.product.variants.rams?.isNotEmpty == true ? widget.product.variants.rams!.first : null;
    selectedSize ??= widget.product.variants.sizes?.isNotEmpty == true ? widget.product.variants.sizes!.first : null;
    selectedVoltage ??= widget.product.variants.voltages?.isNotEmpty == true ? widget.product.variants.voltages!.first : null;
    selectedWattage ??= widget.product.variants.wattages?.isNotEmpty == true ? widget.product.variants.wattages!.first : null;
    selectedType ??= widget.product.variants.types?.isNotEmpty == true ? widget.product.variants.types!.first : null;
    selectedTonnage ??= widget.product.variants.tonnages?.isNotEmpty == true ? widget.product.variants.tonnages!.first : null;
    selectedConnectivity ??= widget.product.variants.connectivity?.isNotEmpty == true ? widget.product.variants.connectivity!.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.product.variants.colors != null)
            _buildChoiceChips("Colors", widget.product.variants.colors!, selectedColor, (val) {
              setState(() => selectedColor = val);
            }),
          if (widget.product.variants.storages != null)
            _buildChoiceChips("Storage", widget.product.variants.storages!, selectedStorage, (val) {
              setState(() => selectedStorage = val);
            }),
          if (widget.product.variants.rams != null)
            _buildChoiceChips("RAM", widget.product.variants.rams!, selectedRam, (val) {
              setState(() => selectedRam = val);
            }),
          if (widget.product.variants.sizes != null)
            _buildChoiceChips("Sizes", widget.product.variants.sizes!, selectedSize, (val) {
              setState(() => selectedSize = val);
            }),
          if (widget.product.variants.voltages != null)
            _buildChoiceChips("Voltages", widget.product.variants.voltages!, selectedVoltage, (val) {
              setState(() => selectedVoltage = val);
            }),
          if (widget.product.variants.wattages != null)
            _buildChoiceChips("Wattages", widget.product.variants.wattages!, selectedWattage, (val) {
              setState(() => selectedWattage = val);
            }),
          if (widget.product.variants.types != null)
            _buildChoiceChips("Type", widget.product.variants.types!, selectedType, (val) {
              setState(() => selectedType = val);
            }),
          if (widget.product.variants.tonnages != null)
            _buildChoiceChips("Tonnages", widget.product.variants.tonnages!, selectedTonnage, (val) {
              setState(() => selectedTonnage = val);
            }),
          if (widget.product.variants.connectivity != null)
            _buildChoiceChips("Connectivity", widget.product.variants.connectivity!, selectedConnectivity, (val) {
              setState(() => selectedConnectivity = val);
            }),
        ],
      ),
    );
  }

  //choicechip for variant selection
  Widget _buildChoiceChips(String title, List<String> options, String? selectedValue, ValueChanged<String?> onSelected,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selectedValue;
            return ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onSelected(isSelected ? null : opt),
              selectedColor: Color(0xFF00AD42).withOpacity(0.2),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  //Bottom buttons for add to cart and buy now
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  add_to_cart();
                },
                icon: Icon(Icons.add_shopping_cart),
                label: Text("Add to Cart"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF00AD42)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  checkout();
                },
                icon: Icon(Icons.shopping_bag,color: Colors.white,),
                label: Text("Buy Now",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00AD42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void add_to_cart() async {
    final prefs = await SharedPreferences.getInstance();
    bool isAvail = prefs.getBool('is_avil') ?? false;

    // If not available, navigate to user details form and wait for result
    if (!isAvail) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => UserDetails()),
      );
      // If user completed form, set flag and continue; else bail out
      if (result == true) {
        await prefs.setBool('is_avil', true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please complete your details to add to cart"))
        );
        return;
      }
    }

    // At this point, details are available — proceed with add to cart
    Map<String,String> variant = get_variants();
    var price = widget.product.price;
    var tax = widget.product.tax;
    double totalPrice = double.parse(
        (price + ((price * tax) / 100)).toStringAsFixed(2)
    );

    final cartItem = CartModel(
      product_id: widget.product.id,
      name: widget.product.name,
      variants: variant,
      price: price,
      tax: tax,
      category: widget.product.category!,
      image: widget.product.images[0],
      quantity: quantity,
      total_amount: totalPrice * quantity,
    );

    try {
      await DBHelper.instance.add_to_cart(cartItem);
      await Get.find<CartController>().addItem();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product Added in Cart"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product is Already in Cart"))
      );
      print(e);
    }
  }

  void checkout() async {
    final prefs = await SharedPreferences.getInstance();
    bool isAvail = prefs.getBool('is_avil') ?? false;

    // Check details flag
    if (!isAvail) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => UserDetails()),
      );
      if (result == true) {
        await prefs.setBool('is_avil', true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please complete your details to checkout"))
        );
        return;
      }
    }

    // Details confirmed — proceed to checkout
    Map<String,String> variant = get_variants();
    var price = widget.product.price;
    var tax = widget.product.tax;
    double totalPrice = double.parse(
        (price + ((price * tax) / 100)).toStringAsFixed(2)
    );

    final product = CartModel(
      product_id: widget.product.id,
      name: widget.product.name,
      variants: variant,
      price: price,
      tax: tax,
      category: widget.product.category!,
      image: widget.product.images[0],
      quantity: quantity,
      total_amount: totalPrice * quantity,
    );

    CheckOutService.showConfirmAndEditDetailsDialog(
      item: product,
      context: context,
    );
  }

  Map<String,String> get_variants(){
    Map<String,String> selectedVariant={};
    selectedColor != null ?selectedVariant["Color"]= selectedColor!:null;
    selectedStorage != null ?selectedVariant["Storage"]= selectedStorage!:null;
    selectedRam != null ?selectedVariant["Ram"]= selectedRam!:null;
    selectedSize != null ?selectedVariant["Size"]= selectedSize!:null;
    selectedCapacitie != null ?selectedVariant["Capacitie"]= selectedCapacitie!:null;
    selectedVoltage != null ?selectedVariant["Voltage"]= selectedVoltage!:null;
    selectedWattage != null ?selectedVariant["Wattage"]= selectedWattage!:null;
    selectedType != null ?selectedVariant["Type"]= selectedType!:null;
    selectedTonnage != null ?selectedVariant["Tonnage"]= selectedTonnage!:null;
    selectedConnectivity != null ?selectedVariant["Connectivity"]= selectedConnectivity!:null;
    return selectedVariant;
  }
}