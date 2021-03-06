package example.com.example;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

  @Override
  public FlutterEngine provideFlutterEngine(Context context) {
    // Instantiate a FlutterEngine.
    FlutterEngine flutterEngine = new FlutterEngine(context.getApplicationContext());

    // Start executing Dart code to pre-warm the FlutterEngine.
    flutterEngine.getDartExecutor().executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
    );

    return flutterEngine;
  }
}
