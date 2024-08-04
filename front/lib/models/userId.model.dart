class UserId {
  final int id;
  final String nome;
  final String email;
  final String senha;

  UserId(this.id, this.nome, this.email, this.senha);

  static UserId? fromJson(jsonData) {}
}
