import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;
  Future<void> _resend() async {
    if (widget.email.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup, email: widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email requested. Check your inbox.')));
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verify your email')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.mark_email_unread_outlined, size: 76),
            const SizedBox(height: 22),
            const Text('Check your inbox',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('We sent a confirmation link to ${widget.email}. Open it, then return to TouRathi and sign in.',
              textAlign: TextAlign.center),
            const SizedBox(height: 25),
            FilledButton(onPressed: () => context.go('/login'),
              child: const Text('Go to sign in')),
            TextButton(onPressed: _sending ? null : _resend,
              child: Text(_sending ? 'Sending…' : 'Resend confirmation email')),
          ]),
        ),
      ),
    ),
  );
}
