import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../api/colors_tazweed.dart';
import '../../api/some_api_response.dart';
import '../../collect_info/pages/tafseer_language.dart';
import '../../collect_info/pages/translation_language.dart';
import '../../theme/theme_controller.dart';
import '../../theme/theme_icon_button.dart';
import '../getx_controller.dart';

class Settings extends StatefulWidget {
  final bool showNavigator;
  const Settings({super.key, required this.showNavigator});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final fontSize = Get.put(ScreenGetxController());
  final translation = Hive.box("translation");
  final infoBox = Hive.box("info");
  final quranInitialStyleBox = Hive.box(quranScriptType);
  late final info = infoBox.get("info", defaultValue: false);

  late String ayahTranslation =
      translation.get("${info["translation_book_ID"]}/1");

  late Widget review = Obx(
    () => Text(
      quranInitialStyleBox.get("10",
          defaultValue: "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ"),
      style: TextStyle(
        fontSize: fontSize.fontSizeArabic.value,
      ),
    ),
  );

  @override
  void initState() {
    getWidgetsInit();
    super.initState();
  }

  getWidgetsInit() async {
    final tem = await buildArabicText(quranScriptType, "10");
    setState(() {
      review = tem;
    });
  }

  @override
  Widget build(BuildContext context) {
    String bookName = "";
    for (var element in allTranslationLanguage) {
      if (element['id'].toString() == info['translation_book_ID']) {
        bookName = element['name'];
      }
    }
    String tafsirBookName = "";
    for (var element in allTafseer) {
      if (element['id'].toString() == info['tafseer_book_ID']) {
        tafsirBookName = element['name'];
      }
    }
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        Row(
          children: [
            const Icon(
              Icons.settings,
              color: Colors.green,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: themeIconButton,
            ),
          ],
        ),
        const Row(
          children: [
            Icon(
              Icons.font_download_rounded,
              color: Colors.green,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Quran Font",
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Font Size Of Quran",
          style: TextStyle(
            fontSize: 16,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Expanded(
                child: Slider(
                    value: fontSize.fontSizeArabic.value,
                    max: 50,
                    min: 5,
                    onChanged: (value) {
                      final infoBox = Hive.box("info");
                      infoBox.put("fontSizeArabic", value.toPrecision(2));
                      fontSize.fontSizeArabic.value = value.toPrecision(2);
                    }),
              ),
            ),
            Obx(
              () => Text(
                fontSize.fontSizeArabic.value.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Script Type",
          style: TextStyle(
              fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        DropdownButtonFormField(
          value: quranScriptType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: "quran_tajweed",
              child: Text("Uthmani Tajweed Script"),
            ),
            DropdownMenuItem(
              value: "quran_indopak",
              child: Text("Indopak Script"),
            ),
            DropdownMenuItem(
              value: "quran",
              child: Text("Uthmani Script"),
            ),
            DropdownMenuItem(
              value: "quran_uthmani_simple",
              child: Text("Uthmani Simple Script"),
            ),
            DropdownMenuItem(
              value: "quran_imlaei",
              child: Text("Imlaei Simple Text"),
            ),
          ],
          onChanged: (value) async {
            review = await buildArabicText(value ?? "quran_tajweed", "10");
            final box = Hive.box("info");
            box.put("quranScriptType", value ?? quranScriptType);
            fontSize.quranScriptTypeGetx.value = value ?? "quran_tajweed";

            setState(() {
              quranScriptType = value ?? quranScriptType;
              review;
            });
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(20, 120, 120, 120),
            borderRadius: BorderRadius.circular(10),
          ),
          child: review,
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        const Row(
          children: [
            Icon(
              Icons.font_download_rounded,
              color: Colors.green,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Translation Font",
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Font Size Of Translation",
          style: TextStyle(
            fontSize: 16,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Expanded(
                child: Slider(
                    value: fontSize.fontSizeTranslation.value,
                    max: 50,
                    min: 5,
                    onChanged: (value) {
                      final infoBox = Hive.box("info");
                      infoBox.put("fontSizeTranslation", value.toPrecision(2));
                      fontSize.fontSizeTranslation.value = value.toPrecision(2);
                    }),
              ),
            ),
            Obx(
              () => Text(
                fontSize.fontSizeTranslation.value.toString(),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(20, 120, 120, 120),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Obx(
            () => Text(
              ayahTranslation,
              style: TextStyle(
                fontSize: fontSize.fontSizeTranslation.value,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        const Row(
          children: [
            Icon(
              Icons.translate_rounded,
              color: Colors.green,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Quran Translation Language & Book",
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(20, 120, 120, 120),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Language : ${info['translation_language']}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    "Book Name : ${bookName.length > 20 ? "${bookName.substring(0, 18)}..." : bookName}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) {
                      return const TranslationLanguage(
                        showNextButtonOnAppBar: true,
                      );
                    },
                  );
                },
                child: const Text(
                  "Change",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        const Row(
          children: [
            Icon(
              FontAwesomeIcons.bookOpen,
              color: Colors.green,
              size: 22,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Quran Tafsir Language & Book",
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(20, 120, 120, 120),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Language : ${info['tafseer_language']}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    "Book Name : ${tafsirBookName.length > 20 ? "${tafsirBookName.substring(0, 18)}..." : tafsirBookName}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => const TafseerLanguage(
                      showAppBarNextButton: true,
                    ),
                  );
                },
                child: const Text(
                  "Change",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<Widget> buildArabicText(String styleType, String ayahKey) async {
    final box = await Hive.openBox(styleType);
    if (styleType == "quran_tajweed") {
      return getTazweedTexSpan(
        box.get(ayahKey, defaultValue: ""),
      );
    }
    return Obx(
      () => Text(
        box.get(ayahKey, defaultValue: ""),
        style: TextStyle(
          fontSize: fontSize.fontSizeArabic.value,
        ),
      ),
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
          spanText.add(
            TextSpan(
              text: "۝$word",
              style: const TextStyle(),
            ),
          );
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
            fontSize: fontSize.fontSizeArabic.value,
          ),
          children: spanText,
        ),
      ),
    );
  }
}

List<Map<String, String?>> extractWordsGetTazweeds(String text) {
  final regexp = RegExp(r'<[^>]+>(.*?)</[^>]+>|[^<]+');
  final matchesr = regexp.allMatches(text);
  final allWords = matchesr.map((match) => match.group(0)!).toList();
  List<Map<String, String?>> tazweeds = [];
  for (String word in allWords) {
    List<Map<String, String?>> tem = getTagAndWord(word);
    if (tem.isEmpty) {
      tazweeds.add({
        "tag": "null",
        "class": "null",
        "word": word,
      });
    } else {
      tazweeds.add(tem[0]);
    }
  }
  return tazweeds;
}

List<Map<String, String?>> getTagAndWord(String word) {
  final regex = RegExp(
      r'<(?<tag>\w+)\s+class=(?<class>\w+)>(?<word>[^<]+)</(?<tag2>\1)>' // Capture tag, class, and word
      );

  final matches = regex.allMatches(word);
  final result = matches
      .map((match) => {
            "tag": match.namedGroup('tag'),
            "class": match.namedGroup('class'),
            "word": match.namedGroup('word'),
          })
      .toList();
  return result;
}
