import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:eko_payu/payu_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class EkoPayu {
  static const MethodChannel _channel = const MethodChannel('eko_payu');
  final Void Function(dynamic) onSuccess;
  final Void Function(dynamic) onError;
  final Void Function(dynamic) onCancel;
  final Void Function(dynamic) onFailure;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  EkoPayu({this.onSuccess, this.onError, this.onCancel, this.onFailure}) {
    _channel.setMethodCallHandler(nativeMethodCallHandler);
  }

  Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async {
    print('Native call!');
    switch (methodCall.method) {
      case "success":
        if (this.onSuccess != null) {
          this.onSuccess(methodCall.arguments);
        }
        break;
      case "error":
        if (this.onError != null) {
          this.onError(methodCall.arguments);
        }
        break;
      case "cancel":
        if (this.onCancel != null) {
          this.onCancel(methodCall.arguments);
        }
        break;
      case "failure":
        if (this.onFailure != null) {
          this.onFailure(methodCall.arguments);
        }
        break;
      default:
        return "Nothing";
        break;
    }
  }

  Future<dynamic> payuConfig(PayuConfig config) async {
    var response = await _channel.invokeMethod("payuConfig", config.toMap);
    return response;
  }

  Future<dynamic> startPayment(
      {@required String merchantName,
      @required String merchantKey,
      @required String merchantID,
      @required bool isProduction,
      @required String amount,
      @required String txnId,
      @required String userCredential,
      @required String phoneNumber,
      @required String productName,
      @required String firstName,
      @required String emailId,
      @required String sUrl,
      @required String fUrl,
      @required String hash}) async {
    print("Starting Called ");
    var response = await _channel.invokeMethod("startPayment", {
      "merchantName": merchantName,
      "merchantKey": merchantKey,
      "merchantID": merchantID,
      "isProduction": isProduction,
      "amount": amount,
      "txnId": txnId,
      "userCredential": userCredential,
      "phoneNumber": phoneNumber,
      "productName": productName,
      "firstName": firstName,
      "emailId": emailId,
      "sUrl": sUrl,
      "fUrl": fUrl,
      "hash": hash
    });
    log("Start Payment Done");
  }
}
