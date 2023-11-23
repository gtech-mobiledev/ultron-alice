// ignore_for_file: null_closures

import 'dart:async';

import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice/ui/page/alice_calls_list_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AliceCore {
  /// Rx subject which contains all intercepted http calls
  final BehaviorSubject<List<AliceHttpCall>> callsSubject =
      BehaviorSubject.seeded([]);

  GlobalKey<NavigatorState> _navigatorKey;
  Brightness _brightness = Brightness.light;
  bool _isInspectorOpened = false;
  StreamSubscription<dynamic>? _callsSubscription;

  /// Creates alice core instance
  AliceCore(
    this._navigatorKey,
  ) {
    _brightness = Brightness.light;
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    _callsSubscription?.cancel();
  }

  /// Get currently used brightness
  Brightness get brightness => _brightness;

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void navigateToCallListScreen() {
    final context = getContext();
    if (context == null) {
      if (kDebugMode) {
        print(
          '''
Cant start Alice HTTP Inspector. 
Please add NavigatorKey to your application''',
        );
      }
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (context) => AliceCallsListScreen(this),
        ),
      ).then((onValue) => _isInspectorOpened = false);
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() => _navigatorKey.currentState?.overlay?.context;

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) {
    callsSubject.add([...callsSubject.value, call]);
  }

  /// Add error to exisng alice http call
  void addError(AliceHttpError error, int requestId) {
    final selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      if (kDebugMode) {
        print('Selected call is null');
      }
      return;
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing alice http call
  void addResponse(AliceHttpResponse? response, int? requestId) {
    assert(response != null, "response can't be null");
    assert(requestId != null, "requestId can't be null");
    if (response == null || requestId == null) {
      return;
    }

    try {
      final selectedCall = _selectCall(requestId);

      if (selectedCall == null) {
        if (kDebugMode) {
          print('Selected call is null');
        }
        return;
      }
      selectedCall
        ..loading = false
        ..response = response;
      if (selectedCall.request?.time.millisecondsSinceEpoch != null) {
        selectedCall.duration = response.time.millisecondsSinceEpoch -
            selectedCall.request!.time.millisecondsSinceEpoch;
      }

      callsSubject.add([...callsSubject.value]);
    } catch (e) {
      //ingore
    }
  }

  /// Remove all calls from calls subject
  void removeCalls() {
    callsSubject.add([]);
  }

  AliceHttpCall? _selectCall(int requestId) {
    return callsSubject.value
        .firstWhere((call) => call.id == requestId, orElse: null);
  }
}
