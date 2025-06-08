class PaymentResult {
  final String orderId;
  final String status;
  final String? paymentType;
  final double? grossAmount;
  final String? bank;
  final String? vaNumber;
  final List<Item>? items;
  final String? userEmail;
  final String? userName;
  final String? userPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentResult({
    required this.orderId,
    required this.status,
    this.paymentType,
    this.grossAmount,
    this.bank,
    this.vaNumber,
    this.items,
    this.userEmail,
    this.userName,
    this.userPhone,
    this.createdAt,
    this.updatedAt,
  });
}

class Item {
  final String id;
  final String name;
  final int quantity;
  final double price;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });
}