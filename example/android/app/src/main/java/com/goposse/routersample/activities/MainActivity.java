package com.goposse.routersample.activities;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import com.goposse.routersample.constants.Channels;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.PluginRegistry;

public class MainActivity extends FlutterActivity {

    private static final String LOG_TAG = "A:Main";

    PluginRegistry pluginRegistry;
    private static MethodChannel deepLinkChannel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        pluginRegistry = new PluginRegistry();
        pluginRegistry.registerAll(this);

        if (deepLinkChannel == null) {
            deepLinkChannel = new MethodChannel(getFlutterView(), Channels.DEEP_LINK_RECEIVED);
        }

        Intent intent = getIntent();
        checkForLinkEvent(intent);
    }

    private void checkForLinkEvent(Intent intent) {
        String action = intent.getAction();
        Log.d(LOG_TAG, "Hey!!! " + action);
        if (action.equals(Intent.ACTION_VIEW)) {
            Uri data = intent.getData();
            if (data != null) {
                String path = data.getQueryParameter("path");
                if (path != null) {
                    Log.d(LOG_TAG, String.format("Received external link: %s", data.toString()));
                    deepLinkChannel.invokeMethod("linkReceived", path);
                }
            }
        }
    }

}
