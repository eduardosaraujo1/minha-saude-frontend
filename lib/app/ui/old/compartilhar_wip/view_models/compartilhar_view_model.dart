import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/domain/models/share.dart';
import 'package:minha_saude_frontend/app/data/repositories/share_repository.dart';

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
