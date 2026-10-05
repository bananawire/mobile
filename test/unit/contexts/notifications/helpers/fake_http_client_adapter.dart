import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A transport double for [Dio] that records every [RequestOptions] handed to
/// it and replies with a canned payload, so no socket is ever opened.
///
/// It mirrors the pattern already used by the other contexts without importing
/// across context folders.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.respond);

  /// Builds a JSON response body.
  static ResponseBody jsonBody(Object? body, {int statusCode = 200}) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  /// Builds a response body carrying no payload at all.
  static ResponseBody emptyBody(int statusCode) {
    return ResponseBody.fromString(
      '',
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  /// Builds a response body with a raw string payload, for malformed payloads.
  static ResponseBody rawBody(String body, {int statusCode = 200}) {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  final ResponseBody Function(RequestOptions options, int index) respond;

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
    return respond(options, requests.length - 1);
  }

  @override
  void close({bool force = false}) {
    closed = true;
  }
}