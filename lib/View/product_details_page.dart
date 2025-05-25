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
    _controller.fetchProductData(widget.productId);
    _controller.addListener(_updateState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _controller.dispose();
    super.dispose();
  }

  void _updateState() {
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
            color: isSelected ? Colors.black : Color(0xFFD0B8A8),
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
          color: _controller.selectedSize == sizeText ? Color(0xFF561C24) : Color(0xFFD0B8A8),
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (_controller.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: PageView.builder(
                          itemCount: _controller.imagePaths.length,
                          onPageChanged: (index) => _controller.setCurrentImageIndex(index),
                          itemBuilder: (context, index) {
                            return Image.asset(
                              _controller.imagePaths[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: height * 0.02,
                        left: width * 0.04,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.arrow_back_ios, color: Color(0xFF561C24), size: width * 0.05),
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
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(width * 0.04, height * 0.02, 0, height * 0.1),
                    color: Color(0xFFFFFDF6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_controller.productName,
                                style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: EdgeInsets.only(right: width * 0.04),
                              child: Text('\$ ${_controller.productPrice.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        Text('Color', style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w500)),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _controller.availableColors.map((colorName) {
                              print("Building color option for: $colorName");
                              return buildColorOption(_controller.getColorFromName(colorName), colorName, width);
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Text('Size', style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w500)),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _controller.availableSizes.map((size) => buildSizeOption(size, width)).toList(),
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        ListTile(
                          title: Text('Description', style: TextStyle(fontSize: width * 0.04)),
                          trailing: Icon(
                              _controller.showDescription ? Icons.expand_less : Icons.arrow_forward_ios,
                              size: width * 0.05),
                          onTap: _controller.toggleDescription,
                        ),
                        if (_controller.showDescription)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            child: Text(_controller.productDescription, style: TextStyle(fontSize: width * 0.035)),
                          ),
                        SizedBox(height: height * 0.01),
                        ListTile(
                          title: Text('Reviews', style: TextStyle(fontSize: width * 0.04)),
                          trailing: Icon(
                              _controller.showReviews ? Icons.expand_less : Icons.arrow_forward_ios,
                              size: width * 0.05),
                          onTap: _controller.toggleReviews,
                        ),
                        if (_controller.showReviews)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _controller.productReviews
                                  .map((review) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text("- $review", style: TextStyle(fontSize: width * 0.035)),
                              ))
                                  .toList(),
                            ),
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
                decoration: BoxDecoration(
                  color: Color(0xFF561C24),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => _controller.addToCart(context),
                    icon: Icon(
                      _controller.isAddedToCart ? Icons.check_circle : Icons.shopping_cart,
                      color: Color(0xFFD0B8A8),
                      size: width * 0.06,
                    ),
                    label: Text(
                      _controller.isAddedToCart ? "Added to Cart" : "Add to Cart",
                      style: TextStyle(
                        color: Color(0xFFD0B8A8),
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