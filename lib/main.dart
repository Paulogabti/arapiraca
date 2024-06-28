import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'perfil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Ambiente de Trabalho - CPC-Obras',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/register': (context) => RegisterPage(), // Defina a rota para a página de registro
          '/perfil': (context) => PerfilPage(),
        },
      ),
    );
  }
}
