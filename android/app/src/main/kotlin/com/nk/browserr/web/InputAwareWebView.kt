package com.nk.browserr.web

import android.content.Context
import android.graphics.Rect
import android.os.Build
import android.util.AttributeSet
import android.util.Log
import android.view.ContextMenu
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.webkit.WebView
import android.widget.ListPopupWindow
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception


/**
 * A WebView subclass that mirrors the same implementation hacks that the system WebView does in
 * order to correctly create an InputConnection.
 *
 * These hacks are only needed in Android versions below N and exist to create an InputConnection
 * on the WebView's dedicated input, or IME, thread. The majority of this proxying logic is in
 * https://github.com/flutter/plugins/blob/master/packages/webview_flutter/android/src/main/java/io/flutter/plugins/webviewflutter/InputAwareWebView.java
 */
class InputAwareWebView : WebView {
    private var containerView: View? = null
    private var threadedInputConnectionProxyView: View? = null
    private var proxyAdapterView: ThreadedInputConnectionProxyAdapterView? = null
    private var methodChannel: MethodChannel? = null
    private var useHybridComposition = false

    constructor(context: Context?, containerView: View?, useHybridComposition: Boolean?, methodChannel: MethodChannel?) : super(context!!) {
        this.containerView = containerView
        this.methodChannel = methodChannel
        this.useHybridComposition = useHybridComposition ?: false
    }

    constructor(context: Context?, attrs: AttributeSet?) : super(context!!, attrs) {
        containerView = null
    }

    constructor(context: Context?) : super(context!!) {
        containerView = null
    }

    constructor(context: Context?, attrs: AttributeSet?, defaultStyle: Int) : super(context!!, attrs, defaultStyle) {
        containerView = null
    }

    override fun onCreateContextMenu(menu: ContextMenu){
        super.onCreateContextMenu(menu)
        val webViewHitTestResult: HitTestResult = this.hitTestResult
        try {
            methodChannel!!.invokeMethod("createContextMenu", webViewHitTestResult.extra)
        }
        catch (e: Exception){
            Log.d("myLog", e.message!!)
        }
    }

    fun setContainerView(containerView: View?) {
        this.containerView = containerView
        if (proxyAdapterView == null) {
            return
        }
        Log.w(LOG_TAG, "The containerView has changed while the proxyAdapterView exists.")
        if (containerView != null) {
            setInputConnectionTarget(proxyAdapterView)
        }
    }

    /**
     * Set our proxy adapter view to use its cached input connection instead of creating new ones.
     *
     *
     * This is used to avoid losing our input connection when the virtual display is resized.
     */
    fun lockInputConnection() {
        if (proxyAdapterView == null) {
            return
        }
        proxyAdapterView!!.setLocked(true)
    }

    /** Sets the proxy adapter view back to its default behavior.  */
    fun unlockInputConnection() {
        if (proxyAdapterView == null) {
            return
        }
        proxyAdapterView!!.setLocked(false)
    }

    /** Restore the original InputConnection, if needed.  */
    fun dispose() {
        if (useHybridComposition) {
            return
        }
        resetInputConnection()
    }

    /**
     * Creates an InputConnection from the IME thread when needed.
     *
     *
     * We only need to create a [ThreadedInputConnectionProxyAdapterView] and create an
     * InputConnectionProxy on the IME thread when WebView is doing the same thing. So we rely on the
     * system calling this method for WebView's proxy view in order to know when we need to create our
     * own.
     *
     *
     * This method would normally be called for any View that used the InputMethodManager. We rely
     * on flutter/engine filtering the calls we receive down to the ones in our hierarchy and the
     * system WebView in order to know whether or not the system WebView expects an InputConnection on
     * the IME thread.
     */
    override fun checkInputConnectionProxy(view: View): Boolean {
        if (useHybridComposition) {
            return super.checkInputConnectionProxy(view)
        }
        // Check to see if the view param is WebView's ThreadedInputConnectionProxyView.
        val previousProxy = threadedInputConnectionProxyView
        threadedInputConnectionProxyView = view
        if (previousProxy === view) {
            // This isn't a new ThreadedInputConnectionProxyView. Ignore it.
            return super.checkInputConnectionProxy(view)
        }
        if (containerView == null) {
            Log.e(
                    LOG_TAG,
                    "Can't create a proxy view because there's no container view. Text input may not work.")
            return super.checkInputConnectionProxy(view)
        }

        // We've never seen this before, so we make the assumption that this is WebView's
        // ThreadedInputConnectionProxyView. We are making the assumption that the only view that could
        // possibly be interacting with the IMM here is WebView's ThreadedInputConnectionProxyView.
        proxyAdapterView = ThreadedInputConnectionProxyAdapterView(
            containerView!!,  /*targetView=*/
            view,  /*imeHandler=*/
            view.handler
        )
        setInputConnectionTarget( /*targetView=*/proxyAdapterView)
        return super.checkInputConnectionProxy(view)
    }

