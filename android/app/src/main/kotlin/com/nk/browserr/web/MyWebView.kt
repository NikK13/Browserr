package com.nk.browserr.web

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.app.Activity.RESULT_OK
import android.app.DownloadManager
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
import android.view.*
import android.webkit.WebViewClient
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewFeature
import java.lang.Exception
import android.content.Context.DOWNLOAD_SERVICE
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.os.Environment
import android.util.Log
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.checkSelfPermission
import androidx.core.content.FileProvider
import java.io.File
import androidx.core.content.ContextCompat.startActivity
import java.io.ByteArrayOutputStream


@SuppressLint("SetJavaScriptEnabled", "ClickableViewAccessibility")
class MyWebView internal constructor(context: Context, messenger: BinaryMessenger, id: Int, private val activity: Activity) : PlatformView, MethodCallHandler{
    private val methodChannel = MethodChannel(messenger, "webview$id")
    private val webView: WebView = InputAwareWebView(context, null, true, methodChannel)

    private var mFilePathCallback: ValueCallback<Array<Uri?>?>? = null
    private val pickFileRequestId = 0
    private val mobileAgent = "Mozilla/5.0 (Linux; Android 4.1.1; Galaxy Nexus Build/JRO03C) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/92.0.4515.131 Mobile Safari/535.19"
    private var isResource: String? = null

    override fun getView(): View {
        return webView
    }

    init {
        activity.registerForContextMenu(this.webView)
        webView.settings.apply {
            builtInZoomControls = true
            useWideViewPort = true
            displayZoomControls = false
            javaScriptEnabled = true
            loadWithOverviewMode = true
            domStorageEnabled = true
            userAgentString = mobileAgent
            mediaPlaybackRequiresUserGesture = false
        }
        /*WebView.setWebContentsDebuggingEnabled(true);
        webView.isFocusableInTouchMode = true*/
        methodChannel.setMethodCallHandler(this)

        webView.webViewClient = InsideWebViewClient()
        webView.setDownloadListener { url, _, contentDisposition, mimetype, _ ->
            val request: DownloadManager.Request = DownloadManager.Request(Uri.parse(url))
            val filename = URLUtil.guessFileName(url, contentDisposition, mimetype)
            request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
            request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, filename)
            val dm: DownloadManager? = webView.context.getSystemService(DOWNLOAD_SERVICE) as DownloadManager?
            dm!!.enqueue(request)
        }
        webView.webChromeClient = object : WebChromeClient() {
            override fun onShowFileChooser(webView: WebView?, filePathCallback: ValueCallback<Array<Uri?>?>, fileChooserParams: FileChooserParams?): Boolean {
                mFilePathCallback = filePathCallback
                openImageChooserActivity(activity)
                return true
            }

            override fun onPermissionRequest(request: PermissionRequest?) {
                checkPermissions()
                request!!.grant(request.resources)
            }

            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                methodChannel.invokeMethod("onProgress", newProgress)
            }

            override fun onReceivedTitle(view: WebView?, title: String?) {
                methodChannel.invokeMethod("onTitleReceived", title!!)
            }

