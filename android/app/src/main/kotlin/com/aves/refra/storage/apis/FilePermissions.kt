package com.aves.refra.storage.apis

import android.content.Context
import android.os.Build
import android.os.Environment
import com.aves.refra.storage.StorageUtils

object FilePermissions : StoragePermissions {
    fun getAccessibleDirectories(context: Context): Set<String> {
        return hashSetOf<String>().apply {
            addAll(StorageUtils.getAvesAppDirectories(context))

            // from API 21 / Android 5.0 / Lollipop, removable storage requires access permission, but directory access grant is possible
            // from API 30 / Android 11 / R, any storage requires access permission
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
                add(StorageUtils.getPrimaryVolumePath(context))
            }

            // with "all files access", every storage volume can be edited directly
            if (hasAllFilesAccess()) {
                addAll(StorageUtils.getVolumePaths(context))
            }
        }
    }

    fun hasAllFilesAccess(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && Environment.isExternalStorageManager()
    }

    fun canEdit(context: Context, anyPath: String): Boolean {
        val dirs = getAccessibleDirectories(context)
        return dirs.any { anyPath.startsWith(it) }
    }

    override fun canEditWithUserInteraction(context: Context, dirPath: String, insertion: Boolean): Boolean {
        if (dirPath == StorageUtils.TRASH_PATH_PLACEHOLDER) return true
        return canEdit(context, dirPath)
    }
}