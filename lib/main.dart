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
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // NotificationService.notifInit();
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
                )),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            FutureBuilder<List<SongModel>>(
                future: controller.audioQuery.querySongs(
                  ignoreCase: true,
                  sortType: null,
                  orderType: OrderType.ASC_OR_SMALLER,
                  uriType: UriType.EXTERNAL,
                ),
                builder: ((context, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('You dont have any songs'),
                    );
                  } else {
                    allSongs = snapshot.data!;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: ListView.builder(
                          itemCount: allSongs.length,
                          itemBuilder: (BuildContext context, int index) {
                            controller.data = snapshot.data!;
                            return Obx(
                              () => Card(
                                color: snapshot.data![index].id ==
                                            controller.playId.value &&
                                        controller.audioPlayer.playing
                                    ? Colors.deepPurple
                                    : Theme.of(context).primaryColor,
                                child: ListTile(
                                    onTap: () {
                                      if (controller.playId.value !=
                                          snapshot.data![index].id) {
                                        controller.playsong(snapshot.data!,
                                            snapshot.data![index].id, index);
                                      } else {
                                        Get.to(
                                            () => Player(
                                                  data: snapshot.data!,
                                                  songIndex: index,
                                                ),
                                            transition: Transition.downToUp);
                                      }
                                    },
                                    leading: QueryArtworkWidget(
                                      id: snapshot.data![index].id,
                                      type: ArtworkType.AUDIO,
                                      nullArtworkWidget: Icon(
                                        Icons.music_note_rounded,
                                        size: 32,
                                      ),
                                    ),
                                    trailing:
                                        controller.playId.value == index &&
                                                controller.isPlaying.value
                                            ? IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.play_arrow_rounded,
                                                  size: 30,
                                                ))
                                            : null,
                                    title: Text(snapshot
                                        .data![index].displayNameWOExt)),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                }))
          ],
        ),
      )),
    );
  }
}
