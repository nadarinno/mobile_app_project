// views/setting_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_project/Controller/settings_controller.dart';

const Color primaryColor = Color(0xFF561C24);

class SettingPage extends StatefulWidget {
  final Function(String) onLanguageChange;
  final Locale currentLocale;

  const SettingPage({
    super.key,
    required this.onLanguageChange,
    required this.currentLocale,
  });

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
  String _selectedLanguage = 'en';
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  bool _isEditingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLocale.languageCode;
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
        _selectedLanguage = _controller.userData!['language'] ?? 'en';
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

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  );

  Widget _card({required Widget child}) => Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: const Color(0xFFFFFDF6),
    child: child,
  );

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
    bool isArabic = widget.currentLocale.languageCode == 'ar';
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
              leading: Icon(icon, color: primaryColor),
              title: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              onTap: onTap),
          if (isEditing) ...[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton(isArabic ? 'حفظ' : 'Save', onSave),
                  if (showDone && onDone != null) ...[
                    const SizedBox(width: 10),
                    _actionButton(isArabic ? 'تم' : 'Done', onDone),
                  ],
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed) {
    bool isArabic = widget.currentLocale.languageCode == 'ar';
    return TextButton(
      onPressed: () async {
        if (_isEditingName) {
          _controller.validateName(_nameController.text, isArabic);
          if (!_controller.nameValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_controller.nameError!),
                  backgroundColor: primaryColor),
            );
            return;
          }
        }
        if (_isEditingEmail) {
          _controller.validateEmail(_emailController.text, isArabic);
          if (!_controller.emailValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_controller.emailError!),
                  backgroundColor: primaryColor),
            );
            return;
          }
        }
        if (_isEditingPhone) {
          _controller.validatePhone(_phoneController.text, isArabic);
          if (!_controller.phoneValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_controller.phoneError!),
                  backgroundColor: primaryColor),
            );
            return;
          }
        }
        if (_isEditingLocation) {
          _controller.validateLocation(_locationController.text, isArabic);
          if (!_controller.locationValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_controller.locationError!),
                  backgroundColor: primaryColor),
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
          'language': _selectedLanguage,
          'notificationsEnabled': _receiveNotifications,
        };
        await _controller.updateUserProfile(context, updatedData);
      },
      style: TextButton.styleFrom(
          backgroundColor: primaryColor, foregroundColor: Colors.white),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = widget.currentLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: primaryColor),
        title: Text(isArabic ? 'الإعدادات' : 'Settings',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: primaryColor)),
        backgroundColor: const Color(0xFFE5E1DA),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFE5E1DA),
      body: _controller.userData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          _sectionTitle(isArabic ? 'إعدادات الحساب' : 'Account Settings'),
          _editableTile(
            title: isArabic ? 'تغيير الاسم' : 'Change Name',
            icon: Icons.person,
            isEditing: _isEditingName,
            onTap: () => _toggleEdit('name'),
            onSave: () {
              _controller.validateName(_nameController.text, isArabic);
              if (_controller.nameValid) {
                setState(() => _isEditingName = false);
              }
            },
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  hintText: isArabic ? 'الاسم الجديد' : 'New Name',
                  errorText: _controller.nameError),
            ),
          ),
          _editableTile(
            title: isArabic ? 'تغيير البريد الإلكتروني' : 'Change Email',
            icon: Icons.email,
            isEditing: _isEditingEmail,
            onTap: () => _toggleEdit('email'),
            onSave: () {
              _controller.validateEmail(_emailController.text, isArabic);
              if (_controller.emailValid) {
                setState(() => _isEditingEmail = false);
              }
            },
            showDone: _controller.emailValid,
            onDone: () => setState(() => _isEditingEmail = false),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'name@gmail.com',
                errorText: _controller.emailError,
                suffixIcon: _controller.emailValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : (_controller.emailError != null
                    ? const Icon(Icons.cancel, color: primaryColor)
                    : null),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          _editableTile(
            title: isArabic ? 'تحديث رقم الهاتف' : 'Update Phone Number',
            icon: Icons.phone,
            isEditing: _isEditingPhone,
            onTap: () => _toggleEdit('phone'),
            onSave: () {
              _controller.validatePhone(_phoneController.text, isArabic);
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
                    ? const Icon(Icons.cancel, color: primaryColor)
                    : null),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          _card(
            child: ListTile(
              leading: Icon(Icons.lock, color: primaryColor),
              title: Text(
                  isArabic ? 'تغيير كلمة المرور' : 'Change Password',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage())),
            ),
          ),
          const Divider(),
          _sectionTitle(isArabic ? 'التفضيلات' : 'Preferences'),
          _card(
            child: ListTile(
              leading: Icon(Icons.language, color: primaryColor),
              title: Text(isArabic ? 'اختيار اللغة' : 'Choose Language',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              trailing: IconTheme(
                data: const IconThemeData(color: primaryColor),
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  dropdownColor: const Color(0xFFE5E1DA),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                  onChanged: (val) async {
                    if (val != null) {
                      setState(() => _selectedLanguage = val);
                      widget.onLanguageChange(val);
                      final updatedData = {
                        'id': _controller.userData?['id'] ?? '',
                        'name': _nameController.text.trim(),
                        'email': _emailController.text.trim(),
                        'phone': _phoneController.text.trim(),
                        'location': _locationController.text.trim(),
                        'language': _selectedLanguage,
                        'notificationsEnabled': _receiveNotifications,
                      };
                      await _controller.updateUserProfile(context, updatedData);
                    }
                  },
                ),
              ),
            ),
          ),
          _card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.notifications, color: primaryColor),
              title: Text(
                isArabic ? 'استقبال الإشعارات' : 'Receive Notifications',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: primaryColor),
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
                  'language': _selectedLanguage,
                  'notificationsEnabled': _receiveNotifications,
                };
                await _controller.updateUserProfile(context, updatedData);
              },
              activeColor: primaryColor,
            ),
          ),
          _editableTile(
            title: isArabic ? 'تحديد الموقع' : 'Set Location',
            icon: Icons.location_on,
            isEditing: _isEditingLocation,
            onTap: () => _toggleEdit('location'),
            onSave: () {
              _controller.validateLocation(_locationController.text, isArabic);
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
                  errorText: _controller.locationError),
            ),
          ),
          _card(
            child: ListTile(
              leading: Icon(Icons.payment, color: primaryColor),
              title: Text(
                  isArabic ? 'طريقة الدفع' : 'Select Payment Method',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PaymentPage())),
            ),
          ),
          const Divider(),
          _card(
            child: ListTile(
              leading: Icon(Icons.logout, color: primaryColor),
              title: Text(isArabic ? 'تسجيل الخروج' : 'Log Out',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Optionally navigate to login page
              },
            ),
          ),
          _card(
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                isArabic ? 'حذف الحساب' : 'Delete Account',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title:
                    Text(isArabic ? 'تأكيد الحذف' : 'Confirm Deletion'),
                    content: Text(
                      isArabic
                          ? 'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.'
                          : 'Are you sure you want to delete your account? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _controller.deleteAccount(context, isArabic);
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(isArabic ? 'حذف' : 'Delete'),
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
        appBar: AppBar(title: const Text("Change Password")),
        body: const Center(child: Text("Change Password Page")));
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Payment Method")),
        body: const Center(child: Text("Payment Method Page")));
  }
}