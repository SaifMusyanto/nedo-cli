import 'package:moncube_mobile/core/config/constants/endpoint_constant.dart';

class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, String> headers;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 120),
    this.receiveTimeout = const Duration(seconds: 120),
    this.headers = const <String, String>{'Content-Type': 'application/json'},
  });

  factory ApiConfig.defaultConfig() {
    return const ApiConfig(
      baseUrl: EndpointConstant.baseUrl,
      connectTimeout: Duration(seconds: 120),
      receiveTimeout: Duration(seconds: 120),
      headers: <String, String>{'Content-Type': 'application/json'},
    );
  }
}
