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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: burgundy,
        centerTitle: true,
        title: const Text(
          'Search Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFDF6),
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
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.4,
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

            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (category['image'] != null)
                  Image.asset(
                    category['image']!,
                    height: 50,
                    width: 50,
                  ),
                const SizedBox(height: 10),
                Text(
                  category['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${category['title']}',
                  style: TextStyle(
                    color: burgundy,
                    fontSize: 12,
                  ),
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
