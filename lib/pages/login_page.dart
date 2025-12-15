import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;
  bool _obscurePassword = true;

  // n8n login webhook
  final String _loginUrl =
      'https://fitsit.app.n8n.cloud/webhook/7568b8e2-51b3-4b86-8a37-90376347d014';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final uri = Uri.parse(_loginUrl).replace(queryParameters: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      print('=== LOGIN REQUEST ===');
      print('GET $uri');

      final response = await http.get(uri);

      print('=== LOGIN RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Raw body: ${response.body}');

      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() => _errorText = 'Server error: ${response.statusCode}');
        return;
      }

      final decoded = jsonDecode(response.body);

      Map<String, dynamic> obj;
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        obj = Map<String, dynamic>.from(decoded.first as Map);
      } else if (decoded is Map) {
        obj = Map<String, dynamic>.from(decoded);
      } else {
        if (!mounted) return;
        setState(() => _errorText = 'Unexpected response format');
        return;
      }

      final success = obj['success'] == true;

      if (success) {
        final user = obj['user'] as Map<String, dynamic>?;

        print('=== PARSED USER FROM LOGIN ===');
        print('id: ${user?['id']}');
        print('name: ${user?['name']}');
        print('email: ${user?['email']}');
        print('role: ${user?['role']}');

        if (user == null) {
          if (!mounted) return;
          setState(() => _errorText = 'User data missing from response');
          return;
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              userId: user['id']?.toString() ?? '',
              userName: user['name'] ?? '',
              email: user['email'] ?? '',
              role: user['role'] ?? '',
              token: obj['token'],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        setState(() => _errorText = obj['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // App bar optional for a login screen – I’d remove it for a cleaner look
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                color: const Color(0xFF020617),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo / icon
                        Center(
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                colorScheme.primary.withOpacity(0.15),
                            child: Icon(
                              Icons.track_changes_rounded,
                              size: 30,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title + subtitle
                        Center(
                          child: Text(
                            'Client Tracking App',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            'Sign in with your FITS credentials',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Colors.white.withOpacity(0.6),
                                ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        if (_errorText != null) ...[
                          Text(
                            _errorText!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 8),

                        // Login button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submitLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'v1.0.0 • Internal use only',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color:
                                      Colors.white.withOpacity(0.4),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
