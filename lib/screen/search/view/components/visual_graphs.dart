import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VisualGraphs extends StatefulWidget {
  const VisualGraphs({super.key});

  @override
  _VisualGraphsState createState() => _VisualGraphsState();
}

class _VisualGraphsState extends State<VisualGraphs> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  int _currentPage = 0;

  final List<Map<String, String>> images = [
    {
      'image': 'https://cdn.statcdn.com/Infographic/images/normal/24350.jpeg',
      'url':
          'https://www.statista.com/chart/24350/total-annual-household-waste-produced-in-selected-countries/',
    },
    {
      'image': 'https://media.market.us/wp-content/uploads/2023/07/fw1.avif',
      'url': 'https://media.market.us/food-waste-statistics/',
    },
    {
      'image':
          'https://market.us/wp-content/uploads/2023/06/Smart-Food-Bin-Market.jpg',
      'url': 'https://media.market.us/food-waste-statistics/',
    },
    {
      'image':
          'https://media.market.us/wp-content/uploads/2023/07/global-food-waste-by-sector.png',
      'url': 'https://media.market.us/food-waste-statistics/',
    },
    {
      'image': 'https://media.market.us/wp-content/uploads/2023/07/fw2.jpg',
      'url': 'https://media.market.us/food-waste-statistics/',
    },
    {
      'image':
          'https://assets.weforum.org/editor/p1atYEuo-Ks5eWm8FxEK71VfbrS0hkvaYneE8gpUIj4.jpg',
      'url': 'https://media.market.us/food-waste-statistics/',
    },
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _goToPage(int page) {
    if (page >= 0 && page < images.length) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _onImageTap(String imageUrl, String resourceUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 60, color: Colors.blueAccent),
              const SizedBox(height: 16),
              const Text(
                'What do you want to do?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showFullImage(imageUrl);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                      ),
                      child: const Text('View Image'),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white,
                    child: const VerticalDivider(
                      color: Colors.grey,
                      thickness: 1,
                      width: 1,
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchURL(resourceUrl);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                      ),
                      child: const Text("Open Source"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = images[index];
              return GestureDetector(
                onTap: () => _onImageTap(item['image']!, item['url']!),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      item['image']!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image));
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            top: 140,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 30),
              onPressed: () => _goToPage(_currentPage - 1),
            ),
          ),
          Positioned(
            right: 0,
            top: 140,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 30),
              onPressed: () => _goToPage(_currentPage + 1),
            ),
          ),
        ],
      ),
    );
  }
}
