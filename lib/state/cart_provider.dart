// CartProvider — shared state across screens ≈ an Activity-scoped /
// app-scoped ViewModel (e.g. `by activityViewModels()`).
import 'package:flutter/foundation.dart';

class CartItem {
  const CartItem(this.name, this.price);
  final String name;
  final double price;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Expose an unmodifiable view ≈ exposing LiveData, not MutableLiveData.
  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.length;
  double get total => _items.fold(0, (sum, i) => sum + i.price);

  void add(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
