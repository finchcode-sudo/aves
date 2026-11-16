package com.aves.refra

import android.content.Intent
import com.aves.refra.model.FieldMap

class ScreenSaverSettingsActivity : MainActivity() {
    override fun extractIntentData(intent: Intent?): FieldMap {
        return hashMapOf(
            INTENT_DATA_KEY_ACTION to INTENT_ACTION_SCREEN_SAVER_SETTINGS,
        )
    }
}