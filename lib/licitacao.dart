class Licitacao {
  final int id;
  final String numero;
  final String modalidade;
  final String objeto;
  final String responsavel;
  final String status;
  final String data;
  final String? observacoes;

  Licitacao({
    required this.id,
    required this.numero,
    required this.modalidade,
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
      objeto: map['objeto'],
      responsavel: map['responsavel'],
      status: map['status'],
      data: map['data'],
      observacoes: map['observacoes'],
    );
  }
}
