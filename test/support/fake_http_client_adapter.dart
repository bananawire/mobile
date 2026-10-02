import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

typedef RequestHandler = Future<ResponseBody> Function(RequestOptions options);

class FakeHttpClientAdapter implements HttpClientAdapter {
  final RequestHandler handler;

  FakeHttpClientAdapter(this.handler);

  static ResponseBody jsonResponse(
    dynamic data, {
    int statusCode = 200,
    Map<String, List<String>>? headers,
  }) {
    final jsonString = jsonEncode(data);
    final responseHeaders = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...?headers,
    };
    return ResponseBody.fromString(
      jsonString,
      statusCode,
      headers: responseHeaders,
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
