class Licitacao {
  final int id;
  final String numero;
  final String modalidade;
  final String numeroModalidade; // Adicionado o campo numeroModalidade
  final String objeto;
  final String responsavel;
  final String status;
  final String data;
  final String? observacoes;

  Licitacao({
    required this.id,
    required this.numero,
    required this.modalidade,
    required this.numeroModalidade, // Adicionado no construtor
    required this.objeto,
    required this.responsavel,
    required this.status,
    required this.data,
    this.observacoes,
  });

  factory Licitacao.fromMap(Map<String, dynamic> map) {
    return Licitacao(
      id: map['id'],
      numero: map['numero'],
      modalidade: map['modalidade'],
      numeroModalidade: map['numeroModalidade'], // Adicionado no fromMap
      objeto: map['objeto'],
      responsavel: map['responsavel'],
      status: map['status'],
      data: map['data'],
      observacoes: map['observacoes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'modalidade': modalidade,
      'numeroModalidade': numeroModalidade, // Adicionado no toMap
      'objeto': objeto,
      'responsavel': responsavel,
      'status': status,
      'data': data,
      'observacoes': observacoes,
    };
  }
}
