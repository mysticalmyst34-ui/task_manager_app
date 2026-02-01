import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _showPass = false;
  bool _showConfirm = false;
  bool _pressed = false;
  bool _passwordsMatch = true;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _pass.addListener(_checkMatch);
    _confirm.addListener(_checkMatch);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _checkMatch() {
    if (!mounted) return;
    setState(() {
      _passwordsMatch = _confirm.text.isEmpty || _pass.text == _confirm.text;
    });
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _register() async {
    if (_first.text.isEmpty || _last.text.isEmpty) {
      _show("Please enter your name");
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_email.text.trim())) {
      _show("Invalid email format");
      return;
    }
    if (_pass.text.length < 6) {
      _show("Password must be at least 6 characters");
      return;
    }
    if (!_passwordsMatch) {
      _show("Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    final error = await _authService.register(
      email: _email.text.trim(),
      password: _pass.text,
      name: '${_first.text.trim()} ${_last.text.trim()}',
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _show(error);
    } else {
      _show("Account created successfully 🎉");
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Colors.redAccent;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/login_bg.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.15)),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 1.2,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Expanded(
                            child: _field("First Name", Icons.person, _first),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              "Last Name",
                              Icons.person_outline,
                              _last,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      _field("Email", Icons.email_outlined, _email),
                      const SizedBox(height: 18),

                      _passwordField("Password", _pass, _showPass, () {
                        setState(() => _showPass = !_showPass);
                      }),
                      const SizedBox(height: 18),

                      _passwordField(
                        "Confirm Password",
                        _confirm,
                        _showConfirm,
                        () => setState(() => _showConfirm = !_showConfirm),
                        borderColor: _passwordsMatch
                            ? Colors.white
                            : errorColor,
                      ),

                      if (!_passwordsMatch)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Passwords do not match",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 26),

                      GestureDetector(
                        onTapDown: (_) => setState(() => _pressed = true),
                        onTapCancel: () => setState(() => _pressed = false),
                        onTapUp: (_) {
                          setState(() => _pressed = false);
                          if (!_loading) _register();
                        },
                        child: AnimatedScale(
                          scale: _pressed ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBFD9FF), Color(0xFF8AB6F9)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Back to Login",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: label,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool show,
    VoidCallback toggle, {
    Color borderColor = Colors.white,
  }) {
    return TextField(
      controller: controller,
      obscureText: !show,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            show ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: toggle,
        ),
        hintText: label,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
