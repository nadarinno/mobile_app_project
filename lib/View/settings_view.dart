// views/setting_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/settings_controller.dart';
import 'package:mobile_app_project/View/Login.dart';
const Color primaryColor = Color(0xFF561C24);

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final SettingsController _controller = SettingsController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _receiveNotifications = true;
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  bool _isEditingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _controller.loadUserProfile();
    if (_controller.userData != null) {
      setState(() {
        _nameController.text = _controller.userData!['name'] ?? '';
        _emailController.text = _controller.userData!['email'] ?? '';
        _phoneController.text = _controller.userData!['phone'] ?? '';
        _locationController.text = _controller.userData!['location'] ?? '';
        _receiveNotifications = _controller.userData!['notificationsEnabled'] ?? true;
      });
    }
  }

  void _toggleEdit(String field) {
    setState(() {
      _isEditingName = field == 'name' ? !_isEditingName : false;
      _isEditingEmail = field == 'email' ? !_isEditingEmail : false;
      _isEditingPhone = field == 'phone' ? !_isEditingPhone : false;
      _isEditingLocation = field == 'location' ? !_isEditingLocation : false;
    });
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFFFFDF6),
      child: child,
    );
  }

  Widget _editableTile({
    required String title,
    required IconData icon,
    required bool isEditing,
    required VoidCallback onTap,
    required Widget child,
    required VoidCallback onSave,
    bool showDone = false,
    VoidCallback? onDone,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon, color: primaryColor),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            onTap: onTap,
          ),
          if (isEditing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton('Save', onSave),
                  if (showDone && onDone != null) ...[
                    const SizedBox(width: 10),
                    _buildActionButton('Done', onDone),
                  ],
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: () async {
        if (_isEditingName) {
          _controller.validateName(_nameController.text);
          if (!_controller.nameValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_controller.nameError ?? 'Invalid name'),
                backgroundColor: primaryColor,
              ),
            );
            return;
          }
        }
        if (_isEditingEmail) {
          _controller.validateEmail(_emailController.text);
          if (!_controller.emailValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_controller.emailError ?? 'Invalid email'),
                backgroundColor: primaryColor,
              ),
            );
            return;
          }
        }
        if (_isEditingPhone) {
          _controller.validatePhone(_phoneController.text);
          if (!_controller.phoneValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_controller.phoneError ?? 'Invalid phone'),
                backgroundColor: primaryColor,
              ),
            );
            return;
          }
        }
        if (_isEditingLocation) {
          _controller.validateLocation(_locationController.text);
          if (!_controller.locationValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_controller.locationError ?? 'Invalid location'),
                backgroundColor: primaryColor,
              ),
            );
            return;
          }
        }

        setState(() {
          _isEditingName = false;
          _isEditingEmail = false;
          _isEditingPhone = false;
          _isEditingLocation = false;
        });

        final updatedData = {
          'id': _controller.userData?['id'] ?? '',
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
          'notificationsEnabled': _receiveNotifications,
        };
        await _controller.updateUserProfile(context, updatedData);
      },
      style: TextButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: primaryColor),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: const Color(0xFFE5E1DA),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFE5E1DA),
      body: _controller.userData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          _buildSectionTitle('Account Settings'),
          _editableTile(
            title: 'Change Name',
            icon: Icons.person,
            isEditing: _isEditingName,
            onTap: () => _toggleEdit('name'),
            onSave: () {
              _controller.validateName(_nameController.text);
              if (_controller.nameValid) {
                setState(() => _isEditingName = false);
              }
            },
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'New Name',
                errorText: _controller.nameError,
              ),
            ),
          ),
          _editableTile(
            title: 'Change Email',
            icon: Icons.email,
            isEditing: _isEditingEmail,
            onTap: () => _toggleEdit('email'),
            onSave: () {
              _controller.validateEmail(_emailController.text);
              if (_controller.emailValid) {
                setState(() => _isEditingEmail = false);
              }
            },
            showDone: _controller.emailValid,
            onDone: () => setState(() => _isEditingEmail = false),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'name@example.com',
                errorText: _controller.emailError,
                suffixIcon: _controller.emailValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : (_controller.emailError != null
                    ? const Icon(Icons.error, color: primaryColor)
                    : null),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          _editableTile(
            title: 'Update Phone Number',
            icon: Icons.phone,
            isEditing: _isEditingPhone,
            onTap: () => _toggleEdit('phone'),
            onSave: () {
              _controller.validatePhone(_phoneController.text);
              if (_controller.phoneValid) {
                setState(() => _isEditingPhone = false);
              }
            },
            showDone: _controller.phoneValid,
            onDone: () => setState(() => _isEditingPhone = false),
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: '059xxxxxxxx',
                errorText: _controller.phoneError,
                suffixIcon: _controller.phoneValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : (_controller.phoneError != null
                    ? const Icon(Icons.error, color: primaryColor)
                    : null),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          _buildCard(
            child: ListTile(
              leading: Icon(Icons.lock, color: primaryColor),
              title: const Text(
                'Change Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordPage(),
                ),
              ),
            ),
          ),
          const Divider(),
          _buildSectionTitle('Preferences'),
          _buildCard(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.notifications, color: primaryColor),
              title: const Text(
                'Receive Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              value: _receiveNotifications,
              onChanged: (val) async {
                setState(() => _receiveNotifications = val);
                final updatedData = {
                  'id': _controller.userData?['id'] ?? '',
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'phone': _phoneController.text.trim(),
                  'location': _locationController.text.trim(),
                  'notificationsEnabled': _receiveNotifications,
                };
                await _controller.updateUserProfile(context, updatedData);
              },
              activeColor: primaryColor,
            ),
          ),
          _editableTile(
            title: 'Set Location',
            icon: Icons.location_on,
            isEditing: _isEditingLocation,
            onTap: () => _toggleEdit('location'),
            onSave: () {
              _controller.validateLocation(_locationController.text);
              if (_controller.locationValid) {
                setState(() => _isEditingLocation = false);
              }
            },
            showDone: _controller.locationValid,
            onDone: () => setState(() => _isEditingLocation = false),
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Nablus, Rafidia',
                errorText: _controller.locationError,
              ),
            ),
          ),
          _buildCard(
            child: ListTile(
              leading: Icon(Icons.payment, color: primaryColor),
              title: const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentPage(),
                ),
              ),
            ),
          ),
          const Divider(),
          _buildCard(
            child: ListTile(
              leading: Icon(Icons.logout, color: primaryColor),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Optionally navigate to login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                );
              },
            ),
          ),
          _buildCard(
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text(
                      'Are you sure you want to delete your account? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _controller.deleteAccount(context);
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: const Center(child: Text('Change Password Page')),
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Method')),
      body: const Center(child: Text('Payment Method Page')),
    );
  }
}