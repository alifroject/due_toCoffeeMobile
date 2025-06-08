import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  static Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final cartDoc =
        await FirebaseFirestore.instance.collection('carts').doc(userId).get();

    if (!cartDoc.exists || cartDoc.data() == null) return [];

    // Explicitly cast cartDoc.data() to Map<String, dynamic>
    final cartData = cartDoc.data() as Map<String, dynamic>?;

    // Check if cartData is null or not a valid map
    if (cartData == null || !(cartData is Map<String, dynamic>)) return [];

    final List items = cartData['items'] ?? [];

    List<Map<String, dynamic>> detailedItems = [];

    for (var item in items) {
      final String productId = item['productId'];
      final int quantity = item['quantity'];

      // Debugging: Log productId
      print('Fetching product for productId: $productId');

      try {
        // We will need to check the product type or category and use the corresponding collection name
        final productSnap =
            await _fetchProductFromDifferentCollections(productId);

        if (productSnap != null &&
            productSnap.exists &&
            productSnap.data() != null) {
          // Safely cast the data to Map<String, dynamic>
          final productData = productSnap.data() as Map<String, dynamic>;

          detailedItems.add({
            'title': productData['name'] ?? 'Unnamed',
            'price': productData['price'] ?? 0,
            'quantity': quantity,
            'imageUrl': productData['imageUrl'] ?? '',
          });
        } else {
          print('Product not found for productId $productId');
        }
      } catch (e) {
        print('Error fetching product details: $e');
      }
    }

    return detailedItems;
  }

  // Function to dynamically fetch product based on productId
  static Future<DocumentSnapshot?> _fetchProductFromDifferentCollections(
      String productId) async {
    // List of product categories/collections you might have
    final productCategories = ['coffees', 'drinks', 'pastries', 'foods'];

    // Loop through each category to find the product
    for (String category in productCategories) {
      final productSnap = await FirebaseFirestore.instance
          .collection(category)
          .doc(productId)
          .get();
      if (productSnap.exists) {
        return productSnap;
      }
    }

    return null; // Return null if not found in any collection
  }
}
