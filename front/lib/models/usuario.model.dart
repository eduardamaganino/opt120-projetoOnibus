class User {
  final String nome;
  final String email;
  final String senha;
  final String? telefone;
  final bool? isAdm;

  User(this.nome, this.email, this.senha, this.telefone, this.isAdm);

  static User? fromJson(jsonData) {}
}
