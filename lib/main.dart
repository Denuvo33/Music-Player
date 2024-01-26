import 'package:get/get.dart';
import 'package:music_player/model/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:music_player/page/details_page.dart';
import 'package:music_player/service/notif_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  @override
  void initState() {
    super.initState();
    NotificationService.notifInit();
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
                  hintText: 'Search Here',
                )),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.all(5),
              child: const SizedBox(
                  height: 80,
                  width: 100,
                  child: Card(
                      color: Colors.green,
                      child: Center(
                          child: Text(
                        'Playlist',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )))),
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
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Obx(
                              () => Card(
                                color: snapshot.data![index].id ==
                                        controller.playId.value
                                    ? Colors.deepPurple
                                    : Theme.of(context).primaryColor,
                                child: ListTile(
                                    onTap: () {
                                      NotificationService.showNotif(
                                          title: 'Music Player',
                                          body: snapshot
                                              .data![index].displayNameWOExt);
                                      if (controller.playId.value !=
                                          snapshot.data![index].id) {
                                        controller.playsong(
                                            snapshot.data![index].uri!,
                                            snapshot.data![index].id);
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
