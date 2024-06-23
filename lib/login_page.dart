import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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

  // Execute the query and get the raw response
  final responseJson = await Supabase.instance.client
    .from('users')
    .select()
    .eq('login', username)
    .eq('password_hash', passwordHash)
    .single();

  // Check if the response contains an error
  if (responseJson.containsKey('error') && responseJson['error']!= null) {
    setState(() {
      _errorMessage = 'Usuário ou senha inválidos';
    });
  } else if (responseJson.containsKey('data') && responseJson['data']!= null && responseJson['data'].isNotEmpty) {
    // Assuming 'data' contains the UUID under a key named 'uuid'
    Provider.of<AuthProvider>(context, listen: false).login(responseJson['data']['uuid']);
    Navigator.pushReplacementNamed(context, '/home', arguments: responseJson['data']['uuid']);
  } else {
    setState(() {
      _errorMessage = 'Usuário ou senha inválidos';
    });
  }
}
}
