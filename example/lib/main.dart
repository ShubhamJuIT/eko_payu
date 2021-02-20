import 'dart:developer';

import 'package:eko_payu/payu_config.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:eko_payu/eko_payu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  EkoPayu ekoPayu;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    this.ekoPayu = new EkoPayu(
        onSuccess: (data) => this.onSuccess(data),
        onCancel: (data) => this.onCancel(data),
        onError: (data) => this.onError(data),
        onFailure: (data) => this.onFailure(data));
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await EkoPayu.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  onSuccess(dynamic data) {
    print("Success");
  }

  onError(dynamic data) {
    print("Error");
  }

  onCancel(dynamic data) {
    print("cancel");
  }

  onFailure(dynamic data) {
    print("Failure");
  }

  Future<void> start() async {
    try {
      print("Starting Payment");
      dynamic res =
          await this.ekoPayu.payuConfig(PayuConfig(merchantName: "Hello"));
      this.ekoPayu.startPayment(
          merchantName: "Eko",
          merchantKey: "fnuDx1",
          merchantID: "130033",
          txnId: "602ed0df6cea174459457337",
          amount: "500.00",
          productName: "bucket-1",
          firstName: "Shubham",
          emailId: "Shubham|shubham.mua@gmail.com",
          isProduction: false,
          phoneNumber: "7838821488",
          sUrl: "https://payuresponse.firebaseapp.com/success",
          fUrl: "https://payuresponse.firebaseapp.com/failure",
          userCredential: "fnuDx1:1",
          hash:
              "112e784011a26de9d5ec73ee997320a63ef659063a0dbe5862405639077b976562c846d316707b6ee640c2cf8706c0e47976bcb029ae2e05bbcd3f11bcae1501");
    } on PlatformException {
      log("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Row(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            FlatButton(
              child: Text('Start'),
              onPressed: () {
                this.start();
              },
            )
          ],
        ),
      ),
    );
  }
}
