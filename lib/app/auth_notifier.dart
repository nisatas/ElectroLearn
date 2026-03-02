import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  bool get isLoggedIn => Supabase.instance.client.auth.currentUser != null;
}
