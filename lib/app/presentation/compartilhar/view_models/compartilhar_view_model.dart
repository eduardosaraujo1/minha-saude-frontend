class CompartilharViewModel {
  CompartilharViewModel(this.shareRepository);

  final ShareRepository shareRepository;
}

class ShareRepository {
  // CREATE
  Future<void> createShare() async {
    // Implement create logic
  }

  // READ
  Future<Share?> readShare() async {
    // Implement read logic
  }

  Future<List<Share>> listShares() async {
    // Implement list logic
    return [];
  }

  // UPDATE
  Future<void> updateShare(Share share) async {
    // Implement update logic
  }

  // DELETE
  Future<void> deleteShare() async {
    // Implement delete logic
  }
}

class Share {
  final String id;
  final String code;
  final DateTime validUntil;

  Share({required this.code, required this.validUntil, required this.id});

  factory Share.fromMap(Map<String, dynamic> map) {
    return Share(
      id: map['id'],
      code: map['code'],
      validUntil: DateTime.parse(map['validUntil']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'validUntil': validUntil.toIso8601String()};
  }
}
