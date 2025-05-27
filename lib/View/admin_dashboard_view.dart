import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project/Controller/admin_dashboard_controller.dart';
import 'package:mobile_app_project/logic/admin_dashboard_logic.dart';

class AdminDashboardView extends StatelessWidget {
  final AdminDashboardController controller = AdminDashboardController(AdminDashboardLogic());

  AdminDashboardView({Key? key}) : super(key: key);

  static const Color beige = Color(0xFFE5E1DA);
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: controller.getSellersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
          body: sellers.isEmpty
              ? const Center(child: Text('No sellers found.'))
              : ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index];
              return Card(
                color: lightBurgundy,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: burgundy,
                    child: Icon(Icons.store, color: Colors.white),
                  ),
                  title: Text(
                    seller['name']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: burgundy),
                  ),
                  subtitle: Text(
                    seller['business']!,
                    style: const TextStyle(color: burgundy),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white),
                  onTap: () => controller.onSellerTap(context, seller),
                ),
              );
            },
          ),
        );
      },
    );
  }
}