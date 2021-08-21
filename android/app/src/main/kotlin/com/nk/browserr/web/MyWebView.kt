package com.nk.browserr.web

import android.annotation.SuppressLint
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import android.webkit.*
import android.webkit.WebView
import android.graphics.Bitmap
import android.net.Uri
import android.os.Handler
import android.os.Message
import android.text.InputType
import android.util.AttributeSet
import android.view.*
import android.view.View.OnTouchListener
import android.view.inputmethod.BaseInputConnection
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import android.webkit.WebViewClient
import androidx.core.content.ContextCompat
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewFeature
import java.lang.Exception
import java.util.concurrent.Executor
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.content.ContextCompat.getSystemService

@SuppressLint("SetJavaScriptEnabled", "ClickableViewAccessibility")
class MyWebView internal constructor(context: Context, messenger: BinaryMessenger, id: Int) : PlatformView, MethodCallHandler{
    private val webView: WebView = WebView(context, null)
    private val methodChannel: MethodChannel

    override fun getView(): View {
        return webView
    }

    init {
        webView.settings.apply {
            builtInZoomControls = true
            useWideViewPort = true
            displayZoomControls = false
            javaScriptEnabled = true
            loadWithOverviewMode = true
            domStorageEnabled = true
        }
        webView.isFocusableInTouchMode = true

        methodChannel = MethodChannel(messenger, "webview$id")
        methodChannel.setMethodCallHandler(this)

        webView.webViewClient = InsideWebViewClient()
        webView.webChromeClient = object : WebChromeClient() {
            override fun onShowFileChooser(webView: WebView?, filePathCallback: ValueCallback<Array<Uri?>?>, fileChooserParams: FileChooserParams?): Boolean {
                /*if (mFilePathCallback != null) {
                    mFilePathCallback.onReceiveValue(null)
                }
                mFilePathCallback = filePathCallback
                showChooserDialog()*/
                return true
            }

            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                methodChannel.invokeMethod("onProgress", newProgress)
            }

            /*override fun onReceiveIcon(view: WebView?, icon: Bitmap?){
                methodChannel.invokeMethod("onReceiveIcon", icon)
            }*/
        }

        /*webView.setOnTouchListener { v, event ->
            if (event.action == KeyEvent.) {
                hideSoftKeyboard(v)
            }
            false
        }*/
    }

    override fun onMethodCall(methodCall: MethodCall, result: Result) {
        when (methodCall.method) {
            "loadUrl" -> loadUrl(methodCall, result)
            "reloadPage" -> webView.reload()
            "canGoBack" -> canGoBack(result)
            "goBack" -> goBack()
            "hideKeyboard" -> hideKeyboard()
            "getTitle" -> getTitle(result)
            "canGoForward" -> canGoForward()
            "isDesktopMode" -> isDesktopMode(methodCall)
            "forceDarkEnabled" -> forceDarkEnabled(methodCall)
            else -> result.notImplemented()
        }
    }

    private fun canGoBack(result: Result){
        result.success(webView.canGoBack())
    }

    private fun getTitle(result: Result){
        result.success(webView.title)
    }

    private fun goBack(){
        if(webView.canGoBack()){
            webView.goBack()
        }
    }

    private fun loadUrl(methodCall: MethodCall, result: Result) {
        val url = methodCall.arguments as String
        webView.loadUrl(url)
        result.success(null)
    }

    private fun forceDarkEnabled(methodCall: MethodCall) {
        val isEnabled = methodCall.arguments as Boolean
        if(WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK)) {
            if (isEnabled) WebSettingsCompat.setForceDark(webView.settings, WebSettingsCompat.FORCE_DARK_ON)
            else WebSettingsCompat.setForceDark(webView.settings, WebSettingsCompat.FORCE_DARK_OFF)
            webView.reload()
        }
    }

    private fun isDesktopMode(methodCall: MethodCall) {
        val isEnabled = methodCall.arguments as Boolean
        var newUserAgent = webView.settings.userAgentString
        if (isEnabled) {
            try {
                newUserAgent =  "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36"
            } catch (e: Exception) {
                e.printStackTrace()
            }
        } else {
            newUserAgent = null
        }
        webView.settings.apply {
            userAgentString = newUserAgent
        }
        webView.reload()
    }

    private fun canGoForward(): Boolean{
        if(webView.canGoForward()){
            webView.goForward()
            return false
        }
        return true
    }

    override fun dispose() {
        // TODO dispose actions if needed
    }

    fun launchInsta(view: WebView, name: String) {
        val uriForApp: Uri = Uri.parse("http://instagram.com/_u/$name")
        val forApp = Intent(Intent.ACTION_VIEW, uriForApp)
        forApp.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        val uriForBrowser: Uri = Uri.parse("http://instagram.com/$name")
        val forBrowser = Intent(Intent.ACTION_VIEW, uriForBrowser)
        forBrowser.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        forApp.component =
            ComponentName(
                "com.instagram.android",
                "com.instagram.android.activity.UrlHandlerActivity"
            )

        try {
            view.context.startActivity(forApp)
        } catch (e: ActivityNotFoundException) {
            view.context.startActivity(forBrowser)
        }
    }

    fun hideKeyboard() {
        val imm = view.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager?
        imm!!.toggleSoftInput(InputMethodManager.HIDE_IMPLICIT_ONLY, 0)
    }

    inner class InsideWebViewClient : WebViewClient() {
        override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
            if (url.startsWith("intent://instagram.com")) {
                launchInsta(view, "instagram")
            }
            else view.loadUrl(url)
            return true
        }

        override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
            methodChannel.invokeMethod("onStarted", url)
        }

        override fun onPageFinished(view: WebView?, url: String?) {
            methodChannel.invokeMethod("onFinished", url)
            //hideSoftKeyboard(view!!)
        }

        override fun onReceivedError(view: WebView, request: WebResourceRequest?, error: WebResourceError) {

        }
    }
}

class WebViewGo(context: Context?, attrs: AttributeSet?) : WebView(context!!, attrs) {
    override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection {
        var connection: InputConnection = BaseInputConnection(this, true)
        outAttrs.imeOptions = EditorInfo.IME_ACTION_DONE
        if (outAttrs.inputType and InputType.TYPE_CLASS_NUMBER == InputType.TYPE_CLASS_NUMBER) {
            connection = BaseInputConnection(this, false)
        } else {
            outAttrs.inputType = EditorInfo.TYPE_CLASS_TEXT
        }
        return connection
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val isDispatched = super.dispatchKeyEvent(event)
        if (event.action == KeyEvent.ACTION_UP) {
            //Log.d("anton", "dispatchKeyEvent=" + event.keyCode)
            when (event.keyCode) {
                KeyEvent.KEYCODE_ENTER -> {
                    val imm =
                        context.getSystemService(Activity.INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.hideSoftInputFromWindow(windowToken, 0)
                }
            }
        }
        return isDispatched
    }
}

