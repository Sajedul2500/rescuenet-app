import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'RegistrationStep2Page.dart';
import '../features/registration/data/services/registration_service.dart';
import '../features/registration/domain/models/registration_models.dart';

class RegistrationStep1Page extends StatefulWidget {
  const RegistrationStep1Page({super.key});

  @override
  State<RegistrationStep1Page> createState() => _RegistrationStep1PageState();
}

class _RegistrationStep1PageState extends State<RegistrationStep1Page>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final RegistrationService _registrationService = RegistrationService();

  String _selectedGender = 'Male';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;

  // Server-side validation errors
  Map<String, String> _serverErrors = {};

  late AnimationController _formController;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _formFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _formController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      // Email is optional
      return null;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }

    final mobileRegex = RegExp(r'^(?:\+88)?01[3-9]\d{8}$');
    if (!mobileRegex.hasMatch(value)) {
      return 'Enter a valid Bangladesh mobile number';
    }
    return null;
  }

  String? _getServerError(String field) {
    return _serverErrors[field];
  }

  void _proceedToNextStep() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _serverErrors = {}; // Clear previous errors
      });

      try {
        // Prepare Step 1 data
        final step1Data = Step1Data(
          fullName: _fullNameController.text.trim(),
          gender: _selectedGender, // Male, Female, Other
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null, // Send null if empty, let backend handle it
          phone: _mobileController.text.trim().isNotEmpty
              ? _mobileController.text.trim()
              : null, // Send null if empty
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

        // Submit to backend
        final response = await _registrationService.submitStep1(step1Data);

        if (!mounted) return;

        if (response.success) {
          // Success - Navigate to Step 2
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  response.message ?? 'Registration started successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Collect registration data for UI flow
          final registrationData = {
            'fullName': _fullNameController.text.trim(),
            'gender': _selectedGender,
            'mobile': _mobileController.text.trim(),
            'email': _emailController.text.trim(),
            'userId': response.data?.userId,
          };

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (_, __, ___) =>
                  RegistrationStep2Page(registrationData: registrationData),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOut))
                      .animate(animation),
                  child: child,
                );
              },
            ),
          );
        } else {
          // API Error - Set server errors to display below fields
          setState(() {
            if (response.errors != null) {
              response.errors!.forEach((key, value) {
                if (value is List) {
                  _serverErrors[key] = value.join(', ');
                } else {
                  _serverErrors[key] = value.toString();
                }
              });
            }
          });

          // Show general error message as snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ??
                  'Registration failed. Please check the errors below.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'Registration - Step 1 of 3',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _formFadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SlideTransition(
            position: _formSlideAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Create Your Account',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please fill in your basic information',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _getServerError('name') ??
                          _getServerError('full_name'),
                    ),
                    onChanged: (value) {
                      // Clear server error when user types
                      if (_serverErrors.containsKey('name') ||
                          _serverErrors.containsKey('full_name')) {
                        setState(() {
                          _serverErrors.remove('name');
                          _serverErrors.remove('full_name');
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full Name is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender *',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _getServerError('gender'),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGender = value;
                          _serverErrors.remove('gender');
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mobile Number
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number *',
                      hintText: '01XXXXXXXXX',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText:
                          _getServerError('phone') ?? _getServerError('mobile'),
                    ),
                    onChanged: (value) {
                      if (_serverErrors.containsKey('phone') ||
                          _serverErrors.containsKey('mobile')) {
                        setState(() {
                          _serverErrors.remove('phone');
                          _serverErrors.remove('mobile');
                        });
                      }
                    },
                    validator: _validateMobile,
                  ),
                  const SizedBox(height: 16),

                  // Email Address
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address (Optional)',
                      hintText: 'example@email.com',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _getServerError('email'),
                    ),
                    onChanged: (value) {
                      if (_serverErrors.containsKey('email')) {
                        setState(() {
                          _serverErrors.remove('email');
                        });
                      }
                    },
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(
                              () => _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _getServerError('password'),
                    ),
                    onChanged: (value) {
                      if (_serverErrors.containsKey('password')) {
                        setState(() {
                          _serverErrors.remove('password');
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _getServerError('password_confirmation') ??
                          _getServerError('confirmPassword'),
                    ),
                    onChanged: (value) {
                      if (_serverErrors.containsKey('password_confirmation') ||
                          _serverErrors.containsKey('confirmPassword')) {
                        setState(() {
                          _serverErrors.remove('password_confirmation');
                          _serverErrors.remove('confirmPassword');
                        });
                      }
                    },
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
                  const SizedBox(height: 32),

                  // Next Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _proceedToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next Step',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD32F2F),
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
      ),
    );
  }
}
