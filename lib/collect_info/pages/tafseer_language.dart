import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/some_api_response.dart';
import '../getx/get_controller.dart';
import 'choice_tafseer_book.dart';

class TafseerLanguage extends StatefulWidget {
  final bool? showAppBarNextButton;
  const TafseerLanguage({super.key, this.showAppBarNextButton});

  @override
  State<TafseerLanguage> createState() => _TafseerLanguageState();
}

class _TafseerLanguageState extends State<TafseerLanguage> {
  late List<String> language;
  void getLanguageList() {
    Set<String> temLangauge = {};
    for (int index = 0; index < allTafseer.length; index++) {
      String lanName = "${allTafseer[index]["language_name"]}";
      String tem = lanName[0];
      tem = tem.toUpperCase();
      lanName = tem + lanName.substring(1);
      temLangauge.add(lanName);
    }
    List<String> x = temLangauge.toList();
    x.sort();
    language = x;
  }

  @override
  void initState() {
    getLanguageList();
    setValue();

    super.initState();
  }

  void setValue() async {
    await Future.delayed(
      const Duration(milliseconds: 100),
    );
    tafseerLanguage.isPreviousEnaviled.value = true;
  }

  final tafseerLanguage = Get.put(InfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tafseer",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (widget.showAppBarNextButton == true)
            TextButton(
              onPressed: () {
                tafseerLanguage.tafseerBookIndex.value = -1;
                Navigator.pop(context);
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return const ChoiceTafseerBook(
                      showDownloadOnAppbar: true,
                    );
                  },
                );
              },
              child: const Text(
                "NEXT",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
        ],
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(bottom: 100, top: 10, left: 3, right: 3),
        itemCount: language.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              int value = index;
              tafseerLanguage.tafseerIndex.value = value;
              tafseerLanguage.tafseerLanguage.value = language[value];
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(10, 145, 255, 160),
              ),
              child: ListTile(
                title: Text(language[index]),
                leading: Obx(
                  () => Radio(
                    activeColor: Colors.green,
                    value: index,
                    groupValue: tafseerLanguage.tafseerIndex.value,
                    onChanged: (value) {
                      tafseerLanguage.tafseerIndex.value = value!;
                      tafseerLanguage.tafseerLanguage.value = language[value];
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
