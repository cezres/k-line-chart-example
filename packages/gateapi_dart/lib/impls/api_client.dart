// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'package:gateapi_dart/gateapi_dart.dart';

final _kDio = Dio(
  BaseOptions(
    baseUrl: kBaseURL,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ),
);

class ApiClient {
  /// 发送请求
  Future<dynamic> dispatch(
    String path, {
    ApiMethod method = ApiMethod.GET,
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _kDio.get(path, queryParameters: params);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

enum ApiMethod {
  GET,
  POST,
  DELETE,
  PUT,
  PATCH,
}
