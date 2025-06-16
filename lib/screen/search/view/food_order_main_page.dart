import 'package:flutter/material.dart';
import 'food_order_status_list.dart';
import 'orderMutationPage.dart';
import 'package:easy_localization/easy_localization.dart';

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
                    title: Text("my_food_orders".tr()),
                    automaticallyImplyLeading: false,
                  ),
                  TabBar(
                    tabs: [
                      Tab(text: "ongoing_todays_order".tr()),
                      Tab(text: "history".tr()),
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
