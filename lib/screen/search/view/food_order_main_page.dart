import 'package:flutter/material.dart';
import 'food_order_status_list.dart';
import 'orderMutationPage.dart';

class FoodOrderMainPage extends StatelessWidget {
  const FoodOrderMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Material(
              elevation: 4,
              child: Column(
                children: [
                  AppBar(
                    title: const Text("My Food Orders"),
                    automaticallyImplyLeading: false,
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: "Ongoing Today's Order"),
                      Tab(text: "History"),
                    ],
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  FoodOrderStatusList(),
                  HistoryMutationPage(), // <--- use the new page here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
