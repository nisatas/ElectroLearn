import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/colors.dart';
import '../../app/supabase_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isSupabaseConfigured =>
      !supabaseUrl.startsWith('YOUR_') && !supabaseAnonKey.startsWith('YOUR_');

  Future<void> _login() async {
    if (!_isSupabaseConfigured) return;
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
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
          _error = 'Giriş yapılamadı.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  'ElectroLearn',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elektrik & Elektronik öğren',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 48),
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
                    labelText: 'Şifre',
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Şifre girin' : null,
                ),
                if (!_isSupabaseConfigured) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Supabase ayarlanmamış. lib/app/supabase_config.dart içinde supabaseUrl ve supabaseAnonKey girin.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
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
                            _login();
                          }
                        },
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Giriş yap'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: const Text('Hesabım yok, kayıt ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
