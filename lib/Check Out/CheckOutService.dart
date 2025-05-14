import 'package:flutter/material.dart';

import '../Model Classes/cart_model.dart';
import 'CheckOut.dart';
import 'User_Details_Form.dart';

class CheckOutService{
  static Future<void> showConfirmAndEditDetailsDialog(
      {required BuildContext context, CartModel? item}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'E-Shop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Do you want to change your details?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if(item==null)
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CheckoutScreen()),
              );
              else
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CheckoutScreen(item: item)),
              );
            },
            child: const Text('Continue without changing'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              bool res=await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => UserDetails()),
              );
              if(res){
                if(item==null)
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CheckoutScreen(item: item)),
                  );
                else
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CheckoutScreen(item: item)),
                  );
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}