//
//  PaymentData.swift
//  eko_payu
//
//  Created by Shubham Kumar on 21/02/21.
//

import Foundation
public class PaymentData{
    var merchantName: String = "Eko"
    var merchantKey: String? = nil
    var merchantID: String? = nil
    var merchantLogo: String = "logo"
    var isProduction: Bool? = false
    var amount: String? = nil;
    var txnId: String? = nil;
    var userCredential: String? = nil;
    var phoneNumber: String? = nil;
    var productName: String? = nil;
    var firstName: String? = nil;
    var emailId: String? =  nil;
    var sUrl: String = "https://payuresponse.firebaseapp.com/success";
    var fUrl: String = "https://payuresponse.firebaseapp.com/failure";
    var udf1: String = "";
    var udf2: String = "";
    var udf3: String = "";
    var udf4: String = "";
    var udf5: String = "";
    var udf6: String = "";
    var udf7: String = "";
    var udf8: String = "";
    var udf9: String = "";
    var udf10: String = "";
    var hash: String? = nil;
    var paymentSdkHash: String? = nil;
    var vasSdkHash: String? = nil;
}
