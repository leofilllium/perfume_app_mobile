import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthPage extends StatefulWidget {
  // Callback to inform the parent (MainScreen) about successful authentication
  final VoidCallback onAuthSuccess;

  const AuthPage({Key? key, required this.onAuthSuccess}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitAuthForm() {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });

    if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Username and Password cannot be empty.';
      });
      return;
    }

    if (!_isLogin && _emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email is required for registration.';
      });
      return;
    }

    final authBloc = BlocProvider.of<AuthBloc>(context);

    if (_isLogin) {
      authBloc.add(LoginEvent(
        name: _nameController.text,
        password: _passwordController.text,
      ));
    } else {
      authBloc.add(RegisterEvent(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ));
    }
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isLogin ? 'Login successful!' : 'Registration successful! Please log in.'),
                backgroundColor: Colors.green,
              ),
            );
            if (_isLogin) {
              widget.onAuthSuccess(); // Notify parent on successful login
            } else {
              _switchAuthMode(); // Switch to login after successful registration
            }
          } else if (state is AuthError) {
            setState(() {
              _errorMessage = state.message;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Belle Aura"),
                const SizedBox(height: 32),
                Text(
                  _isLogin ? "Welcome Back!" : "Join Belle Aura",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Username', Icons.person_outline),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                if (!_isLogin)
                  TextField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email', Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                  ),
                if (!_isLogin) const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: _inputDecoration('Password', Icons.lock_outline),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is AuthLoading ? null : _submitAuthForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87, // Dark button as per image
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50), // Full width button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        elevation: 5,
                      ),
                      child: state is AuthLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                        _isLogin ? "Log In" : "Register",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _switchAuthMode,
                  child: RichText(
                    text: TextSpan(
                      text: _isLogin ? "Don't have an account? " : "Already have an account? ",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                      children: [
                        TextSpan(
                          text: _isLogin ? "Register here" : "Log In here",
                          style: const TextStyle(
                            color: Colors.deepOrange, // Highlight color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border line
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepOrange, width: 2), // Highlight focused
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}