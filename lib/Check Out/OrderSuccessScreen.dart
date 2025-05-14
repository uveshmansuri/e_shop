import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:e_shop/Model Classes/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderSuccessScreen extends StatefulWidget {
  final List<CartModel> items;
  final double subTotal;
  final double tax;
  final double shipping;
  final double discount;
  final double cashback;
  final double total;

  const OrderSuccessScreen({
    Key? key,
    required this.items,
    required this.subTotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.cashback,
    required this.total,
  }) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  String _name = '';
  String _mobile = '';
  String _address = '';
  String _city = '';
  String _state = '';
  String _pin = '';

  @override
  void initState() {
    super.initState();
    print(widget.items);
    _loadUserDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '';
      _mobile = prefs.getString('mobileNo') ?? '';
      _address = prefs.getString('address') ?? '';
      _city = prefs.getString('city') ?? '';
      _state = prefs.getString('state') ?? '';
      _pin = prefs.getString('pin') ?? '';
    });
  }

  pw.Document _buildPdfDocument() {
    final pdf = pw.Document();
    final orderDate = DateFormat('dd MMM yyyy').format(DateTime.now());
    final deliveryDate = DateFormat('dd MMM yyyy')
        .format(DateTime.now().add(const Duration(days: 7)));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text('E-Shop Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 8),
          if (_name.isNotEmpty) pw.Text('Customer: $_name', style: pw.TextStyle(fontSize: 12)),
          if (_mobile.isNotEmpty) pw.Text('Mobile: $_mobile', style: pw.TextStyle(fontSize: 12)),
          pw.Text('Address: ${[_address, _city, _state, _pin].where((s) => s.isNotEmpty).join(', ')}', style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Order Date: $orderDate'),
              pw.Text('Delivery By: $deliveryDate'),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Order Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.Table.fromTextArray(
            headers: ['Item', 'Qty', 'Unit Price (R.s)', 'Tax (%)', 'Total (Unit Price + Tax)R.s.'],
            data: widget.items.map((item) => [
              item.name,
              item.quantity.toString(),
              '${item.price.toStringAsFixed(2)}',
              '${item.tax.toStringAsFixed(0)}',
              '${(item.total_amount).toStringAsFixed(2)}',
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Subtotal: ${widget.subTotal.toStringAsFixed(2)} R.s.'),
                if (widget.discount > 0)
                  pw.Text('Discount: -${widget.discount.toStringAsFixed(2)} R.s.'),
                if (widget.cashback > 0)
                  pw.Text('Cashback: ${widget.cashback.toStringAsFixed(2)} R.s.'),
                pw.Text('Tax: ${widget.tax.toStringAsFixed(2)} R.s.'),
                pw.Text('Shipping: ${widget.shipping.toStringAsFixed(2)} R.s.'),
                pw.Divider(),
                pw.Text('Total: ${widget.total.toStringAsFixed(2)} R.s.', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Thank you for shopping with us!', style: pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
    return pdf;
  }

  Future<void> _printOrSharePdf(BuildContext context) async {
    final doc = _buildPdfDocument();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryDate = DateFormat('dd MMM yyyy')
        .format(DateTime.now().add(const Duration(days: 7)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        backgroundColor: Colors.tealAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.tealAccent.shade100,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 20),
                    const Text(
                      'Your order has been placed successfully!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Expected delivery by $deliveryDate',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _printOrSharePdf(context),
                      icon: const Icon(Icons.picture_as_pdf,color: Colors.red,),
                      label: const Text('Download/Print Invoice',style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text('Back to Home',style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
