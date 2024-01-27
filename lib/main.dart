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

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  Future<void> loadSongs() async {
    List<SongModel> songs = await controller.audioQuery.querySongs(
      ignoreCase: true,
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    setState(() {
      allSongs = songs;
      passSongs = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.all(10),
                child: SearchBar(
                  controller: searchController,
                  hintText: 'Search Here',
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
                )),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(5),
                child: ListView.builder(
                  itemCount: allSongs.length,
                  itemBuilder: (BuildContext context, int index) {
                    controller.data = passSongs;
                    return Obx(
                      () => Card(
                        color: allSongs[index].id == controller.playId.value &&
                                controller.audioPlayer.playing
                            ? Colors.deepPurple
                            : Theme.of(context).primaryColor,
                        child: ListTile(
                            onTap: () {
                              if (searchController.text.isEmpty) {
                                if (controller.playId.value !=
                                    allSongs[index].id) {
                                  controller.playsong(
                                      allSongs, allSongs[index].id, index);
                                } else {
                                  Get.to(
                                      () => Player(
                                            data: allSongs,
                                          ),
                                      transition: Transition.downToUp);
                                }
                              } else {
                                int findIndexInPassSongs(String songId) {
                                  for (int i = 0; i < passSongs.length; i++) {
                                    if (passSongs[i].id.toString() == songId) {
                                      return i;
                                    }
                                  }

                                  return -1;
                                }

                                if (controller.playId.value !=
                                    allSongs[index].id) {
                                  controller.playsong(
                                      passSongs,
                                      allSongs[0].id,
                                      findIndexInPassSongs(
                                          allSongs[0].id.toString()));
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
                              nullArtworkWidget: Icon(
                                Icons.music_note_rounded,
                                size: 32,
                              ),
                            ),
                            trailing: controller.playId.value == index &&
                                    controller.isPlaying.value
                                ? IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.play_arrow_rounded,
                                      size: 30,
                                    ))
                                : null,
                            title: Text(allSongs[index].displayNameWOExt)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
