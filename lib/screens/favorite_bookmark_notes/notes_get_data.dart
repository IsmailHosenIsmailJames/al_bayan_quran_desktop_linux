import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../api/some_api_response.dart';
import '../getx_controller.dart';
import '../surah_view.dart/surah_with_translation.dart';
import '../surah_view.dart/tafseer/tafseer.dart';

int getAyahCountFromStart(int ayahNumber, int surahNumber) {
  for (int i = 0; i < surahNumber; i++) {
    int verseCount = allChaptersInfo[i]['verses_count'];
    ayahNumber += verseCount;
  }
  return ayahNumber;
}

List<Map<String, String>> getNotesData() {
  final notesBox = Hive.box("notes");
  final quranBox = Hive.box("quran");
  final translationBox = Hive.box("translation");
  List<Map<String, String>> notesMapList = [];
  final box = Hive.box("info");

  for (String key in notesBox.keys) {
    if (key.endsWith("note")) {
      String note = notesBox.get(key, defaultValue: null) ?? "";
      String title =
          notesBox.get(key.replaceAll("note", "title"), defaultValue: null) ??
              "";
      String ayahKey = key.replaceAll("note", "");
      String surahNumber = (int.parse(ayahKey.substring(0, 3)) - 1).toString();
      String ayahNumber = (int.parse(ayahKey.substring(3)) - 1).toString();

      String ayahCount =
          getAyahCountFromStart(int.parse(ayahNumber), int.parse(surahNumber))
              .toString();
      final info = box.get("info", defaultValue: false);
      Map<String, dynamic> surahInfo = allChaptersInfo[int.parse(surahNumber)];
      String surahNameSimple = surahInfo['name_simple'];
      String surahNameArabic = surahInfo["name_arabic"];

      String quranAyah = quranBox.get(ayahCount) ?? "";
      String transltionOfAyah =
          translationBox.get("${info["translation_book_ID"]}/$ayahCount") ?? "";

      notesMapList.add({
        "ayahKey": ayahKey,
        "title": title,
        "note": note,
        "name": surahNameSimple,
        "arabicName": surahNameArabic,
        "surahNumber": surahNumber,
        "ayahNumber": ayahNumber,
        "ayahCount": ayahCount,
        "arabicAyah": quranAyah,
        "translation": transltionOfAyah
      });
    }
  }
  return notesMapList;
}

List<Widget> buildListOfWidgetForNotes() {
  final controller = Get.put(ScreenGetxController());

  List<Map<String, String>> list = getNotesData();
  List<Widget> toReturn = [];
  for (int index = 0; index < list.length; index++) {
    toReturn.add(
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          final tafseerBox = await Hive.openBox("tafseer");
          int ayahCountFromStart = getAyahCountFromStart(
              (int.parse(list[index]['ayahNumber'] ?? "0")), 0);
          final infoBox = Hive.box("info");
          final info = infoBox.get("info", defaultValue: false);

          final tafseer =
              tafseerBox.get("${info['tafseer_book_ID']}/$ayahCountFromStart");
          GZipDecoder decoder = GZipDecoder();
          String decodedTafseer =
              utf8.decode(decoder.decodeBytes(base64Decode(tafseer)));
          Get.to(() => TafseerVoiceLess(
                fontS: controller.fontSizeTranslation.value,
                ayahNumber: int.parse(list[index]['ayahNumber'] ?? "0"),
                surahNumber: int.parse(list[index]['surahNumber'] ?? "0"),
                tafseer: decodedTafseer,
              ));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            color: const Color.fromARGB(255, 103, 134, 105).withOpacity(0.1),
          ),
          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
          padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Surah: ${list[index]['name']} - (${int.parse(list[index]["ayahNumber"] ?? "0") + 1} : ${int.parse(list[index]['surahNumber'] ?? "0") + 1})",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    list[index]['arabicName'] ?? "",
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      Get.to(
                        () => SuraView(
                          surahNumber:
                              int.parse(list[index]['surahNumber'] ?? "0"),
                          surahName: list[index]['name'],
                          scrollToAyah:
                              int.parse(list[index]["ayahNumber"] ?? "0") + 1,
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
              const Divider(),
              Container(
                alignment: Alignment.topRight,
                child: Obx(
                  () => Text(
                    list[index]['arabicAyah'] ?? "",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: controller.fontSizeArabic.value,
                    ),
                  ),
                ),
              ),
              const Divider(),
              Obx(
                () => Text(
                  list[index]['translation'] ?? "",
                  style: TextStyle(
                    fontSize: controller.fontSizeTranslation.value,
                  ),
                ),
              ),
              const Divider(),
              const Center(
                child: Text(
                  "Notes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const Divider(),
              Text(
                list[index]['title'] ?? "",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Text(list[index]['note'] ?? ""),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
  return toReturn;
}