    /**
     * Ensure that input creation happens back on [.containerView]'s thread once this view no
     * longer has focus.
     *
     *
     * The logic in [.checkInputConnectionProxy] forces input creation to happen on Webview's
     * thread for all connections. We undo it here so users will be able to go back to typing in
     * Flutter UIs as expected.
     */
    override fun clearFocus() {
        super.clearFocus()
        if (useHybridComposition) {
            return
        }
        resetInputConnection()
    }

    /**
     * Ensure that input creation happens back on [.containerView].
     *
     *
     * The logic in [.checkInputConnectionProxy] forces input creation to happen on Webview's
     * thread for all connections. We undo it here so users will be able to go back to typing in
     * Flutter UIs as expected.
     */
    private fun resetInputConnection() {
        if (proxyAdapterView == null) {
            // No need to reset the InputConnection to the default thread if we've never changed it.
            return
        }
        if (containerView == null) {
            Log.e(LOG_TAG, "Can't reset the input connection to the container view because there is none.")
            return
        }
        setInputConnectionTarget( /*targetView=*/containerView)
    }

    /**
     * This is the crucial trick that gets the InputConnection creation to happen on the correct
     * thread pre Android N.
     * https://cs.chromium.org/chromium/src/content/public/android/java/src/org/chromium/content/browser/input/ThreadedInputConnectionFactory.java?l=169&rcl=f0698ee3e4483fad5b0c34159276f71cfaf81f3a
     *
     *
     * `targetView` should have a [View.getHandler] method with the thread that future
     * InputConnections should be created on.
     */
    private fun setInputConnectionTarget(targetView: View?) {
        if (containerView == null) {
            Log.e(
                    LOG_TAG,
                    "Can't set the input connection target because there is no containerView to use as a handler.")
            return
        }
        targetView!!.requestFocus()
        containerView!!.post {
            val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            // This is a hack to make InputMethodManager believe that the target view now has focus.
            // As a result, InputMethodManager will think that targetView is focused, and will call
            // getHandler() of the view when creating input connection.

            // Step 1: Set targetView as InputMethodManager#mNextServedView. This does not affect
            // the real window focus.
            targetView.onWindowFocusChanged(true)

            // Step 2: Have InputMethodManager focus in on targetView. As a result, IMM will call
            // onCreateInputConnection() on targetView on the same thread as
            // targetView.getHandler(). It will also call subsequent InputConnection methods on this
            // thread. This is the IME thread in cases where targetView is our proxyAdapterView.

            // TODO (ALexVincent525): Currently only prompt has been tested, still needs more test cases.
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                imm.isActive(containerView)
            }
        }
    }

    override fun onFocusChanged(focused: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
        if (useHybridComposition) {
            super.onFocusChanged(focused, direction, previouslyFocusedRect)
            return
        }
        // This works around a crash when old (<67.0.3367.0) Chromium versions are used.

        // Prior to Chromium 67.0.3367 the following sequence happens when a select drop down is shown
        // on tablets:
        //
        //  - WebView is calling ListPopupWindow#show
        //  - buildDropDown is invoked, which sets mDropDownList to a DropDownListView.
        //  - showAsDropDown is invoked - resulting in mDropDownList being added to the window and is
        //    also synchronously performing the following sequence:
        //    - WebView's focus change listener is loosing focus (as mDropDownList got it)
        //    - WebView is hiding all popups (as it lost focus)
        //    - WebView's SelectPopupDropDown#hide is invoked.
        //    - DropDownPopupWindow#dismiss is invoked setting mDropDownList to null.
        //  - mDropDownList#setSelection is invoked and is throwing a NullPointerException (as we just set mDropDownList to null).
        //
        // To workaround this, we drop the problematic focus lost call.
        // See more details on: https://github.com/flutter/flutter/issues/54164
        //
        // We don't do this after Android P as it shipped with a new enough WebView version, and it's
        // better to not do this on all future Android versions in case DropDownListView's code changes.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P && isCalledFromListPopupWindowShow
                && !focused) {
            return
        }
        super.onFocusChanged(focused, direction, previouslyFocusedRect)
    }

    private val isCalledFromListPopupWindowShow: Boolean
        private get() {
            val stackTraceElements = Thread.currentThread().stackTrace
            for (stackTraceElement in stackTraceElements) {
                if (stackTraceElement.className == ListPopupWindow::class.java.canonicalName && stackTraceElement.methodName == "show") {
                    return true
                }
            }
            return false
        }

    companion object {
        private const val LOG_TAG = "InputAwareWebView"
    }
}