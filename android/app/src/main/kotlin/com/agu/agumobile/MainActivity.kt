package com.agu.agumobile

import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.agu.agumobile/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToPublicDownloads" -> {
                        val filename = call.argument<String>("filename")
                        val bytes = call.argument<ByteArray>("bytes")
                        if (filename == null || bytes == null) {
                            result.error("INVALID_ARGS", "filename ve bytes gerekli", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val path = saveToPublicDownloads(filename, bytes)
                            result.success(path)
                        } catch (e: Exception) {
                            result.error("SAVE_ERROR", e.message, null)
                        }
                    }
                    "deleteFromPublicDownloads" -> {
                        val filename = call.argument<String>("filename")
                        if (filename == null) {
                            result.error("INVALID_ARGS", "filename gerekli", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val deleted = deleteFromPublicDownloads(filename)
                            result.success(deleted)
                        } catch (e: Exception) {
                            result.error("DELETE_ERROR", e.message, null)
                        }
                    }
                    "openLocalFile" -> {
                        val path = call.arguments as? String
                        if (path.isNullOrBlank()) {
                            result.error("INVALID_ARGS", "path gerekli", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val ok = openAppScopedFileForView(path)
                            result.success(ok)
                        } catch (e: SecurityException) {
                            result.error("INVALID_PATH", e.message, null)
                        } catch (e: ActivityNotFoundException) {
                            result.success(false)
                        } catch (e: Exception) {
                            result.error("OPEN_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Uygulama korumalı dizinlerindeki dosyayı (indirilenler) harici uygulamada açar.
     * READ_MEDIA_* gerektirmez; yalnızca FileProvider ile content:// URI paylaşılır.
     */
    private fun openAppScopedFileForView(path: String): Boolean {
        val file = File(path).canonicalFile
        if (!file.exists() || !file.isFile) return false

        val ctx = applicationContext
        val appFiles = ctx.filesDir.canonicalFile
        val cacheDir = ctx.cacheDir.canonicalFile
        val extDir = ctx.getExternalFilesDir(null)?.canonicalFile

        val allowed = file.path.startsWith(appFiles.path) ||
            file.path.startsWith(cacheDir.path) ||
            (extDir != null && file.path.startsWith(extDir.path))
        if (!allowed) {
            throw SecurityException("Dosya yolu uygulama alanı dışında")
        }

        val authority = "${ctx.packageName}.localfileprovider"
        val uri = FileProvider.getUriForFile(ctx, authority, file)
        val mime = getMimeType(file.name) ?: "application/octet-stream"

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mime)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(intent)
        return true
    }

    private fun saveToPublicDownloads(filename: String, bytes: ByteArray): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+ (API 29+): MediaStore kullan
            val resolver = contentResolver
            val contentValues = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, filename)
                put(MediaStore.Downloads.IS_PENDING, 1)
                // MIME type belirle
                val mimeType = getMimeType(filename)
                if (mimeType != null) {
                    put(MediaStore.Downloads.MIME_TYPE, mimeType)
                }
            }

            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
                ?: return null

            resolver.openOutputStream(uri)?.use { outputStream ->
                outputStream.write(bytes)
            }

            // IS_PENDING'i kaldır — dosya artık görünür
            contentValues.clear()
            contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)

            return uri.toString()
        } else {
            // Android 9 ve altı: doğrudan dosya yaz
            @Suppress("DEPRECATION")
            val downloadsDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
            )
            if (!downloadsDir.exists()) downloadsDir.mkdirs()

            var targetFile = File(downloadsDir, filename)
            var counter = 1
            while (targetFile.exists()) {
                val dotIndex = filename.lastIndexOf('.')
                val newName = if (dotIndex != -1) {
                    "${filename.substring(0, dotIndex)} ($counter)${filename.substring(dotIndex)}"
                } else {
                    "$filename ($counter)"
                }
                targetFile = File(downloadsDir, newName)
                counter++
            }

            targetFile.writeBytes(bytes)
            return targetFile.absolutePath
        }
    }

    private fun deleteFromPublicDownloads(filename: String): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+ (API 29+): MediaStore'dan sil
            val resolver = contentResolver
            val projection = arrayOf(MediaStore.Downloads._ID)
            val selection = "${MediaStore.Downloads.DISPLAY_NAME} = ?"
            val selectionArgs = arrayOf(filename)

            resolver.query(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                null
            )?.use { cursor ->
                while (cursor.moveToNext()) {
                    val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Downloads._ID))
                    val deleteUri = android.content.ContentUris.withAppendedId(
                        MediaStore.Downloads.EXTERNAL_CONTENT_URI, id
                    )
                    resolver.delete(deleteUri, null, null)
                }
            }
            return true
        } else {
            // Android 9 ve altı: doğrudan sil
            @Suppress("DEPRECATION")
            val downloadsDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
            )
            val targetFile = File(downloadsDir, filename)
            return if (targetFile.exists()) targetFile.delete() else true
        }
    }

    private fun getMimeType(filename: String): String? {
        val ext = filename.substringAfterLast('.', "").lowercase()
        return when (ext) {
            "pdf" -> "application/pdf"
            "doc" -> "application/msword"
            "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            "xls" -> "application/vnd.ms-excel"
            "xlsx" -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            "ppt" -> "application/vnd.ms-powerpoint"
            "pptx" -> "application/vnd.openxmlformats-officedocument.presentationml.presentation"
            "txt" -> "text/plain"
            "csv" -> "text/csv"
            "rtf" -> "application/rtf"
            "odt" -> "application/vnd.oasis.opendocument.text"
            "zip" -> "application/zip"
            "rar" -> "application/vnd.rar"
            "7z" -> "application/x-7z-compressed"
            "tar" -> "application/x-tar"
            "gz" -> "application/gzip"
            "jpg", "jpeg" -> "image/jpeg"
            "png" -> "image/png"
            "gif" -> "image/gif"
            "bmp" -> "image/bmp"
            "svg" -> "image/svg+xml"
            "mp4" -> "video/mp4"
            "avi" -> "video/x-msvideo"
            "mkv" -> "video/x-matroska"
            "mov" -> "video/quicktime"
            "mp3" -> "audio/mpeg"
            else -> "application/octet-stream"
        }
    }
}
