package com.ekodemy.eko_payu

//import com.payu.sampleapp.databinding.ActivityMainBinding
//import kotlinx.android.synthetic.main.activity_main.*
//import kotlinx.android.synthetic.main.layout_si_details.*

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.text.TextUtils
import android.webkit.WebView
import androidx.annotation.NonNull
import androidx.databinding.DataBindingUtil
import com.ekodemy.eko_payu.databinding.ActivityMainBinding
import com.google.android.material.snackbar.Snackbar
import com.payu.base.models.*
import com.payu.checkoutpro.PayUCheckoutPro
import com.payu.checkoutpro.models.PayUCheckoutProConfig
import com.payu.checkoutpro.utils.PayUCheckoutProConstants
import com.payu.ui.model.listeners.PayUCheckoutProListener
import com.payu.ui.model.listeners.PayUHashGenerationListener
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
//import kotlinx.android.synthetic.main.activity_main.*
//import kotlinx.android.synthetic.main.layout_si_details.*


/** EkoPayuPlugin */
class EkoPayuPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private lateinit var context: Context;
    private val TAG: String = "EkoPayu"
    private var paymentData: PaymentData? = null;
    private var salt: String = "99FzqrK2";
    private var reviewOrderAdapter: ReviewOrderRecyclerViewAdapter? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "eko_payu")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.i(TAG,"EkoPayu Method called ["+call.method+"]")
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "startPayment") {
            this.startPayment(call, result);
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = binding.applicationContext
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.e(TAG, "request code $requestCode resultcode $resultCode")
//        if (requestCode == PayUmoneyFlowManager.REQUEST_CODE_PAYMENT && resultCode == RESULT_OK && data != null) {
//            val transactionResponse: TransactionResponse = data.getParcelableExtra(PayUmoneyFlowManager.INTENT_EXTRA_TRANSACTION_RESPONSE)
//            if (transactionResponse != null && transactionResponse.getPayuResponse() != null) {
//                if (transactionResponse.getTransactionStatus().equals(TransactionResponse.TransactionStatus.SUCCESSFUL)) {
//                    val response = HashMap<String, Any>()
//                    response["status"] = "success"
//                    response["message"] = transactionResponse.getMessage()
//                    mainResult.success(response)
//                } else {
//                    val response = HashMap<String, Any>()
//                    response["message"] = transactionResponse.getMessage()
//                    response["status"] = "failed"
//                    mainResult.success(response)
//                }
//            }
//        }
        return false;
    }

    fun setupDetails(@NonNull call: MethodCall, @NonNull result: Result) {

//        payUmoneyConfig.setPayUmoneyActivityTitle(call.argument("activityTitle") as String)
//        payUmoneyConfig.disableExitConfirmation(call.argument("disableExitConfirmation") as Boolean)


    }

    private fun startPayment(call: MethodCall, @NonNull result: Result) {
        this.paymentData = PaymentData();
        this.paymentData!!.merchantKey = call.argument("merchantKey");
        this.paymentData!!.merchantID = call.argument("merchantID");
        this.paymentData!!.isProduction = call.argument("isProduction");
        this.paymentData!!.amount = call.argument("amount");
        this.paymentData!!.emailId = call.argument("emailId");
        this.paymentData!!.fUrl = call.argument("fUrl")!!;
        this.paymentData!!.firstName = call.argument("firstName")
        this.paymentData!!.phoneNumber = call.argument("phoneNumber");
        this.paymentData!!.productName = call.argument("productName");
        this.paymentData!!.sUrl = call.argument("sUrl")!!;
        this.paymentData!!.txnId = call.argument("txnId");
        this.paymentData!!.userCredential = call.argument("userCredential");
        this.paymentData!!.hash = call.argument("hash");
        val payUPaymentParams = preparePayUBizParams();
        this.initUiSdk(payUPaymentParams);
    }

    fun preparePayUBizParams(): PayUPaymentParams {
        val vasForMobileSdkHash = HashGenerationUtils.generateHashFromSDK(
                "${this.paymentData!!.merchantKey}|${PayUCheckoutProConstants.CP_VAS_FOR_MOBILE_SDK}|${PayUCheckoutProConstants.CP_DEFAULT}|",
                salt
        )
        val paymenRelatedDetailsHash = HashGenerationUtils.generateHashFromSDK(
                "${this.paymentData!!.merchantKey}|${PayUCheckoutProConstants.CP_PAYMENT_RELATED_DETAILS_FOR_MOBILE_SDK}|${this.paymentData!!.userCredential}|",
                salt
        )

        val additionalParamsMap: HashMap<String, Any?> = HashMap()
        additionalParamsMap[PayUCheckoutProConstants.CP_UDF1] = ""
        additionalParamsMap[PayUCheckoutProConstants.CP_UDF2] = ""
        additionalParamsMap[PayUCheckoutProConstants.CP_UDF3] = ""
        additionalParamsMap[PayUCheckoutProConstants.CP_UDF4] = ""
        additionalParamsMap[PayUCheckoutProConstants.CP_UDF5] = ""
        additionalParamsMap[PayUCheckoutProConstants.CP_VAS_FOR_MOBILE_SDK] = vasForMobileSdkHash
        additionalParamsMap[PayUCheckoutProConstants.CP_PAYMENT_RELATED_DETAILS_FOR_MOBILE_SDK] =
                paymenRelatedDetailsHash

        var siDetails: PayUSIParams? = null
//        if(switch_si_on_off.isChecked) {
//            siDetails  = PayUSIParams.Builder()
//                    .setFreeTrial(sp_free_trial.isChecked)
//                    .setSIDetails(PayUSIParamsDetails.Builder()
//                            .setBillingAmount(et_billingAmount_value.text.toString())
//                            .setBillingCycle(PayUBillingCycle.valueOf(et_billingCycle_value.selectedItem.toString()))
//                            .setBillingInterval(et_billingInterval_value.text.toString().toInt())
//                            .setPaymentStartDate(et_paymentStartDate_value.text.toString())
//                            .setPaymentEndDate(et_paymentEndDate_value.text.toString())
//                            .setRemarks(et_remarks_value.text.toString())
//                            .build()
//                    ).build()
//        }

        return PayUPaymentParams.Builder().setAmount(this.paymentData!!.amount)
                .setIsProduction(this.paymentData!!.isProduction!!)
                .setKey(this.paymentData!!.merchantKey)
                .setProductInfo(this.paymentData!!.productName)
                .setPhone(this.paymentData!!.phoneNumber)
                .setTransactionId(this.paymentData!!.txnId)
                .setFirstName(this.paymentData!!.firstName)
                .setEmail(this.paymentData!!.emailId)
                .setSurl(this.paymentData!!.sUrl)
                .setFurl(this.paymentData!!.fUrl)
                .setUserCredential(this.paymentData!!.userCredential)
                .setAdditionalParams(additionalParamsMap)
                .setPayUSIParams(siDetails)
                .build()
    }

    private fun initUiSdk(payUPaymentParams: PayUPaymentParams) {
        PayUCheckoutPro.open(
                this.activity!!,
                payUPaymentParams,
                getCheckoutProConfig(PayUCheckoutProConfig()),
                object : PayUCheckoutProListener {

                    override fun onPaymentSuccess(response: Any) {                        
                        Log.i(TAG,"Payment Success")
                        channel.invokeMethod("success",response)
                        processResponse(response)
                    }

                    override fun onPaymentFailure(response: Any) {                        
                        Log.i(TAG,"Payment Failure")
                        channel.invokeMethod("failure",response)
                        processResponse(response)
                    }

                    override fun onPaymentCancel(isTxnInitiated: Boolean) {
                        Log.i(TAG,"Payment Cancelled")
                        channel.invokeMethod("cancel",null)
                        showSnackBar("Transaction cancelled by user")                    
                    }

                    override fun onError(errorResponse: ErrorResponse) {
                        Log.i(TAG,"Payment Error")
                        channel.invokeMethod("error",errorResponse)
                        val errorMessage: String
                        if (errorResponse != null && errorResponse.errorMessage != null && errorResponse.errorMessage!!.isNotEmpty())
                            errorMessage = errorResponse.errorMessage!!
                        else
                            errorMessage = "Some error occurred...";
                        showSnackBar(errorMessage)
                        
                    }

                    override fun generateHash(
                            map: HashMap<String, String?>,
                            hashGenerationListener: PayUHashGenerationListener
                    ) {
                        if (map.containsKey(PayUCheckoutProConstants.CP_HASH_STRING)
                                && map.containsKey(PayUCheckoutProConstants.CP_HASH_STRING) != null
                                && map.containsKey(PayUCheckoutProConstants.CP_HASH_NAME)
                                && map.containsKey(PayUCheckoutProConstants.CP_HASH_NAME) != null
                        ) {

                            val hashData = map[PayUCheckoutProConstants.CP_HASH_STRING]
                            val hashName = map[PayUCheckoutProConstants.CP_HASH_NAME]

                            val hash: String? =
                                    HashGenerationUtils.generateHashFromSDK(
                                            hashData!!,
                                            salt
                                    )
                            if (!TextUtils.isEmpty(hash)) {
                                val hashMap: HashMap<String, String?> = HashMap()
                                hashMap[hashName!!] = hash!!
                                hashGenerationListener.onHashGenerated(hashMap)
                            }
                        }
                    }

                    override fun setWebViewProperties(webView: WebView?, bank: Any?) {
                    }
                })
    }

    private fun getCheckoutProConfig(payuConfig: PayUCheckoutProConfig): PayUCheckoutProConfig {
        val checkoutProConfig = PayUCheckoutProConfig()
        checkoutProConfig.paymentModesOrder = getCheckoutOrderList()
        checkoutProConfig.showCbToolbar = payuConfig.showCbToolbar
        checkoutProConfig.autoSelectOtp = payuConfig.autoSelectOtp;
        checkoutProConfig.autoApprove = payuConfig.autoApprove
        checkoutProConfig.surePayCount = payuConfig.surePayCount;
        checkoutProConfig.cartDetails = reviewOrderAdapter?.getOrderDetailsList()
        checkoutProConfig.showExitConfirmationOnPaymentScreen = payuConfig.showExitConfirmationOnPaymentScreen;
        checkoutProConfig.showExitConfirmationOnCheckoutScreen = payuConfig.showExitConfirmationOnCheckoutScreen;
        checkoutProConfig.merchantName = this.paymentData!!.merchantName;
        checkoutProConfig.merchantLogo = R.drawable.merchant_logo
        return checkoutProConfig
    }

    private fun getCheckoutOrderList(): ArrayList<PaymentMode> {
        val checkoutOrderList = ArrayList<PaymentMode>()
        if (true) checkoutOrderList.add(
                PaymentMode(
                        PaymentType.UPI,
                        PayUCheckoutProConstants.CP_GOOGLE_PAY
                )
        )
        if (true) checkoutOrderList.add(
                PaymentMode(
                        PaymentType.WALLET,
                        PayUCheckoutProConstants.CP_PHONEPE
                )
        )
        if (true) checkoutOrderList.add(
                PaymentMode(
                        PaymentType.WALLET,
                        PayUCheckoutProConstants.CP_PAYTM
                )
        )
        Log.i(TAG,"checkoutOrdeList "+checkoutOrderList);
        return checkoutOrderList
    }

    private fun processResponse(response: Any) {
        response as HashMap<*, *>
        android.util.Log.d(
                BaseApiLayerConstants.SDK_TAG,
                "payuResponse ; > " + response[PayUCheckoutProConstants.CP_PAYU_RESPONSE]
                        + ", merchantResponse : > " + response[PayUCheckoutProConstants.CP_MERCHANT_RESPONSE]
        )

//        AlertDialog.Builder(context, R.style.Theme_AppCompat_Light_Dialog_Alert)
//                .setCancelable(false)
//                .setMessage(
//                        "Payu's Data : " + response.get(PayUCheckoutProConstants.CP_PAYU_RESPONSE) + "\n\n\n Merchant's Data: " + response.get(
//                                PayUCheckoutProConstants.CP_MERCHANT_RESPONSE
//                        )
//                )
//                .setPositiveButton(
//                        android.R.string.ok
//                ) { dialog, cancelButton -> dialog.dismiss() }.show()
    }

    private fun showSnackBar(message: String) {
//        Snackbar.make(binding.clMain, message, Snackbar.LENGTH_LONG).show()
    }


    override fun registrarFor(pluginKey: String?): PluginRegistry.Registrar {
        TODO("Not yet implemented")
    }

    override fun hasPlugin(pluginKey: String?): Boolean {
        TODO("Not yet implemented")
    }

    override fun <T : Any?> valuePublishedByPlugin(pluginKey: String?): T {
        TODO("Not yet implemented")
    }
}
