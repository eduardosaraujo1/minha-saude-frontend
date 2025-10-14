class Share {
  // id CHAR(36) PRIMARY KEY,
  // codigo CHAR(8) NOT NULL UNIQUE,
  // expiresAt DATETIME NULL,
  final String id;
  final String codigo;
  final DateTime expiresAt;

  const Share({
    required this.id,
    required this.codigo,
    required this.expiresAt,
  });

  factory Share.fromMap(Map<String, dynamic> map) {
    return Share(
      id: map['id'],
      codigo: map['codigo'],
      expiresAt: DateTime.parse(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
