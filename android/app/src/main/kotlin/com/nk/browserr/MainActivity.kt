package com.nk.browserr

import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.widget.Toast
import android.os.Bundle
import com.nk.browserr.refresh.RefreshViewPlugin
import com.nk.browserr.web.WebViewPlugin

class MainActivity: FlutterActivity(){
    companion object {
        const val CHANNEL = "flutter.toast"
        const val METHOD_TOAST = "toast"
        const val KEY_MESSAGE = "message"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(flutterEngine!!)
        flutterEngine!!.plugins.add(WebViewPlugin(activity))
        flutterEngine!!.plugins.add(RefreshViewPlugin())
        MethodChannel(flutterEngine!!.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_TOAST -> {
                    val message = call.argument<String>(KEY_MESSAGE)
                    Toast.makeText(this@MainActivity, message, Toast.LENGTH_SHORT).show()
                }
                else -> result.notImplemented()
            }
        }
    }
}
