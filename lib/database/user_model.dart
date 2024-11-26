class User {
  final int? id;
  final String nome;
  final String email;
  final String tipo;
  final int senha;
  final bool excluido;
  final String createdAt;

  User({
    this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    required this.senha,
    this.excluido = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'senha': senha,
      'excluido': excluido ? 1 : 0,
      'created_at': createdAt,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      tipo: map['tipo'],
      senha: map['senha'],
      excluido: map['excluido'] == 1,
      createdAt: map['created_at'],
    );
  }
}
