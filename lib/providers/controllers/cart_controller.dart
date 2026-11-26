import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../data/database_helper.dart';

class CartProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Key: productId, Value: OrderItemModel
  final Map<int, OrderItemModel> _items = {};
  bool _isProcessingCheckout = false;
  String? _checkoutError;

  Map<int, OrderItemModel> get items => {..._items};
  bool get isProcessingCheckout => _isProcessingCheckout;
  String? get checkoutError => _checkoutError;

  int get itemCount => _items.length;

  int get totalProductsCount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.subtotal;
    });
    return total;
  }

  bool get isEmpty => _items.isEmpty;

  bool addToCart(ProductModel product, {int quantity = 1}) {
    if (product.id == null || product.stock <= 0) return false;

    if (_items.containsKey(product.id!)) {
      final currentItem = _items[product.id!]!;
      final newQuantity = currentItem.quantity + quantity;
      if (newQuantity > product.stock) {
        return false; // Exceeds available stock
      }
      _items[product.id!] = currentItem.copyWith(quantity: newQuantity);
    } else {
      if (quantity > product.stock) return false;
      _items[product.id!] = OrderItemModel(
        productId: product.id!,
        productName: product.name,
        presentation: product.presentation,
        quantity: quantity,
        unitPrice: product.price,
      );
    }

    notifyListeners();
    return true;
  }

  bool increaseQuantity(int productId, int maxStock) {
    if (!_items.containsKey(productId)) return false;

    final current = _items[productId]!;
    if (current.quantity >= maxStock) {
      return false; // Cannot exceed stock
    }

    _items[productId] = current.copyWith(quantity: current.quantity + 1);
    notifyListeners();
    return true;
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;

    final current = _items[productId]!;
    if (current.quantity > 1) {
      _items[productId] = current.copyWith(quantity: current.quantity - 1);
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _checkoutError = null;
    notifyListeners();
  }

  Future<int?> processCheckout({
    required String clientName,
    required String clientPhone,
    required String clientEmail,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    if (_items.isEmpty) {
      _checkoutError = 'El carrito está vacío.';
      notifyListeners();
      return null;
    }

    _isProcessingCheckout = true;
    _checkoutError = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final formattedDate =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final order = OrderModel(
        clientName: clientName,
        clientPhone: clientPhone,
        clientEmail: clientEmail,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        total: totalAmount,
        createdAt: formattedDate,
        status: 'Preparando',
        items: _items.values.toList(),
      );

      final orderId = await _dbHelper.createOrder(order);
      _items.clear();
      _isProcessingCheckout = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      _checkoutError = e.toString().replaceAll('Exception: ', '');
      _isProcessingCheckout = false;
      notifyListeners();
      return null;
    }
  }
}
