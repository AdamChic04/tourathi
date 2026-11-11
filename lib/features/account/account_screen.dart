import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Basic authenticated account page. Organizer/admin portals come later.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final Future<Map<String, String>> _details;

  @override
  void initState() {
    super.initState();
    _details = _load();
  }

  Future<Map<String, String>> _load() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return {};
    final profile = await supabase.from('profiles')
      .select('full_name').eq('id', user.id).maybeSingle();
    final roles = await supabase.from('account_roles')
      .select('role').eq('user_id', user.id).maybeSingle();
    return {
      'name': (profile?['full_name'] ?? '').toString(),
      'role': (roles?['role'] ?? 'tourist').toString(),
    };
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/login');
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('My account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: Icon(Icons.account_circle_outlined, size: 86)),
                const SizedBox(height: 18),
                FutureBuilder<Map<String, String>>(
                  future: _details,
                  builder: (context, snapshot) {
                    final details = snapshot.data ?? {};
                    return Column(children: [
                      Text(details['name']?.isNotEmpty == true
                            ? details['name']! : 'TouRathi traveler',
                        style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(user?.email ?? 'No email found'),
                      const SizedBox(height: 12),
                      Chip(label: Text(
                        snapshot.hasError ? 'Role unavailable' :
                        snapshot.connectionState == ConnectionState.waiting
                            ? 'Loading account…' : (details['role'] ?? 'tourist'))),
                    ]);
                  },
                ),
                const SizedBox(height: 28),
                const Text('Organizer, seller and admin portals will be added after their access rules and dashboards are built.',
                  textAlign: TextAlign.center),
                const Spacer(),
                OutlinedButton.icon(
                  key: const Key('account_sign_out'),
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
