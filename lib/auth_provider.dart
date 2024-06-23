import 'package:flutter/foundation.dart';
import 'user.dart'; // Certifique-se de importar a classe User que você definiu

class AuthProvider with ChangeNotifier {
  User? currentUser;

  // Função para simular o login
  void login(User user) {
    currentUser = user;
    notifyListeners(); // Notifica todos os listeners sobre a mudança de estado
  }

  // Função para sair
  void logout() {
    currentUser = null;
    notifyListeners();
  }
}
