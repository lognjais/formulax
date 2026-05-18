class AppConfig {
  AppConfig._();

  static const String dataRepoOwner = String.fromEnvironment(
    'DATA_REPO_OWNER',
    defaultValue: 'jvoltci',
  );
  static const String dataRepoName = String.fromEnvironment(
    'DATA_REPO_NAME',
    defaultValue: 'formulax',
  );
}
