import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

// Substitua 'http://localhost:3000' pelo endereço do seu servidor backend Node.js
const String backendUrl = 'http://localhost:3000';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ambiente de Trabalho - CPC-Obras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 24.0),
                  child: Image.asset('assets/logo.png', height: 100),
                ),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Nome de usuário'),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text('Entrar'),
                ),
                SizedBox(height: 20),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Hash the password
    var bytes = utf8.encode(password);
    var passwordHash = sha256.convert(bytes).toString();

    // URL do backend para login
    final url = Uri.parse('$backendUrl/login');

    try {
      // Enviar requisição de login para o backend
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password_hash': passwordHash}),
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        // Armazenar o UUID do usuário ao fazer login
        Provider.of<AuthProvider>(context, listen: false).login(responseJson['uuid'], responseJson['additionalArgument']); // Substitua 'additionalArgument' pelo nome real do argumento esperado
        Navigator.pushReplacementNamed(context, '/home', arguments: responseJson['uuid']);
      } else {
        setState(() {
          _errorMessage = 'Usuário ou senha inválidos';
        });
      }
    } catch (error) {
      print('Erro ao fazer login: $error');
      setState(() {
        _errorMessage = 'Erro ao fazer login. Tente novamente mais tarde.';
      });
    }
  }
}
