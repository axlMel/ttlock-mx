package com.example.api_app

import io.flutter.embedding.android.FlutterActivity
import com.ttlock.ttlock_flutter.TtlockFlutterPlugin

class MainActivity : FlutterActivity() {

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {

        val plugin =
            flutterEngine?.plugins?.get(
                TtlockFlutterPlugin::class.java
            ) as? TtlockFlutterPlugin

        plugin?.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )

        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )
    }
}