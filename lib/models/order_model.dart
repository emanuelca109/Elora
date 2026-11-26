class OrderItemModel {
  final int? id;
  final int? orderId;
  final int productId;
  final String productName;
  final String presentation;
  final int quantity;
  final double unitPrice;

  OrderItemModel({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.presentation,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toMap({int? explicitOrderId}) {
    return {
      if (id != null) 'id': id,
      'order_id': explicitOrderId ?? orderId,
      'product_id': productId,
      'product_name': productName,
      'presentation': presentation,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as int?,
      orderId: map['order_id'] as int?,
      productId: (map['product_id'] as int?) ?? 0,
      productName: map['product_name'] as String? ?? '',
      presentation: map['presentation'] as String? ?? '',
      quantity: (map['quantity'] as int?) ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  OrderItemModel copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    String? presentation,
    int? quantity,
    double? unitPrice,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      presentation: presentation ?? this.presentation,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class OrderModel {
  final int? id;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String deliveryAddress;
  final String paymentMethod;
  final double total;
  final String createdAt;
  final String status;
  final List<OrderItemModel> items;

  OrderModel({
    this.id,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.total,
    required this.createdAt,
    this.status = 'Preparando',
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'client_name': clientName,
      'client_phone': clientPhone,
      'client_email': clientEmail,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'total': total,
      'created_at': createdAt,
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {List<OrderItemModel> items = const []}) {
    return OrderModel(
      id: map['id'] as int?,
      clientName: map['client_name'] as String? ?? '',
      clientPhone: map['client_phone'] as String? ?? '',
      clientEmail: map['client_email'] as String? ?? '',
      deliveryAddress: map['delivery_address'] as String? ?? '',
      paymentMethod: map['payment_method'] as String? ?? 'Tarjeta de crédito',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] as String? ?? '',
      status: map['status'] as String? ?? 'Preparando',
      items: items,
    );
  }

  OrderModel copyWith({
    int? id,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? deliveryAddress,
    String? paymentMethod,
    double? total,
    String? createdAt,
    String? status,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}
