import 'package:flutter/material.dart';
import 'package:multiple_result/multiple_result.dart';

class CompartilharViewModel {
  CompartilharViewModel(this.shareRepository) {
    refresh();
  }

  final ShareRepository shareRepository;

  final shares = ValueNotifier<List<Share>>([]);

  final errorMessage = ValueNotifier<String?>(null);

  Future<void> refresh() async {
    final sharesQuery = await shareRepository.listShares();

    if (sharesQuery.isError()) {
      errorMessage.value = sharesQuery.tryGetError()!.toString();
      return;
    }

    shares.value = sharesQuery.tryGetSuccess()!;
  }
}

class ShareRepository {
  // CREATE
  Future<Result<void, Exception>> createShare() async {
    // Implement create logic
    return Result.success(null);
  }

  // READ
  Future<Result<Share?, Exception>> readShare() async {
    // Implement read logic
    return Result.success(null);
  }

  Future<Result<List<Share>, Exception>> listShares() async {
    // Implement list logic
    return Result.success([
      Share(
        id: '1',
        code: 'ABC123',
        validUntil: DateTime.now().add(const Duration(days: 7)),
      ),
      Share(
        id: '2',
        code: 'DEF456',
        validUntil: DateTime.now().add(const Duration(days: 14)),
      ),
      Share(
        id: '3',
        code: 'GHI789',
        validUntil: DateTime.now().add(const Duration(days: 30)),
      ),
    ]);
  }

  // UPDATE
  Future<Result<void, Exception>> updateShare(Share share) async {
    // Implement update logic
    return Result.success(null);
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
