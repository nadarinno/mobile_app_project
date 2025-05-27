import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/product_details_controller.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({required this.productId, Key? key}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late final ProductDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProductDetailsController();
    print("Initiating fetch for productId: ${widget.productId} at ${DateTime.now()}");
    _controller.fetchProductData(widget.productId).catchError((e) {
      print("Error in initState: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product: $e'), backgroundColor: Colors.red),
      );
    });
    _controller.addListener(_updateState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _controller.dispose();
    super.dispose();
  }

  void _updateState() {
    print("UI updated - isLoading: ${_controller.isLoading}, productName: ${_controller.productName} at ${DateTime.now()}");
    setState(() {});
  }

  Widget buildColorOption(Color color, String colorName, double size) {
    bool isSelected = _controller.selectedColor.toLowerCase() == colorName.toLowerCase();
    return GestureDetector(
      onTap: () => _controller.setSelectedColor(colorName),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: size * 0.01, vertical: size * 0.02),
        width: size * 0.08,
        height: size * 0.08,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFD0B8A8),
            width: 2,
          ),
        ),
        child: isSelected ? Icon(Icons.check, size: size * 0.05, color: Colors.white) : null,
      ),
    );
  }

  Widget buildSizeOption(String sizeText, double width) {
    return GestureDetector(
      onTap: () => _controller.setSelectedSize(sizeText),
      child: Container(
        margin: EdgeInsets.only(right: width * 0.02, top: width * 0.02),
        padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: width * 0.02),
        decoration: BoxDecoration(
          color: _controller.selectedSize == sizeText ? const Color(0xFF561C24) : const Color(0xFFD0B8A8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          sizeText,
          style: TextStyle(
            color: _controller.selectedSize == sizeText ? Colors.white : Colors.black,
            fontSize: width * 0.035,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building UI - isLoading: ${_controller.isLoading}, productName: ${_controller.productName}, imagePaths: ${_controller.imagePaths} at ${DateTime.now()}");

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Early return for loading
    if (_controller.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Early return for failure
    if (_controller.productName.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Failed to load product data"),
              ElevatedButton(
                onPressed: () => _controller.fetchProductData(widget.productId),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // Main UI
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // IMAGE SECTION
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: _controller.imagePaths.isNotEmpty
                            ? PageView.builder(
                          itemCount: _controller.imagePaths.length,
                          onPageChanged: (index) => _controller.setCurrentImageIndex(index),
                          itemBuilder: (context, index) {
                            final imagePath = _controller.imagePaths[index];
                            print("Rendering image: $imagePath at ${DateTime.now()}");
                            if (imagePath.startsWith('http')) {
                              return Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  print("Error loading network image: $imagePath - $error at ${DateTime.now()}");
                                  return Image.asset(
                                    'assets/images/cozyshoplogo.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            } else {
                              print("Invalid URL, using fallback asset for: $imagePath at ${DateTime.now()}");
                              return Image.asset(
                                'assets/images/cozyshoplogo.png',
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        )
                            : Image.asset(
                          'assets/images/cozyshoplogo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: height * 0.02,
                        left: width * 0.04,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.arrow_back_ios, color: const Color(0xFF561C24), size: width * 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.02,
                        right: width * 0.04,
                        child: GestureDetector(
                          onTap: _controller.toggleFavorite,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              _controller.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _controller.isFavorite ? Colors.red : Colors.black,
                              size: width * 0.05,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: height * 0.01,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _controller.imagePaths.asMap().entries.map((entry) {
                            return Container(
                              width: width * 0.02,
                              height: width * 0.02,
                              margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _controller.currentImageIndex == entry.key
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // PRODUCT INFO SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _controller.productName.isNotEmpty ? _controller.productName : 'Unknown Product',
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          "\$${_controller.productPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF561C24),
                          ),
                        ),
                        SizedBox(height: height * 0.015),
                        Text(
                          _controller.productDescription.isNotEmpty ? _controller.productDescription : 'No description available',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                      ],
                    ),
                  ),
                ),

                // COLORS SECTION
                if (_controller.availableColors.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Color",
                            style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: height * 0.01),
                          Row(
                            children: _controller.availableColors.map((colorName) {
                              Color color = _controller.getColorFromName(colorName);
                              return buildColorOption(color, colorName, width);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // SIZES SECTION
                if (_controller.availableSizes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Size",
                            style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: height * 0.01),
                          Wrap(
                            children: _controller.availableSizes.map((size) => buildSizeOption(size, width)).toList(),
                          ),
                          SizedBox(height: height * 0.02),
                        ],
                      ),
                    ),
                  ),

                // REVIEWS SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reviews",
                          style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: height * 0.01),
                        TextField(
                          controller: _controller.reviewController,
                          decoration: InputDecoration(
                            hintText: "Write a review...",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: height * 0.01),
                        ElevatedButton(
                          onPressed: () => _controller.submitReview(context),
                          child: const Text("Submit Review"),
                        ),
                        SizedBox(height: height * 0.02),
                        if (_controller.productReviews.isNotEmpty)
                          ..._controller.productReviews.map((review) => Padding(
                            padding: EdgeInsets.symmetric(vertical: height * 0.01),
                            child: Text(
                              review,
                              style: TextStyle(fontSize: width * 0.04, color: Colors.grey[700]),
                            ),
                          ))
                        else
                          Text(
                            "No reviews yet.",
                            style: TextStyle(fontSize: width * 0.04, color: Colors.grey[700]),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.08,
                decoration: const BoxDecoration(
                  color: Color(0xFF561C24),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => _controller.addToCart(context),
                    icon: Icon(
                      _controller.isAddedToCart ? Icons.check_circle : Icons.shopping_cart,
                      color: const Color(0xFFD0B8A8),
                      size: width * 0.06,
                    ),
                    label: Text(
                      _controller.isAddedToCart ? "Added to Cart" : "Add to Cart",
                      style: TextStyle(
                        color: const Color(0xFFD0B8A8),
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}