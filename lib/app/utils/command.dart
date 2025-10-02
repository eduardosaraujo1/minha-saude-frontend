import 'package:flutter/material.dart';
import 'package:multiple_result/multiple_result.dart';

typedef CommandAction0<TSuccess, TException> =
    Future<Result<TSuccess, TException>> Function();
typedef CommandAction1<TSuccess, TException, A> =
    Future<Result<TSuccess, TException>> Function(A);

/// Facilitates interaction with a ViewModel.
///
/// Encapsulates an action,
/// exposes its running and error states,
/// and ensures that it can't be launched again until it finishes.
///
/// Use [Command0] for actions without arguments.
/// Use [Command1] for actions with one argument.
///
/// Actions must return a [Result].
///
/// Consume the action result by listening to changes,
/// then call to [clearResult] when the state is consumed.
abstract class Command<TSuccess, TException> extends ChangeNotifier {
  Command();

  bool _isExecuting = false;
  Result<TSuccess, TException>? _result;

  bool get isExecuting => _isExecuting;

  bool get isError {
    // if (_isExecuting) {
    //   throw Exception("Attempted to read error state on a running command.");
    // }
    return _result?.isError() ?? false;
  }

  bool get isSuccess {
    // if (_isExecuting) {
    //   throw Exception(
    //     "Attempted to read completed state on a running command.",
    //   );
    // }

    return _result?.isSuccess() ?? false;
  }

  Result<TSuccess, TException>? get result {
    // if (_isExecuting) {
    //   throw Exception("Attempted to read result on a running command.");
    // }

    return _result;
  }

  Future<void> _execute(CommandAction0<TSuccess, TException> action) async {
    _isExecuting = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }

  void clearResult() {
    if (_isExecuting) {
      throw Exception("Attempted to clear result on a running command.");
    }

    _result = null;
    notifyListeners();
  }
}

class Command0<TSuccess, TException> extends Command<TSuccess, TException> {
  Command0(this._action);

  final CommandAction0<TSuccess, TException> _action;

  Future<void> execute() async {
    await _execute(_action);
  }
}

class Command1<TSuccess, TException> extends Command<TSuccess, TException> {
  Command1(this._action);

  final CommandAction1<TSuccess, TException, dynamic> _action;

  Future<void> execute<T>(T param) async {
    await _execute(() => _action(param));
  }
}
