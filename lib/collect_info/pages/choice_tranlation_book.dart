import 'dart:convert';
import 'package:al_bayan_quran/core/show_twoested_message.dart';
import 'package:al_bayan_quran/screens/getx_controller.dart';
import 'package:al_bayan_quran/screens/home_mobile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../api/some_api_response.dart';
import '../getx/get_controller.dart';

class ChoiceTranslationBook extends StatefulWidget {
  final bool? showDownloadOnAppbar;
  const ChoiceTranslationBook({super.key, this.showDownloadOnAppbar});

  @override
  State<ChoiceTranslationBook> createState() => _ChoiceTranslationStateBook();
}

class _ChoiceTranslationStateBook extends State<ChoiceTranslationBook> {
  final infoController = Get.put(InfoController());
  final fontHandeler = Get.put(ScreenGetxController());
  List<List<String>> books = [];
  void getBooksAsLanguage() {
    for (int i = 0; i < allTranslationLanguage.length; i++) {
      Map<String, dynamic> book = allTranslationLanguage[i];
      if (book['language_name'].toString().toLowerCase() ==
          infoController.translationLanguage.value.toLowerCase()) {
        String autor = book['author_name'];
        String bookName = book['name'];
        String id = book['id'].toString();
        books.add([autor, bookName, id]);
      }
    }
  }

  @override
  void initState() {
    getBooksAsLanguage();
    setValue();
    super.initState();
  }

  void setValue() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    );
    infoController.isPreviousEnaviled.value = true;
  }

  bool downloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Translation Book ${infoController.translationLanguage.value == "null" ? "" : "for${infoController.translationLanguage.value}"}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (widget.showDownloadOnAppbar == true)
            downloading
                ? const CircularProgressIndicator()
                : TextButton.icon(
                    onPressed: () async {
                      if (infoController.selectedOptionTranslation.value !=
                          -1) {
                        final dataBoox = Hive.box("data");
                        final infoBox = Hive.box("info");
                        String bookTranslationID =
                            infoController.bookIDTranslation.value;
                        if (bookTranslationID ==
                            infoBox.get("info")['translation_book_ID']) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Worng Selection"),
                                content: const Text(
                                    "Your selection can't matched with the previous selection."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  )
                                ],
                              );
                            },
                          );
                          return;
                        }

                        dataBoox.put("translation", false);
                        setState(() {
                          downloading = true;
                        });

                        var url = Uri.parse(
                            "https://api.quran.com/api/v4/quran/translations/${infoController.bookIDTranslation.value}");
                        var headers = {"Accept": "application/json"};

                        var response = await http.get(url, headers: headers);

                        if (response.statusCode == 200) {
                          List<Map<String, dynamic>> translation =
                              List<Map<String, dynamic>>.from(
                                  json.decode(response.body)['translations']);

                          final translationBox =
                              await Hive.openBox("translation");

                          for (int i = 0; i < translation.length; i++) {
                            translationBox.put(
                              "$bookTranslationID/$i",
                              translation[i]['text'].toString(),
                            );
                          }
                        }
                        final info = infoBox.get("info", defaultValue: false);
                        info['translation_book_ID'] =
                            bookTranslationID.toString();
                        info['translation_language'] =
                            infoController.translationLanguage.value;
                        infoBox.put("info", info);
                        dataBoox.put("translation", true);
                        infoBox.put('translation', bookTranslationID);

                        Get.offAll(() => const HomeMobile());
                        showTwoestedMessage("Successful");
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Select a Book First"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                    label: const Text(
                      "Done",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                  ),
        ],
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(bottom: 100, top: 10, left: 3, right: 3),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              int value = index;
              infoController.bookNameIndex.value = value;
              infoController.bookIDTranslation.value = books[value][2];
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
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      books[index][1],
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      books[index][0],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                leading: Obx(
                  () => Radio(
                    activeColor: Colors.green,
                    value: index,
                    groupValue: infoController.bookNameIndex.value,
                    onChanged: (value) {
                      infoController.bookNameIndex.value = value!;
                      infoController.bookIDTranslation.value = books[value][2];
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
