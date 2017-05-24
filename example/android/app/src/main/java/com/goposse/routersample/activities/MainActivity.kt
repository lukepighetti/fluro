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
	private var deepLinkChannel: MethodChannel = MethodChannel(flutterView, Channels.DEEP_LINK_RECEIVED)

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		GeneratedPluginRegistrant.registerWith(this)
		checkForLinkEvent(intent)
	}

	private fun checkForLinkEvent(intent: Intent) {
		val action = intent.action
		Log.d(LOG_TAG, "Hey!!! " + action)
		if (action == Intent.ACTION_VIEW) {
			val data = intent.data
			if (data != null) {
				val path = data.getQueryParameter("path")
				if (path != null) {
					Log.d(LOG_TAG, String.format("Received external link: %s", data.toString()))
					deepLinkChannel!!.invokeMethod("linkReceived", path)
				}
			}
		}
	}
}
