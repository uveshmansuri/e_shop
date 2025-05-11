import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_shop/Controller/cart_controller.dart';
import 'package:e_shop/DBHelper.dart';
import 'package:e_shop/Model%20Classes/cart_model.dart';
import 'package:e_shop/Model%20Classes/products_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCartItem extends StatefulWidget {
  final CartModel cartItem;
  final int index;
  final Product product;

  EditCartItem({
    required this.cartItem,
    required this.index,
    required this.product,
  });

  @override
  State<EditCartItem> createState() => _EditCartItemState();
}

class _EditCartItemState extends State<EditCartItem> {
  int _currentImage = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  final CartController cartController = Get.find();

  String? selectedColor, selectedStorage, selectedRam, selectedSize,
      selectedCapacitie, selectedVoltage, selectedWattage, selectedType,
      selectedTonnage, selectedConnectivity;

  DBHelper _databse=DBHelper.instance;

  late double total_amount;

  @override
  void initState() {
    super.initState();
    total_amount=widget.cartItem.total_amount;
    final variants = widget.cartItem.variants;
    selectedColor = variants["Color"];
    selectedStorage = variants["Storage"];
    selectedRam = variants["Ram"];
    selectedSize = variants["Size"];
    selectedCapacitie = variants["Capacitie"];
    selectedVoltage = variants["Voltage"];
    selectedWattage = variants["Wattage"];
    selectedType = variants["Type"];
    selectedTonnage = variants["Tonnage"];
    selectedConnectivity = variants["Connectivity"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Preview")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FFFD), Color(0xFFE3FFF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSlider(widget.product.images),
              _buildTitleSection(),
              Divider(),
              _buildDescriptionSection(),
              Divider(),
              _buildPriceTaxSection(),
              _buildQuantitySection(),
              Divider(),
              _buildVariantsSection(),
              SizedBox(height: 16),
              Center(child: _buildUpdateButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider(List<String> images) {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: images.length,
          itemBuilder: (ctx, i, real) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(images[i], width: double.infinity, fit: BoxFit.cover),
          ),
          options: CarouselOptions(
            height: 300,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, _) => setState(() => _currentImage = index),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((e) {
            return Container(
              width: _currentImage == e.key ? 12 : 8,
              height: _currentImage == e.key ? 12 : 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentImage == e.key ? Color(0xFF00AD42) : Colors.grey[400],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(widget.product.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(widget.product.description, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPriceTaxSection(){
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            "Unit Price: ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          Text(
            "₹${widget.cartItem.price.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.green.shade700,fontWeight: FontWeight.w400,),
          ),
          SizedBox(width: 16),
          Text(
            "Tax: ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
          ),
          Text(
            "${widget.cartItem.tax}%",
            style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w400,),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    double tax=double.parse(((widget.cartItem.price*widget.cartItem.tax)/100).toStringAsFixed(2));
    double totalPrice = double.parse((widget.cartItem.price + tax).toStringAsFixed(2));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Amount: ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800),
                    ),
                    TextSpan(
                      text: "₹${widget.cartItem.price}",
                      style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                    ),
                    TextSpan(
                      text: " + ",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    TextSpan(
                      text:"₹$tax Tax\n",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    TextSpan(
                      text: "₹${double.parse((widget.cartItem.price + tax).toStringAsFixed(2))}",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.green.shade800),
                    ),
                    TextSpan(
                      text: "\nTotal Amount: ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade800),
                    ),
                    TextSpan(
                      text: "₹$totalPrice × ${widget.cartItem.quantity}\n",
                      style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                    ),
                    TextSpan(
                      text: "₹${total_amount.toStringAsFixed(2)}",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.green.shade800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline,color: Colors.red,),
                onPressed: () {
                  setState(() {
                    if(widget.cartItem.quantity==1){
                      remove_product_dialogue();
                      return;
                    }
                    widget.cartItem.quantity-=1;
                    total_amount=totalPrice*widget.cartItem.quantity;
                  });
                },
              ),
              Text('${widget.cartItem.quantity}', style: TextStyle(fontSize: 18)),
              IconButton(
                icon: Icon(Icons.add_circle_outline,color: Colors.green,),
                onPressed: () async {
                  setState(() {
                    if(widget.cartItem.quantity==3){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("You can only order 3 Units of this product"),
                      ),);
                      return;
                    }
                    widget.cartItem.quantity+=1;
                    total_amount=totalPrice*widget.cartItem.quantity;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsSection() {
    final variants = widget.product.variants;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (variants.colors != null) _buildChoiceChips("Color", variants.colors!, selectedColor, (val) => setState(() => selectedColor = val)),
          if (variants.storages != null) _buildChoiceChips("Storage", variants.storages!, selectedStorage, (val) => setState(() => selectedStorage = val)),
          if (variants.rams != null) _buildChoiceChips("RAM", variants.rams!, selectedRam, (val) => setState(() => selectedRam = val)),
          if (variants.sizes != null) _buildChoiceChips("Size", variants.sizes!, selectedSize, (val) => setState(() => selectedSize = val)),
          if (variants.voltages != null) _buildChoiceChips("Voltage", variants.voltages!, selectedVoltage, (val) => setState(() => selectedVoltage = val)),
          if (variants.wattages != null) _buildChoiceChips("Wattage", variants.wattages!, selectedWattage, (val) => setState(() => selectedWattage = val)),
          if (variants.types != null) _buildChoiceChips("Type", variants.types!, selectedType, (val) => setState(() => selectedType = val)),
          if (variants.tonnages != null) _buildChoiceChips("Tonnage", variants.tonnages!, selectedTonnage, (val) => setState(() => selectedTonnage = val)),
          if (variants.connectivity != null) _buildChoiceChips("Connectivity", variants.connectivity!, selectedConnectivity, (val) => setState(() => selectedConnectivity = val)),
        ],
      ),
    );
  }

  Widget _buildChoiceChips(String label, List<String> options, String? selected, ValueChanged<String?> onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            return ChoiceChip(
              label: Text(opt),
              selected: selected == opt,
              onSelected: (_) => onSelected(selected == opt ? null : opt),
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

  Widget _buildUpdateButton() {
    return ElevatedButton.icon(
      onPressed: () async{
        final updatedVariants = getSelectedVariants();
        final quantity = widget.cartItem.quantity;
        final amt=double.parse(total_amount.toStringAsFixed(2));
        update_cart_dialogue(updatedVariants,quantity,amt);
      },
      icon: Icon(Icons.file_upload_outlined,color: Colors.white,),
      label: Text("Update Cart"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF00AD42),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Map<String, String> getSelectedVariants() {
    final Map<String, String> variants = {};
    if (selectedColor != null) variants["Color"] = selectedColor!;
    if (selectedStorage != null) variants["Storage"] = selectedStorage!;
    if (selectedRam != null) variants["Ram"] = selectedRam!;
    if (selectedSize != null) variants["Size"] = selectedSize!;
    if (selectedCapacitie != null) variants["Capacitie"] = selectedCapacitie!;
    if (selectedVoltage != null) variants["Voltage"] = selectedVoltage!;
    if (selectedWattage != null) variants["Wattage"] = selectedWattage!;
    if (selectedType != null) variants["Type"] = selectedType!;
    if (selectedTonnage != null) variants["Tonnage"] = selectedTonnage!;
    if (selectedConnectivity != null) variants["Connectivity"] = selectedConnectivity!;
    return variants;
  }

  void remove_product_dialogue(){
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text("E-Shop"),
      content: Text("Do you want to remove this item from cart?"),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Text("NO"),
        ),
        TextButton(
          onPressed: () async{
            await _databse.delete_by_id(widget.cartItem.id!);
            await cartController.on_delete(widget.cartItem);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text("Yes"),
        ),
      ],
    ));
  }

  void update_cart_dialogue(variants, qty, amt) async{
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text("E-Shop"),
      content: Text("Do you want to update cart?"),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Text("NO"),
        ),
        TextButton(
          onPressed: () async{
            update_cart_item(variants, qty, amt);
            Navigator.pop(context);
          },
          child: Text("Yes"),
        ),
      ],
    ));
  }

  void update_cart_item(var variants, var qty, double amt) async{
    try{
      var res=await _databse.updateCartItem(widget.cartItem.id!, jsonEncode(variants), qty, amt);
      if(res==1){
        Navigator.pop(context);
        cartController.updateCart();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your Cart has been updated")));
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected Variant's Product is already in cart")));
    }
  }
}