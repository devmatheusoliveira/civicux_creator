import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/tree/setup_page.dart';
import 'theme/app_theme.dart';
import 'pages/home/home_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/settings/settings_page.dart';

class DevsImpactoApp extends StatelessWidget {
  const DevsImpactoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devs Impacto Online',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/setup': (context) => const SetupPage(),
      },
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final session = snapshot.data?.session;
          if (session != null) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
