import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'auth_provider.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'perfil.dart';
import 'calendar_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialize a formatação de data para português
  await initializeDateFormatting('pt_BR', null);
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
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('pt', 'BR'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale('pt', 'BR'), // Define o locale para português do Brasil
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/perfil': (context) => PerfilPage(),
          '/calendar': (context) => CalendarPage(),
        },
      ),
    );
  }
}
