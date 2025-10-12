import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeServerPersistentStorage {
  FakeServerPersistentStorage() {
    _init();
  }

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  bool? _isRegistered;
  FakeRegisterModel? _cachedUser;

  Future<void> setRegistered(bool value) async {
    _isRegistered = value;

    // Update SecureStorage
    _secureStorage.write(key: 'is_registered', value: value ? 'true' : 'false');
  }

  Future<bool> getRegistered({bool forceRefresh = false}) async {
    if (forceRefresh || _isRegistered == null) {
      await _init();
    }
    return _isRegistered ?? false;
  }

  /// Registers a user and stores all their data in secure storage.
  /// This will override any existing user data.
  Future<void> setUser(FakeRegisterModel user) async {
    _cachedUser = user;
    _isRegistered = true;

    // Store user data as JSON
    final userData = {
      'id': user.id,
      'email': user.email,
      'cpf': user.cpf,
      'nome': user.nome,
      'telefone': user.telefone,
      'dataNascimento': user.dataNascimento.toIso8601String(),
      'metodoAutenticacao': user.metodoAutenticacao.name,
    };

    await _secureStorage.write(key: 'user_data', value: jsonEncode(userData));
    await _secureStorage.write(key: 'is_registered', value: 'true');
  }

  /// Retrieves the registered user data.
  /// Returns null if no user is registered.
  Future<FakeRegisterModel?> getUser({bool forceRefresh = false}) async {
    if (forceRefresh || _cachedUser == null) {
      await _loadUser();
    }
    return _cachedUser;
  }

  /// Removes the registered user data.
  Future<void> deleteUser() async {
    _cachedUser = null;
    _isRegistered = false;

    await _secureStorage.delete(key: 'user_data');
    await _secureStorage.write(key: 'is_registered', value: 'false');
  }

  /// Updates the user's name.
  Future<void> updateUserName(String name) async {
    final user = await getUser();
    if (user != null) {
      final updatedUser = FakeRegisterModel(
        id: user.id,
        email: user.email,
        cpf: user.cpf,
        nome: name,
        telefone: user.telefone,
        dataNascimento: user.dataNascimento,
        metodoAutenticacao: user.metodoAutenticacao,
      );
      await setUser(updatedUser);
    }
  }

  /// Updates the user's phone number.
  Future<void> updateUserPhone(String telefone) async {
    final user = await getUser();
    if (user != null) {
      final updatedUser = FakeRegisterModel(
        id: user.id,
        email: user.email,
        cpf: user.cpf,
        nome: user.nome,
        telefone: telefone,
        dataNascimento: user.dataNascimento,
        metodoAutenticacao: user.metodoAutenticacao,
      );
      await setUser(updatedUser);
    }
  }

  /// Updates the user's birthdate.
  Future<void> updateUserBirthdate(DateTime dataNascimento) async {
    final user = await getUser();
    if (user != null) {
      final updatedUser = FakeRegisterModel(
        id: user.id,
        email: user.email,
        cpf: user.cpf,
        nome: user.nome,
        telefone: user.telefone,
        dataNascimento: dataNascimento,
        metodoAutenticacao: user.metodoAutenticacao,
      );
      await setUser(updatedUser);
    }
  }

  Future<void> _init() async {
    final val = await _secureStorage.read(key: 'is_registered');
    _isRegistered = (val == 'true');

    if (_isRegistered == true) {
      await _loadUser();
    }
  }

  Future<void> _loadUser() async {
    final userDataJson = await _secureStorage.read(key: 'user_data');
    if (userDataJson != null) {
      try {
        final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
        _cachedUser = FakeRegisterModel(
          id: userData['id'] as String,
          email: userData['email'] as String,
          cpf: userData['cpf'] as String,
          nome: userData['nome'] as String,
          telefone: userData['telefone'] as String,
          dataNascimento: DateTime.parse(userData['dataNascimento'] as String),
          metodoAutenticacao: InternalAuthMethod.values.firstWhere(
            (e) => e.name == userData['metodoAutenticacao'],
          ),
        );
      } catch (e) {
        // If parsing fails, reset the user
        _cachedUser = null;
        _isRegistered = false;
      }
    }
  }

  Future<void> updateUserAuthMethod(
    InternalAuthMethod metodoAutenticacao,
  ) async {
    final user = await getUser();
    if (user != null) {
      final updatedUser = FakeRegisterModel(
        id: user.id,
        email: user.email,
        cpf: user.cpf,
        nome: user.nome,
        telefone: user.telefone,
        dataNascimento: user.dataNascimento,
        metodoAutenticacao: metodoAutenticacao,
      );
      await setUser(updatedUser);
    }
  }
}

class FakeRegisterModel {
  FakeRegisterModel({
    required this.id,
    required this.email,
    required this.cpf,
    required this.nome,
    required this.telefone,
    required this.dataNascimento,
    required this.metodoAutenticacao,
  });

  final String id;
  final String email;
  final String nome;
  final String cpf;
  final DateTime dataNascimento;
  final String telefone;
  final InternalAuthMethod metodoAutenticacao;
}

enum InternalAuthMethod { google, email }
