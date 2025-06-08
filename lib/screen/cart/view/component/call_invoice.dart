import 'package:cloud_functions/cloud_functions.dart';

Future<Map<String, dynamic>> createInvoiceOnBackend({
  required String orderId,
  required int amount,
  required String cartId,
  required String userName,
  required String userPhone,
  required String userEmail,
  required String userId,
  required List<Map<String, dynamic>> items,
  required Map<String, double> location,
}) async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('createXenditInvoice');

  final response = await callable.call({
    'order_id': orderId,
    'amount': amount,
    'cartId': cartId,
    'userName': userName,
    'userPhone': userPhone,
    'userEmail': userEmail,
    'userId': userId,
    'items': items,
    'location': location,
  });

  return Map<String, dynamic>.from(response.data);
}
