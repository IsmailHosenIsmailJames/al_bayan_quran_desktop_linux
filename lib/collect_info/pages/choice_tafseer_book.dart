import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../api/some_api_response.dart';
import '../../core/show_twoested_message.dart';
import '../../data/download/links.dart';
import '../../screens/home_mobile.dart';
import '../getx/get_controller.dart';

class ChoiceTafseerBook extends StatefulWidget {
  final bool? showDownloadOnAppbar;
  const ChoiceTafseerBook({super.key, this.showDownloadOnAppbar});

  @override
  State<ChoiceTafseerBook> createState() => _ChoiceTafseerBookState();
}

class _ChoiceTafseerBookState extends State<ChoiceTafseerBook> {
  final infoController = Get.put(InfoController());
  List<List<String>> books = [];
  void getBooksAsLanguage() {
    for (int i = 0; i < allTafseer.length; i++) {
      Map<String, dynamic> book = allTafseer[i];
      if (book['language_name'].toString().toLowerCase() ==
          infoController.tafseerLanguage.value.toLowerCase()) {
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
        title: const Text(
          "Tafseer Book",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (widget.showDownloadOnAppbar == true)
            downloading
                ? const CircularProgressIndicator()
                : TextButton.icon(
                    onPressed: () async {
                      if (infoController.tafseerBookIndex.value != -1) {
                        String tafsirBookID =
                            infoController.tafseerBookID.value;
                        debugPrint(tafsirBookID);
                        // return;
                        final dataBoox = Hive.box("data");
                        final infoBox = Hive.box("info");
                        if (tafsirBookID ==
                            infoBox.get("info")['tafseer_book_ID']) {
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
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        dataBoox.put("tafseer", false);
                        setState(() {
                          downloading = true;
                        });

                        var url = Uri.parse(
                            tafseerLinks[infoController.tafseerBookID.value]!);
                        debugPrint(
                            tafseerLinks[infoController.tafseerBookID.value]);

                        var headers = {"Accept": "application/json"};

                        var response = await http.get(url, headers: headers);
                        final tafseerBox = await Hive.openBox("tafseer");

                        if (response.statusCode == 200) {
                          final tafseer = json.decode(response.body);
                          for (int i = 0; i < 6236; i++) {
                            String? ayah = tafseer['$i'];
                            if (ayah != null) {
                              tafseerBox.put(
                                "$tafsirBookID/$i",
                                tafseer["$i"],
                              );
                            }
                          }
                          final info = infoBox.get("info", defaultValue: false);
                          info['tafseer_book_ID'] = tafsirBookID;
                          info['tafseer_language'] =
                              infoController.tafseerLanguage.value;
                          infoBox.put("info", info);
                          dataBoox.put("tafseer", true);
                          infoBox.put(
                              'tafseer', infoController.tafseerBookID.value);

                          Get.offAll(() => const HomeMobile());
                          showTwoestedMessage("Successful");
                        } else {
                          showDialog(
                            // ignore: use_build_context_synchronously
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
              infoController.tafseerBookIndex.value = value;
              infoController.tafseerBookID.value = books[value][2];
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
                    groupValue: infoController.tafseerBookIndex.value,
                    onChanged: (value) {
                      infoController.tafseerBookIndex.value = value!;
                      infoController.tafseerBookID.value = books[value][2];
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
