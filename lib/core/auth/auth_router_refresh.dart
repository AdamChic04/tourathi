import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Refreshes GoRouter when a login, logout, or recovery callback occurs.
class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          isRecoveringPassword = true;
        }
        if (state.event == AuthChangeEvent.signedOut) {
          isRecoveringPassword = false;
        }
        notifyListeners();
      },
      onError: (Object error, StackTrace trace) {
        // Network errors from the auth stream must be handled.
        debugPrint('Auth state refresh was temporarily unavailable.');
      },
    );
  }

  late final StreamSubscription<AuthState> _subscription;
  bool isRecoveringPassword = false;

  void finishRecovery() {
    isRecoveringPassword = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
