import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'home_page.dart';  // Certifique-se de que esta importação está correta
import 'register_page.dart';
import 'auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        '/home': (context) => HomePage(),  // Certifique-se de que esta rota está correta
      },
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return authProvider.currentUser != null
            ? HomePage()  // Certifique-se de que esta chamada está correta
            : LoginPage();
      },
    );
  }
}
