// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dental_app/constant/constants.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _rememberMe = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//   }

//   Future<void> _loadSavedData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _rememberMe = prefs.getBool('rememberMe') ?? false;
//       if (_rememberMe) {
//         _usernameController.text = prefs.getString('username') ?? '';
//         _passwordController.text = prefs.getString('password') ?? '';
//       }
//     });
//   }

//   Future<void> _login() async {
//     if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter username and password")),
//       );
//       return;
//     }

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (_rememberMe) {
//       await prefs.setBool('rememberMe', true);
//       await prefs.setString('username', _usernameController.text);
//       await prefs.setString('password', _passwordController.text);
//     } else {
//       await prefs.clear();
//     }

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const SignupScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 500),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
                 
//                 SizedBox(height: screenHeight * 0.05),
//                 const Text(
//                   "Welcome back!",
//                   style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 Image.asset('lib/assets/images/DentistAppLogo.png',
//                     height: 280),
//                 const SizedBox(height: 70),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(0,0,190,0),
//                   child: const Text(
//                     "Enter your credentials to continue",
//                     style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 TextField(
//                   controller: _usernameController,
                
//                   decoration: InputDecoration(contentPadding:
//             const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//                     prefixIcon: const Icon(Icons.person_outline),
//                     hintText: 'Username',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(kBorderRadius),

//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(contentPadding:
//             const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: const Icon(Icons.visibility_outlined),
//                     hintText: 'Password',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(kBorderRadius),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _rememberMe,
//                       onChanged: (value) {
//                         setState(() {
//                           _rememberMe = value ?? false;
//                         });
//                       },
//                     ),
//                     const Text("Remember me next time"),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kPrimaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(kBorderRadius),
//                       ),
//                     ),
//                     onPressed: _login,
//                     child: const Padding(
//                       padding: EdgeInsets.all(14.0),
//                       child: Text("Login",
//                           style: TextStyle(
//                               fontSize: 16, color: kBackgroundColor)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
