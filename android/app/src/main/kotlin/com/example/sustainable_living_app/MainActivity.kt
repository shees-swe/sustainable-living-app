package com.example.sustainable_living_app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity : FlutterActivity() {
    private var pendingImportResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            USER_DATA_IMPORT_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method != "pickJsonFile") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingImportResult != null) {
                result.error("PICKER_BUSY", "A file selection is already in progress.", null)
                return@setMethodCallHandler
            }
            pendingImportResult = result
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "*/*"
                putExtra(
                    Intent.EXTRA_MIME_TYPES,
                    arrayOf("application/json", "text/json", "application/octet-stream")
                )
            }
            try {
                startActivityForResult(intent, USER_DATA_IMPORT_REQUEST)
            } catch (error: ActivityNotFoundException) {
                pendingImportResult = null
                result.error("PICKER_UNAVAILABLE", error.message, null)
            }
        }
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != USER_DATA_IMPORT_REQUEST) return

        val result = pendingImportResult ?: return
        pendingImportResult = null
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        try {
            val bytes = contentResolver.openInputStream(data.data!!)?.use { it.readBytes() }
            if (bytes == null) {
                result.error("FILE_READ_FAILED", "Could not read the selected file.", null)
            } else {
                result.success(bytes)
            }
        } catch (error: IOException) {
            result.error("FILE_READ_FAILED", error.message, null)
        } catch (error: SecurityException) {
            result.error("FILE_READ_FAILED", error.message, null)
        }
    }

    companion object {
        private const val USER_DATA_IMPORT_CHANNEL =
            "app.sustainablelivingguide/user_data_import"
        private const val USER_DATA_IMPORT_REQUEST = 0x534C
    }
}
