import 'package:flutter/material.dart';

class ChoiceFontStyle extends StatefulWidget {
  const ChoiceFontStyle({super.key});

  @override
  State<ChoiceFontStyle> createState() => _ChoiceFontStyleState();
}

class _ChoiceFontStyleState extends State<ChoiceFontStyle> {
  Widget x() {
    const text =
        "بِسْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ <tajweed class=ham_wasl>ٱ</tajweed><tajweed class=laam_shamsiyah>ل</tajweed>رَّحْمَ<tajweed class=madda_normal>ـٰ</tajweed>نِ <tajweed class=ham_wasl>ٱ</tajweed><tajweed class=laam_shamsiyah>ل</tajweed>رَّح<tajweed class=madda_permissible>ِي</tajweed>مِ <span class=end>١</span>";

    final pattern =
        RegExp(r"<(tajweed|span) class=(\w+?)>(.*?)</\1>"); // Updated pattern

    final spans = <TextSpan>[];
    var offset = 0;

    for (final match in pattern.allMatches(text)) {
      // final tagName = match.group(1)!;
      final className = match.group(2)!;
      final textInsideTag = match.group(3)!;

      final textBeforeTag = text.substring(offset, match.start);
      spans.add(TextSpan(
        text: textBeforeTag,
        style: const TextStyle(fontFamily: "Majeed-Quranic", fontSize: 30),
      ));

      // Apply color or style based on tag name and class name
      final color = _getColorForClass(className);
      spans.add(TextSpan(
          text: textInsideTag,
          style: TextStyle(
              fontFamily: "Majeed-Quranic", color: color, fontSize: 30)));

      offset = match.end;
    }

    // Add remaining text after the last tag
    spans.add(TextSpan(text: text.substring(offset)));

    final richText = RichText(
      text: TextSpan(
          children: spans,
          style: const TextStyle(fontFamily: "Majeed-Quranic", fontSize: 30)),
    );

    // Use the richText widget in your UI
    return richText;
  }

  Color _getColorForClass(String className) {
    switch (className) {
      case "ham_wasl":
        return Colors.blue;
      case "laam_shamsiyah":
        return Colors.green;
      case "madda_normal":
        return Colors.red;
      case "madda_permissible":
        return Colors.purple;
      case "end":
        return Colors.orange; // Example color for the "end" class
      default:
        return Colors.black; // Default color for unknown classes
    }
  }

  @override
  Widget build(BuildContext context) {
    final spans = x();
    return Scaffold(body: Center(child: spans));
  }
}