            override fun onReceivedIcon(view: WebView?, icon: Bitmap?) {
                super.onReceivedIcon(view, icon)
                if(isResource == null && view!!.progress == 100){
                    val stream = ByteArrayOutputStream()
                    icon!!.compress(Bitmap.CompressFormat.PNG, 60, stream)
                    val hashMap = mapOf(
                        "image" to stream.toByteArray(),
                        "url" to view.url as Any,
                    )
                    isResource = view.url
                    methodChannel.invokeMethod("onIconReceived", hashMap)
                }
            }
        }
    }

    private fun getAndroidVersion(result: Result){
        result.success(android.os.Build.VERSION.SDK_INT)
    }

    private fun getCache(result: Result){
        val file = activity.applicationContext.cacheDir
        val externalFile = activity.applicationContext.externalCacheDir
        if(file.exists()){
            if(externalFile!!.exists()){
                var size = getDirSize(file)
                result.success(size + getDirSize(externalFile))
            }
            else result.success(getDirSize(file))
        }
        else result.success(0)
    }

    private fun clearCache(result: Result){
        webView.clearCache(true)
        result.success(null)
    }

    private fun getDirSize(dir: File?): Long {
        var size: Long = 0
        for (file in dir!!.listFiles()!!) {
            if (file != null && file.isDirectory) {
                size += getDirSize(file)
            } else if (file != null && file.isFile) {
                size += file.length()
            }
        }
        return size
    }

    fun activityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == pickFileRequestId) {
            if (mFilePathCallback == null) {
                return false
            }
            val result = if (data == null || resultCode != RESULT_OK) null else data.data
            val resultsArray = arrayOfNulls<Uri>(1)
            resultsArray[0] = result
            mFilePathCallback!!.onReceiveValue(resultsArray)
        }
        return false
    }

    private fun openImageChooserActivity(activity: Activity?) {
        val i = Intent(Intent.ACTION_GET_CONTENT)
        i.addCategory(Intent.CATEGORY_OPENABLE)
        i.type = "*/*"
        activity?.startActivityForResult(Intent.createChooser(i, "Pick image"), pickFileRequestId)
    }

    override fun onMethodCall(methodCall: MethodCall, result: Result) {
        when (methodCall.method) {
            "loadUrl" -> loadUrl(methodCall, result)
            "findOnPage" -> findOnPage(methodCall)
            "shareUrl" -> shareCurrentUrl(methodCall)
            "reloadPage" -> webView.reload()
            "canGoBack" -> canGoBack(result)
            "getCache" -> getCache(result)
            "clearCache" -> clearCache(result)
            "isIncognito" -> isIncognito(methodCall)
            "getAndroidVersion" -> getAndroidVersion(result)
            "goBack" -> goBack()
            "viewSource" -> viewSourceCode(methodCall)
            "downloadImage" -> downloadImage()
            "shareImage" -> shareImage(activity)
            "getTitle" -> getTitle(result)
            "isHitForImage" -> isWebHitForImage(result)
            "intentFromOtherApp" -> intentFromOtherApp(result)
            "canGoForward" -> canGoForward()
            "isDesktopMode" -> isDesktopMode(methodCall)
            "forceDarkEnabled" -> forceDarkEnabled(methodCall)
            else -> result.notImplemented()
        }
    }

    private fun checkPermissions() {
        if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            activity.requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), 0)
        }
    }

    private fun isIncognito(methodCall: MethodCall){
        val isIncognito = methodCall.arguments as Boolean
        CookieManager.getInstance().setAcceptCookie(!isIncognito);
        //CookieManager.getInstance().setAcceptThirdPartyCookies(webView, true);
        webView.apply {
            settings.cacheMode = if(isIncognito) WebSettings.LOAD_NO_CACHE else WebSettings.LOAD_DEFAULT
            settings.allowContentAccess = !isIncognito
            if(isIncognito) clearHistory()
            if(isIncognito) clearFormData()
            //clearCache(isIncognito)
            /*settings.savePassword = !isIncognito
            settings.saveFormData = !isIncognito*/
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

    private fun findOnPage(methodCall: MethodCall) {
        val text = methodCall.arguments as String
        webView.findAllAsync(text)
    }

    private fun viewSourceCode(methodCall: MethodCall) {
        val url = methodCall.arguments as String
        webView.loadUrl("view-source:$url")
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
            newUserAgent = mobileAgent
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

    private fun intentFromOtherApp(result: Result){
        result.success(activity.intent.dataString)
    }

    override fun dispose() {}

    fun launchInsta(view: WebView, name: String) {
        val uriForBrowser: Uri = Uri.parse("http://instagram.com/$name")
        val forBrowser = Intent(Intent.ACTION_VIEW, uriForBrowser)
        forBrowser.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        try {
            view.context.startActivity(forBrowser)
        }
        catch (e: ActivityNotFoundException){
            Log.d("myLog", e.message!!)
        }
    }

    inner class InsideWebViewClient : WebViewClient() {
        override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
            if (view!!.url!!.startsWith("intent://instagram.com")) {
                launchInsta(view, view.url!!.substring(26).substringBefore("?"))
            }
            return false
        }

        override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
            isResource = null
            if (url!!.startsWith("https://www.instagram.com")) {
                launchInsta(view!!, url.substring(26).substringBefore("?"))
            }
            else methodChannel.invokeMethod("onStarted", url)
        }

        override fun onPageFinished(view: WebView?, url: String?) {
            if(url!!.contains("intent")){
                if(view!!.canGoBack()) view.goBack()
            }
            methodChannel.invokeMethod("onFinished", url)
        }

        override fun onReceivedError(view: WebView, request: WebResourceRequest?, error: WebResourceError) {
            //Log.d("myLog", request!!.method)
        }
    }

    private fun isWebHitForImage(result: Result){
        result.success((webView.hitTestResult.type == WebView.HitTestResult.IMAGE_TYPE) || (webView.hitTestResult.type == WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE))
    }

    private fun downloadImage(){
        val webViewHitTestResult: WebView.HitTestResult = webView.hitTestResult
        val downloadImageURL = webViewHitTestResult.extra
        if (webViewHitTestResult.type == WebView.HitTestResult.IMAGE_TYPE || webViewHitTestResult.type == WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE) {
            if (URLUtil.isValidUrl(downloadImageURL)) {
                val request = DownloadManager.Request(Uri.parse(downloadImageURL))
                request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, "browserr_${System.currentTimeMillis()}.png")
                val downloadManager = webView.context.getSystemService(DOWNLOAD_SERVICE) as DownloadManager?
                downloadManager!!.enqueue(request)
                Toast.makeText(webView.context, "Downloaded successfully", Toast.LENGTH_SHORT).show()
            }
        }
        else Toast.makeText(webView.context, "Error, try again..", Toast.LENGTH_SHORT).show()
    }

    private fun shareCurrentUrl(methodCall: MethodCall){
        val url = methodCall.arguments as String
        val intent = Intent(Intent.ACTION_SEND)
        intent.type = "*/*"
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        intent.putExtra(Intent.EXTRA_TEXT, url)
        val chooser = Intent.createChooser(intent, "Share url")
        val resInfoList: List<ResolveInfo> = view.context.packageManager.queryIntentActivities(chooser, PackageManager.MATCH_DEFAULT_ONLY)

        for (resolveInfo in resInfoList) {
            val packageName: String = resolveInfo.activityInfo.packageName
            view.context.grantUriPermission(packageName, null, Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        activity.startActivity(chooser)
    }

    @SuppressLint("QueryPermissionsNeeded")
    private fun shareImage(activity: Activity){
        val webViewHitTestResult: WebView.HitTestResult = webView.hitTestResult
        if (webViewHitTestResult.type == WebView.HitTestResult.IMAGE_TYPE || webViewHitTestResult.type == WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE) {
           if(URLUtil.isNetworkUrl(webViewHitTestResult.extra)){
               val intent = Intent(Intent.ACTION_SEND)
               val imageUrl: String = webView.hitTestResult.extra!!
               intent.type = "*/*"
               intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
               intent.putExtra(Intent.EXTRA_TEXT, imageUrl)
               val chooser = Intent.createChooser(intent,"Share Image")
               val resInfoList: List<ResolveInfo> = view.context.packageManager.queryIntentActivities(chooser, PackageManager.MATCH_DEFAULT_ONLY)

               for (resolveInfo in resInfoList) {
                   val packageName: String = resolveInfo.activityInfo.packageName
                   view.context.grantUriPermission(packageName, null, Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION)
               }
               activity.startActivity(chooser)
           }
        }
        else Toast.makeText(webView.context, "Error, try again..", Toast.LENGTH_SHORT).show()
    }
}