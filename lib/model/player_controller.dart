import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();

  var playId = 0.obs;
  var isPlaying = false.obs;
  var duration = ''.obs;
  var position = ''.obs;
  var max = 0.0.obs;
  var value = 0.0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    askPermission();
  }

  updatePosition() {
    audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split('.')[0];
      value.value = p.inSeconds.toDouble();
    });
    audioPlayer.durationStream.listen((d) {
      duration.value = d.toString().split('.')[0];
      max.value = d!.inSeconds.toDouble();
    });
  }

  changeDurationToSeconds(seconds) {
    var duration = Duration(seconds: seconds);
    audioPlayer.seek(duration);
  }

  playsong(String url, songId) {
    playId.value = songId;
    try {
      audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
        ),
      );
      audioPlayer.play();
      isPlaying(true);
      updatePosition();
    } on Exception catch (e) {
      print('error is $e');
    }
  }

  askPermission() async {
    var perm = await Permission.storage.request();
    var notif = await Permission.notification.request();

    if (notif.isGranted) {
    } else {
      askPermission();
    }

    if (perm.isGranted) {
    } else {
      askPermission();
    }
  }
}
