class User {
  final String uuid;
  final String login;
  final String passwordHash;

  User({
    required this.uuid,
    required this.login,
    required this.passwordHash,
  });

  // Métodos getter para acessar os atributos
  String get id => uuid;
  String get username => login;

  // Método toString para facilitar a impressão do objeto User
  @override
  String toString() {
    return 'User{id: $id, username: $username, passwordHash: $passwordHash}';
  }
}
