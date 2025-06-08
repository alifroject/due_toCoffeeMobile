import 'package:flutter/material.dart';
import 'package:due_tocoffee/screen/home/view/component/coffee_category.dart';
import 'package:due_tocoffee/screen/home/view/component/drink_category.dart';
import 'package:due_tocoffee/screen/home/view/component/pastry_category.dart';
import 'package:due_tocoffee/screen/home/view/component/food_category.dart';


class CoffeeShopHome extends StatefulWidget {
  const CoffeeShopHome({super.key});

  @override
  State<CoffeeShopHome> createState() => _CoffeeShopHomeState();
}

class _CoffeeShopHomeState extends State<CoffeeShopHome> {
  int _selectedCategory = 0;
  final List<String> categories = ['Coffee', 'Drinks', 'Pastries', 'Food'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            height: 200,
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'IT\'S OUR THEME',
                    style: TextStyle(
                      color: const Color(0xFFDAC5C5),
                      fontSize: 24,
                      fontFamily: 'Inika',
                    ),
                  ),
                  Text(
                    'WELCOME TO COFFEE SHOP',
                    style: TextStyle(
                      color: const Color(0xFFDAC5C5),
                      fontSize: 24,
                      fontFamily: 'Inika',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: SizedBox(
              height: 50,
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
                child: _getSelectedCategoryWidget(), // Dynamically load content here
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get the category icon for the selected category
  IconData _getCategoryIcon() {
    switch (_selectedCategory) {
      case 0: return Icons.coffee;
      case 1: return Icons.local_drink;
      case 2: return Icons.cake;
      case 3: return Icons.fastfood;
      default: return Icons.coffee;
    }
  }

  // Get the widget for the selected category
  Widget _getSelectedCategoryWidget() {
    switch (_selectedCategory) {
      case 0:
        return const CoffeeCategory(); // Display the CoffeeCategory widget for Coffee
      case 1:
        return const DrinkCategory(); // Placeholder for Drinks
      case 2:
        return const PastryCategory(); // Placeholder for Pastries
      case 3:
        return const FoodCategory(); // Placeholder for Food
      default:
        return const Center(child: Text('Select a category to view items.'));
    }
  }
}
