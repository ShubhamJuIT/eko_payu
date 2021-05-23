import Flutter
import UIKit
import PayUCheckoutProKit
import PayUCheckoutProBaseKit

public class SwiftEkoPayuPlugin: NSObject, FlutterPlugin {
    
    var channel: FlutterMethodChannel;
    var paymentData: PaymentData;
    var pluginRegistrar: FlutterPluginRegistrar;
    var uiViewController: UIViewController;
    var primaryColor: String = "#053ac1"
    var secondaryColor: String = "#ffffff"
    var l1Option: String = "[{\"NetBanking\":\"\"},{\"emi\":\"\"},{\"UPI\":\"TEZ\"},{\"Wallet\":\"PHONEPE\"}]"
    var orderDetail: String = "[{\"GST\":\"18%\"},{\"Delivery Date\":\"25 Dec\"},{\"Status\":\"In Progress\"}]"
    var salt: String = "99FzqrK2";

    init(pluginRegistrar: FlutterPluginRegistrar, uiViewController: UIViewController, channel: FlutterMethodChannel){
        self.pluginRegistrar = pluginRegistrar;
        self.uiViewController = uiViewController;
        self.paymentData = PaymentData();
        self.channel = channel;
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "eko_payu", binaryMessenger: registrar.messenger())
        let viewController: UIViewController =
                    (UIApplication.shared.delegate?.window??.rootViewController)!;
        let instance = SwiftEkoPayuPlugin(pluginRegistrar: registrar, uiViewController: viewController, channel: channel);
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "getPlatformVersion"){
            result("iOS " + UIDevice.current.systemVersion)
        } else if(call.method == "startPayment"){
            print("Start Payment")
            self.startPayment(call: call,result: result)
        }
        
    }
    
    public func startPayment(call: FlutterMethodCall, result: FlutterResult){
        self.paymentData = PaymentData();
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any]
        {
            self.paymentData.merchantName = myArgs["merchantName"] as! String
            self.paymentData.merchantKey = myArgs["merchantKey"] as? String
            self.paymentData.merchantID = myArgs["merchantID"] as? String
            self.paymentData.merchantLogo = myArgs["merchantLogo"] as! String
            self.paymentData.productName = myArgs["productName"] as? String
            self.paymentData.isProduction = myArgs["isProduction"] as? Bool
            self.paymentData.amount = myArgs["amount"] as? String
            self.paymentData.emailId = myArgs["emailId"] as? String
            self.paymentData.fUrl = myArgs["fUrl"] as! String
            self.paymentData.firstName = myArgs["firstName"] as? String
            self.paymentData.phoneNumber = myArgs["phoneNumber"] as? String
            self.paymentData.sUrl = myArgs["sUrl"] as! String
            self.paymentData.txnId = myArgs["txnId"] as? String
            self.paymentData.userCredential = myArgs["userCredential"] as? String
            self.paymentData.hash = myArgs["hash"] as? String
            self.paymentData.paymentSdkHash = myArgs["paymentSdkHash"] as? String
            self.paymentData.vasSdkHash = myArgs["vasSdkHash"] as? String
        }
        let payUConfig = PayUCheckoutProConfig()
        addCheckoutProConfigurations(config: payUConfig)
        let param: PayUPaymentParam = self.getPaymentParam();
        
        PayUCheckoutPro.open(
            on: self.uiViewController,
            paymentParam: getPaymentParam(),
            config: payUConfig,
            delegate: self)
    }
    
    public func getCheckoutProConfig(payuConfig: PayUCheckoutProConfig) -> PayUCheckoutProConfig{
        var checkoutProConfig = PayUCheckoutProConfig();
        checkoutProConfig.paymentModesOrder = getCheckoutOrderList();
        checkoutProConfig.autoSelectOtp = payuConfig.autoSelectOtp;
        checkoutProConfig.surePayCount = payuConfig.surePayCount;
        checkoutProConfig.showExitConfirmationOnPaymentScreen=payuConfig.showExitConfirmationOnPaymentScreen;
        checkoutProConfig.showExitConfirmationOnCheckoutScreen=payuConfig.showExitConfirmationOnCheckoutScreen;
        checkoutProConfig.merchantName=payuConfig.merchantName;
        checkoutProConfig.merchantLogo=payuConfig.merchantLogo;
        return checkoutProConfig;
    }
    
    private func getCheckoutOrderList() -> [PaymentMode] {
        var checkoutOrderList: [PaymentMode] = []
        if (true) {
            checkoutOrderList.append(PaymentMode(paymentType: PaymentType.upi))
        }
        if(true){
            checkoutOrderList.append(PaymentMode(paymentType: PaymentType.wallet))
        }
        if(true){
            checkoutOrderList.append(PaymentMode(paymentType: PaymentType.other))
        }
        
//        checkoutOrderList.add(
//                PaymentMode(
//                    PaymentType.UPI,
//                    PayUCheckoutProConstants.CP_GOOGLE_PAY
//                )
//            )
//            if (true) checkoutOrderList.add(
//                PaymentMode(
//                    PaymentType.WALLET,
//                    PayUCheckoutProConstants.CP_PHONEPE
//                )
//            )
//            if (true) checkoutOrderList.add(
//                PaymentMode(
//                    PaymentType.WALLET,
//                    PayUCheckoutProConstants.CP_PAYTM
//                )
//            )
            Log.i(TAG, "checkoutOrdeList " + checkoutOrderList);
            return checkoutOrderList
        }
    
    public func getEnvironment() -> Environment {
        if (self.paymentData.isProduction!) {
            return  Environment.production
        } else {
            return  Environment.test
        }
    }
    
    public func hexStringToUIColor(hex: String) -> UIColor? {
            var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }
            cString = String(cString.prefix(6))

            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
    
    public func JSONFrom(string: String) -> Any? {
            guard let data = string.data(using: .utf8) else { return nil}
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                return nil
            }
        }
    
    public func getPaymentParam() -> PayUPaymentParam{
        let paymentParam = PayUPaymentParam(key: self.paymentData.merchantKey ?? "",
                                            transactionId: self.paymentData.txnId ?? "",
                                            amount: self.paymentData.amount ?? "",
                                            productInfo: self.paymentData.productName ?? "",
                                            firstName: self.paymentData.firstName ?? "",
                                            email: self.paymentData.emailId ?? "",
                                            phone: self.paymentData.phoneNumber ?? "",
                                            surl: self.paymentData.sUrl,
                                            furl: self.paymentData.fUrl,
                                            environment: getEnvironment())
        paymentParam.userCredential = self.paymentData.userCredential ?? "";
        paymentParam.additionalParam[PaymentParamConstant.udf1] = ""
        paymentParam.additionalParam[PaymentParamConstant.udf2] = ""
        paymentParam.additionalParam[PaymentParamConstant.udf3] = ""
        paymentParam.additionalParam[PaymentParamConstant.udf4] = ""
        paymentParam.additionalParam[PaymentParamConstant.udf5] = ""
        
        //        paymentParam.environment = .test
        paymentParam.additionalParam[HashConstant.paymentRelatedDetailForMobileSDK] = self.paymentData.paymentSdkHash
        paymentParam.additionalParam[HashConstant.vasForMobileSDK] = self.paymentData.vasSdkHash
        paymentParam.additionalParam[HashConstant.payment] = self.paymentData.hash
        return paymentParam
    }
    
    private func addCheckoutProConfigurations(config: PayUCheckoutProConfig) {
        config.merchantName = self.paymentData.merchantName
        config.merchantLogo = UIImage(named: self.paymentData.merchantLogo)
        config.paymentModesOrder = getPreferredPaymentMode()
        config.cartDetails = cartDetails()
        if let primary = hexStringToUIColor(hex: primaryColor ?? ""), let secondary = hexStringToUIColor(hex: secondaryColor) {
            config.customiseUI(primaryColor: primary, secondaryColor: secondary)
        }
        config.showExitConfirmationOnPaymentScreen = true;//showCancelDialogOnPaymentScreenSwitch.isOn
        config.showExitConfirmationOnCheckoutScreen = true;//showCancelDialogOnCheckoutScreenSwitch.isOn
        
        // CB Configurations
        config.autoSelectOtp = true;//autoOTPSelectSwitch.isOn
//        if let surePayCountStr = "2",
//           let surePayCount = UInt("2") {
        config.surePayCount = 2
//        }
//        if let merchantResponseTimeoutStr = merchantResponseTimeoutTextField.text,
//           let merchantResponseTimeout = TimeInterval(merchantResponseTimeoutStr) {
        config.merchantResponseTimeout = 4
//        }
    }
    
    public func getPreferredPaymentMode() -> [PaymentMode]? {
        if let preferredPaymentModesJSON = JSONFrom(string: self.l1Option) as? [[String : String]] {
            var preferredPaymentModes: [PaymentMode] = []
            for eachPreferredPaymentMode in preferredPaymentModesJSON {
                var paymentMode: PaymentMode?
                if eachPreferredPaymentMode.keys.first?.lowercased() == "Cards".lowercased() {
                    paymentMode = PaymentMode(paymentType: .ccdc)
                } else if eachPreferredPaymentMode.keys.first?.lowercased() == "NetBanking".lowercased() {
                    paymentMode = PaymentMode(paymentType: .netBanking, paymentOptionID: eachPreferredPaymentMode.values.first ?? "")
                } else if eachPreferredPaymentMode.keys.first?.lowercased() == "UPI".lowercased() {
                    paymentMode = PaymentMode(paymentType: .upi, paymentOptionID: eachPreferredPaymentMode.values.first ?? "")
                } else if eachPreferredPaymentMode.keys.first?.lowercased() == "Wallet".lowercased() {
                    paymentMode = PaymentMode(paymentType: .wallet, paymentOptionID: eachPreferredPaymentMode.values.first ?? "")
                } else if eachPreferredPaymentMode.keys.first?.lowercased() == "emi".lowercased() {
                    paymentMode = PaymentMode(paymentType: .emi, paymentOptionID: eachPreferredPaymentMode.values.first ?? "")
                }
                if let paymentMode = paymentMode {
                    preferredPaymentModes.append(paymentMode)
                }
            }
            return preferredPaymentModes
        }
        return nil
    }
    
    public func cartDetails() -> [[String: String]]? {
        if let cartDetails = JSONFrom(string: self.orderDetail) as? [[String : String]] {
            return cartDetails
        }
        return nil
    }
}

