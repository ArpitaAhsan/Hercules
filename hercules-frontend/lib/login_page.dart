import 'package:flutter/material.dart';
import 'package:hercules/styles/app_colors.dart';
import 'package:hercules/config/app_routes.dart';
import 'package:hercules/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false; // Loader for login button

  void _login() async {
    setState(() => isLoading = true); // Show loading

    final response = await ApiService.loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => isLoading = false); // Hide loading

    if (response['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Successful!')),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 110),
              ClipOval(
                child: Image.asset(
                  'assets/hercules_logo.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome back!',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Login to continue',
                style: TextStyle(color: AppColors.black),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your Email',
                  prefixIcon: Icon(Icons.email, color: AppColors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Enter your Password',
                  prefixIcon: Icon(Icons.lock, color: AppColors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                ),
                obscureText: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    print('Forgot button is Clicked');
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.black),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.6),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Log in', style: TextStyle(color: AppColors.black)),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Or sign in with',
                style: TextStyle(color: AppColors.black),
              ),
              SizedBox(height: 16),

              // ✅ Google Sign-In Button
              ElevatedButton(
                onPressed: () {
                  print('Google is clicked');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/google_logo.webp', width: 22, height: 22),
                    SizedBox(width: 6),
                    Text('Login with Google', style: TextStyle(color: AppColors.black)),
                  ],
                ),
              ),

              SizedBox(height: 12), // Spacing

              // ✅ Facebook Sign-In Button
              ElevatedButton(
                onPressed: () {
                  print('Facebook is clicked');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/facebook_logo.png', width: 22, height: 22),
                    SizedBox(width: 6),
                    Text('Login with Facebook', style: TextStyle(color: AppColors.black)),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // ✅ Sign Up Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: AppColors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.register);
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.black),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
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
