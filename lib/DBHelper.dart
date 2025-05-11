import 'package:e_shop/Model%20Classes/cart_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DBHelper{

  static Database? _db;
  static DBHelper instance=DBHelper._constructor();

  DBHelper._constructor();

  String Table_Name="cart";

  Future<Database> get database async{
    if(_db!=null) return _db!;
    _db=await _getdatabase();
    return _db!;
  }

  Future<Database> _getdatabase() async{
    final db_Dir_Path=await getDatabasesPath();
    final db_Path=join(db_Dir_Path,"cart.db");
    final db=await openDatabase(
        version: 1,
        db_Path,
        onCreate: (db,version){
          db.execute('''CREATE TABLE cart(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER,
          name TEXT,
          variants TEXT UNIQUE,
          price REAL,
          tax REAL,
          category TEXT,
          image TEXT,
          quantity INTEGER,
          total_amount REAL
          )''');
      }
    );
    return db;
  }

  //Add item in cart table
  Future<int> add_to_cart(CartModel cart_item) async{
    final _db = await database;
    return _db.insert(Table_Name, cart_item.toMap(),);
  }

  //fetch all items from cart table
  Future<List<CartModel>> fetch_all() async{
    final _db=await database;
    final List<Map<String, dynamic>> result=await _db.query(Table_Name);
    return result.map((itm) => CartModel.fromMap(itm)).toList();
  }

  //delete item from cart table by item id
  Future<int> delete_by_id(int id) async{
    final _db=await database;
    return _db.delete(Table_Name,where: 'id = ?',whereArgs: [id]);
  }

  //delete all items from the cart
  Future<int> emptyCart() async{
    final _db=await database;
    return _db.delete(Table_Name);
  }

  Future<int> updateQuantity(int id,int qty, var amt) async{
    final _db=await database;
    return _db.update(Table_Name ,{"quantity": qty,"total_amount":amt} ,where: 'id = ?' ,whereArgs: [id]);
  }

  Future<int> updateCartItem(int id, String updatedVariants, int quantity, double amt) async {
    final _db=await database;
    return _db.update(
      'cart',
      {
        'variants': updatedVariants,
        'quantity': quantity,
        "total_amount":amt,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}