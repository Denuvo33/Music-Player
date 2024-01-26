import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/model/player_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

// ignore: must_be_immutable
class Player extends StatelessWidget {
  final List<SongModel> data;
  int songIndex;
  Player({super.key, required this.data, required this.songIndex});
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Center(
                  child: QueryArtworkWidget(
                artworkClipBehavior: Clip.antiAliasWithSaveLayer,
                id: data[songIndex].id,
                type: ArtworkType.AUDIO,
                artworkHeight: double.infinity,
                artworkWidth: double.infinity,
                nullArtworkWidget: SizedBox(
                    height: 250,
                    width: 250,
                    child: CircleAvatar(
                        child: Icon(
                      Icons.music_note_rounded,
                      size: 100,
                    ))),
              )),
            ),
            Expanded(
              child: Container(
                // color: Colors.red,
                child: Obx(
                  () => Column(
                    children: [
                      Text(
                        data[songIndex].displayNameWOExt,
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(controller.position.value),
                          Expanded(
                              child: Slider(
                                  value: controller.value.value,
                                  thumbColor: Colors.teal,
                                  // inactiveColor: Colors.grey,
                                  // activeColor: Colors.black,
                                  min:
                                      Duration(seconds: 0).inSeconds.toDouble(),
                                  max: controller.max.value,
                                  onChanged: (value) {
                                    controller
                                        .changeDurationToSeconds(value.toInt());
                                    value = value;
                                  })),
                          Text(controller.duration.value)
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: () {
                                if (songIndex == 0) {
                                  songIndex = data.length - 1;
                                  controller.playsong(
                                      data[songIndex].uri!, data[songIndex].id);
                                } else {
                                  songIndex--;
                                  controller.playsong(
                                      data[songIndex].uri!, data[songIndex].id);
                                }
                              },
                              icon: Icon(
                                Icons.skip_previous,
                                size: 50,
                              )),
                          Obx(
                            () => IconButton(
                              onPressed: () {
                                if (controller.isPlaying.value) {
                                  controller.audioPlayer.pause();
                                  controller.isPlaying(false);
                                } else {
                                  controller.audioPlayer.play();
                                  controller.isPlaying(true);
                                }
                              },
                              icon: controller.isPlaying.value &&
                                      data[songIndex].id ==
                                          controller.playId.value
                                  ? Icon(Icons.pause, size: 50)
                                  : Icon(Icons.play_arrow_rounded, size: 50),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                if (songIndex == data.length - 1) {
                                  songIndex = 0;
                                  controller.playsong(
                                      data[songIndex].uri!, data[songIndex].id);
                                } else {
                                  songIndex++;
                                  controller.playsong(
                                      data[songIndex].uri!, data[songIndex].id);
                                }
                              },
                              icon: Icon(Icons.skip_next, size: 50))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
