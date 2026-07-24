import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../repositories/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: isDark ? Colors.white : Colors.black87,
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark 
                      ? [Colors.black, const Color(0xFF121212), const Color(0xFF1E1E1E)]
                      : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB), const Color(0xFF90CAF9)],
                ),
              ),
            ),
          ),
          // Blurred Orbs
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(alpha: 0.3),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).moveX(begin: 20, end: -20, duration: 4.seconds, curve: Curves.easeInOutSine).then().moveX(begin: -20, end: 20, duration: 4.seconds, curve: Curves.easeInOutSine),
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
                    Text(
                      'Join The Crew',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 8),
                    Text(
                      'Create an account to start splitting expenses.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    
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
                              const SizedBox(height: 16),
                              
                              TextField(
                                controller: _confirmController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock_reset),
                                  filled: true,
                                  fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.7),
                                ),
                                obscureText: true,
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
                              
                              const SizedBox(height: 32),
                              
                              SizedBox(
                                height: 56,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _register,
                                  style: FilledButton.styleFrom(
                                    elevation: 5,
                                    shadowColor: theme.primaryColor.withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading 
                                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
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
