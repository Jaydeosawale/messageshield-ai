enum AppEnvironment {
  staging,
  production,
}

class AppEnvironmentConfig {
  static const String _environment =
      String.fromEnvironment('APP_ENV', defaultValue: 'production');

  static AppEnvironment get current {
    switch (_environment) {
      case 'staging':
        return AppEnvironment.staging;
      case 'production':
      default:
        return AppEnvironment.production;
    }
  }

  static bool get isStaging => current == AppEnvironment.staging;
  static bool get isProduction => current == AppEnvironment.production;
}
