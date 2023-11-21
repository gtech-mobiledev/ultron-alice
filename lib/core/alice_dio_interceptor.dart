// ignore_for_file: avoid_renaming_method_parameters

import 'dart:convert';

import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:dio/dio.dart';

class AliceDioInterceptor extends InterceptorsWrapper {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates dio interceptor
  AliceDioInterceptor(this.aliceCore);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final AliceHttpCall call = AliceHttpCall(options.hashCode);

    final Uri uri = options.uri;
    call.method = options.method;
    var path = options.uri.path;
    if (path.isEmpty) {
      path = '/';
    }
    call.endpoint = path;
    call.server = uri.host;
    call.client = 'Dio';
    call.uri = options.uri.toString();

    if (uri.scheme == 'https') {
      call.secure = true;
    }

    final AliceHttpRequest request = AliceHttpRequest();

    final data = options.data;
    if (data == null) {
      request.size = 0;
      request.body = '';
    } else {
      if (data is FormData) {
        request.body += 'Form data';

        if (data.fields.isNotEmpty == true) {
          final List<AliceFormDataField> fields = [];
          for (var entry in data.fields) {
            fields.add(AliceFormDataField(entry.key, entry.value));
          }
          request.formDataFields = fields;
        }
        if (data.files.isNotEmpty == true) {
          final List<AliceFormDataFile> files = [];
          for (var entry in data.files) {
            files.add(AliceFormDataFile(entry.value.filename ?? '',
                entry.value.contentType.toString(), entry.value.length));
          }

          request.formDataFiles = files;
        }
      } else {
        request.size = utf8.encode(data.toString()).length;
        request.body = data;
      }
    }

    request.time = DateTime.now();
    request.headers = options.headers;
    request.contentType = options.contentType.toString();
    request.queryParameters = options.queryParameters;

    call.request = request;
    call.response = AliceHttpResponse();

    aliceCore.addCall(call);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final httpResponse = AliceHttpResponse();
    httpResponse.status = response.statusCode ?? -1;

    if (response.data == null) {
      httpResponse.body = '';
      httpResponse.size = 0;
    } else {
      httpResponse.body = response.data;
      httpResponse.size = utf8.encode(response.data.toString()).length;
    }

    httpResponse.time = DateTime.now();
    final Map<String, String> headers = {};
    response.headers.forEach((header, values) {
      headers[header] = values.toString();
    });

    httpResponse.headers = headers;

    aliceCore.addResponse(httpResponse, response.requestOptions.hashCode);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final httpError = AliceHttpError();
    httpError.error = error.toString();
    if (error is Error) {
      final basicError = error as Error;
      httpError.stackTrace = basicError.stackTrace;
    }

    aliceCore.addError(httpError, error.requestOptions.hashCode);
    final httpResponse = AliceHttpResponse();
    httpResponse.time = DateTime.now();
    if (error.response == null) {
      httpResponse.status = -1;
      aliceCore.addResponse(httpResponse, error.requestOptions.hashCode);
    } else {
      httpResponse.status = error.response?.statusCode ?? -1;

      if (error.response?.data == null) {
        httpResponse.body = '';
        httpResponse.size = 0;
      } else {
        httpResponse.body = error.response?.data;
        httpResponse.size =
            utf8.encode(error.response?.data.toString() ?? '').length;
      }
      final Map<String, String> headers = {};
      error.response?.headers.forEach((header, values) {
        headers[header] = values.toString();
      });
      httpResponse.headers = headers;
      aliceCore.addResponse(
          httpResponse, error.response?.requestOptions.hashCode);
    }
    super.onError(error, handler);
  }
}
