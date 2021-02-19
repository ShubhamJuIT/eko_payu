package com.ekodemy.eko_payu

class PaymentData {
    var merchantName: String = "Eko";
    var merchantKey: String? = null
    var merchantID: String? = null
    var isProduction: Boolean? = false
    var amount: String? = null;
    var txnId: String? = null;
    var userCredential: String? = null;
    var phoneNumber: String? = null;
    var productName: String? =  null;
    var firstName: String? = null;
    var emailId: String? =  null;
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
    var hash: String? = null;
}