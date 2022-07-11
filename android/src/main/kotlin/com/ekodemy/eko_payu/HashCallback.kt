package com.ekodemy.eko_payu

import android.text.TextUtils
import com.payu.ui.model.listeners.PayUHashGenerationListener
import io.flutter.Log
import io.flutter.plugin.common.MethodChannel

class HashCallback(
    var hashName: String,
    var hashData: String,
    var hashGenerationListener: PayUHashGenerationListener
) : MethodChannel.Result {
    private val TAG: String = "EkoPayu"
    public var salt: String = "99FzqrK2";


    override fun success(hash: Any?) {
        Log.i(TAG, "HASH3 Value - $hash")
        var calculatedHash: String? = "";
        if (hash == null) {
            calculatedHash =
                HashGenerationUtils.generateHashFromSDK(
                    hashData!!,
                    salt
                )
        } else if (!TextUtils.isEmpty(hash?.toString())) {
            calculatedHash = hash?.toString();
        } else {
            calculatedHash = "Error";
        }
        val hashMap: HashMap<String, String?> = HashMap()
        hashMap[hashName] = calculatedHash
        hashGenerationListener.onHashGenerated(hashMap)

    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(TAG,"Hash Calculation Error.. errorCode [$errorCode] [$errorMessage]")
    }

    override fun notImplemented() {
        TODO("Not yet implemented")
    }
}