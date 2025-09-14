class Document {
  const Document({
    required this.id,
    required this.paciente,
    required this.titulo,
    required this.tipo,
    required this.medico,
    required this.dataDocumento,
    required this.dataAdicao,
  });

  final String id;
  final String paciente;
  final String titulo;
  final String tipo;
  final String medico;
  final DateTime dataDocumento;
  final DateTime dataAdicao;

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      paciente: map['paciente'],
      titulo: map['titulo'],
      tipo: map['tipo'],
      medico: map['medico'],
      dataDocumento: DateTime.parse(map['dataDocumento']),
      dataAdicao: DateTime.parse(map['dataAdicao']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paciente': paciente,
      'titulo': titulo,
      'tipo': tipo,
      'medico': medico,
      'dataDocumento': dataDocumento.toIso8601String(),
      'dataAdicao': dataAdicao.toIso8601String(),
    };
  }
}
