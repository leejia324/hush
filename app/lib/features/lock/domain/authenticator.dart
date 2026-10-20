abstract interface class Authenticator {
  Future<bool> authenticate(String reason);
}
