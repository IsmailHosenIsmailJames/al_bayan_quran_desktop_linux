import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../api/colors_tazweed.dart';
import '../../api/some_api_response.dart';
import '../../core/show_twoested_message.dart';
import '../../theme/theme_controller.dart';
import '../getx_controller.dart';
import '../settings/settings.dart';
import 'notes/notes.dart';
import 'tafseer/tafseer.dart';

class SuraView extends StatefulWidget {
  final int surahNumber;
  final String? surahName;
  final int? start;
  final int? end;
  final int? scrollToAyah;
  const SuraView(
      {super.key,
      required this.surahNumber,
      this.start,
      this.end,
      this.surahName,
      this.scrollToAyah});

  @override
  State<SuraView> createState() => _SuraViewState();
}

class _SuraViewState extends State<SuraView> {
  late int totalAyahInSuarh;
  late String? surahNameSimple;
  late String? surahNameArabic;
  late String? relavencePlace;

  List<int> listOfAyah = [];
  List<GlobalKey> listOfkey = [];
  List<String> bookmarkSurahKey = [];
  List<String> favoriteSurahKey = [];

  @override
  void initState() {
    totalAyahInSuarh = allChaptersInfo[widget.surahNumber]['verses_count'];
    surahNameSimple = allChaptersInfo[widget.surahNumber]['name_simple'];
    surahNameArabic = allChaptersInfo[widget.surahNumber]['name_arabic'];
    relavencePlace = allChaptersInfo[widget.surahNumber]['revelation_place'];
    int start = widget.start ?? 0;
    int end = widget.end ?? allChaptersInfo[widget.surahNumber]['verses_count'];
    for (int i = start; i < end; i++) {
      listOfAyah.add(i);
      listOfkey.add(GlobalKey());
    }

    final box = Hive.box("info");
    final bookmark = box.get("bookmark", defaultValue: false);
    if (bookmark != false) {
      bookmarkSurahKey = bookmark;
    }

    final favo = box.get("favorite", defaultValue: false);
    if (favo != false) {
      favoriteSurahKey = favo;
    }

    if (widget.scrollToAyah != null) scrollToAyahInit(widget.scrollToAyah!);
    super.initState();
  }

