import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _changeLanguage(String languageCode) {
    setState(() => _locale = Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [],
      home: SettingPage(
        currentLocale: _locale,
        onLanguageChange: _changeLanguage,
      ),
    );
  }
}

class SettingPage extends StatefulWidget {
  final Function(String) onLanguageChange;
  final Locale currentLocale;
  const SettingPage({super.key, required this.onLanguageChange, required this.currentLocale});
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _receiveNotifications = true;
  String _name = '', _email = '', _phone = '', _location = '', _selectedLanguage = 'en';
  bool _isEditingName = false, _isEditingEmail = false, _isEditingPhone = false, _isEditingLocation = false;
  String? _emailError, _phoneError;
  bool _emailValid = false, _phoneValid = false, _locationValid = true;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLocale.languageCode;
  }

  void _toggleEdit(String field) => setState(() {
    _isEditingName = field == 'name' ? !_isEditingName : false;
    _isEditingEmail = field == 'email' ? !_isEditingEmail : false;
    _isEditingPhone = field == 'phone' ? !_isEditingPhone : false;
    _isEditingLocation = field == 'location' ? !_isEditingLocation : false;
  });

  void _validateEmail(bool isArabic) {
    setState(() {
      _emailValid = RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(_email);
      _emailError = _emailValid ? null : (isArabic ? 'استخدم بريدًا مثل name@gmail.com' : 'Use email like name@gmail.com');
    });
  }

  void _validatePhone(bool isArabic) {
    setState(() {
      _phoneValid = RegExp(r'^(059|97259)\d{7}$').hasMatch(_phone);
      _phoneError = _phoneValid ? null : (isArabic ? 'رقم الهاتف يجب أن يبدأ بـ 059 ويحتوي على 10 أرقام' : 'Phone must start with 059 and be 10 digits');
    });
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  );

  Widget _card({required Widget child}) => Card(
    elevation: 5,
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: const Color(0xFFE5E1DA),
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
          ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), onTap: onTap),
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
    return TextButton(
      onPressed: () {
        onPressed();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(text == 'تم' || text == 'حفظ' ? 'تم الحفظ بنجاح' : 'Saved successfully'),
          backgroundColor: const Color(0xFF561C24),
        ));
      },
      style: TextButton.styleFrom(backgroundColor: const Color(0xFF561C24), foregroundColor: Colors.white),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = widget.currentLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإعدادات' : 'Settings',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFFDF6))),
        backgroundColor: const Color(0xFF561C24),
      ),
      backgroundColor: const Color(0xFFFFFDF6),
      body: ListView(
        children: [
          _sectionTitle(isArabic ? 'إعدادات الحساب' : 'Account Settings'),
          _editableTile(
            title: isArabic ? 'تغيير الاسم' : 'Change Name',
            icon: Icons.person,
            isEditing: _isEditingName,
            onTap: () => _toggleEdit('name'),
            onSave: () => setState(() => _isEditingName = false),
            child: TextField(
              decoration: InputDecoration(hintText: isArabic ? 'الاسم الجديد' : 'New Name'),
              onChanged: (v) => _name = v,
            ),
          ),
          _editableTile(
            title: isArabic ? 'تغيير البريد الإلكتروني' : 'Change Email',
            icon: Icons.email,
            isEditing: _isEditingEmail,
            onTap: () => _toggleEdit('email'),
            onSave: () => _validateEmail(isArabic),
            showDone: _emailValid,
            onDone: () => setState(() => _isEditingEmail = false),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'name@gmail.com',
                errorText: _emailError,
                suffixIcon: _emailValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : (_emailError != null ? const Icon(Icons.cancel, color: Colors.red) : null),
              ),
              onChanged: (v) => _email = v,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          _editableTile(
            title: isArabic ? 'تحديث رقم الهاتف' : 'Update Phone Number',
            icon: Icons.phone,
            isEditing: _isEditingPhone,
            onTap: () => _toggleEdit('phone'),
            onSave: () => _validatePhone(isArabic),
            showDone: _phoneValid,
            onDone: () => setState(() => _isEditingPhone = false),
            child: TextField(
              decoration: InputDecoration(
                hintText: '059xxxxxxxx',
                errorText: _phoneError,
                suffixIcon: _phoneValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : (_phoneError != null ? const Icon(Icons.cancel, color: Colors.red) : null),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (v) => _phone = v,
            ),
          ),
          _card(
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: Text(isArabic ? 'تغيير كلمة المرور' : 'Change Password',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
            ),
          ),
          const Divider(),
          _sectionTitle(isArabic ? 'التفضيلات' : 'Preferences'),
          _card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(isArabic ? 'اختيار اللغة' : 'Choose Language',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: const Color(0xFFE5E1DA),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedLanguage = val);
                    widget.onLanguageChange(val);
                  }
                },
              ),
            ),
          ),
          _card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const Icon(Icons.notifications),
              title: Text(
                isArabic ? 'استقبال الإشعارات' : 'Receive Notifications',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              value: _receiveNotifications,
              onChanged: (val) => setState(() => _receiveNotifications = val),
              activeColor: const Color(0xFF561C24),
            ),
          ),
          _editableTile(
            title: isArabic ? 'تحديد الموقع' : 'Set Location',
            icon: Icons.location_on,
            isEditing: _isEditingLocation,
            onTap: () => _toggleEdit('location'),
            onSave: () => setState(() => _locationValid = _location.isNotEmpty),
            showDone: _locationValid,
            onDone: () => setState(() => _isEditingLocation = false),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Nablus, Rafidia'),
              onChanged: (v) => _location = v,
            ),
          ),
          _card(
            child: ListTile(
              leading: const Icon(Icons.payment),
              title: Text(isArabic ? 'طريقة الدفع' : 'Select Payment Method',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentPage())),
            ),
          ),
          const Divider(),
          _card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF561C24)),
              title: Text(isArabic ? 'تسجيل الخروج' : 'Log Out',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF561C24))),
              onTap: () {},
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
    return Scaffold(appBar: AppBar(title: const Text("Change Password")), body: const Center(child: Text("Change Password Page")));
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Payment Method")), body: const Center(child: Text("Payment Method Page")));
  }
}
