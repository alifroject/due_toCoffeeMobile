import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; //<--- make sure you have this!

class IndonesiaStats extends StatelessWidget {
  final String language;
  const IndonesiaStats({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, String>> contents = {
      'English': {
        'title': 'Indonesia: The Biggest Food Waste Contributor in ASEAN',
        'paragraph1':
            'Indonesia holds the dubious honor of being the largest contributor to food waste in ASEAN, generating around 20.93 million tons of food waste annually. This staggering amount not only exacerbates environmental issues but also represents a significant economic loss.',
        'paragraph2':
            'The Indonesian Ministry of National Development Planning (Bappenas) reported that food waste in the country between 2000 and 2019 has led to economic losses amounting to IDR 213 trillion to IDR 551 trillion annually. This problem stems from multiple factors including inefficient supply chains, overproduction, and consumer behavior.',
        'imageUrl':
            'https://infid.org/wp-content/uploads/2023/06/kg-12-1024x745.png', //<-- updated image
        'sourceUrl':
            'https://infid.org/en/indonesia-penyumbang-sampah-makanan-terbanyak-se-asean/?utm_source=chatgpt.com',
      },
      'Indonesia': {
        'title': 'Indonesia: Penyumbang Limbah Makanan Terbesar di ASEAN',
        'paragraph1':
            'Indonesia menempati peringkat pertama sebagai penyumbang limbah makanan terbesar di ASEAN, dengan menghasilkan sekitar 20,93 juta ton limbah makanan setiap tahunnya. Jumlah yang luar biasa ini tidak hanya memperburuk masalah lingkungan, tetapi juga mencerminkan kerugian ekonomi yang signifikan.',
        'paragraph2':
            'Badan Perencanaan Pembangunan Nasional (Bappenas) melaporkan bahwa limbah makanan di Indonesia antara tahun 2000 hingga 2019 telah menyebabkan kerugian ekonomi sebesar Rp213 triliun hingga Rp551 triliun setiap tahunnya. Masalah ini disebabkan oleh berbagai faktor, termasuk rantai pasokan yang tidak efisien, produksi berlebihan, dan perilaku konsumen.',
        'imageUrl':
            'https://infid.org/wp-content/uploads/2023/06/kg-12-1024x745.png', //<-- updated image
        'sourceUrl':
            'https://infid.org/en/indonesia-penyumbang-sampah-makanan-terbanyak-se-asean/?utm_source=chatgpt.com',
      }
    };

    final content = contents[language]!;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content['title']!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(content['paragraph1']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(content['paragraph2']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _launchURL(content['sourceUrl']!);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  content['imageUrl']!,
                  fit: BoxFit.cover,
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
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  _launchURL(content['sourceUrl']!);
                },
                child: const Text("Go to Source",
                    style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not open URL");
    }
  }
}
