import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/Controller/SavedPageController.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with TickerProviderStateMixin {
  final SavedPageController controller = SavedPageController();
  final Map<String, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize animations after the first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller.savedItemsStream.listen((snapshot) {
        for (var doc in snapshot.docs) {
          final productId = doc.id;
          if (!_animationControllers.containsKey(productId)) {
            _animationControllers[productId] = controller.initAnimationController(
              productId,
              this,
              delay: 100 * snapshot.docs.indexOf(doc),
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isAuthenticated) {
      return const Center(child: Text('Please log in to view saved items'));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Saved Items',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.savedItemsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading saved items'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final savedItems = snapshot.data!.docs;

          if (savedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved items yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            itemCount: savedItems.length,
            itemBuilder: (context, index) {
              final item = savedItems[index].data() as Map<String, dynamic>;
              final productId = savedItems[index].id;
              final animationController = _animationControllers[productId];

              return SlideTransition(
                position: animationController != null
                    ? Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animationController,
                  curve: Curves.easeOutQuart,
                ))
                    : const AlwaysStoppedAnimation(Offset.zero),
                child: Opacity(
                  opacity: animationController?.value ?? 1,
                  child: _SavedItemCard(
                    item: item,
                    onToggleSaved: () {
                      if (animationController != null) {
                        controller.deleteSavedItem(productId, animationController, context).then((_) {
                          setState(() {
                            _animationControllers.remove(productId);
                          });
                        });
                      }
                    },
                    onViewProduct: () => controller.viewProduct(item['name'], context),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onToggleSaved;
  final VoidCallback onViewProduct;

  const _SavedItemCard({
    required this.item,
    required this.onToggleSaved,
    required this.onViewProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onViewProduct,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image'] ?? 'assets/images/cozyshoplogo.png'),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) => const AssetImage('assets/images/cozyshoplogo.png'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'Unnamed Item',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF561C24),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF561C24),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggleSaved,
                  icon: const Icon(
                    Icons.favorite,
                    color: Color(0xFF561C24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
