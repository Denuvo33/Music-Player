import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/model/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:music_player/page/details_page.dart';
import 'package:on_audio_query/on_audio_query.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData.dark(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var controller = Get.put(PlayerController());
  List<SongModel> allSongs = [];
  List<SongModel> passSongs = [];
  TextEditingController searchController = TextEditingController();
  FocusNode myfocus = FocusNode();
  bool songIsStart = false;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    allSongs = [];
    passSongs = [];
    List<SongModel> songs = await controller.audioQuery.querySongs(
      ignoreCase: true,
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    songs = songs
        .where((song) =>
            song.displayName.toLowerCase().endsWith('.mp3') &&
            song.duration! > Duration(minutes: 1).inMilliseconds)
        .toList();

    setState(() {
      allSongs = songs;
      passSongs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: SearchBar(
                controller: searchController,
                onTap: () {
                  myfocus.requestFocus();
                },
                hintText: 'Search Here',
                trailing: [
                  if (searchController.text.isNotEmpty)
                    IconButton(
                        onPressed: () {
                          searchController.clear();
                          myfocus.unfocus();
                          loadSongs();
                        },
                        icon: Icon(Icons.clear))
                ],
                focusNode: myfocus,
                onChanged: (query) {
                  setState(() {
                    if (query.isEmpty) {
                      loadSongs();
                    } else {
                      allSongs = controller.data.where((song) {
                        var searcher = song.displayNameWOExt
                            .toLowerCase()
                            .contains(query.toLowerCase());

                        return searcher;
                      }).toList();
                    }
                  });
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 60,
              width: 100,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [Colors.teal, Colors.blueGrey],
                ),
              ),
              child: Center(
                  child: Text(
                'Total Songs \n ${passSongs.length}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              )),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(5),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: allSongs.length,
                      itemBuilder: (BuildContext context, int index) {
                        controller.data = passSongs;
                        return Obx(
                          () => Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  if (searchController.text.isEmpty) {
                                    if (controller.playId.value !=
                                        allSongs[index].id) {
                                      controller.playsong(
                                          allSongs, allSongs[index].id, index);
                                      setState(() {
                                        songIsStart = true;
                                      });
                                    } else {
                                      myfocus.unfocus();
                                      Get.to(
                                          () => Player(
                                                data: passSongs,
                                              ),
                                          transition: Transition.downToUp);
                                    }
                                  } else {
                                    int findIndexInPassSongs(String songId) {
                                      for (int i = 0;
                                          i < passSongs.length;
                                          i++) {
                                        if (passSongs[i].id.toString() ==
                                            songId) {
                                          return i;
                                        }
                                      }

                                      return -1;
                                    }

                                    if (controller.playId.value !=
                                        allSongs[index].id) {
                                      controller.playsong(
                                          passSongs,
                                          allSongs[index].id,
                                          findIndexInPassSongs(
                                              allSongs[index].id.toString()));
                                      setState(() {
                                        songIsStart = true;
                                      });
                                    } else {
                                      Get.to(
                                          () => Player(
                                                data: passSongs,
                                              ),
                                          transition: Transition.downToUp);
                                    }
                                  }
                                },
                                leading: QueryArtworkWidget(
                                  id: allSongs[index].id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.blueGrey,
                                              Colors.grey
                                            ]),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: const Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                trailing: controller.playId.value == index &&
                                        controller.isPlaying.value
                                    ? IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.play_arrow_rounded,
                                          size: 30,
                                        ))
                                    : null,
                                title: Text(
                                  allSongs[index].displayNameWOExt,
                                  style: TextStyle(
                                      color: allSongs[index].id ==
                                                  controller.playId.value &&
                                              controller.audioPlayer.playing
                                          ? Colors.red
                                          : Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle:
                                    Text(allSongs[index].album.toString()),
                              ),
                              const SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    Visibility(
                      visible: songIsStart,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => Player(data: passSongs),
                              transition: Transition.downToUp);
                        },
                        child: Container(
                          height: 70,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.topRight,
                                  colors: [Colors.grey, Colors.blueGrey]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          margin: const EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              if (songIsStart)
                                QueryArtworkWidget(
                                  id: controller
                                      .data[controller.currentSongIndex.value]
                                      .id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Icon(
                                    Icons.music_note_rounded,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              SizedBox(
                                width: 15,
                              ),
                              if (songIsStart)
                                Obx(
                                  () => Flexible(
                                    child: Text(
                                      controller
                                          .data[
                                              controller.currentSongIndex.value]
                                          .displayNameWOExt,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              Obx(
                                () => IconButton(
                                    onPressed: () {
                                      if (controller.isPlaying.value) {
                                        controller.audioPlayer.pause();
                                        setState(() {
                                          controller.isPlaying(false);
                                        });
                                      } else {
                                        controller.audioPlayer.play();
                                        setState(() {
                                          controller.isPlaying(true);
                                        });
                                      }
                                    },
                                    icon: controller.isPlaying.value
                                        ? const Icon(
                                            Icons.pause_outlined,
                                            size: 50,
                                          )
                                        : const Icon(
                                            Icons.play_arrow_rounded,
                                            size: 50,
                                          )),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
