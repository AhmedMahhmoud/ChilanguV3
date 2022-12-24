abstract class AbstractMember {
  Future<Object> getMemberData(
      String username, String password, String token, int osType);
}
