import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:primefit/Login.dart';
// import 'package:primefit/main.dart';
import 'package:primefit/welcome.dart';


// Registration Page
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> signUserUp() async {
  if (!_formKey.currentState!.validate()) return;
  
  if (!_agreeToTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please agree to the Terms of Service and Privacy Policy')),
    );
    return;
  }
 
  setState(() {
    _isLoading = true;
  });
  
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    // Update the user's display name
    await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameController.text.trim());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      
      // Navigate to MainNavigationPage instead of ProfilePage directly
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
      );
    }
  } on FirebaseAuthException catch (e) {
    // Handle specific Firebase Auth errors
    String errorMessage;
    switch (e.code) {
      case 'weak-password':
        errorMessage = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        errorMessage = 'An account already exists with this email.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is invalid.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Email/password accounts are not enabled.';
        break;
      default:
        errorMessage = 'An error occurred. Please try again.';
    }
   
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header
                const Text(
                  'JOIN THE\nPRIME FIT COMMUNITY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Create your account to access premium gear',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 53, 243, 104),
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Full Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color.fromARGB(255, 36, 181, 70),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color.fromARGB(255, 36, 181, 70),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      HapticFeedback.lightImpact();
                      await signUserUp();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _agreeToTerms && !_isLoading ? Color.fromARGB(255, 38, 134, 83) : Colors.grey[700],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 25, 193, 48) ,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}