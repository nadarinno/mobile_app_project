import 'package:flutter/material.dart';

class SellerDetailPage extends StatelessWidget {
  final Map<String, String> seller;
  const SellerDetailPage({super.key, required this.seller});

  static const Color beige = Color(0xFFE5E1DA);
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: beige,
        title: const Text(
          'Seller Information',
          style: TextStyle(
              color: Color(0xFF561C24),
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: lightBurgundy,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
          alpha: 0,
            red: 0,
            green: 0,
            blue: 0,
          ),

          blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Name', seller['name']!),
              _infoRow('Email', seller['email']!),
              _infoRow('Phone', seller['phone']!),
              _infoRow('Location', seller['location']!),
              _infoRow('Business Type', seller['business']!),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: burgundy,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                    },
                    child: const Text('Accept', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      _showRejectDialog(context);
                    },
                    child: const Text('Reject', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: burgundy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: lightBurgundy,
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to reject this seller?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
              // You can remove the seller here using state management
            },
            child: const Text('Yes, Reject'),
          ),
        ],
      ),
    );
  }
}
