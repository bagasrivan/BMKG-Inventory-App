import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  
  List<Map<String, dynamic>> get items => _items;
  
  void addItem(Map<String, dynamic> item) {
    // Cek apakah barang sudah ada di keranjang
    if (!_items.any((element) => element['id'] == item['id'])) {
      _items.add(item);
      notifyListeners();
    }
  }
  
  void removeItem(int itemId) {
    _items.removeWhere((item) => item['id'] == itemId);
    notifyListeners();
  }
  
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Tambahkan validasi jumlah barang jika diperlukan
  bool canAddItem() {
    // Contoh: Batasi maksimal 10 barang
    return _items.length < 10;
  }
}