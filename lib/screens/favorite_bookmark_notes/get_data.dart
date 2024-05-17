import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../api/some_api_response.dart';
import '../getx_controller.dart';
import '../surah_view.dart/surah_with_translation.dart';
import '../surah_view.dart/tafseer/tafseer.dart';

List<Map<String, String>> getAllFavoriteWithData(String name) {
  final box = Hive.box("info");
  final tem = box.get(name, defaultValue: false);
  if (tem == false) {
    return [];
  } else {
    final quran = Hive.box('quran');
    List<Map<String, String>> toReturn = [];
    List<String> myFavorite = tem;
    final translation = Hive.box("translation");
    final info = box.get("info", defaultValue: false);

    for (String ayahKey in myFavorite) {
      List<String> splitedAyahKey = ayahKey.split(":");
      int surahNumber = int.parse(splitedAyahKey[0]);
      int ayahNumber = int.parse(splitedAyahKey[1]);
      Map<String, dynamic> surahInfo = allChaptersInfo[surahNumber];
      String surahNameSimple = surahInfo['name_simple'];
      String surahNameArabic = surahInfo["name_arabic"];
      String arbicAyah =
          quran.get("${getAyahCountFromStart(ayahNumber, surahNumber)}");
      String ayahTranslation = translation.get(
          "${info["translation_book_ID"]}/${getAyahCountFromStart(ayahNumber, surahNumber)}");
      toReturn.add({
        "name": surahNameSimple,
        "arabicName": surahNameArabic,
        "surahNumber": surahNumber.toString(),
        "ayahNumber": ayahNumber.toString(),
        "ayahKey": ayahKey,
        "arabicAyah": arbicAyah,
        "translation": ayahTranslation,
      });
    }
    return toReturn;
  }
}

int getAyahCountFromStart(int ayahNumber, int surahNumber) {
  for (int i = 0; i < surahNumber; i++) {
    int verseCount = allChaptersInfo[i]['verses_count'];
    ayahNumber += verseCount;
  }
  return ayahNumber;
}

List<Widget> buildWidgetForFavBook(String name) {
  List<Map<String, String>> list = getAllFavoriteWithData(name);
  final controller = Get.put(ScreenGetxController());
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
            ],
          ),
        ),
      ),
    );
  }
  return toReturn;
}
