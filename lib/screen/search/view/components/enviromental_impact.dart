import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EnvironmentalImpacts extends StatelessWidget {
  final String language;
  const EnvironmentalImpacts({super.key, required this.language});

  final String sourceUrl =
      "https://www.toogoodtogo.com/about-food-waste/environmental-impact?utm_source=chatgpt.com";

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> translations = {
      'English': {
        'mainTitle': 'The Environmental Impact of Food Waste',
        'cards': [
          {
            'title': "CO₂ Emissions Saved",
            'paragraph':
                "Food waste generates around 3.3 gigatonnes CO₂ annually, equal to 2.5 kg CO₂e per kg of wasted food. "
                    "It accounts for 8–10% of global greenhouse gas emissions, even exceeding aviation. "
                    "Saving 3 kg of food weekly can reduce about 1.2 tonnes CO₂e yearly, nearly ¼ of a car’s emissions.",
            'image':
                "https://cdn.sanity.io/images/nqimd3nr/production/66a75a08564220ebf8c715e4b74b2c4d2d31ef18-1200x1200.png?w=828&h=828&fit=max&auto=format",
          },
          {
            'title': "Water Resources Saved",
            'paragraph':
                "Food waste consumes 25% of global freshwater—equal to three Lake Genevas yearly. "
                    "Rescuing one meal (~1 kg) saves about 810 L of water. "
                    "Avoiding 3 kg of waste weekly conserves 5,000 L of water, enough for 143 showers.",
            'image':
                "https://images.unsplash.com/photo-1528825871115-3581a5387919",
          },
          {
            'title': "Land Saved",
            'paragraph':
                "Half of the world’s habitable land is used for farming, but 30% of that grows wasted food. "
                    "That’s 1.4 billion hectares—larger than Canada—used for food that’s never eaten. "
                    "Saving 1 kg of food spares around 2.8 m² of land yearly.",
            'image':
                "https://images.unsplash.com/photo-1560493676-04071c5f467b",
          },
          {
            'title': "Relatable Equivalents",
            'paragraph':
                "Wasting 79 kg of food per person yearly equals about 3–4 shopping carts. "
                    "A household’s waste (~156 kg/year) fills 6–8 carts. "
                    "Globally, 1.3 billion tonnes of food waste equals 52 billion shopping carts.",
            'image':
                "https://images.unsplash.com/photo-1619983081563-430f6360276d",
          },
        ]
      },
      'Indonesia': {
        'mainTitle': 'Dampak Lingkungan dari Limbah Makanan',
        'cards': [
          {
            'title': "Pengurangan Emisi CO₂",
            'paragraph':
                "Limbah makanan menghasilkan sekitar 3,3 gigaton CO₂ per tahun, setara dengan 2,5 kg CO₂e per kg makanan yang terbuang. "
                    "Ini menyumbang 8–10% emisi gas rumah kaca global, bahkan melebihi penerbangan. "
                    "Menyelamatkan 3 kg makanan tiap minggu dapat mengurangi sekitar 1,2 ton CO₂e per tahun, hampir seperempat emisi sebuah mobil.",
            'image':
                "https://cdn.sanity.io/images/nqimd3nr/production/66a75a08564220ebf8c715e4b74b2c4d2d31ef18-1200x1200.png?w=828&h=828&fit=max&auto=format",
          },
          {
            'title': "Penghematan Sumber Air",
            'paragraph':
                "Limbah makanan menghabiskan 25% air tawar global—setara dengan tiga Danau Jenewa per tahun. "
                    "Menyelamatkan satu porsi makan (~1 kg) menghemat sekitar 810 L air. "
                    "Menghindari 3 kg limbah per minggu menghemat 5.000 L air, cukup untuk 143 kali mandi.",
            'image':
                "https://images.unsplash.com/photo-1528825871115-3581a5387919",
          },
          {
            'title': "Lahan yang Diselamatkan",
            'paragraph':
                "Setengah lahan layak huni di dunia digunakan untuk pertanian, namun 30% di antaranya menghasilkan makanan yang terbuang. "
                    "Itu setara 1,4 miliar hektar—lebih besar dari Kanada—untuk makanan yang tidak pernah dimakan. "
                    "Menyelamatkan 1 kg makanan menghemat sekitar 2,8 m² lahan per tahun.",
            'image':
                "https://images.unsplash.com/photo-1560493676-04071c5f467b",
          },
          {
            'title': "Perbandingan yang Relevan",
            'paragraph':
                "Membuang 79 kg makanan per orang per tahun setara dengan 3–4 troli belanja. "
                    "Limbah rumah tangga (~156 kg/tahun) mengisi 6–8 troli. "
                    "Secara global, 1,3 miliar ton limbah makanan setara 52 miliar troli belanja.",
            'image':
                "https://images.unsplash.com/photo-1619983081563-430f6360276d",
          },
        ]
      }
    };

    final data = translations[language]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            data['mainTitle'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        ...List.generate((data['cards'] as List).length, (index) {
          final card = data['cards'][index];
          return _buildCard(
            context: context,
            title: card['title'],
            paragraph: card['paragraph'],
            imageUrl: card['image'],
          );
        }),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String paragraph,
    required String imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(paragraph, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 180,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Icon(Icons.broken_image, size: 60));
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _launchURL(context),
                child:
                    const Text("Source", style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(BuildContext context) async {
    final Uri uri = Uri.parse(sourceUrl);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the source URL")),
      );
    }
  }
}
