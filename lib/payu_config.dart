import 'dart:convert';

class PayuConfig {
  bool showCbToolbar = true;
  bool merchantSmsPermission = true;
  bool autoSelectOtp = false;
  bool autoApprove = false;
  int surePayCount = 0;
  bool showExitConfirmationOnPaymentScreen = true;
  int merchantResponseTimeout = 10000;
  bool showExitConfirmationOnCheckoutScreen = true;
  String merchantName = "Eko";
  PayuConfig({
    this.showCbToolbar,
    this.merchantSmsPermission,
    this.autoSelectOtp,
    this.autoApprove,
    this.surePayCount,
    this.showExitConfirmationOnPaymentScreen,
    this.merchantResponseTimeout,
    this.showExitConfirmationOnCheckoutScreen,
    this.merchantName,
  });

  Map<String, dynamic> toMap() {
    return {
      'showCbToolbar': showCbToolbar,
      'merchantSmsPermission': merchantSmsPermission,
      'autoSelectOtp': autoSelectOtp,
      'autoApprove': autoApprove,
      'surePayCount': surePayCount,
      'showExitConfirmationOnPaymentScreen':
          showExitConfirmationOnPaymentScreen,
      'merchantResponseTimeout': merchantResponseTimeout,
      'showExitConfirmationOnCheckoutScreen':
          showExitConfirmationOnCheckoutScreen,
      'merchantName': merchantName,
    };
  }

  factory PayuConfig.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return PayuConfig(
      showCbToolbar: map['showCbToolbar'],
      merchantSmsPermission: map['merchantSmsPermission'],
      autoSelectOtp: map['autoSelectOtp'],
      autoApprove: map['autoApprove'],
      surePayCount: map['surePayCount'],
      showExitConfirmationOnPaymentScreen:
          map['showExitConfirmationOnPaymentScreen'],
      merchantResponseTimeout: map['merchantResponseTimeout'],
      showExitConfirmationOnCheckoutScreen:
          map['showExitConfirmationOnCheckoutScreen'],
      merchantName: map['merchantName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PayuConfig.fromJson(String source) =>
      PayuConfig.fromMap(json.decode(source));
}
