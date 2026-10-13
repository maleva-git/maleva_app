package com.kassapos.maleva

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterFragmentActivity() {

    private var speech: SummarySpeech? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SummarySpeech.CHANNEL)
        speech = SummarySpeech(this, channel)
    }

    override fun onDestroy() {
        speech?.shutdown()
        speech = null
        super.onDestroy()
    }
}

/**
 * Reads the mail report summary aloud with Android's own TextToSpeech, for `TtsSummarySpeaker` in Dart
 * (channel com.kassapos.maleva/tts). Replaces the flutter_tts plugin (owner, 2026-10-13), which applied the
 * old Kotlin Gradle Plugin. Methods: isLanguageAvailable {language}, speak {text, language}, stop; it calls
 * back onDone, onCancel and onError when a speech ends.
 */
class SummarySpeech(activity: FlutterFragmentActivity, private val channel: MethodChannel) {

    companion object {
        const val CHANNEL = "com.kassapos.maleva/tts"
        private const val UTTERANCE = "maleva-summary"
        /** flutter_tts's 0.5 was Android's normal rate (1.0). */
        private const val RATE = 1.0f
    }

    private val main = Handler(Looper.getMainLooper())
    private var ready = false
    private val waiting = mutableListOf<() -> Unit>()
    private val tts: TextToSpeech = TextToSpeech(activity.applicationContext) { status ->
        main.post {
            ready = status == TextToSpeech.SUCCESS
            waiting.forEach { it() }
            waiting.clear()
        }
    }

    init {
        tts.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) {}
            override fun onDone(utteranceId: String?) = callBack("onDone", null)
            override fun onStop(utteranceId: String?, interrupted: Boolean) = callBack("onCancel", null)
            @Deprecated("Deprecated in Java")
            override fun onError(utteranceId: String?) = callBack("onError", "speech failed")
            override fun onError(utteranceId: String?, errorCode: Int) = callBack("onError", "speech failed ($errorCode)")
        })
        channel.setMethodCallHandler { call, result ->
            whenReady {
                when (call.method) {
                    "isLanguageAvailable" -> result.success(ready && available(call.argument<String>("language")))
                    "speak" -> result.success(ready && speak(call.argument<String>("text"), call.argument<String>("language")))
                    "stop" -> {
                        tts.stop()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun whenReady(action: () -> Unit) {
        if (ready) action() else waiting.add(action)
    }

    private fun locale(language: String?): Locale = Locale.forLanguageTag(language ?: "en-US")

    private fun available(language: String?): Boolean =
        tts.isLanguageAvailable(locale(language)) >= TextToSpeech.LANG_AVAILABLE

    private fun speak(text: String?, language: String?): Boolean {
        if (text.isNullOrBlank()) return false
        tts.language = locale(language)
        tts.setSpeechRate(RATE)
        return tts.speak(text, TextToSpeech.QUEUE_FLUSH, Bundle(), UTTERANCE) == TextToSpeech.SUCCESS
    }

    private fun callBack(method: String, argument: Any?) {
        main.post { channel.invokeMethod(method, argument) }
    }

    fun shutdown() {
        channel.setMethodCallHandler(null)
        tts.stop()
        tts.shutdown()
    }
}
