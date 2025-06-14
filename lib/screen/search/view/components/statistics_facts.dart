import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StatisticsFacts extends StatefulWidget {
  final String language; // <-- added

  const StatisticsFacts({super.key, required this.language});

  @override
  _StatisticsFactsState createState() => _StatisticsFactsState();
}

class _StatisticsFactsState extends State<StatisticsFacts>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late Animation<double> _imageOpacity;

  late List<AnimationController> _textControllers;
  late List<Animation<Offset>> _textOffsets;
  late List<Animation<double>> _textOpacities;

  late final List<String> paragraphs;

  @override
  void initState() {
    super.initState();

    final isIndonesian = widget.language.toLowerCase().contains('indo');

    paragraphs = isIndonesian
        ? [
            "Produksi limbah global terus meningkat. Berdasarkan data Statista, Amerika Serikat menghasilkan sekitar 258 juta ton limbah rumah tangga setiap tahun, diikuti oleh Jerman dengan 52 juta ton, Inggris dengan 31 juta ton, dan Prancis dengan 30 juta ton.",
            "Dalam hal limbah makanan, Forum Ekonomi Dunia melaporkan hampir sepertiga dari seluruh makanan yang diproduksi secara global terbuang sia-sia, sekitar 1,3 miliar ton setiap tahun.",
            "Menurut Market.us, limbah makanan menyumbang sekitar 8-10% dari total emisi gas rumah kaca global. Sebagian besar limbah makanan berasal dari rumah tangga.",
            "Mengatasi limbah makanan sangat penting untuk perlindungan lingkungan dan ketahanan pangan global. Kesadaran konsumen, solusi penyimpanan yang lebih baik, dan kebiasaan konsumsi yang bijak merupakan strategi kunci.",
          ]
        : [
            "Waste generation is a growing global concern. Based on Statista data, the United States generates approximately 258 million tonnes of household waste annually, followed by Germany with 52 million tonnes, the United Kingdom with 31 million tonnes, and France with 30 million tonnes. This highlights how developed nations contribute significantly to overall waste production.",
            "In terms of food waste specifically, the World Economic Forum reports that nearly one-third of all food produced globally goes to waste, which equals around 1.3 billion tonnes every year. This not only leads to financial losses but also represents wasted resources such as water, energy, and agricultural land.",
            "Market.us highlights that food waste accounts for about 8-10% of total global greenhouse gas emissions. A significant portion of food waste comes from households, driven by over-purchasing, improper storage, and misunderstandings about expiration dates. Reducing food waste can play a major role in improving environmental sustainability.",
            "Addressing waste and food loss is crucial to support both environmental protection and global food security. Improved consumer awareness, better storage solutions, and responsible consumption habits are key strategies to reduce waste effectively.",
          ];
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _imageOpacity = Tween<double>(begin: 0, end: 1).animate(_imageController);
    _imageController.forward();

    _textControllers = List.generate(paragraphs.length, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
    });

    _textOffsets = _textControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _textOpacities = _textControllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    }).toList();

    Future.delayed(const Duration(milliseconds: 500), () {
      for (int i = 0; i < _textControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 400), () {
          _textControllers[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _launchURL(
                      'https://www.stocksolutions.com.au/wp-content/uploads/2023/01/171205-food-waste-compost-ac-421p.jpg');
                },
                child: FadeTransition(
                  opacity: _imageOpacity,
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Image.network(
                      'https://www.stocksolutions.com.au/wp-content/uploads/2023/01/171205-food-waste-compost-ac-421p.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Statistics & Facts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Paragraph 1
              SlideTransition(
                position: _textOffsets[0],
                child: FadeTransition(
                  opacity: _textOpacities[0],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paragraphs[0], textAlign: TextAlign.justify),
                      InkWell(
                        onTap: () {
                          _launchURL(
                              'https://www.statista.com/chart/24350/total-annual-household-waste-produced-in-selected-countries/');
                        },
                        child: const Text(
                          "Source: Statista",
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Paragraph 2
              SlideTransition(
                position: _textOffsets[1],
                child: FadeTransition(
                  opacity: _textOpacities[1],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paragraphs[1], textAlign: TextAlign.justify),
                      InkWell(
                        onTap: () {
                          _launchURL(
                              'https://www.weforum.org/stories/2021/03/global-food-waste-solutions/');
                        },
                        child: const Text(
                          "Source: World Economic Forum",
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Paragraph 3
              SlideTransition(
                position: _textOffsets[2],
                child: FadeTransition(
                  opacity: _textOpacities[2],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paragraphs[2], textAlign: TextAlign.justify),
                      InkWell(
                        onTap: () {
                          _launchURL(
                              'https://media.market.us/food-waste-statistics/');
                        },
                        child: const Text(
                          "Source: Market.us",
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Paragraph 4
              SlideTransition(
                position: _textOffsets[3],
                child: FadeTransition(
                  opacity: _textOpacities[3],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paragraphs[3], textAlign: TextAlign.justify),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
