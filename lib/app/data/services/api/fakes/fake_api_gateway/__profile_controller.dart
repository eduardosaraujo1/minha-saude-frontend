part of 'fake_api_gateway.dart';

class _ProfileController {
  _ProfileController({required this.fakeServerDatabase});

  final FakeServerDatabase fakeServerDatabase;

  /// GET /profile - Get user profile data
  ///
  /// Response: `{id: int, nome: String, cpf: String, email: String, telefone: String?, dataNascimento: String (YYYY-MM-DD), metodoAutenticacao: String (email | google)}`
  static const String getUserProfile = '/profile';

  /// PUT /profile/name - Edit user name
  ///
  /// Data: `{nome: String}`
  ///
  /// Response: `{id: int, nome: String}`
  static const String editName = '/profile/name';

  /// PUT /profile/birthdate - Edit user birthdate
  ///
  /// Data: `{dataNascimento: String (YYYY-MM-DD)}`
  ///
  /// Response: `{id: int, dataNascimento: String (YYYY-MM-DD)}`
  static const String editBirthdate = '/profile/birthdate';

  /// PUT /profile/phone - Edit phone number (requires SMS verification)
  ///
  /// Data: `{telefone: String, codigoSms: String}`
  ///
  /// Response: `{id: int, telefone: String}`
  static const String editPhone = '/profile/phone';

  /// POST /profile/phone/verify - Verify SMS code sent to phone
  ///
  /// Data: `{telefone: String, codigo: String}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String verifyPhoneCode = '/profile/phone/verify';

  /// POST /profile/phone/send-sms - Send SMS verification code
  ///
  /// Data: `{telefone: String}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String sendPhoneSms = '/profile/phone/send-sms';

  /// POST /profile/google/link - Link Google account
  ///
  /// Data: `{tokenOauth: String}`
  ///
  /// Response: `{status: String (success | error), message: String?}`
  static const String linkGoogleAccount = '/profile/google/link';

  /// DELETE /profile - Schedule account deletion
  ///
  /// Data: `{authType: String (email | google), auth: {email: String?, codigoEmail: String?, tokenOauth: String?}}`
  ///
  /// Response: `{status: String (success | error)}`
  static const String deleteAccount = '/profile';
}
