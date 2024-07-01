import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _currentUser;
  String? _currentUserName; // Novo campo para armazenar o nome do usuário
  String? get currentUser => _currentUser;
  String? get currentUserName => _currentUserName; // Getter para o nome do usuário

  Future<void> register(String nome, String email, String senha) async {
    final url = Uri.parse('http://localhost:3000/register');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': nome, 'email': email, 'password': senha}),
    );

    if (response.statusCode == 200) {
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
      body: json.encode({'email': email, 'password': senha}),
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      _currentUser = responseJson['user']['id'].toString(); // Converta o user_id para string
      _currentUserName = responseJson['user']['name']; // Armazena o nome do usuário
      notifyListeners();
    } else {
      throw Exception('Falha ao fazer login');
    }
  }

  Future<void> updatePassword(String userId, String currentPassword, String newPassword) async {
    final url = Uri.parse('http://localhost:3000/update-password');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar senha');
    }
  }

  void logout() {
    _currentUser = null;
    _currentUserName = null; // Limpar o nome do usuário ao fazer logout
    notifyListeners();
  }
}
