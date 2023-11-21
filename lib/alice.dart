import 'dart:io';

import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_dio_interceptor.dart';
import 'package:alice/core/alice_http_client_adapter.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Alice {
  /// Should inspector use dark theme
  final bool darkTheme;

  GlobalKey<NavigatorState> _navigatorKey;
  AliceCore _aliceCore;
  AliceHttpClientAdapter _httpClientAdapter;

  Alice._(this.darkTheme, this._navigatorKey, this._aliceCore,
      this._httpClientAdapter);

  /// Creates alice instance.
  factory Alice({
    GlobalKey<NavigatorState> navigatorKey =
        const GlobalObjectKey<NavigatorState>('AliceNavigatorState'),
    bool darkTheme = false,
  }) {
    final aliceCore = AliceCore(navigatorKey, darkTheme);
    final httpClientAdapter = AliceHttpClientAdapter(aliceCore);

    return Alice._(
      darkTheme,
      navigatorKey,
      aliceCore,
      httpClientAdapter,
    );
  }

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _aliceCore.setNavigatorKey(navigatorKey);
  }

  /// Get currently used navigation key
  GlobalKey<NavigatorState> getNavigatorKey() {
    return _navigatorKey;
  }

  /// Get Dio interceptor which should be applied to Dio instance.
  AliceDioInterceptor getDioInterceptor() {
    return AliceDioInterceptor(_aliceCore);
  }

  /// Handle request from HttpClient
  void onHttpClientRequest(HttpClientRequest request, {dynamic body}) {
    _httpClientAdapter.onRequest(request, body: body);
  }

  /// Handle response from HttpClient
  void onHttpClientResponse(
      HttpClientResponse response, HttpClientRequest request,
      {dynamic body}) {
    _httpClientAdapter.onResponse(response, request, body: body);
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void showInspector() {
    _aliceCore.navigateToCallListScreen();
  }

  /// Handle generic http call. Can be used to any http client.
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    _aliceCore.addCall(aliceHttpCall);
  }
}
