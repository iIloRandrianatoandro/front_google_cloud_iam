package com.example.gestion_identite

import io.flutter.embedding.android.FlutterActivity
import android.media.MediaScannerConnection
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private val CHANNEL = "gallery_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    MediaScannerConnection.scanFile(
                        context,
                        arrayOf(path),
                        null,
                        null
                    )
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "Chemin manquant", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
