import 'package:flutter/material.dart';

void main() => runApp(ProductDetailApp());

class ProductDetailApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductDetailsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int currentImageIndex = 0;
  bool isFavorite = false;
  bool isAddedToCart = false;
  bool showDescription = false;
  bool showReviews = false;
  String selectedColor = 'Black';
  String selectedSize = 'M';

  final List<String> imagePaths = [
    'assets/images/product.png',
    'assets/images/product2.png',
    'assets/images/product3.png',
  ];

  Widget buildColorOption(Color color, String colorName, double size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = colorName;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: size * 0.01, vertical: size * 0.02),
        width: size * 0.08,
        height: size * 0.08,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == colorName ? Colors.black : Colors.grey,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget buildSizeOption(String sizeText, double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = sizeText;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: width * 0.02, top: width * 0.02),
        padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: width * 0.02),
        decoration: BoxDecoration(
          color: selectedSize == sizeText ? Color(0xFF561C24) : Color(0xFFD0B8A8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          sizeText,
          style: TextStyle(
            color: selectedSize == sizeText ? Colors.white : Colors.black,
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
                          itemCount: imagePaths.length,
                          onPageChanged: (index) {
                            setState(() => currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              imagePaths[index],
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
                            child: Icon(Icons.arrow_back_ios, color:Color(0xFF561C24), size: width * 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        top: height * 0.02,
                        right: width * 0.04,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
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
                          children: imagePaths.asMap().entries.map((entry) {
                            return Container(
                              width: width * 0.02,
                              height: width * 0.02,
                              margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentImageIndex == entry.key
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
                    color:  Color(0xFFFFFDF6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sportwear Set',
                                style: TextStyle(
                                    fontSize: width * 0.05, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: EdgeInsets.only(right: width * 0.04),
                              child: Text('\$ 80.00',
                                  style: TextStyle(
                                      fontSize: width * 0.05, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        Text('Color',
                            style: TextStyle(
                                fontSize: width * 0.04, fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            buildColorOption(Colors.white, 'White', width),
                            buildColorOption(Colors.black, 'Black', width),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        Text('Size',
                            style: TextStyle(
                                fontSize: width * 0.04, fontWeight: FontWeight.w500)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start, // or center/spaceAround as needed
                          children: ['S', 'M', 'L']
                              .map((size) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: buildSizeOption(size, width),
                          ))
                              .toList(),
                        ),
                        SizedBox(height: height * 0.02),
                        ListTile(
                          title: Text('Description',
                              style: TextStyle(fontSize: width * 0.04)),
                          trailing: Icon(
                              showDescription ? Icons.expand_less : Icons.arrow_forward_ios,
                              size: width * 0.05),
                          onTap: () => setState(() => showDescription = !showDescription),
                        ),
                        if (showDescription)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 4),
                            child: Text(
                              'This sportwear set is made of high-quality, breathable material perfect for active lifestyles. Available in stylish colors and sizes.',
                              style: TextStyle(color: Colors.grey[800], fontSize: width * 0.035),
                            ),
                          ),
                        ListTile(
                          title:
                          Text('Reviews', style: TextStyle(fontSize: width * 0.04)),
                          trailing: Icon(
                              showReviews ? Icons.expand_less : Icons.arrow_forward_ios,
                              size: width * 0.05),
                          onTap: () => setState(() => showReviews = !showReviews),
                        ),
                        if (showReviews)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('⭐️⭐️⭐️⭐️⭐️ - "Very comfortable and stylish!"',
                                    style: TextStyle(fontSize: width * 0.035)),
                                SizedBox(height: 4),
                                Text('⭐️⭐️⭐️⭐️ - "Great quality for the price."',
                                    style: TextStyle(fontSize: width * 0.035)),
                              ],
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
                    onPressed: () {
                      setState(() => isAddedToCart = !isAddedToCart);
                    },
                    icon: Icon(
                      isAddedToCart ? Icons.check_circle : Icons.shopping_cart,
                      color: Color(0xFFD0B8A8),
                      size: width * 0.06,
                    ),
                    label: Text(
                      isAddedToCart ? "Added Successfully" : "Add to cart",
                      style: TextStyle(color: Color(0xFFD0B8A8),  fontSize: width * 0.045),
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
