package com.pansoft.jel_music

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileNotFoundException
import java.net.URLDecoder

class ArtworkContentProvider : ContentProvider() {

    override fun onCreate(): Boolean = true

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor? {
        val encodedPath = uri.encodedPath ?: throw FileNotFoundException("No path in URI")
        val path = URLDecoder.decode(encodedPath.removePrefix("/"), "UTF-8")
        val file = File(path).canonicalFile

        val context = context ?: throw FileNotFoundException("No context")
        val cacheRoot = context.cacheDir?.canonicalPath ?: throw FileNotFoundException("No cache dir")
        val filesRoot = context.filesDir?.canonicalPath ?: throw FileNotFoundException("No files dir")

        if (!file.path.startsWith(cacheRoot + File.separator) &&
            !file.path.startsWith(filesRoot + File.separator) &&
            file.path != cacheRoot &&
            file.path != filesRoot
        ) {
            throw FileNotFoundException("Path not allowed: $path")
        }

        if (!file.exists()) {
            throw FileNotFoundException("File not found: $path")
        }

        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    }

    override fun getType(uri: Uri): String? {
        return when (uri.path?.substringAfterLast('.', "")?.lowercase()) {
            "png" -> "image/png"
            "webp" -> "image/webp"
            "gif" -> "image/gif"
            else -> "image/jpeg"
        }
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?
    ): Int = 0

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
}
