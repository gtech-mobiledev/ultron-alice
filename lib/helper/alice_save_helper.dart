import 'dart:convert';
import 'package:alice/helper/alice_conversion_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/utils/alice_parser.dart';

mixin AliceSaveHelper {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  static Future<String> _buildAliceLog() async {
    final stringBuffer = StringBuffer()
      ..write('Alice - HTTP Inspector\n')
      ..write('Generated: ${DateTime.now().toIso8601String()}\n')
      ..write('\n');
    return stringBuffer.toString();
  }

  static String _buildCallLog(AliceHttpCall call) {
    final stringBuffer = StringBuffer()
      ..write('===========================================\n')
      ..write('Id: ${call.id}\n')
      ..write('============================================\n')
      ..write('--------------------------------------------\n')
      ..write('General data\n')
      ..write('--------------------------------------------\n')
      ..write('Server: ${call.server} \n')
      ..write('Method: ${call.method} \n')
      ..write('Endpoint: ${call.endpoint} \n')
      ..write('Client: ${call.client} \n')
      ..write('Duration ${AliceConversionHelper.formatTime(call.duration)}\n')
      ..write('Secured connection: ${call.secure}\n')
      ..write('Completed: ${!call.loading} \n')
      ..write('--------------------------------------------\n')
      ..write('Request\n')
      ..write('--------------------------------------------\n')
      ..write('Request time: ${call.request!.time}\n')
      ..write('Request content type: ${call.request!.contentType}\n')
      ..write('Request cookies: ${_encoder.convert(call.request!.cookies)}\n')
      ..write('Request headers: ${_encoder.convert(call.request!.headers)}\n');
    if (call.request!.queryParameters.isNotEmpty) {
      stringBuffer.write(
        'Request query params: '
        '${_encoder.convert(call.request!.queryParameters)}\n',
      );
    }
    stringBuffer
      ..write(
        'Request size: '
        '${AliceConversionHelper.formatBytes(call.request!.size)}\n',
      )
      ..write(
        'Request body: ${AliceParser.formatBody(
          call.request!.body,
          AliceParser.getContentType(call.request!.headers),
        )}\n',
      )
      ..write('--------------------------------------------\n')
      ..write('Response\n')
      ..write('--------------------------------------------\n')
      ..write('Response time: ${call.response!.time}\n')
      ..write('Response status: ${call.response!.status}\n')
      ..write(
        'Response size: '
        '${AliceConversionHelper.formatBytes(call.response!.size)}\n',
      )
      ..write(
        'Response headers: ${_encoder.convert(call.response!.headers)}\n',
      )
      ..write(
        'Response body: ${AliceParser.formatBody(
          call.response!.body,
          AliceParser.getContentType(call.response!.headers),
        )}\n',
      );
    if (call.error != null) {
      stringBuffer
        ..write('--------------------------------------------\n')
        ..write('Error\n')
        ..write('--------------------------------------------\n')
        ..write('Error: ${call.error!.error}\n');
      if (call.error!.stackTrace != null) {
        stringBuffer.write('Error stacktrace: ${call.error!.stackTrace}\n');
      }
    }
    stringBuffer
      ..write('--------------------------------------------\n')
      ..write('Curl\n')
      ..write('--------------------------------------------\n')
      ..write(call.getCurlCommand())
      ..write('\n')
      ..write('==============================================\n')
      ..write('\n');

    return stringBuffer.toString();
  }

  static Future<String> buildCallLog(AliceHttpCall call) async {
    try {
      return await _buildAliceLog() + _buildCallLog(call);
    } catch (exception) {
      return 'Failed to generate call log';
    }
  }
}
