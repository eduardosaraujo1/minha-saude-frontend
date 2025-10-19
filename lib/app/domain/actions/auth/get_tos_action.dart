import 'package:flutter/services.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../config/asset.dart';

/// Gets the Terms of Service for the application
///
/// Uses [rootBundle] to load the TOS text from assets.
class GetTosAction {
  Future<Result<String, Exception>> execute() async {
    try {
      final tos = await rootBundle.loadString(Asset.tos);
      return Success(tos);
    } catch (e) {
      return Error(Exception("Failed to load Terms of Service: $e"));
    }
  }
}
