import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // This provides the Platform class
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_confirmation_page.dart';
import 'package:due_tocoffee/screen/cart/view/component/payment_result.dart';
import 'dart:convert';
import 'package:due_tocoffee/screen/cart/view/component/proceede_url.dart';
import 'package:due_tocoffee/screen/cart/view/component/call_invoice.dart';

Future<void> showLocationCheckPopup(
  BuildContext context, {
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
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Navigator.pop(context); // Close the loading dialog

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Permission Required",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Location permission is required to proceed."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
      return;
    }
  }

  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
    timeLimit: const Duration(seconds: 10),
  );

  // Dismiss loading dialog
  Navigator.pop(context);

  // Continue with the map popup
  final double cafeLat = -6.3550489960042835;
  final double cafeLng = 106.84177572834753;
  final LatLng cafeLocation = LatLng(cafeLat, cafeLng);
  final LatLng userLocation = LatLng(position.latitude, position.longitude);

  double distance = Geolocator.distanceBetween(
    position.latitude,
    position.longitude,
    cafeLat,
    cafeLng,
  );

  bool withinRange = distance <= 1000000000000000000;

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Location Check",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.maxFinite,
              height: 250,
              child: FlutterMap(
                options: MapOptions(center: cafeLocation, zoom: 16),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: cafeLocation,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 30),
                      ),
                      if (withinRange)
                        Marker(
                          point: userLocation,
                          child: const Icon(Icons.person_pin_circle,
                              color: Colors.blue, size: 30),
                        ),
                    ],
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: cafeLocation,
                        radius: 10000000000000000000000,
                        color: Colors.green.withOpacity(0.3),
                        useRadiusInMeter: true,
                        borderColor: Colors.green,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (withinRange)
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context); // close dialog first

                    try {
                      // Assuming you have these variables ready in your scope:
                      // orderId, amount, cartId, userName, userPhone, userEmail, userId, items, location
                      final currentLocation = {
                        'latitude': position.latitude,
                        'longitude': position.longitude,
                      };
                      final result = await createInvoiceOnBackend(
                        orderId: orderId,
                        amount: amount,
                        cartId: cartId,
                        userName: userName,
                        userPhone: userPhone,
                        userEmail: userEmail,
                        userId: userId,
                        items: items,
                        location: currentLocation,
                      );

                      final invoiceUrl = result['invoiceUrl'] as String;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentConfirmationPage(invoiceUrl: invoiceUrl),
                        ),
                      );
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Error"),
                          content: Text("Failed to create invoice: $e"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text("Pay Now"),
                ),
              )
            else
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      "You are too far. Please move closer than 4000m to pre-order.",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.redAccent, width: 2),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close",
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

