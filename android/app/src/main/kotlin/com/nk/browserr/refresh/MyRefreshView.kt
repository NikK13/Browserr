package com.nk.browserr.refresh

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import com.nk.browserr.web.MyWebView
import android.view.*
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout

class MyRefreshView internal constructor(private var context: Context, messenger: BinaryMessenger) : PlatformView, MethodCallHandler, SwipeRefreshLayout.OnRefreshListener{
    private val swipeRefreshLayout: SwipeRefreshLayout = SwipeRefreshLayout(context)
    private val methodChannel: MethodChannel = MethodChannel(messenger, "my_refresh")

    override fun getView(): View {
        return swipeRefreshLayout
    }

    init {
        methodChannel.setMethodCallHandler(this)
        swipeRefreshLayout.setOnRefreshListener(this)
    }

    override fun onRefresh() {
        methodChannel.invokeMethod("onRefresh", null)
    }

    override fun onMethodCall(methodCall: MethodCall, result: Result) {
        when (methodCall.method) {
            "isRefreshing" -> isRefreshing(methodCall)
            "childView" -> childView(methodCall)
            else -> result.notImplemented()
        }
    }

    private fun isRefreshing(methodCall: MethodCall) {
        val isRefresh = methodCall.arguments as Boolean
        swipeRefreshLayout.isRefreshing = isRefresh
    }

    private fun childView(methodCall: MethodCall){
        val child = methodCall.arguments as View
        swipeRefreshLayout.addView(child)
    }

    override fun dispose() {
        // TODO dispose actions if needed
    }
}