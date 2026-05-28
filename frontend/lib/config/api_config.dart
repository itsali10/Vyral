import 'api_config_io.dart' if (dart.library.html) 'api_config_web.dart';

/// Backend base URL. Android emulator uses 10.0.2.2 to reach host machine.
abstract final class ApiConfig {
  static String get baseUrl => resolveApiBaseUrl();
}