// Dummy function for payment logic to be called when the user is within range
// void proceedToPayment(BuildContext context) {
//   // Example: Navigate to a new screen where the payment is processed
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => const PaymentScreen(),
//     ),
//   );
// }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late InAppWebViewController webViewController;
  bool isLoading = true;
  String? paymentUrl;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _getPaymentUrl();
  }

  Future<void> _getPaymentUrl() async {
    try {
      setState(() => isLoading = true);
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception('Please sign in to make a payment');
      if (!user.emailVerified)
        throw Exception('Please verify your email first');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw Exception('User profile not found');

      final userData = userDoc.data()!;
      final userName = (userData['name'] as String?)?.trim() ?? '';
      final userPhone = (userData['phone'] as String?)?.trim() ?? '';
      final userEmail = user.email?.trim() ?? '';

      if (userName.isEmpty)
        throw Exception('Please complete your profile name');
      if (userEmail.isEmpty) throw Exception('Email address is required');

      final cartSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (cartSnapshot.docs.isEmpty) throw Exception('Your cart is empty');

      final cartDoc = cartSnapshot.docs.first;
      final items =
          (cartDoc.data()['items'] as List?)?.cast<Map<String, dynamic>>() ??
              [];

      if (items.isEmpty) throw Exception('Your cart is empty');

      final amount = await _calculateCartTotal(items);
      if (amount <= 0) throw Exception('Invalid cart total');

      final paymentItems = items.map((item) {
        final category = item['category']?.toString() ?? '';
        final map = {
          'productId': item['productId']?.toString() ?? '',
          'category': category,
          'quantity': (item['quantity'] as num?)?.toInt() ?? 0,
          'name': item['name']?.toString() ?? 'Unknown Product',
          'price': (item['price'] as num?)?.toInt() ?? 0,
        };

        return map;
      }).toList();

      if (paymentItems.any((item) =>
          (item['productId'] as String).isEmpty ||
          (item['category'] as String).isEmpty ||
          (item['quantity'] as int) <= 0)) {
        throw Exception('Invalid items in cart');
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final requestData = {
        'order_id': 'ORDER-${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'cartId': cartDoc.id,
        'userName': userName,
        'userPhone': userPhone,
        'userEmail': userEmail,
        'userId': user.uid,
        'items': paymentItems,
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      };

      // Call Firebase function for Midtrans URL generation
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('createXenditInvoice');
      final response = await callable.call(requestData);

      setState(() {
        isLoading = false;
        paymentUrl = response.data['paymentUrl'];
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        paymentUrl = null;
      });

      String errorMessage = 'Something went wrong, please try again';
      if (error is Exception) {
        errorMessage = error.toString();
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<int> _calculateCartTotal(List<Map<String, dynamic>> items) async {
    int total = 0;
    final validCategories = {'coffees', 'drinks', 'pastries', 'foods'};
    bool hasValidItems = false;

    for (final item in items) {
      try {
        // Get required fields with null checks
        String category = (item['category'] as String?)?.trim() ?? '';
        final productId = (item['productId'] as String?)?.trim() ?? '';
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

        // Skip invalid items
        if (productId.isEmpty || quantity <= 0) {
          debugPrint('Skipping invalid item: $item');
          continue;
        }

        // Determine category if not provided
        if (category.isEmpty) {
          for (final possibleCategory in validCategories) {
            final doc = await FirebaseFirestore.instance
                .collection(possibleCategory)
                .doc(productId)
                .get();

            if (doc.exists) {
              category = possibleCategory;
              break;
            }
          }
        }

        // Validate category
        if (!validCategories.contains(category)) {
          debugPrint('Invalid category for product $productId');
          continue;
        }

        // Get product details
        final productDoc = await FirebaseFirestore.instance
            .collection(category)
            .doc(productId)
            .get();

        if (!productDoc.exists) {
          debugPrint('Product $productId not found in $category');
          continue;
        }

        final productData = productDoc.data()!;
        final price = (productData['price'] as num?)?.toInt() ?? 0;
        final name = (productData['name'] as String?) ?? 'Unknown Product';

        // Update item with complete data
        item
          ..['category'] = category
          ..['name'] = name
          ..['price'] = price;

        total += price * quantity;
        hasValidItems = true;
      } catch (e) {
        debugPrint('Error processing item: $e');
      }
    }

    if (!hasValidItems || total <= 0) {
      throw Exception('No valid items in cart');
    }

    return total;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _getPaymentUrl(); // Retry
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSuccessfulPayment(String orderId) async {
    try {
      // Fetch directly from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(orderId)
          .get();

      if (!doc.exists) {
        throw Exception('Transaction not found');
      }

      final data = doc.data()!;
      debugPrint('Full transaction data: ${data.toString()}');

      // Helper to parse Firestore timestamps
      DateTime? parseTimestamp(dynamic timestamp) {
        if (timestamp == null) return null;
        if (timestamp is Timestamp) return timestamp.toDate();
        return null;
      }

      final result = PaymentResult(
        orderId: data['order_id'] ?? orderId,
        status: data['transaction_status'] ?? 'settlement',
        paymentType: data['payment_type'],
        grossAmount: (data['gross_amount'] as num?)?.toDouble(),
        bank: (data['va_numbers'] as List?)?.first?['bank'],
        vaNumber: (data['va_numbers'] as List?)?.first?['va_number'],
        userEmail: data['user_email'],
        userName: data['user_name'],
        userPhone: data['user_phone'],
        createdAt: parseTimestamp(data['created_at']),
        updatedAt: parseTimestamp(data['updated_at']),
        items: (data['item_details'] as List?)?.map<Item>((item) {
          return Item(
            id: item['id']?.toString() ?? '',
            name: item['name']?.toString() ?? 'Unknown Item',
            quantity: (item['quantity'] as num?)?.toInt() ?? 1,
            price: (item['price'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(paymentResult: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transaction: ${e.toString()}')),
      );
      debugPrint('Error loading transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: paymentUrl == null
                ? const Center(child: CircularProgressIndicator())
                : InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(paymentUrl!)),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        this.progress = progress / 100;
                        isLoading = progress < 100;
                      });
                    },
                    onLoadStop: (controller, url) async {
                      final uri = Uri.parse(url.toString());
                      final queryParams = uri.queryParameters;

                      if (queryParams['transaction_status'] == 'settlement') {
                        await controller.stopLoading();
                        final orderId = queryParams['order_id'];
                        if (orderId != null) {
                          await _handleSuccessfulPayment(orderId);
                        }
                      }
                    },
                    onLoadError: (controller, url, code, message) {
                      setState(() => isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment error: $message')),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
