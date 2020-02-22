package com.goposse.fluro.activities

import android.content.Intent
import android.os.Bundle
import android.util.Log

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

	private val logTag = "A:Main"

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		GeneratedPluginRegistrant.registerWith(this)
		checkForLinkEvent(intent)
	}

	private fun checkForLinkEvent(intent: Intent) {
		val data = intent.data
		if (intent.action == Intent.ACTION_VIEW && data != null) {
			val path = data.getQueryParameter("path")
			val text = data.getQueryParameter("message") ?: "Why you don't enter text?"
			if (path != null) {
				Log.d(logTag, "Setting initial route to: $path?message=$text")
				flutterView.setInitialRoute("$path?message=$text")
			}
		}
	}
}
