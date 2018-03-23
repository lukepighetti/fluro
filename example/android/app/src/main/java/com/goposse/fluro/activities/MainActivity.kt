package com.goposse.fluro.activities

import android.content.Intent
import android.os.Bundle
import android.util.Log

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

	private val LOG_TAG = "A:Main"

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		GeneratedPluginRegistrant.registerWith(this)
		checkForLinkEvent(intent)
	}

	override fun onResume() {
		super.onResume()
	}

	private fun checkForLinkEvent(intent: Intent) {
		if (intent.action == Intent.ACTION_VIEW && intent.data != null) {
			val path = intent.data.getQueryParameter("path")
			val text = intent.data.getQueryParameter("message") ?: "Why you don't enter text?"
			if (path != null) {
				Log.d(LOG_TAG, "Setting initial route to: $path?message=$text")
				flutterView.setInitialRoute("$path?message=$text")
			}
		}
	}
}
