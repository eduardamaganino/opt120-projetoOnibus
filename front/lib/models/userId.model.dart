class UserId {
  final int id;
  final String nome;
  final String email;
  final String senha;
  final String cpf;

  UserId(this.id, this.nome, this.email, this.senha, this.cpf);

  static UserId? fromJson(jsonData) {}
}
