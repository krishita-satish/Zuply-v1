import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

/// Zuply – Smart Food Redistribution Platform
///
/// An AI-powered platform connecting food donors, recipients, and
/// delivery agents to redistribute surplus food efficiently.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Supabase ──
  // Replace these with your actual Supabase project credentials.
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT_ID.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );

  // Set status bar style for a clean look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ZuplyApp());
}

class ZuplyApp extends StatelessWidget {
  const ZuplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final auth = AuthService();
        auth.tryAutoLogin(); // Restore session if available
        return auth;
      },
      child: MaterialApp(
        title: 'Zuply',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            return auth.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
