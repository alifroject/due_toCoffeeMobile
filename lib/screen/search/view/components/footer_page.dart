import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterLinks extends StatelessWidget {
  const FooterLinks({super.key});

  final List<Map<String, String>> links = const [
    {
      'icon': '🌍',
      'url': 'https://www.toogoodtogo.com/about-food-waste/environmental-impact?utm_source=chatgpt.com',
    },
    {
      'icon': '🇮🇩',
      'url': 'https://infid.org/en/indonesia-penyumbang-sampah-makanan-terbanyak-se-asean/?utm_source=chatgpt.com',
    },
    {
      'icon': '📊',
      'url': 'https://www.statista.com/chart/24350/total-annual-household-waste-produced-in-selected-countries/',
    },
    {
      'icon': '📈',
      'url': 'https://media.market.us/food-waste-statistics/',
    },
  ];

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C5364), Color(0xFF0F2027)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: links.map((link) {
          return GestureDetector(
            onTap: () => _launchURL(link['url']!),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                link['icon']!,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
