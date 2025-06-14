import 'package:flutter/material.dart';
import 'package:due_tocoffee/screen/home/view/component/coffee_category.dart';
import 'package:due_tocoffee/screen/home/view/component/drink_category.dart';
import 'package:due_tocoffee/screen/home/view/component/pastry_category.dart';
import 'package:due_tocoffee/screen/home/view/component/food_category.dart';
import 'package:due_tocoffee/routes/screen_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CoffeeShopHome extends StatefulWidget {
  const CoffeeShopHome({super.key});

  @override
  State<CoffeeShopHome> createState() => _CoffeeShopHomeState();
}

class _CoffeeShopHomeState extends State<CoffeeShopHome> {
  int _selectedCategory = 0;
  final List<String> categories = ['Coffee', 'Drinks', 'Pastries', 'Food'];

  int _cartItemCount = 0;
  StreamSubscription<DocumentSnapshot>? _cartSubscription;

  @override
  void initState() {
    super.initState();
    _listenToCartChanges();
  }

  void _listenToCartChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _cartSubscription = FirebaseFirestore.instance
        .collection('carts')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final List<dynamic> items = data['items'] ?? [];
        setState(() {
          _cartItemCount = items.length;
        });
      } else {
        setState(() {
          _cartItemCount = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF210F0F),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'DUE TO COFFEE',
                    style: const TextStyle(
                      color: Color(0xFFDAC5C5),
                      fontSize: 26,
                      fontFamily: 'Inika',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        color: Color.fromARGB(255, 219, 212, 212),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartPage()),
                          );
                        },
                      ),
                      if (_cartItemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                            child: Center(
                              child: Text(
                                '$_cartItemCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(categories[index]),
                      selected: _selectedCategory == index,
                      selectedColor: const Color(0xFFB20000),
                      labelStyle: TextStyle(
                        color: _selectedCategory == index ? Colors.white : Colors.black,
                        fontFamily: 'Inika',
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _getSelectedCategoryWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedCategoryWidget() {
    switch (_selectedCategory) {
      case 0:
        return const CoffeeCategory();
      case 1:
        return const DrinkCategory();
      case 2:
        return const PastryCategory();
      case 3:
        return const FoodCategory();
      default:
        return const Center(child: Text('Select a category to view items.'));
    }
  }
}
