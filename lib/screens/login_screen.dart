import 'package:dental_app/services/user_authintication.dart';
import 'package:dental_app/constant/constants.dart';
import 'package:dental_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final user = await _authService.loginWithEmailPassword(
      emailController.text,
      passwordController.text,
    );
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful")),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Failed")),
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                 
                const Text(
                  "Welcome back!",
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Image.asset('lib/assets/images/DentistAppLogo.png',
                    height: 280),
                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,190,0),
                  child: const Text(
                    "Enter your credentials to continue",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                
                  decoration: InputDecoration(contentPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Email : ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),

                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(contentPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: const Icon(Icons.visibility_outlined),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                  ),
                ),
                // Row(
                //   children: [
                //     Checkbox(
                //       value: _rememberMe,
                //       onChanged: (value) {
                //         setState(() {
                //           _rememberMe = value ?? false;
                //         });
                //       },
                //     ),
                //     const Text("Remember me next time"),
                //   ],
                // ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                    ),
                    onPressed: _login,
                    child: const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Text("Login",
                          style: TextStyle(
                              fontSize: 16, color: kBackgroundColor)),
                    ),
                  ),
                ),
             SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text("Don't have an account? Signup"),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
