import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'supabase_config.dart' as supabaseConfig; // Alias para supabase_config.dart
import 'auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase using the configuration
  await Supabase.initialize(
    url: supabaseConfig.SupabaseConfig.supabaseUrl, // Usando o alias
    anonKey: supabaseConfig.SupabaseConfig.supabaseAnonKey, // Usando o alias
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambiente de Trabalho CPC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _buildHomeScreen(context),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => LicitacoesScreen(),
      },
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return authProvider.currentUser != null
            ? LicitacoesScreen()
            : LoginPage();
      },
    );
  }
}
