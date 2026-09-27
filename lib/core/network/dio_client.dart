import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.openFdaBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 10),
      headers: const {'Accept': 'application/json'},
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        responseBody: false,
        logPrint: (message) => debugPrint(message.toString()),
      ),
    );
  }

  return dio;
}
