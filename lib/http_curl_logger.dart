library http_curl_logger;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

///
class HttpCurlLoggerInterceptor implements InterceptorContract {
  final _logger = Logger();
  @override
  Future<bool> shouldInterceptRequest() {
    return Future.value(kDebugMode);
  }

  @override
  Future<bool> shouldInterceptResponse() {
    return Future.value(false);
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final newRequest = request.copyWith();
    final method = request.method;
    final url = request.url.toString();
    final headers = request.headers;

    // Read the request body, if it exists
    final bodyBytes = await newRequest.finalize().toBytes();
    final body = utf8.decode(bodyBytes);
    _logger
        .i('Curl command: ${_generateCurlCommand(method, url, headers, body)}');
    return request;
  }

  String _generateCurlCommand(
      String method, String url, Map<String, String> headers, String body) {
    String curlCommand = 'curl -X $method $url';
    headers.forEach((key, value) {
      curlCommand += ' -H "$key: $value"';
    });
    if (body.isNotEmpty) {
      curlCommand += ' --data \'$body\'';
    }

    return curlCommand;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    return Future.value(response);
  }
}
