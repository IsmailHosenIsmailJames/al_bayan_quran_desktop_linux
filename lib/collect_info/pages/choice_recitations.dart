// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';

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

  late List<String> allRecitationSearch = [];
  bool isPlaying = false;

  @override
  void initState() {
    allRecitationSearch.addAll(allRecitation);
    player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed &&
          player.currentIndex! >= 6) {
        setState(() {
          playingIndex = -1;
        });
      }
      setState(() {
        isPlaying = event.playing;
      });
    });
    if (widget.previousInfo != null) {
      Map<String, String> temInfo = widget.previousInfo!;
      int index = allRecitationSearch.indexOf(temInfo['recitation_ID'] ?? "");
      if (index != -1) {
        infoController.recitationIndex.value = index;
        infoController.recitationName.value = allRecitationSearch[index];
      }
    }
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

    List<AudioSource> audioResourceSource = [];
    for (int i = 0; i < 7; i++) {
      audioResourceSource.add(AudioSource.uri(Uri.parse(listUrl[i])));
    }
    final playlist = ConcatenatingAudioSource(
      shuffleOrder: DefaultShuffleOrder(),
      children: audioResourceSource,
    );
    await player.setAudioSource(playlist,
        initialIndex: 0, initialPosition: Duration.zero);
    await Future.delayed(const Duration(milliseconds: 100));
    await player.play();
  }

  void resumeOrPuseAudio(bool isPlay) {
    if (isPlay) {
      player.play();
    } else {
      player.pause();
    }
  }

  AudioPlayer player = AudioPlayer();

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
