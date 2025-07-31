import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  @singleton
  GoogleSignIn get googleSignIn => GoogleSignIn.instance;
}
