class AppConfig {
  const AppConfig._();

  static const openFdaBaseUrl = String.fromEnvironment(
    'OPEN_FDA_BASE_URL',
    defaultValue: 'https://api.fda.gov/drug/label.json',
  );

  static const pageSize = 20;
  static const searchMinLength = 2;
  static const searchDebounce = Duration(milliseconds: 350);
}
