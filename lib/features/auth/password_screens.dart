import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/auth/auth_redirects.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _working = false;
  bool _sent = false;
  @override
  void dispose() { _email.dispose(); super.dispose(); }

  Future<void> _requestReset() async {
    if (!_form.currentState!.validate() || _working) return;
    setState(() => _working = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _email.text.trim(), redirectTo: AuthRedirects.passwordReset);
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Request failed. Try again.')));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset your password')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: _sent
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.mark_email_read_outlined, size: 65),
                  const SizedBox(height: 18),
                  const Text('Check your email',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('If the address is registered, a password reset link will arrive.'),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () => context.go('/login'),
                      child: const Text('Back to sign in')),
                ])
              : Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Forgot password?',
                        style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text('Enter the email address associated with your account.'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline)),
                      validator: (value) =>
                          (value ?? '').contains('@') ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: 22),
                    FilledButton(onPressed: _working ? null : _requestReset,
                      child: Text(_working ? 'Sending…' : 'Send reset link')),
                  ],
                ),
              ),
        ),
      ),
    ),
  );
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _working = false;
  @override
  void dispose() { _password.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _updatePassword() async {
    if (!(_form.currentState?.validate() ?? false) || _working) return;
    setState(() => _working = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _password.text));
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated. Sign in again.')));
        context.go('/login');
      }
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not update password.')));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Set a new password')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create a new password',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                const Text('Use at least 8 characters.'),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                  validator: (v) => (v ?? '').length >= 8
                      ? null : 'Use at least 8 characters',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirm, obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm password'),
                  validator: (v) => v == _password.text
                      ? null : 'Passwords do not match',
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _working ? null : _updatePassword,
                  child: Text(_working ? 'Updating…' : 'Update password'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
