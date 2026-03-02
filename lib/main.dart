import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/auth_notifier.dart';
import 'app/router.dart';
import 'app/supabase_config.dart';
import 'app/theme.dart';
import 'data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  if (supabaseUrl.startsWith('YOUR_') || supabaseAnonKey.startsWith('YOUR_')) {
    // Supabase anahtarları girilmemişse uygulama yine açılır; giriş ekranında hata alırsın.
    debugPrint('UYARI: lib/app/supabase_config.dart içinde Supabase URL ve anon key girin.');
  } else {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  final authNotifier = AuthNotifier();
  final router = createGoRouter(authNotifier);

  runApp(
    ProviderScope(
      child: MaterialApp.router(
        title: 'ElectroLearn',
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
}
