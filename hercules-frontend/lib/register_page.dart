import 'package:flutter/material.dart';
import 'package:hercules/styles/app_colors.dart';
import 'package:hercules/config/app_routes.dart';
import 'package:hercules/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool termsAccepted = false;
  String? selectedCountry;
  final List<String> countries = ['Bangladesh', 'Canada', 'UK', 'Germany', 'France'];

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Function to handle registration
  void _register() async {
    if (_formKey.currentState!.validate() && termsAccepted) {
      // Collect form data
      String name = _nameController.text;
      String email = _emailController.text;
      String phone = _phoneController.text;
      String password = _passwordController.text;
      String country = selectedCountry ?? '';

      try {
        // Call the API Service to register user
        final response = await ApiService.registerUser(
          name: name,
          email: email,
          phone: phone,
          password: password,
          country: country,
          termsAccepted: termsAccepted,
        );

        if (response['error'] != null) {
          // If error, show the error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'])),
          );
        } else {
          // If successful, navigate to login page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Successful!')),
          );

          // Navigate to the login page
          Navigator.of(context).pushReplacementNamed(AppRoutes.login); // Modified this line
        }
      } catch (e) {
        // Handle any exceptions or errors during the API call
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7CFB6), // Updated Background Color
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 110),

            // Hercules Logo (Matching Login Page)
            ClipOval(
              child: Image.asset(
                'assets/hercules_logo.png',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            const Text(
              "Create an Account",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.black),
            ),

            const SizedBox(height: 14),

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField("Full Name", Icons.person, _nameController),
                  const SizedBox(height: 16),
                  _buildTextField("Email Address", Icons.email, _emailController),
                  const SizedBox(height: 16),
                  _buildTextField("Phone Number", Icons.phone, _phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildPasswordField("Password", _passwordController, isConfirm: false),
                  const SizedBox(height: 16),
                  _buildPasswordField("Confirm Password", _confirmPasswordController, isConfirm: true),
                  const SizedBox(height: 16),

                  // Country Dropdown
                  _buildCountryDropdown(),

                  const SizedBox(height: 16),

                  // Terms & Conditions Checkbox
                  _buildTermsCheckbox(),

                  const SizedBox(height: 20),

                  // Register Button
                  _buildRegisterButton(),

                  const SizedBox(height: 20),

                  // Social Login Buttons
                  const Text("Or sign up with", style: TextStyle(color: AppColors.black)),
                  const SizedBox(height: 12),
                  _buildSocialLoginButton("Login with Google", "assets/google_logo.webp"),
                  _buildSocialLoginButton("Login with Facebook", "assets/facebook_logo.png"),

                  const SizedBox(height: 20),

                  // Already have an account? Log in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: AppColors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                        },
                        style: TextButton.styleFrom(foregroundColor: AppColors.black),
                        child: const Text(
                          'Log in',
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
          ],
        ),
      ),
    );
  }

  // Reusable Input Field with Icon
  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5), // Matching Login Page
      ),
      validator: (value) => value!.isEmpty ? "$hint cannot be empty" : null,
    );
  }

  // Password Field with Toggle Visibility
  Widget _buildPasswordField(String hint, TextEditingController controller, {required bool isConfirm}) {
    return TextFormField(
      controller: controller,
      obscureText: isConfirm ? !_confirmPasswordVisible : !_passwordVisible,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(isConfirm ? (_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off) : (_passwordVisible ? Icons.visibility : Icons.visibility_off)),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              } else {
                _passwordVisible = !_passwordVisible;
              }
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5), // Matching Login Page
      ),
      validator: (value) {
        if (value!.isEmpty) return "$hint cannot be empty";
        if (isConfirm && value != _passwordController.text) return "Passwords do not match";
        return null;
      },
    );
  }

  // Country Dropdown
  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCountry,
      decoration: InputDecoration(
        hintText: 'Select Country',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5), // Matching Login Page
      ),
      items: countries.map((String country) {
        return DropdownMenuItem(value: country, child: Text(country));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCountry = value;
        });
      },
      validator: (value) => value == null ? "Please select a country" : null,
    );
  }

  // Terms & Conditions Checkbox
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: termsAccepted,
          onChanged: (value) {
            setState(() {
              termsAccepted = value!;
            });
          },
        ),
        const Expanded(child: Text('I accept the Terms & Conditions')),
      ],
    );
  }

  // Register Button
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (termsAccepted && _formKey.currentState!.validate())
            ? _register
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.withOpacity(termsAccepted ? 1.0 : 0.5),
        ),
        child: const Text('Register Account', style: TextStyle(color: AppColors.black)),
      ),
    );
  }

  Widget _buildSocialLoginButton(String text, String assetPath) {
    return ElevatedButton(
      onPressed: () {
        print('$text clicked');
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, width: 22, height: 22),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: AppColors.black)),
        ],
      ),
    );
  }
}
