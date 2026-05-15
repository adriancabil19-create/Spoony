import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home_screen.dart';
import '../screens/dashboard_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  static const routeName = '/';
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isAdminMode = false;
  bool _isSignUpMode = false;
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String? _successMessage;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    // Handles OAuth redirect completion and all sign-in events
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      if (data.event != AuthChangeEvent.signedIn) return;
      final user = data.session?.user;
      if (user == null) return;
      final isAdmin = user.appMetadata['role'] == 'admin';
      if (_isAdminMode && !isAdmin) {
        Supabase.instance.client.auth.signOut();
        setState(() => _errorMessage = 'Not authorized as admin.');
        return;
      }
      Navigator.pushReplacementNamed(
        context,
        isAdmin ? DashboardScreen.routeName : HomeScreen.routeName,
      );
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Navigation handled by onAuthStateChange listener
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      // Offline/dev fallback — navigate directly without credentials
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        _isAdminMode ? DashboardScreen.routeName : HomeScreen.routeName,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'All fields are required.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (!mounted) return;
      setState(() {
        _isSignUpMode = false;
        _successMessage = 'Account created! Check your email to verify, then sign in.';
        _passwordController.clear();
        _confirmPasswordController.clear();
        _nameController.clear();
      });
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://spoony.vercel.app',
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => _ForgotPasswordDialog(
        initialEmail: _emailController.text.trim(),
      ),
    );
  }

  InputDecoration _field(String hint, IconData icon) => InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
      );

  Widget _errorBanner(String msg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
      );

  Widget _successBanner(String msg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
      );

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF006994), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.14,
              child: Image.network(
                'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 560),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Colors.white.withValues(alpha: 0.14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 32,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: _isSignUpMode
                          ? _buildSignUpForm(primary)
                          : _buildLoginForm(primary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login form ──────────────────────────────────────────────────────────────

  Widget _buildLoginForm(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isAdminMode ? 'Admin Access' : 'Welcome Back',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontSize: 34,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          _isAdminMode
              ? 'Secure admin authentication for Spoony operators.'
              : 'Sign in to continue your Cebu travel experience.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.6,
              ),
        ),
        const SizedBox(height: 22),
        // Guest / Admin toggle
        ToggleButtons(
          isSelected: [!_isAdminMode, _isAdminMode],
          borderRadius: BorderRadius.circular(16),
          fillColor: Colors.white.withValues(alpha: 0.16),
          selectedColor: Colors.white,
          color: Colors.white70,
          borderColor: Colors.white24,
          selectedBorderColor: Colors.white38,
          onPressed: (index) => setState(() {
            _isAdminMode = index == 1;
            _isSignUpMode = false;
            _errorMessage = null;
            _successMessage = null;
          }),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text('Guest'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text('Admin'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (_successMessage != null) ...[
          _successBanner(_successMessage!),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: _field('Email address', Icons.person),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          onSubmitted: (_) => _handleLogin(),
          decoration: _field('Password', Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          _errorBanner(_errorMessage!),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              activeColor: Colors.white,
              checkColor: primary,
              onChanged: (v) => setState(() => _rememberMe = v ?? true),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text('Remember me', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text('Forgot password?', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                )
              : Text(
                  _isAdminMode ? 'Admin Login' : 'Sign In',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
        ),
        if (!_isAdminMode) ...[
          const SizedBox(height: 18),
          const Center(child: Text('or continue with', style: TextStyle(color: Colors.white70))),
          const SizedBox(height: 14),
          _SocialBtn(label: 'Google', icon: Icons.g_mobiledata, onTap: _signInWithGoogle),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() {
              _isSignUpMode = true;
              _errorMessage = null;
              _successMessage = null;
            }),
            child: const Text(
              "Don't have an account? Create one",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white70,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Sign-up form ─────────────────────────────────────────────────────────────

  Widget _buildSignUpForm(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                _isSignUpMode = false;
                _errorMessage = null;
              }),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
            Expanded(
              child: Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          "Join Spoony and explore Cebu's best tourist spots.",
          style: TextStyle(color: Colors.white70, height: 1.6),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: _field('Full name', Icons.person),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: _field('Email address', Icons.email),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: _field('Password (min. 6 chars)', Icons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          style: const TextStyle(color: Colors.white),
          onSubmitted: (_) => _handleSignUp(),
          decoration: _field('Confirm password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          _errorBanner(_errorMessage!),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _isLoading ? null : _handleSignUp,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primary,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                )
              : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 18),
        const Center(child: Text('or sign up with', style: TextStyle(color: Colors.white70))),
        const SizedBox(height: 14),
        _SocialBtn(label: 'Google', icon: Icons.g_mobiledata, onTap: _signInWithGoogle),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() {
            _isSignUpMode = false;
            _errorMessage = null;
          }),
          child: const Text(
            'Already have an account? Sign in',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Forgot password dialog ────────────────────────────────────────────────────

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _ctrl;
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter your email and we'll send a reset link."),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            enabled: !_sent,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email address',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          if (_sent) ...[
            const SizedBox(height: 10),
            const Text(
              'Reset link sent! Check your inbox.',
              style: TextStyle(color: Colors.green, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_sent ? 'Done' : 'Cancel'),
        ),
        if (!_sent)
          FilledButton(
            onPressed: _loading
                ? null
                : () async {
                    setState(() { _loading = true; _error = null; });
                    try {
                      await Supabase.instance.client.auth.resetPasswordForEmail(
                        _ctrl.text.trim(),
                      );
                      setState(() => _sent = true);
                    } on AuthException catch (e) {
                      setState(() => _error = e.message);
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
            child: _loading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send Reset Link'),
          ),
      ],
    );
  }
}

// ── Shared social login button ────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
