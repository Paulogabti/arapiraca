//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_web_app/main.dart';
//import 'package:my_flutter_web_app/login_page.dart'; // Importar a LoginPage para referência no teste

void main() {
  testWidgets('Login page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the Login page displays the text 'Nome de usuário'.
    expect(find.text('Nome de usuário'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    // Verifique se a mensagem de erro não está exibida inicialmente
    expect(find.text('Usuário ou senha incorretos'), findsNothing);
  });
}
