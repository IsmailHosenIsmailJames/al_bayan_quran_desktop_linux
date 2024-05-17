import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

import '../theme/theme_icon_button.dart';
import 'init.dart';
import 'pages/choice_tafseer_book.dart';
import 'getx/get_controller.dart';
import 'pages/choice_tranlation_book.dart';
import 'pages/tafseer_language.dart';
import 'pages/translation_language.dart';

class CollectInfoDesktop extends StatefulWidget {
  final int pageNumber;
  const CollectInfoDesktop({super.key, required this.pageNumber});

  @override
  State<CollectInfoDesktop> createState() => _CollectInfoDesktopState();
}

class _CollectInfoDesktopState extends State<CollectInfoDesktop> {
  late PageController pageController;
  late int indexPage;
  String nextButtonText = "Next";
  @override
  void initState() {
    pageController = PageController(initialPage: widget.pageNumber);
    indexPage = widget.pageNumber;
    checkPageNumber(widget.pageNumber);
    super.initState();
  }

  void checkPageNumber(int index) {
    if (index >= 4) {
      setState(() {
        nextButtonText = "Done";
      });
    } else {
      setState(() {
        nextButtonText = "Next";
      });
    }
  }

  final infoController = Get.put(InfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: (infoController.tafseerBookIndex.value != -1 &&
                  infoController.tafseerIndex.value != -1 &&
                  infoController.bookNameIndex.value != -1 &&
                  infoController.selectedOptionTranslation.value != -1)
              ? () async {
                  {
                    Map<String, String> info = {
                      "translation_language":
                          infoController.translationLanguage.value,
                      "translation_book_ID":
                          infoController.bookIDTranslation.value,
                      "tafseer_language": infoController.tafseerLanguage.value,
                      "tafseer_book_ID": infoController.tafseerBookID.value,
                      "recitation_ID": infoController.recitationName.value,
                    };
                    if (Hive.isBoxOpen("info")) {
                      final box = Hive.box("info");

                      box.put("info", info);
                      Get.offAll(() => const InIt());
                    } else {
                      final box = await Hive.openBox("info");

                      box.put("info", info);
                      Get.offAll(() => const InIt());
                    }
                  }
                }
              : () {
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Please fill all information properly"),
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
                },
          label: const Center(
            child: Row(
              children: [
                Text("Done"),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              "Al Quran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Center(
              child: Text(
                "Choice your preferance",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Spacer(),
          ],
        ),
        actions: [themeIconButton],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Expanded(flex: 3, child: TranslationLanguage()),
          Obx(() {
            if (infoController.selectedOptionTranslation.value != -1) {
              return const Expanded(flex: 4, child: ChoiceTranslationBook());
            } else {
              return const SizedBox();
            }
          }),
          const Expanded(flex: 3, child: TafseerLanguage()),
          Obx(
            () {
              if (infoController.tafseerIndex.value != -1) {
                return const Expanded(flex: 4, child: ChoiceTafseerBook());
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
