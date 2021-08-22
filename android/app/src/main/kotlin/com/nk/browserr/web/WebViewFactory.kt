package com.nk.browserr.web

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class WebViewFactory(private val messenger: BinaryMessenger, private val activity: Activity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private var flutterWebView: MyWebView? = null

    override fun create(context: Context, id: Int, o: Any?): PlatformView {
        flutterWebView = MyWebView(context, messenger, id, activity)
        return flutterWebView!!
    }
    fun getFlutterWebView(): MyWebView? {
        return flutterWebView
    }

}