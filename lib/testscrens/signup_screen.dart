import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dental_app/constant/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _saveUserInfo() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('password', _passwordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signup info saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), // Tablet friendly
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: 100,),
                SizedBox(height: screenHeight * 0.05),
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    // Add photo picker here later
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: kPrimaryColor,
                        child:
                            Icon(Icons.person, size: 90, color: Colors.white),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 150),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Account Information",
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField("Name*", "Enter Name", _nameController),
                const SizedBox(height: 10),
                _buildTextField("Phone*", "93218 65xxx", _phoneController),
                const SizedBox(height: 10),
                _buildTextField("Email*", "example@gmail.com", _emailController),
                const SizedBox(height: 10),
                _buildTextField("Password*", "Enter Password",
                    _passwordController, obscure: true),
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
                    onPressed: _saveUserInfo,
                    child: const Text(
                      "Signup",
                      style: TextStyle(
                          fontSize: 16, color: kBackgroundColor),
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
      String label, String hint, TextEditingController controller,
      {bool obscure = false}) {
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
