import 'package:dental_app/services/user_authintication.dart';
import 'package:dental_app/constant/constants.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signup() async {
    try {
      final user = await _authService.signUpWithEmailPassword(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup Successful")),
        );
        Navigator.pop(context); // go back to login
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 100),
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: kPrimaryColor,
                  child: Icon(Icons.person, size: 90, color: Colors.white),
                ),
                const SizedBox(height: 150),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Account Information",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField("Name*", "Enter Name", _nameController),
                const SizedBox(height: 10),
                _buildTextField("Phone*", "93218 65xxx", _phoneController),
                const SizedBox(height: 10),
                _buildTextField("Email*", "example@gmail.com", _emailController),
                const SizedBox(height: 10),
                _buildTextField(
                  "Password*",
                  "Enter Password",
                  _passwordController,
                  obscure: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                    ),
                    onPressed: _signup, // ✅ FIXED
                    child: const Text(
                      "Signup",
                      style: TextStyle(fontSize: 16, color: kBackgroundColor),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      ),
    );
  }
}
