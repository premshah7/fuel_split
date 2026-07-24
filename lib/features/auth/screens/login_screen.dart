import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\] '), ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\] '), ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailResetController = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address to receive a password reset link.'),
              const SizedBox(height: 16),
              TextField(
                controller: emailResetController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final email = emailResetController.text.trim();
                if (email.isEmpty) return;
                try {
                  await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset email sent to $email'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString().replaceAll(RegExp(r'\[.*?\] '), '')}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                      ? [Colors.black, const Color(0xFF121212), const Color(0xFF1E1E1E)]
                      : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB), const Color(0xFF90CAF9)],
                ),
              ),
            ),
          ),
          // Blurred Orbs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).moveY(begin: -20, end: 20, duration: 4.seconds, curve: Curves.easeInOutSine).then().moveY(begin: 20, end: -20, duration: 4.seconds, curve: Curves.easeInOutSine),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(alpha: 0.2),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).moveX(begin: -20, end: 20, duration: 5.seconds, curve: Curves.easeInOutSine).then().moveX(begin: 20, end: -20, duration: 5.seconds, curve: Curves.easeInOutSine),
          ),
          // Glassmorphism Filter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.5), width: 2),
                        ),
                        child: Icon(
                          Icons.local_gas_station_rounded,
                          size: 60,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'FuelSplit',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 8),
                    Text(
                      'Never argue about gas money again.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 48),
                    
                    // Glass Card Form
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                spreadRadius: -5,
                              )
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.7),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                              ),
                              const SizedBox(height: 16),
                              
                              // Password
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  filled: true,
                                  fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.7),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ).animate().fadeIn().shake(duration: 300.ms),
                              ],
                              
                              const SizedBox(height: 24),
                              
                              // Button
                              SizedBox(
                                height: 56,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: FilledButton.styleFrom(
                                    elevation: 5,
                                    shadowColor: theme.primaryColor.withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading 
                                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 56,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _loginWithGoogle,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.g_mobiledata_rounded, size: 32),
                                  label: const Text('Sign In with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: const Text('Create One', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
