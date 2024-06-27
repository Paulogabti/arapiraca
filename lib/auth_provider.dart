import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _currentUser;
  String? get currentUser => _currentUser;

  Future<void> register(String nome, String email, String senha) async {
    final url = Uri.parse('http://localhost:3000/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nome': nome, 'email': email, 'senha': senha}),
    );

    if (response.statusCode == 201) {
      // Usuário registrado com sucesso
    } else {
      throw Exception('Falha ao registrar usuário');
    }
  }

  Future<void> login(String email, String senha) async {
    final url = Uri.parse('http://localhost:3000/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      _currentUser = json.decode(response.body)['user']['email'];
      notifyListeners();
    } else {
      throw Exception('Falha ao fazer login');
    }
  }
}
