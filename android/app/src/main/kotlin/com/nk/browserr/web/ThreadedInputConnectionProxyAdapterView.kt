package com.nk.browserr.web

import android.annotation.SuppressLint
import android.os.Handler
import android.os.IBinder
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection


/**
 * A fake View only exposed to InputMethodManager.
 * https://github.com/flutter/plugins/blob/master/packages/webview_flutter/android/src/main/java/io/flutter/plugins/webviewflutter/ThreadedInputConnectionProxyAdapterView.java
 */
@SuppressLint("ViewConstructor")
class ThreadedInputConnectionProxyAdapterView(private var containerView: View, private val targetView: View, private val imeHandler: Handler) : View(containerView.context) {
    private var windowToken: IBinder? = null
    private var rootView: View? = null

    /** Returns whether or not this is currently asynchronously acquiring an input connection.  */
    private var isTriggerDelayed = true
    private var isLocked = false
    private var cachedConnection: InputConnection? = null

    /** Sets whether or not this should use its previously cached input connection.  */
    fun setLocked(locked: Boolean) {
        isLocked = locked
    }

    /**
     * This is expected to be called on the IME thread. See the setup required for this in [ ][InputAwareWebView.checkInputConnectionProxy].
     *
     *
     * Delegates to ThreadedInputConnectionProxyView to get WebView's input connection.
     */
    override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection {
        isTriggerDelayed = false
        val inputConnection = if (isLocked) cachedConnection else targetView.onCreateInputConnection(outAttrs)
        isTriggerDelayed = true
        cachedConnection = inputConnection
        return inputConnection!!
    }

    override fun checkInputConnectionProxy(view: View): Boolean {
        return true
    }

    override fun hasWindowFocus(): Boolean {
        // None of our views here correctly report they have window focus because of how we're embedding
        // the platform view inside of a virtual display.
        return true
    }

    override fun getRootView(): View {
        return rootView!!
    }

    override fun onCheckIsTextEditor(): Boolean {
        return true
    }

    override fun isFocused(): Boolean {
        return true
    }

    override fun getWindowToken(): IBinder {
        return windowToken!!
    }

    override fun getHandler(): Handler {
        return imeHandler
    }

    init {
        rootView = containerView.rootView
        isFocusable = true
        isFocusableInTouchMode = true
        visibility = VISIBLE
    }
}