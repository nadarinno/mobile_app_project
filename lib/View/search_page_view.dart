
import 'package:flutter/material.dart';
import 'package:mobile_app_project/View/search_bar_view.dart';
import '../Controller/search_page_controller.dart';

class SearchPageView extends StatelessWidget {
  const SearchPageView({super.key});

  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);
  static const Color beige = Color(0xFFE5E1DA);

  @override
  Widget build(BuildContext context) {
    final SearchPageController controller = SearchPageController();

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        centerTitle: true,
        title: const Text(
          'Search Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: burgundy,
          ),
        ),
        iconTheme: const IconThemeData(color: burgundy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBarView(
              onSearch: (query) => controller.navigateToResults(context, query),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildCategories(context, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, SearchPageController controller) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: controller.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load categories'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('There are no categories.'));
        }
        final categories = snapshot.data!;
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
            final title = category['title'] ?? 'Untitled';
            final image = category['image'] ?? '';
            return InkWell(
              onTap: () => controller.navigateToResults(context, '', title),
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
                    if (image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          image,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 40, color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
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
      },
    );
  }
}