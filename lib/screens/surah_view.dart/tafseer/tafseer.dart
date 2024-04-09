import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class TafseerVoiceLess extends StatefulWidget {
  final String? surahName;
  final int ayahNumber;
  final int surahNumber;
  final String tafseer;
  const TafseerVoiceLess(
      {super.key,
      this.surahName,
      required this.ayahNumber,
      required this.surahNumber,
      required this.tafseer});

  @override
  State<TafseerVoiceLess> createState() => _TafseerVoiceLessState();
}

class _TafseerVoiceLessState extends State<TafseerVoiceLess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tafseer",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          HtmlWidget(widget.tafseer),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
