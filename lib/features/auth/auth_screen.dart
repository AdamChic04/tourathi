import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_redirects.dart';
import '../../core/theme/app_colors.dart';

/// One email/password authentication form; no public admin self-registration.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.isSignUp});
  final bool isSignUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _working = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _notice(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    if (_working || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _working = true);
    try {
      final auth = Supabase.instance.client.auth;
      final email = _email.text.trim();
      if (widget.isSignUp) {
        final response = await auth.signUp(
          email: email,
          password: _password.text,
          data: {'full_name': _name.text.trim()},
          emailRedirectTo: AuthRedirects.callback,
        );
        if (!mounted) return;
        if (response.session != null) {
          context.go('/main');
        } else {
          context.go('/verify-email?email=${Uri.encodeComponent(email)}');
        }
      } else {
        await auth.signInWithPassword(
          email: email,
          password: _password.text,
        );
        if (mounted) context.go('/main');
      }
    } on AuthException catch (e) {
      _notice(e.message);
    } catch (_) {
      _notice('Could not connect right now. Please try again.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = widget.isSignUp;
    final colors = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AuthBrand(),
                    const SizedBox(height: 36),
                    Text(isSignUp ? 'Create your account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      isSignUp
                          ? 'Start discovering Jordan with TouRathi.'
                          : 'Sign in to continue exploring Jordan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurface.withValues(alpha: .65))),
                    const SizedBox(height: 30),
                    if (isSignUp) ...[
                      TextFormField(
                        key: const Key('auth_full_name'),
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline_rounded)),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) return 'Enter your name';
                          if (value!.trim().length > 120) return 'Name is too long';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      key: const Key('auth_email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline_rounded)),
                      validator: (value) {
                        final email = (value ?? '').trim();
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('auth_password'),
                      controller: _password,
                      obscureText: !_showPassword,
                      textInputAction: isSignUp ? TextInputAction.next : TextInputAction.done,
                      onFieldSubmitted: (_) { if (!isSignUp) _submit(); },
                      autofillHints: [isSignUp ? AutofillHints.newPassword : AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _showPassword ? 'Hide password' : 'Show password',
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                          icon: Icon(_showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined)),
                      ),
                      validator: (value) =>
                          (value ?? '').length < 8 ? 'Use at least 8 characters' : null,
                    ),
                    if (isSignUp) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const Key('auth_confirm_password'),
                        controller: _confirm,
                        obscureText: !_showPassword,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.verified_user_outlined)),
                        validator: (value) =>
                            value != _password.text ? 'Passwords do not match' : null,
                      ),
                    ] else ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _working ? null : () => context.push('/forgot-password'),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        key: const Key('auth_submit'),
                        onPressed: _working ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.warmBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _working
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(isSignUp ? 'Create account' : 'Sign in',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isSignUp ? 'Already have an account?' : 'New to TouRathi?'),
                        TextButton(
                          onPressed: _working ? null : () => context.go(isSignUp ? '/login' : '/signup'),
                          child: Text(isSignUp ? 'Sign in' : 'Sign up'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'TouRathi · Discover Jordan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: colors.onSurface.withValues(alpha: .45)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 86, height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldShimmer,
            boxShadow: [
              BoxShadow(color: AppColors.desertGold.withValues(alpha: .23),
                blurRadius: 28, spreadRadius: 3),
            ],
          ),
          child: const Icon(Icons.explore_rounded, size: 52, color: Colors.white),
        ),
        const SizedBox(height: 15),
        const Text('TouRathi',
            style: TextStyle(fontSize: 28, letterSpacing: 1,
              fontWeight: FontWeight.w800)),
      ],
    );
  }
}
