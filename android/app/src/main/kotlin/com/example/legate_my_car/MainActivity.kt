package com.laqeetarabeety.managers

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.laqeetarabeety.app/flavor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAppFlavor") {
                val flavor = getAppFlavor()
                result.success(flavor)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getAppFlavor(): String {
        return try {
            val context: Context = applicationContext
            val packageName = context.packageName
            when {
                packageName.contains("managers") -> "managers"
                packageName.contains("clinets") -> "clients"
                else -> "managers" // default
            }
        } catch (e: Exception) {
            "managers" // default
        }
    }
}
