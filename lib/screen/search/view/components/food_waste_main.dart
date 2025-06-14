import 'package:flutter/material.dart';
import 'statistics_facts.dart';
import './enviromental_impact.dart';
import 'visual_graphs.dart';
import 'educational_contents.dart';
import 'Indonesia_stats.dart';


class FoodWasteMain extends StatefulWidget {
  const FoodWasteMain({super.key});

  @override
  _FoodWasteMainState createState() => _FoodWasteMainState();
}

class _FoodWasteMainState extends State<FoodWasteMain> {
  String _selectedLanguage = 'English';

  final Map<String, Map<String, String>> _translations = {
    'English': {
      'title': 'Food Waste Information',
      'warning': 'Currently, content is only available in English.',
    },
    'Indonesia': {
      'title': 'Informasi Limbah Makanan',
      'warning': 'Beberapa konten sudah tersedia dalam Bahasa Indonesia.',
    }
  };

  @override
  Widget build(BuildContext context) {
    final trans = _translations[_selectedLanguage]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(trans['title']!),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
              });
            },
            items: <String>['English', 'Indonesia']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_selectedLanguage == 'Indonesia')
              Container(
                width: double.infinity,
                color: Colors.amber[100],
                padding: const EdgeInsets.all(12),
                child: Text(
                  trans['warning']!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            StatisticsFacts(
              key: ValueKey('StatisticsFacts-$_selectedLanguage'),
              language: _selectedLanguage,
            ),
            // <-- passed language here
            const VisualGraphs(),
            IndonesiaStats(
              key: ValueKey('IndonesiaStats-$_selectedLanguage'),
              language: _selectedLanguage,
            ),

            EnvironmentalImpacts(
              key: ValueKey('EnvironmentalImpacts-$_selectedLanguage'),
              language: _selectedLanguage,
            ),

            EducationalContents(language: _selectedLanguage),
           
          ],
        ),
      ),
    );
  }
}
