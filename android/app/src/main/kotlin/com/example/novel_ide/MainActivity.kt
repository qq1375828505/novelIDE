package com.example.novel_ide

import android.os.Bundle
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var tts: TextToSpeech? = null
    private val channel = "com.example.novel_ide/tts"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "initTTS" -> {
                    val locale = call.argument<String>("locale") ?: "zh-CN"
                    initTTS(locale, result)
                }
                "speak" -> {
                    val text = call.argument<String>("text") ?: ""
                    speak(text, result)
                }
                "stop" -> {
                    tts?.stop()
                    result.success(null)
                }
                "setSpeechRate" -> {
                    val rate = call.argument<Double>("rate") ?: 1.0
                    tts?.setSpeechRate(rate.toFloat())
                    result.success(null)
                }
                "setPitch" -> {
                    val pitch = call.argument<Double>("pitch") ?: 1.0
                    tts?.setPitch(pitch.toFloat())
                    result.success(null)
                }
                "setLanguage" -> {
                    val locale = call.argument<String>("locale") ?: "zh-CN"
                    val javaLocale = java.util.Locale(locale)
                    val ttsResult = tts?.setLanguage(javaLocale)
                    result.success(ttsResult == TextToSpeech.LANG_AVAILABLE || ttsResult == TextToSpeech.LANG_COUNTRY_AVAILABLE)
                }
                "shutdown" -> {
                    tts?.stop()
                    tts?.shutdown()
                    tts = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initTTS(locale: String, result: MethodChannel.Result) {
        if (tts != null) {
            tts?.stop()
            tts?.shutdown()
        }
        tts = TextToSpeech(this, TextToSpeech.OnInitListener { status ->
            if (status == TextToSpeech.SUCCESS) {
                val javaLocale = java.util.Locale(locale)
                tts?.language = javaLocale
                tts?.setSpeechRate(0.8f)
                runOnUiThread { result.success(true) }
            } else {
                runOnUiThread { result.error("TTS_INIT_FAILED", "TTS初始化失败", null) }
            }
        })
    }

    private fun speak(text: String, result: MethodChannel.Result) {
        if (tts == null) {
            result.error("TTS_NOT_INIT", "TTS未初始化", null)
            return
        }
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "novel_ide_tts")
        result.success(null)
    }

    override fun onDestroy() {
        super.onDestroy()
        tts?.stop()
        tts?.shutdown()
    }
}
