import 'package:flutter/material.dart';
import 'searched_page.dart';
import 'search_bar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);
  static const Color beige = Color(0xFFE5E1DA);

  final List<Map<String, String>> categories = const [
    {'title': 'Pants', 'image': 'assets/pants.png'},
    {'title': 'Shoes', 'image': 'assets/shoes.png'},
    {'title': 'Bags', 'image': 'assets/bag.png'},
    {'title': 'Accessories', 'image': 'assets/accessories.png'},
    {'title': 'Hats', 'image': 'assets/hats.png'},
    {'title': 'Watches', 'image': 'assets/watches.png'},
    {'title': 'Sunglasses', 'image': 'assets/sunglasses.png'},
    {'title': 'Jackets', 'image': 'assets/jackets.png'},
    {'title': 'T-Shirts', 'image': 'assets/tshirts.png'},
    {'title': 'Jeans', 'image': 'assets/jeans.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        centerTitle: true,
        title: const Text(
          'Search Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF561C24),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomSearchBar(
              onSearch: (query) => _navigateToResults(context, query),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildCategories(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () => _navigateToResults(context, category['title']!),
          child: Container(
            decoration: BoxDecoration(
              color: lightBurgundy,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: burgundy.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (category['image'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      category['image']!,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 40, color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  category['title']!,
                  style: TextStyle(
                    color: burgundy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToResults(BuildContext context, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchedPage(searchQuery: query),
      ),
    );
  }
}
