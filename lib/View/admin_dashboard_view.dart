import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/admin_dashboard_controller.dart';
import 'package:mobile_app_project/logic/admin_dashboard_logic.dart';
import 'package:mobile_app_project/logic/AuthService.dart';
import 'package:mobile_app_project/view/login.dart';

class AdminDashboardView extends StatelessWidget {
  final AdminDashboardController controller = AdminDashboardController(AdminDashboardLogic());

  AdminDashboardView({Key? key}) : super(key: key);

  static const Color beige = Color(0xFFE5E1DA);
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);


  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: beige,
          title: const Text(
            'Confirm Sign Out',
            style: TextStyle(color: burgundy, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: burgundy),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text(
                'Sign Out',
                style: TextStyle(color: burgundy),
              ),
              onPressed: () async {

                final authService = AuthService();
                await authService.logout();
                Navigator.pop(dialogContext);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );

              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: controller.getSellersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading sellers'));
        }

        final sellers = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: beige,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: beige,
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(color: burgundy, fontWeight: FontWeight.bold),
            ),
          ),
          body: Stack(
            children: [
              sellers.isEmpty
                  ? const Center(child: Text('No sellers found.'))
                  : ListView.builder(
                itemCount: sellers.length,
                itemBuilder: (context, index) {
                  final seller = sellers[index];
                  return Card(
                    color: lightBurgundy,
                    margin: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: burgundy,
                        child: Icon(Icons.store, color: Colors.white),
                      ),
                      title: Text(
                        seller['name'] ?? 'No name',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: burgundy),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business: ${seller['business'] ?? 'No business'}',
                            style: const TextStyle(color: burgundy),
                          ),

                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,

                      ),
                      onTap: () => controller.onSellerTap(context, seller),
                    ),
                  );
                },
              ),

              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: ElevatedButton(
                  onPressed: () => _showLogoutConfirmationDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: burgundy,
                    foregroundColor: beige,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}