  void scrollToAyahInit(int ayah) async {
    for (int i = 1; i < ayah; i++) {
      await Future.delayed(const Duration(milliseconds: 5));

      if (listOfkey[i].currentContext != null) {
        await Scrollable.ensureVisible(
          listOfkey[i].currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
  }

  final controller = Get.put(ScreenGetxController());
  bool isPlaying = false;
  int playingIndex = -1;
  bool isLoading = false;
  bool showFloatingControllers = false;
  bool expandFloatingControllers = true;
  bool playFromStart = true;
  int currentPlayingAyah = 0;
  int maxAyahToPlay = 0;

  int getAyahCountFromStart(int ayahNumber) {
    for (int i = 0; i < widget.surahNumber; i++) {
      int verseCount = allChaptersInfo[i]['verses_count'];
      ayahNumber += verseCount;
    }
    return ayahNumber;
  }

  void showInfomationOfSurah() async {
    final quranInfoBox = await Hive.openBox("quran_info");
    final infoBox = Hive.box("info");
    final info = infoBox.get("info", defaultValue: false);

    final quranInformation = quranInfoBox.get(
        "info_${info["translation_book_ID"]}/${widget.surahNumber + 1}/text",
        defaultValue: false);
    String text = "";
    String shortText = "";
    String source = "";

    if (quranInformation != false) {
      GZipDecoder decoder = GZipDecoder();
      text = utf8
          .decode(decoder.decodeBytes(base64Decode(quranInformation["text"])));
      shortText = quranInformation['short_text'];
      source = quranInformation['source'];
    }
    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.90,
          minChildSize: 0.25,
          maxChildSize: 1,
          builder: (context, scrollController) {
            return Obx(
              () => ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Text(
                    "Source",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    source,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(
                    thickness: 3,
                  ),
                  const Text(
                    "Summary",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    shortText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(
                    thickness: 3,
                  ),
                  Text(
                    "In Detail",
                    style: TextStyle(
                      fontSize: controller.fontSizeTranslation.value,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  HtmlWidget(
                    text,
                    textStyle: TextStyle(
                      fontSize: controller.fontSizeTranslation.value,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            );
          },
        );
      },
      isScrollControlled: true,
    );
  }

  Future<String> showTafseerOfAyah(
      int ayahNumber, String? surahName, bool goRoute) async {
    final tafseerBox = await Hive.openBox("tafseer");
    int ayahCountFromStart = getAyahCountFromStart(ayahNumber - 1);
    final infoBox = Hive.box("info");
    final info = infoBox.get("info", defaultValue: false);

    final tafseer =
        tafseerBox.get("${info['tafseer_book_ID']}/$ayahCountFromStart");
    GZipDecoder decoder = GZipDecoder();
    String decodedTafseer =
        utf8.decode(decoder.decodeBytes(base64Decode(tafseer)));

    if (goRoute) {
      Get.to(() => TafseerVoiceLess(
            fontS: controller.fontSizeTranslation.value,
            surahName: surahName,
            ayahNumber: ayahNumber,
            surahNumber: widget.surahNumber,
            tafseer: decodedTafseer,
          ));
    }
    return decodedTafseer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  setState(() {
                    playFromStart = true;
                    isPlaying = false;
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 30,
                ),
              ),
              Text(
                widget.surahName ?? "",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Hive.openBox(quranScriptType);
                  showModalBottomSheet(
                    // ignore: use_build_context_synchronously
                    context: context,
                    useSafeArea: true,
                    builder: (context) {
                      return DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.90,
                        minChildSize: 0.25,
                        maxChildSize: 1,
                        builder: (context, scrollController) {
                          return const Settings(
                            showNavigator: true,
                          );
                        },
                      );
                    },
                    isScrollControlled: true,
                  );
                },
                icon: const Icon(
                  color: Colors.green,
                  Icons.settings,
                ),
              )
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: listOfWidgetOfAyah(listOfAyah.length + 1),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> listOfWidgetOfAyah(int length) {
    List<Widget> listAyahWidget = [];

    int firstAyahNumber = getAyahCountFromStart(0);

    for (int index = 0; index < length; index++) {
      {
        if (index == 0) {
          String relevancePlace =
              allChaptersInfo[widget.surahNumber]['revelation_place'];
          int ayahNumber = allChaptersInfo[widget.surahNumber]['verses_count'];
          listAyahWidget.add(Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(15, 120, 120, 120),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    height: 150,
                    width: 150,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(relevancePlace == 'makkah'
                            ? "assets/img/makkah.jpg"
                            : "assets/img/madina.jpeg"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Revelation Place",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      relavencePlace![0].toUpperCase() +
                          relevancePlace.substring(1),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$ayahNumber Ayahs",
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: showInfomationOfSurah,
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.green,
                            ),
                          ),
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ));
        } else {
          final translation = Hive.box("translation");
          final quran = Hive.box('quran');
          int ayahNumber = listOfAyah[index - 1];
          final infoBox = Hive.box("info");
          final info = infoBox.get("info", defaultValue: false);

          String arbicAyah = quran.get("${ayahNumber + firstAyahNumber}");
          String ayahTranslation = translation.get(
              "${info["translation_book_ID"]}/${firstAyahNumber + listOfAyah[index - 1]}",
              defaultValue: "No Found");
          String bookName = "";
          for (var element in allTranslationLanguage) {
            if (element['id'].toString() == info['translation_book_ID']) {
              bookName = element['name'];
            }
          }
          String surahNumber = widget.surahNumber.toString();
          if (surahNumber.length == 1) {
            surahNumber = "00$surahNumber";
          } else if (surahNumber.length == 2) {
            surahNumber = "0$surahNumber";
          }
          String ayahNumberString = ayahNumber.toString();
          if (ayahNumberString.length == 1) {
            ayahNumberString = "00$ayahNumberString";
          } else if (ayahNumberString.length == 2) {
            ayahNumberString = "0$ayahNumberString";
          }
          String ayahKey = "$surahNumber:$ayahNumberString";

          listAyahWidget.add(
            Container(
              key: listOfkey[index - 1],
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(15, 120, 120, 120),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            const Color.fromARGB(180, 134, 134, 134),
                        child: Text(
                          (listOfAyah[index - 1] + 1).toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton(
                        onSelected: (value) async {
                          if (value == "copy" || value == "copyWithTafseer") {
                            String allToCopy =
                                "${widget.surahName} ( ${widget.surahNumber + 1} : ${ayahNumber + 1} )\n\n$arbicAyah\n\n$ayahTranslation";

                            if (value == "copy") {
                              FlutterClipboard.copy(allToCopy);
                            }

                            allToCopy +=
                                "\n\n${await showTafseerOfAyah(index, surahNameArabic, false)}";
                            FlutterClipboard.copy(allToCopy);
                          }
                          if (value == 'note') {
                            await Hive.openBox("notes");
                            Get.to(() => Notes(
                                  surahNumber: widget.surahNumber,
                                  ayahNumber: ayahNumber,
                                  surahName: widget.surahName,
                                ));
                          }

                          if (value == "bookmark") {
                            infoBox.put("bookmarkUploaded", false);
                            if (!(bookmarkSurahKey.contains(ayahKey))) {
                              setState(() {
                                bookmarkSurahKey.add(ayahKey);
                              });
                              final infoBox = Hive.box("info");
                              infoBox.put(value, bookmarkSurahKey);
                              showTwoestedMessage("Added to Book Mark");
                            } else {
                              setState(() {
                                bookmarkSurahKey.remove(ayahKey);
                              });
                              final infoBox = Hive.box("info");
                              infoBox.put(value, bookmarkSurahKey);
                              showTwoestedMessage("Removed from Book Mark");
                            }
                          }
                          if (value == "favorite") {
                            infoBox.put("favoriteUploaded", false);
                            if (!(favoriteSurahKey.contains(ayahKey))) {
                              setState(() {
                                favoriteSurahKey.add(ayahKey);
                              });
                              final infoBox = Hive.box("info");
                              infoBox.put(value, favoriteSurahKey);
                              showTwoestedMessage("Added to favorite");
                            } else {
                              setState(() {
                                favoriteSurahKey.remove(ayahKey);
                              });
                              final infoBox = Hive.box("info");
                              infoBox.put(value, favoriteSurahKey);
                              showTwoestedMessage("Removed from favorite");
                            }
                          }
                          if (value == 'tafsir') {
                            showTafseerOfAyah(index, surahNameArabic, true);
                          }
                        },
                        icon: const Icon(
                          Icons.more_horiz,
                        ),
                        itemBuilder: (BuildContext bc) {
                          return [
                            const PopupMenuItem(
                              value: 'tafsir',
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.bookOpen,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('See Tafsir'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'favorite',
                              child: Row(
                                children: [
                                  favoriteSurahKey.contains(ayahKey)
                                      ? const Icon(
                                          Icons.favorite,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.favorite_border,
                                          color: Colors.grey,
                                        ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(favoriteSurahKey.contains(ayahKey)
                                      ? "Remove Favorite"
                                      : "Add Favorite"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'note',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.note_add,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Notes"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'bookmark',
                              child: Row(
                                children: [
                                  bookmarkSurahKey.contains(ayahKey)
                                      ? const Icon(
                                          Icons.bookmark_added_rounded,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.bookmark,
                                          color: Colors.grey,
                                        ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(bookmarkSurahKey.contains(ayahKey)
                                      ? "Remove BookMark"
                                      : "Add BookMark"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'copy',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.copy,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Copy"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'copyWithTafseer',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.copy,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Copy With Tafsser"),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      showTafseerOfAyah(index, surahNameArabic, true);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child: Obx(
                            () => buildArabicText(
                                controller.quranScriptTypeGetx.value,
                                "${ayahNumber + firstAyahNumber}",
                                ayahNumber),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Translation : $bookName",
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Obx(
                          () => Text(
                            ayahTranslation,
                            style: TextStyle(
                              fontSize: controller.fontSizeTranslation.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
    return listAyahWidget;
  }

  Widget buildArabicText(String styleType, String ayahKey, int ayahNumber) {
    final box = Hive.box(styleType);
    if (styleType == "quran_tajweed") {
      return getTazweedTexSpan(
        box.get(ayahKey, defaultValue: ""),
      );
    }
    return Obx(
      () {
        return Text(
          box.get(ayahKey, defaultValue: ""),
          style: TextStyle(
            fontSize: controller.fontSizeArabic.value,
          ),
          textAlign: TextAlign.right,
        );
      },
    );
  }

  Widget getTazweedTexSpan(String ayah) {
    List<Map<String, String?>> tazweeds = extractWordsGetTazweeds(ayah);
    List<InlineSpan> spanText = [];
    for (Map<String, String?> taz in tazweeds) {
      String word = taz['word'] ?? "";
      String className = taz['class'] ?? "null";
      String tag = taz['tag'] ?? "null";
      if (className == 'null' || tag == "null") {
        spanText.add(
          TextSpan(text: word),
        );
      } else {
        if (className == "end") {
        } else {
          Color textColor = colorsForTazweed[className] ??
              const Color.fromARGB(255, 121, 85, 72);
          spanText.add(
            TextSpan(
              text: word,
              style: TextStyle(
                color: textColor,
              ),
            ),
          );
        }
      }
    }
    return Obx(
      () => Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: controller.fontSizeArabic.value,
          ),
          children: spanText,
        ),
      ),
    );
  }
}
