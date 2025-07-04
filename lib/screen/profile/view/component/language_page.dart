import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('choose_language'.tr()),
        backgroundColor: Colors.brown,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () async {
              await context.setLocale(const Locale('en', 'US'));
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Bahasa Indonesia'),
            onTap: () async {
              await context.setLocale(const Locale('id', 'ID'));
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