extension SwiftEkoPayuPlugin: PayUCheckoutProDelegate {
    public func onError(_ error: Error?) {
        // handle error scenario
        self.uiViewController.navigationController?.popToViewController(self.uiViewController, animated: true)
        // showAlert(title: "Error", message: error?.localizedDescription ?? "")
        channel.invokeMethod("error",arguments: error)
    }
    
    public func onPaymentSuccess(response: Any?) {
        // handle success scenario
        self.uiViewController.navigationController?.popToViewController(self.uiViewController, animated: true)
        // showAlert(title: "Success", message: "\(response ?? "")")
        self.channel.invokeMethod("success",arguments: response)
    }
    
    public func onPaymentFailure(response: Any?) {
        // handle failure scenario
        self.uiViewController.navigationController?.popToViewController(self.uiViewController, animated: true)
        // showAlert(title: "Failure", message: "\(response ?? "")")
        channel.invokeMethod("failure",arguments: response)
        
    }
    
    public func onPaymentCancel(isTxnInitiated: Bool) {
        // handle txn cancelled scenario
        // isTxnInitiated == YES, means user cancelled the txn when on reaching bankPage
        // isTxnInitiated == NO, means user cancelled the txn before reaching the bankPage
        self.uiViewController.navigationController?.popToViewController(self.uiViewController, animated: true)
        // let completeResponse = "isTxnInitiated = \(isTxnInitiated)"
        // showAlert(title: "Cancelled", message: "\(completeResponse)")
        channel.invokeMethod("cancel",arguments: nil)
    }
    
    
    public func generateHash(for param: DictOfString, onCompletion: @escaping PayUHashGenerationCompletion) {
        let commandName = (param[HashConstant.hashName] ?? "")
        let hashStringWithoutSalt = (param[HashConstant.hashString] ?? "")
        // get hash for "commandName" from server
        // get hash for "hashStringWithoutSalt" from server
    
        //callback.hashGenerationListener;
//        channel.invokeMethod("hash", arguments: hashStringWithoutSalt, result: callback.hashGenerationListener);
        channel.invokeMethod("hash", arguments: hashStringWithoutSalt, result:{(r:Any?) -> () in
          // this will be called with r = "some string" (or FlutterMethodNotImplemented)
            if let error = r as? FlutterError {
                print("Erro in hash method call.. "+error.message!)
              } else if FlutterMethodNotImplemented.isEqual(r) {
                print("hash Methodn not implementd")
              } else {
                print("Hash Generated")
                var hashValue = ""
                if(r == nil){
                    hashValue = Utils.generateHashFromSDK(paymentParams: hashStringWithoutSalt, salt: self.salt)!
                }else{
                    hashValue = r as! String
                }
                onCompletion([commandName : hashValue])
              }
        });
        
        // After fetching hash set its value in below variable "hashValue"
//        let hashValue = "hashValue"
//        onCompletion([commandName : hashValue])
    }
    
    public func showAlert(title: String, message: String) {
        print("alert "+message)
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.uiViewController.present(alert, animated: true, completion: nil)
    }
}
