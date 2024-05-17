import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:hive/hive.dart';

class TafseerVoiceLess extends StatefulWidget {
  final String? surahName;
  final int ayahNumber;
  final int surahNumber;
  final String tafseer;
  final double fontS;
  const TafseerVoiceLess(
      {super.key,
      this.surahName,
      required this.ayahNumber,
      required this.surahNumber,
      required this.tafseer,
      required this.fontS});

  @override
  State<TafseerVoiceLess> createState() => _TafseerVoiceLessState();
}

class _TafseerVoiceLessState extends State<TafseerVoiceLess> {
  late double fontS;
  @override
  void initState() {
    fontS = widget.fontS;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              "Tafseer",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Text("Font size : "),
            IconButton(
                onPressed: () {
                  setState(() {
                    fontS++;
                  });
                  final infoBox = Hive.box("info");
                  infoBox.put("fontSizeTranslation", fontS);
                },
                icon: const Icon(Icons.exposure_plus_1_sharp)),
            IconButton(
                onPressed: () {
                  setState(() {
                    fontS--;
                  });
                  final infoBox = Hive.box("info");
                  infoBox.put("fontSizeTranslation", fontS);
                },
                icon: const Icon(Icons.exposure_minus_1)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          HtmlWidget(
            widget.tafseer,
            textStyle: TextStyle(fontSize: fontS),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
