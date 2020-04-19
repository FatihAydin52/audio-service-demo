import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:audio_service/audio_service.dart';
import 'package:example/audio_player_task.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';


void shutDownAudioService() async {
  await AudioService.connect();
  if (AudioService.running) {
    AudioService.stop();
  }
}
void _audioPlayerTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

  AndroidAlarmManager.initialize();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AudioServiceWidget(child: MainScreen()),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ScreenState>(
        stream: _screenStateStream,
        builder: (context, snapshot) {
          final screenState = snapshot.data;
          final queue = screenState?.queue;
          final mediaItem = screenState?.mediaItem;
          final state = screenState?.playbackState;
          final basicState = state?.basicState ?? BasicPlaybackState.none;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (queue != null && queue.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      iconSize: 64.0,
                      onPressed: mediaItem == queue.first ? null : AudioService.skipToPrevious,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      iconSize: 64.0,
                      onPressed: mediaItem == queue.last ? null : AudioService.skipToNext,
                    ),
                  ],
                ),
              if (mediaItem?.title != null) Text(mediaItem.title),
              if (basicState == BasicPlaybackState.none) ...[
                audioPlayerButton(),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (basicState == BasicPlaybackState.playing)
                      pauseButton()
                    else if (basicState == BasicPlaybackState.paused)
                      playButton()
                    else if (basicState == BasicPlaybackState.buffering || basicState == BasicPlaybackState.skippingToNext || basicState == BasicPlaybackState.skippingToPrevious)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 64.0,
                          height: 64.0,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    stopButton(),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  RaisedButton audioPlayerButton() => startButton(
    'AudioPlayer',
        () {
      AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntryPoint,
        androidNotificationChannelName: 'Audio Service Demo',
        notificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        enableQueue: true,
      );

      AndroidAlarmManager.oneShot(Duration(seconds: 30), 0, shutDownAudioService);
      print("Audio Service will shut down after 30 seconds.");
    },
  );


  RaisedButton startButton(String label, VoidCallback onPressed) =>
      RaisedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
    icon: Icon(Icons.play_arrow),
    iconSize: 64.0,
    onPressed: AudioService.play,
  );

  IconButton pauseButton() => IconButton(
    icon: Icon(Icons.pause),
    iconSize: 64.0,
    onPressed: AudioService.pause,
  );

  IconButton stopButton() => IconButton(
    icon: Icon(Icons.stop),
    iconSize: 64.0,
    onPressed: AudioService.stop,
  );


  Stream<ScreenState> get _screenStateStream => Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
      AudioService.queueStream, AudioService.currentMediaItemStream, AudioService.playbackStateStream, (queue, mediaItem, playbackState) => ScreenState(queue, mediaItem, playbackState));
}

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}
