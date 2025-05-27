import 'package:flutter/material.dart';
import 'Login.dart';
import 'package:mobile_app_project/View/HomePage.dart';
import 'package:mobile_app_project/Controller/SellerSignUpController.dart';

class SellerSignUp extends StatefulWidget {
  const SellerSignUp({super.key});

  @override
  State<SellerSignUp> createState() => _SellerSignUpState();
}

class _SellerSignUpState extends State<SellerSignUp> {
  final _formKey = GlobalKey<FormState>();
  final SellerSignUpController controller = SellerSignUpController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? result = await controller.registerSeller(context);

      if (result == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
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
              const Center(
                child: Text(
                  "Create Seller Account",
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
              if (controller.errorMessage != null)
                Center(
                  child: Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: controller.validateName,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.businessNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your business name',
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: controller.validateBusinessName,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12.0),
                ),
                validator: controller.validatePassword,
              ),
              const SizedBox(height: 20),
              Center(
                child: controller.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF561C24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 140, vertical: 15),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFFFFDF6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
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