import 'package:flutter/material.dart';
import 'package:mobile_app_project/View/settings_view.dart';
import 'Login.dart';
import 'package:mobile_app_project/Controller/ForgotPasswordController.dart';

class ForgotPasswordPage extends StatefulWidget {
  final bool fromSettings;

  const ForgotPasswordPage({super.key, this.fromSettings = false});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}


class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final ForgotPasswordController controller = ForgotPasswordController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      String? result = await controller.sendResetLink(context);

      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent! Check your email.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.fromSettings ? const Login(): const SettingPage() ,
          ),
        );

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF561C24),
                    ),
                    onPressed: () {
                      if (widget.fromSettings) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      }

                    },
                  ),
                ],
              ),
              const Center(
                child: Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF561C24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Image(
                  image: AssetImage('assets/images/cozyshoplogo.png'),
                  height: 250,
                ),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Enter your email to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF561C24),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (controller.errorMessage != null)
                Center(
                  child: Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 10),
              TextFormField(

                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 20),
              Center(
                child: controller.isSending
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _sendResetLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF561C24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 140, vertical: 10),
                  ),
                  child: const Text(
                    'Send Reset Link',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFFDF6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!widget.fromSettings)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Remembered your password? ",
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF561C24),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

            ],
          ),
        ),
      ),
    );
  }
}
