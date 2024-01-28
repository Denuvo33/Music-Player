import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();
  var playId = 0.obs;
  var playIndex = 0;
  var isPlaying = false.obs;
  var duration = ''.obs;
  var position = ''.obs;
  var max = 0.0.obs;
  var currentSongIndex = 0.obs;
  var value = 0.0.obs;
  List<SongModel> data = [];
  List<AudioSource> allSongs = [];
  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    await askPermission();
    askNotifPermission();
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
    audioPlayer.currentIndexStream.listen((i) {
      currentSongIndex.value = i!;
      playId.value = data[currentSongIndex.value].id;
    });
  }

  changeDurationToSeconds(seconds) {
    var duration = Duration(seconds: seconds);
    audioPlayer.seek(duration);
  }

  playsong(List<SongModel> songModel, songId, int songIndex) {
    playId.value = songId;
    allSongs = [];
    songModel.forEach((element) {
      allSongs.add(AudioSource.uri(Uri.parse(element.uri!),
          tag: MediaItem(
            id: '${element.id}',
            album: '${element.album}',
            title: element.displayNameWOExt,
            // artUri: Uri.parse('https://example.com/albumart.jpg')),
          )));
    });
    // Define the playlist
    final playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the playlist items
      children: allSongs,
    );
    try {
      audioPlayer.setAudioSource(playlist,
          initialIndex: songIndex, initialPosition: Duration.zero);
      audioPlayer.play();
      isPlaying(true);
      updatePosition();
    } on Exception catch (e) {
      print('error is $e');
    }
  }

  askPermission() async {
    var perm = await Permission.storage.request();

    if (perm.isGranted) {
    } else {
      askPermission();
    }
  }

  askNotifPermission() async {
    var notif = await Permission.notification.request();

    if (notif.isGranted) {
    } else {
      askPermission();
    }
  }
}
