import 'package:local_auth/local_auth.dart';

import '../domain/authenticator.dart';

class LocalAuthenticator implements Authenticator {
  LocalAuthenticator([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on LocalAuthException {
      return false;
    }
  }
}
