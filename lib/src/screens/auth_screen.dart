import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home_screen.dart';
import '../screens/driver_screen.dart';
import '../recovery_flag.dart';

class AuthScreen extends ConsumerStatefulWidget {
  static const routeName = '/';
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isAdminMode = false;
  bool _isSignUpMode = false;
  bool _isPasswordRecovery = false;
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
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialState();
      // If already logged in (e.g. browser back button landed here), skip login
      if (!_isPasswordRecovery) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null && mounted) {
          _navigateAfterLogin(session.user);
        }
      }
    });

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      if (data.event == AuthChangeEvent.passwordRecovery) {
        setState(() {
          _isPasswordRecovery = true;
          _errorMessage = null;
          _successMessage = null;
        });
        return;
      }
      if (data.event != AuthChangeEvent.signedIn) return;
      if (_isPasswordRecovery) return; // stay on reset form until done
      final user = data.session?.user;
      if (user == null) return;
      final isAdmin = user.appMetadata['role'] == 'admin';
      if (_isAdminMode && !isAdmin) {
        Supabase.instance.client.auth.signOut();
        setState(() => _errorMessage = 'Not authorized as admin.');
        return;
      }
      _navigateAfterLogin(user);
    });
  }

  Future<void> _navigateAfterLogin(User user) async {
    if (!mounted) return;
    // Check driver table first (before navigating)
    try {
      final driverRow = await Supabase.instance.client
          .from('drivers')
          .select('id')
          .eq('email', user.email ?? '')
          .maybeSingle();
      if (!mounted) return;
      if (driverRow != null) {
        Navigator.pushReplacementNamed(context, DriverScreen.routeName);
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  void dispose() {
    _authSub.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
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
    } catch (e) {
      setState(() => _errorMessage = 'Unexpected error. Please try again.');
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
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (!mounted) return;
      if (response.session != null) {
        // Email confirmation disabled — user is auto-confirmed; onAuthStateChange handles navigation
      } else {
        setState(() {
          _isSignUpMode = false;
          _successMessage = 'Account created! Check your email to verify, then sign in.';
          _passwordController.clear();
          _confirmPasswordController.clear();
          _nameController.clear();
        });
      }
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

  // Fallback: supabase_flutter processes the recovery token during initialize()
  // (before AuthScreen builds), so the passwordRecovery event fires into an
  // empty stream and is lost. kHasRecoveryToken is captured in main() before
  // Supabase cleans the URL, so it works on both desktop and mobile browsers.
  void _checkInitialState() {
    if (_isPasswordRecovery) return;
    if (!kHasRecoveryToken) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
    try {
      final parts = session.accessToken.split('.');
      if (parts.length < 2) return;
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)))
          as Map<String, dynamic>;
      final amr = payload['amr'] as List?;
      final isRecovery =
          amr?.any((m) => m is Map && m['method'] == 'recovery') ?? false;
      if (isRecovery && mounted) {
        setState(() {
          _isPasswordRecovery = true;
          _errorMessage = null;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleResetPassword() async {
    final password = _newPasswordController.text;
    final confirm = _confirmNewPasswordController.text;
    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both fields.');
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
      await Supabase.instance.client.auth.updateUser(UserAttributes(password: password));
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
      setState(() {
        _isPasswordRecovery = false;
        _successMessage = 'Password updated! Please sign in with your new password.';
      });
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
                      child: _isPasswordRecovery
                          ? _buildResetPasswordForm(primary)
                          : _isSignUpMode
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

  // ── Reset password form ───────────────────────────────────────────────────

  Widget _buildResetPasswordForm(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Set New Password',
          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter and confirm your new password below.',
          style: TextStyle(color: Colors.white70, height: 1.6),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: _field('New password (min. 6 chars)', Icons.lock).copyWith(
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
          controller: _confirmNewPasswordController,
          obscureText: _obscureConfirm,
          style: const TextStyle(color: Colors.white),
          onSubmitted: (_) => _handleResetPassword(),
          decoration: _field('Confirm new password', Icons.lock_outline).copyWith(
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
          onPressed: _isLoading ? null : _handleResetPassword,
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
              : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Reset Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Text(
                _sent ? 'Check your inbox for the reset link.' : 'Enter your email and we\'ll send a reset link.',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_sent) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.mark_email_read_outlined, color: Color(0xFF16A34A), size: 22),
                    SizedBox(width: 12),
                    Flexible(child: Text('Reset link sent! Check your inbox and spam folder.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF15803D)))),
                  ]),
                ),
              ] else ...[
                TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'your@email.com',
                    hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, size: 16, color: Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Flexible(child: Text(_error!, style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)))),
                    ]),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
                  child: Text(_sent ? 'Close' : 'Cancel'),
                ),
                if (!_sent) ...[
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _loading ? null : () async {
                      setState(() { _loading = true; _error = null; });
                      try {
                        await Supabase.instance.client.auth
                            .resetPasswordForEmail(
                              _ctrl.text.trim(),
                              redirectTo: 'https://spoony.vercel.app/',
                            )
                            .timeout(const Duration(seconds: 20));
                        if (mounted) setState(() => _sent = true);
                      } on AuthException catch (e) {
                        if (mounted) setState(() => _error = e.message);
                      } catch (_) {
                        if (mounted) setState(() => _error = 'Request timed out. Please check your connection and try again.');
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Send Reset Link'),
                  ),
                ],
              ]),
            ]),
          ),
        ]),
      ),
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
