import 'package:audio_service/audio_service.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/providers/music_controller_provider.dart';

 Future<AudioHandler> initAudioService() async {
      return await AudioService.init(
        builder: () => MyAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.mycompany.myapp.audio',
          androidNotificationChannelName: 'panaudio',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
    }

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler{

  MusicController controller = MusicController();

   Future<void> play() async {
    controller.playPause(true, false);
    controller.getQueue();
   // MusicControllerProvider.of().playPause(true, false);
    // All 'play' requests from all origins route to here. Implement this
    // callback to start playing audio appropriate to your app. e.g. music.
  }
  Future<void> pause() async {
    controller.playPause(true, false);
    controller.getQueue();
  }
  Future<void> stop() async {}
  Future<void> seek(Duration position) async {}
  Future<void> skipToQueueItem(int i) async {}
}