package com.goposse.routersample.activities

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log

import com.goposse.routersample.constants.Channels

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

	private val LOG_TAG = "A:Main"
	private var deepLinkChannel: MethodChannel? = null

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		GeneratedPluginRegistrant.registerWith(this)
		deepLinkChannel = MethodChannel(flutterView, Channels.DEEP_LINK_RECEIVED)
		checkForLinkEvent(intent)
	}

	private fun checkForLinkEvent(intent: Intent) {
		if (intent.action == Intent.ACTION_VIEW && intent.data != null) {
			val path = intent.data.getQueryParameter("path")
			if (path != null) {
				deepLinkChannel?.invokeMethod("linkReceived", path)
			}
		}
	}
}
