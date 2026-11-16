package com.aves.refra.storage

import android.content.Context
import com.aves.refra.model.FieldMap
import com.aves.refra.storage.StorageUtils.ensureTrailingSeparator
import com.aves.refra.storage.StorageUtils.getVolumePath
import java.io.File

// `fullPath` should match "volumePath + relativeDir + fileName"
class PathSegments {
    var volumePath: String? = null // `volumePath` with trailing "/"
    var relativeDir: String? = null // `relativeDir` with trailing "/"
    private var fileName: String? = null // null for directories

    constructor(context: Context, fullPath: String) {
        volumePath = getVolumePath(context, fullPath)
        if (volumePath != null) {
            val lastSeparatorIndex = fullPath.lastIndexOf(File.separator) + 1
            val volumePathLength = volumePath!!.length
            if (lastSeparatorIndex > volumePathLength) {
                fileName = fullPath.substring(lastSeparatorIndex)
                relativeDir = fullPath.substring(volumePathLength, lastSeparatorIndex)
            }
        }
    }

    constructor(volumePath: String?, relativeDir: String?) {
        this.volumePath = volumePath
        this.relativeDir = if (relativeDir != null) ensureTrailingSeparator(relativeDir) else null
    }

    override fun toString(): String = "PathSegments#${hashCode()}{volumePath=$volumePath relativeDir=$relativeDir fileName=$fileName}"

    fun getPrimaryDir() = relativeDir?.split(File.separator)?.firstOrNull()

    fun toMap(): FieldMap {
        return hashMapOf(
            "volumePath" to volumePath,
            "relativeDir" to relativeDir,
        )
    }
}
