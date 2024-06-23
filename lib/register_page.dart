import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
  String email = _emailController.text;
  String password = _passwordController.text;

  // Preparando os dados para inserção no banco de dados
  final insertData = {
    'login': email,
    'password_hash': password, // Enviando a senha em texto simples
  };

  try {
    // Realizando a inserção no banco de dados
    final response = await Supabase.instance.client
   .from('users')
   .insert(insertData);

    print("Resposta da inserção: $response"); // Log para diagnosticar a resposta

    // Navega de volta para a tela de login usando a rota nomeada, independentemente do resultado
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  } catch (e) {
    print("Erro ao registrar: $e");
    setState(() {
      _errorMessage = "Erro ao registrar";
    });
  }
}

}