import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/colors.dart';
import '../../app/supabase_config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  bool get _isSupabaseConfigured =>
      !supabaseUrl.startsWith('YOUR_') && !supabaseAnonKey.startsWith('YOUR_');

  Future<void> _signUp() async {
    if (!_isSupabaseConfigured) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Kayıt oluşturulamadı.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kayıt ol'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'ornek@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'E-posta girin' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre (en az 6 karakter)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.primary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Şifre girin';
                    if (v.length < 6) return 'En az 6 karakter olmalı';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmController,
                  obscureText: _obscurePasswordConfirm,
                  decoration: InputDecoration(
                    labelText: 'Şifre tekrar',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.primary,
                      ),
                      onPressed: () => setState(
                          () => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Şifreyi tekrar girin';
                    if (v != _passwordController.text) return 'Şifreler eşleşmiyor';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_loading || !_isSupabaseConfigured)
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _signUp();
                          }
                        },
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kayıt ol'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Zaten hesabım var, giriş yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
