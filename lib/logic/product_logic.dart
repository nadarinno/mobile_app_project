class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });


  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
    );
  }
}