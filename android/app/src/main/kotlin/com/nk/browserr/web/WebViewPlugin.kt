package com.nk.browserr.web

import android.app.Activity
import android.content.Intent
import android.view.ContextMenu
import android.view.View
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

class WebViewPlugin(private val activity: Activity) : FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener{
    private var factory: WebViewFactory? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = binding.binaryMessenger
        factory = WebViewFactory(messenger, activity)
        binding.platformViewRegistry.registerViewFactory("webview", factory)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (factory != null && factory!!.getFlutterWebView() != null){
            return factory!!.getFlutterWebView()!!.activityResult(requestCode, resultCode, data)
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        //factory!!.getFlutterWebView()!!.view.setOnCreateContextMenuListener(this)
        //binding.activity.registerForContextMenu(factory!!.getFlutterWebView()!!.view)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { }

    override fun onDetachedFromActivity() {}
}