import 'package:e_shop/DBHelper.dart';
import 'package:e_shop/Model%20Classes/cart_model.dart';
import 'package:get/get.dart';

class CartController extends GetxController{
  final DBHelper _dbHelper = DBHelper.instance;

  var cartItems = <CartModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    isLoading.value = true;
    cartItems.assignAll(await _dbHelper.fetch_all());
    isLoading.value = false;
  }

  Future<void> addItem()async {
    loadCart();
    cartItems.refresh();
  }

  Future<void> on_delete(CartModel itm) async{
    cartItems.remove(itm);
  }

  Future<void> onClear() async{
    cartItems.clear();
  }

  Future<int> increment_quntity(int index) async{
    if(cartItems[index].quantity==3){
      return -1;
    }
    cartItems[index].quantity+=1;
    await update_total_amount(index);
    int flag=await updateQuntity(cartItems[index].id!,cartItems[index].quantity,cartItems[index].total_amount);
    cartItems.refresh();
    return flag;
  }

  Future<int> decrement_quntity(int index) async{
    if(cartItems[index].quantity==1){
      _dbHelper.delete_by_id(cartItems[index].id!);
      await on_delete(cartItems[index]);
      cartItems.refresh();
      return 0;
    }
    cartItems[index].quantity-=1;
    await update_total_amount(index);
    int flag=await updateQuntity(cartItems[index].id!,cartItems[index].quantity,cartItems[index].total_amount);
    cartItems.refresh();
    return flag;
  }

  Future<void> update_total_amount(int index) async{
    var total_price= double.parse((cartItems[index].price +((cartItems[index].price*cartItems[index].tax)/100)).toStringAsFixed(2));
    cartItems[index].total_amount=total_price*cartItems[index].quantity;
  }

  Future<int> updateQuntity(int id,int qty, var amt) async{
    return _dbHelper.updateQuantity(id, qty, amt);
  }

  Future<void> updateCart() async{
    cartItems.clear();
    loadCart();
  }
}