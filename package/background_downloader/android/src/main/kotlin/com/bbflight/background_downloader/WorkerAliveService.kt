package com.bbflight.background_downloader

import android.annotation.SuppressLint
import android.app.Service
import android.content.Intent
import android.content.SharedPreferences
import android.os.IBinder
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.embedding.engine.loader.FlutterLoader


class WorkerAliveService: Service() {
    private lateinit var flutterLoader: FlutterLoader

    private lateinit var prefs: SharedPreferences

    private var taskCompleteCallbackHandle: Long? = null

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences("com.bbflight.background_downloader.worker_alive_service", MODE_PRIVATE)

        val value = prefs.getLong("callback_handle", -1)
        if (value != -1L) taskCompleteCallbackHandle = value

        flutterLoader = FlutterInjector.instance().flutterLoader()

        if (!flutterLoader.initialized()) {
            flutterLoader.startInitialization(this)
        }

        flutterLoader.ensureInitializationComplete(this, null)
        Log.d("flutter", "WorkerAliveService is Start")
    }

    @SuppressLint("CommitPrefEdits")
    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        when (intent.getStringExtra("action")) {
            "completeTaskCallback" -> {
                val backgroundEngine = FlutterEngine(this)
                DartEntrypoint.createDefault()
                val dartEntrypoint = DartEntrypoint(flutterLoader.findAppBundlePath(), "package:background_downloader/src/background_downloader_callback.dart", "callback")
                val args = mutableListOf<String?>()
                args.add(intent.getStringExtra("value"))
                if (taskCompleteCallbackHandle != null) {
                    args.add(taskCompleteCallbackHandle.toString())
                }
                backgroundEngine.dartExecutor.executeDartEntrypoint(dartEntrypoint, args)
            }
            "registerTaskCompleteCallback" -> {
                val value = intent.getLongExtra("value", -1L)
                if (value != -1L) {
                    taskCompleteCallbackHandle = value
                    prefs.edit().putLong("callback_handle", value).apply()
                }
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        Log.d("flutter", "WorkerAliveService is Destroy")
        prefs.edit().remove("callback_handle").apply()
        super.onDestroy()
    }

}