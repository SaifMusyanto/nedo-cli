class EndpointConstant {
  EndpointConstant._();

  static const String baseUrl = ''; // TODO: add base url
  static String getFile(String filePath) => '/file/get-file/$filePath';

  static const String generateCode = '/auth/generate';
  static const String token = '/auth/token';
  static const String userInfo = '/auth/userinfo';
  static const String pageAccess = '/auth/page-access';
  static const String logout = '/auth/logout';
}
