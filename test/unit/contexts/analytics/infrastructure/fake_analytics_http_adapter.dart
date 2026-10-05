import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A transport double for [Dio] that records every [RequestOptions] it is
/// asked to send and replies with a canned payload, so no socket is opened.
///
/// This helper is intentionally NOT named `*_test.dart` so that the test
/// runner never executes it as a suite.
class FakeAnalyticsHttpAdapter implements HttpClientAdapter {
  FakeAnalyticsHttpAdapter(this.respond);

  /// Builds a JSON response body.
  static ResponseBody jsonBody(Object body, {int statusCode = 200}) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  /// Builds a response body with no payload at all.
  static ResponseBody emptyBody(int statusCode) {
    return ResponseBody.fromString(
      '',
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  /// Builds a response body whose bytes are not decodable JSON.
  static ResponseBody malformedBody({int statusCode = 200}) {
    return ResponseBody.fromString(
      'not-json',
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  /// The responder, which may also throw to simulate transport failures.
  final ResponseBody Function(RequestOptions options) respond;

  /// Every request that reached the transport, in order.
  final List<RequestOptions> requests = <RequestOptions>[];

  bool closed = false;

  /// The single request that reached the transport.
  RequestOptions get singleRequest => requests.single;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {
    closed = true;
  }
}