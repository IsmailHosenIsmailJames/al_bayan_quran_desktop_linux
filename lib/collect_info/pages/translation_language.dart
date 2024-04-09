import 'package:al_bayan_quran/collect_info/pages/choice_tranlation_book.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/some_api_response.dart';
import '../getx/get_controller.dart';

class TranslationLanguage extends StatefulWidget {
  final bool? showNextButtonOnAppBar;
  const TranslationLanguage({super.key, this.showNextButtonOnAppBar});

  @override
  State<TranslationLanguage> createState() => _TranslationLanguageState();
}

class _TranslationLanguageState extends State<TranslationLanguage> {
  late List<String> language;
  void getLanguageList() {
    Set<String> temLangauge = {};
    for (int index = 0; index < allTranslationLanguage.length; index++) {
      String langName = "${allTranslationLanguage[index]["language_name"]}";
      String tem = langName[0];
      tem = tem.toUpperCase();
      langName = tem + langName.substring(1);
      temLangauge.add(langName);
    }
    List<String> tem = temLangauge.toList();
    tem.sort();
    language = tem;
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
    translationLanguageController.isPreviousEnaviled.value = false;
  }

  final translationLanguageController = Get.put(InfoController());

  @override
  Widget build(BuildContext context) {
    setValue();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Translation",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (widget.showNextButtonOnAppBar == true)
            TextButton(
              onPressed: () {
                translationLanguageController.bookNameIndex.value = -1;
                Navigator.pop(context);
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return const ChoiceTranslationBook(
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
              translationLanguageController.selectedOptionTranslation.value =
                  value;
              translationLanguageController.translationLanguage.value =
                  language[value];
            },
            behavior: HitTestBehavior.translucent,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(10, 145, 255, 160),
              ),
              child: ListTile(
                title: Text(
                  language[index],
                ),
                leading: Obx(
                  () => Radio(
                    activeColor: Colors.green,
                    value: index,
                    groupValue: translationLanguageController
                        .selectedOptionTranslation.value,
                    onChanged: (value) {
                      translationLanguageController
                          .selectedOptionTranslation.value = value!;
                      translationLanguageController.translationLanguage.value =
                          language[value];
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
