// models/seller.dart

class Seller {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String business;
  final bool approved;

  Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.business,
    required this.approved,
  });

  // Convert Firestore document to Seller object
  factory Seller.fromMap(Map<String, dynamic> data, String id) {
    return Seller(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? '',
      business: data['business'] ?? '',
      approved: data['approved'] ?? false,
    );
  }

  // Convert Seller object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'business': business,
      'approved': approved,
    };
  }
}