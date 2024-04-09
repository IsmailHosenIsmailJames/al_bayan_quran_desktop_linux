import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../api/all_recitation.dart';
import '../getx/get_controller.dart';

class RecitaionChoice extends StatefulWidget {
  final Map<String, String>? previousInfo;
  const RecitaionChoice({super.key, this.previousInfo});

  @override
  State<RecitaionChoice> createState() => _RecitaionChoiceState();
}

class _RecitaionChoiceState extends State<RecitaionChoice> {
  final infoController = Get.put(InfoController());
  AudioPlayer player = AudioPlayer();

  late List<String> allRecitationSearch = [];
  bool isPlaying = false;
  bool isPaused = false;
  int playingAyahIndex = 0;
  int maxPlayingIndex = 6;

  @override
  void initState() {
    allRecitationSearch.addAll(allRecitation);
    if (widget.previousInfo != null) {
      Map<String, String> temInfo = widget.previousInfo!;
      int index = allRecitationSearch.indexOf(temInfo['recitation_ID'] ?? "");
      if (index != -1) {
        infoController.recitationIndex.value = index;
        infoController.recitationName.value = allRecitationSearch[index];
      }
    }
    player.onPlayerComplete.listen((event) {
      setState(() {
        playingAyahIndex++;
      });
      if (playingAyahIndex <= maxPlayingIndex) {
        player.play(UrlSource(listUrl[playingAyahIndex]));
      } else {
        setState(() {
          playingIndex = -1;
          playingAyahIndex = 0;
        });
      }
    });
    setValue();
    super.initState();
  }

  void search(String s) {
    setState(() {
      allRecitationSearch = allRecitation.where((element) {
        return element.toLowerCase().contains(s.toLowerCase());
      }).toList();
    });
    select();
  }

  void select() {
    infoController.recitationIndex.value =
        allRecitationSearch.indexOf(infoController.recitationName.value);
    if (widget.previousInfo != null) {
      Map<String, String> temInfo = widget.previousInfo!;
      temInfo["recitation_ID"] = infoController.recitationName.value;
      final temInfoBox = Hive.box("info");
      temInfoBox.put("info", temInfo);
    }
  }

  List<String> listUrl = [];

  void playResource(String url, int ayahCount) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (!(connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile))) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("No Internet Connection"),
          content: const Text(
              "We need to download audio data from server.\nMake sure you are connected with internet."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        playingAyahIndex = 0;
      });
      listUrl = [];
      setState(() {
        listUrl;
      });
      for (int i = 1; i <= 7; i++) {
        listUrl.add("$url/00100$i.mp3");
      }
      setState(() {
        listUrl;
      });
      player.play(UrlSource(listUrl[playingAyahIndex]));
    }
  }

  void resumeOrPuseAudio(bool isPlay) {
    if (isPlay) {
      player.resume();
      setState(() {
        isPaused = false;
      });
    } else {
      player.pause();
      setState(() {
        isPaused = true;
      });
    }
  }

  String getBaseURLOfAudio(int value) {
    String recitor = allRecitationSearch[value];
    List<String> splited = recitor.split("(");
    String urlID = splited[1].replaceAll(")", "");
    String audioBaseURL = "https://everyayah.com/data/$urlID";
    return audioBaseURL;
  }

  int playingIndex = -1;

  void setValue() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    );
    infoController.isPreviousEnaviled.value = true;
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choice Recitation",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 5.0, right: 5, bottom: 2, top: 2),
            child: TextFormField(
              autofocus: false,
              onChanged: (value) => search(value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: 100, top: 10, left: 1, right: 1),
              itemCount: allRecitationSearch.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    int value = index;
                    infoController.recitationName.value =
                        allRecitationSearch[value];
                    select();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(10, 145, 255, 160),
                    ),
                    child: ListTile(
                      titleAlignment: ListTileTitleAlignment.center,
                      title: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              child: IconButton(
                                onPressed: () async {
                                  if (playingIndex != index) {
                                    setState(() {
                                      playingIndex = index;
                                      String url = getBaseURLOfAudio(index);
                                      playResource(url, 7);
                                    });
                                  } else {
                                    setState(() {
                                      playingIndex = -1;
                                    });
                                    resumeOrPuseAudio(false);
                                  }
                                },
                                icon: Icon(
                                  playingIndex == index
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.green.shade600,
                                  size: 30,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(60, 126, 126, 126),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allRecitationSearch[index],
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      leading: Obx(
                        () => Radio(
                          activeColor: Colors.green,
                          value: index,
                          groupValue: infoController.recitationIndex.value,
                          onChanged: (value) {
                            infoController.recitationName.value =
                                allRecitationSearch[value!];
                            select();
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
