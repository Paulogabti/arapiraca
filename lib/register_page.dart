import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
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
                  onPressed: () => _register(context),
                  child: Text('Registrar'),
                ),
                SizedBox(height: 20),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Hash da senha
    var bytes = utf8.encode(password);
    var passwordHash = sha256.convert(bytes).toString();

    // Preparando os dados para inserção no banco de dados
    final insertData = {
      'name': name,
      'email': email,
      'password_hash': passwordHash,
    };

    try {
      // Realizando a inserção no banco de dados via backend
      final response = await http.post(
        Uri.parse('http://localhost:3000/register'), // Atualize com a URL do seu backend
        headers: {'Content-Type': 'application/json'},
        body: json.encode(insertData),
      );

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        setState(() {
          _errorMessage = "Erro ao registrar";
        });
      }
    } catch (e) {
      print("Erro ao registrar: $e");
      setState(() {
        _errorMessage = "Erro ao registrar";
      });
    }
  }
}
