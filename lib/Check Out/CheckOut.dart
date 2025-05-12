import 'package:e_shop/Check%20Out/OrderSuccessScreen.dart';
import 'package:e_shop/DBHelper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_shop/Model Classes/cart_model.dart';
import '../Controller/cart_controller.dart';

enum PaymentMethod { cod, card, upi }

class CheckoutScreen extends StatefulWidget {
  final CartModel? item;

  const CheckoutScreen({Key? key, this.item}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.cod;

  final TextEditingController _couponController = TextEditingController();
  String? _appliedCoupon;
  double _couponDiscount = 0;
  bool _freeDelivery = false;
  double _cashBack = 0;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _onPaymentMethodChanged(PaymentMethod method) {
    if (_appliedCoupon == 'get50' && method != PaymentMethod.upi) {
      // Remove cashback coupon when switching off UPI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GET50 coupon removed: cashback only on UPI')),  );
      setState(() {
        _appliedCoupon = null;
        _cashBack = 0;
      });
    }
    setState(() => _selectedMethod = method);
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();
    final items = widget.item != null
        ? [widget.item!]
        : cartController.cartItems;

    double subTotal = 0;
    double totalTax = 0;
    for (var item in items) {
      subTotal += item.price * item.quantity;
      totalTax += (item.price * item.tax / 100) * item.quantity;
    }
    double shippingFee = _freeDelivery ? 0 : (subTotal + totalTax) * 0.01;
    double total = subTotal + totalTax + shippingFee - _couponDiscount - _cashBack;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7F1), Color(0xFFB2DFDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qty: ${item.quantity}'),
                        Text('Price: ₹${item.price.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: Text(
                      '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 10),

              const Divider(height: 30, thickness: 1.2),

              // Coupon Section
              if (_appliedCoupon != null)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.local_offer, color: Colors.teal),
                    title: Text('Coupon: ${_appliedCoupon!.toUpperCase()}'),
                    subtitle: Text(
                        _couponDiscount > 0 ? 'Discount: ₹${_couponDiscount.toStringAsFixed(2)}'
                            :
                        _cashBack>0 ? 'Cashback: ₹${_cashBack.toStringAsFixed(2)}': 'Free Shipping'
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _appliedCoupon = null;
                          _couponDiscount = 0;
                          _freeDelivery = false;
                          _cashBack = 0;
                        });
                      },
                    ),
                  ),
                ),

              ElevatedButton.icon(
                onPressed: () => _showCouponSheet(items),
                icon: const Icon(Icons.local_offer_outlined),
                label: Text(_appliedCoupon == null
                    ? 'Apply Coupon'
                    : 'Change Coupon'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
              const Divider(height: 30, thickness: 1.2),

              // Payment Method
              _buildPaymentMethod(),
              const Divider(height: 30, thickness: 1.2),

              // Summary
              _buildSummaryRow('Subtotal', subTotal),
              if (_couponDiscount > 0)
                _buildSummaryRow('Discount', -_couponDiscount),
              if (_cashBack > 0)
                _buildSummaryRow('Cashback', -_cashBack),
              _buildSummaryRow('Tax', totalTax),
              _buildSummaryRow('Shipping', shippingFee,
                  isFreeShipping: _freeDelivery),
              const SizedBox(height: 10),
              _buildSummaryRow('Total', total, isTotal: true),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_)=>AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text(
                          'E-Shop',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text("Do you want to place order?"),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text("No",style: TextStyle(color: Colors.red),),
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_)=> OrderSuccessScreen(
                                    items: items, subTotal: subTotal, tax: totalTax, shipping: shippingFee,
                                    discount: _couponDiscount, cashback: _cashBack, total: total),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order placed successfully!')),
                              );
                            },
                            child: Text("Continue",style: TextStyle(color: Colors.blue),),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Place Order', style: TextStyle(fontSize: 18)),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: PaymentMethod.values.map((method) {
            IconData icon;
            String label;
            switch (method) {
              case PaymentMethod.cod:
                icon = Icons.money;
                label = 'COD';
                break;
              case PaymentMethod.card:
                icon = Icons.credit_card;
                label = 'Card';
                break;
              case PaymentMethod.upi:
                icon = Icons.account_balance_wallet;
                label = 'UPI';
                break;
            }
            final isSelected = method == _selectedMethod;
            return GestureDetector(
              onTap: () => _onPaymentMethodChanged(method),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.teal : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.teal.shade700 : Colors.grey,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showCouponSheet(List<CartModel> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final controller = TextEditingController();
        String errorMsg = '';

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Apply Coupon',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Coupon Code',
                              border: const OutlineInputBorder(),
                              errorText: errorMsg.isEmpty ? null : errorMsg,
                            ),
                            onChanged: (_) {
                              if (errorMsg.isNotEmpty) {
                                setModalState(() => errorMsg = '');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final code = controller.text.trim().toLowerCase();
                            final msg = _applyCoupon(code, items);
                            setModalState(() => errorMsg = msg.startsWith('Applied') || msg.startsWith('Free') || msg.contains('cashback') ? '' : msg);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 8),
                            child: Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        children: const [
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.local_offer),
                              title: Text('COOL7'),
                              subtitle: Text('20% off on refrigerators, ACs, coolers'),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.local_shipping),
                              title: Text('USM794'),
                              subtitle: Text('Free shipping'),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.account_balance_wallet),
                              title: Text('GET50'),
                              subtitle: Text('₹500 cashback on UPI payments'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _applyCoupon(String code, List<CartModel> items) {
    double discount = 0;
    bool freeShip = false;
    double cb = 0;
    String msg;

    switch (code) {
      case 'cool7':
        for (var it in items) {
          final cat = it.category.toLowerCase();
          if (['refrigerators', 'air conditioners', 'air coolers'].contains(cat)) {
            discount += it.price * it.quantity * 0.2;
          }
        }
        if (discount > 0) {
          msg = 'Applied COOL7: saved ₹${discount.toStringAsFixed(2)}';
        } else {
          msg = 'No eligible items for COOL7';
        }
        break;
      case 'usm794':
        freeShip = true;
        msg = 'Free shipping applied';
        break;
      case 'get50':
        if (_selectedMethod == PaymentMethod.upi) {
          cb = 500;
          msg = 'Applied GET50: ₹500 cashback';
        } else {
          msg = 'GET50 works only with UPI';
        }
        break;
      default:
        msg = 'Invalid coupon code';
    }

    final success = msg.startsWith('Applied') || msg.startsWith('Free');
    if (success) {
      setState(() {
        _appliedCoupon = code;
        _couponDiscount = discount;
        _freeDelivery = freeShip;
        _cashBack = cb;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      Navigator.pop(context);
    }
    return msg;
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isTotal = false, bool isFreeShipping = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w400)),
          Text(isFreeShipping
              ? 'Free Shipping'
              : '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: isTotal ? Colors.redAccent : Colors.black87)),
        ],
      ),
    );
  }
}