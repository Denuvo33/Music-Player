import 'package:just_audio/just_audio.dart';

class MusicPlayer {
  final audioPlayer = AudioPlayer();

  void play(String url) async {
    try {
      audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      audioPlayer.play();
    } on Exception catch (e) {
      print('some error here $e');
    }
  }

  void pause() async {}

  void stop() async {}
}
