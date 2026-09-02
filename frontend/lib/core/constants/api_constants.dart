class ApiConstants {
  static const String environment =
      String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  static final String baseUrl = _getBaseUrl();

  static final String register = '$baseUrl/auth/register';

  static final String login = '$baseUrl/auth/login';

  static final String firebaseLogin =
      '$baseUrl/auth/firebase/login';

  static final String firebaseRegister =
      '$baseUrl/auth/firebase/register';

  static final String checkEmail =
      '$baseUrl/auth/check-email';

  static final String me = '$baseUrl/auth/me';

  static final String analyze =
      '$baseUrl/analyze';

  static final String analyses =
      '$baseUrl/analyses';

  static const String _devBaseUrl =
      'http://127.0.0.1:8000/api/v1';

  static const String _stagingBaseUrl =
      'https://messageshield-staging.onrender.com/api/v1';

  static const String _prodBaseUrl =
      'https://messageshield-ai.onrender.com/api/v1';

  static String _getBaseUrl() {
    switch (environment) {
      case 'dev':
        return _devBaseUrl;

      case 'staging':
        return _stagingBaseUrl;

      case 'prod':
      default:
        return _prodBaseUrl;
    }
  }
}
