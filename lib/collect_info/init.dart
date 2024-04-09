import 'package:al_bayan_quran/collect_info/collect_info_layout_responsive.dart';
import 'package:al_bayan_quran/screens/home_mobile.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../data/download/download.dart';

class InIt extends StatefulWidget {
  const InIt({super.key});

  @override
  State<InIt> createState() => _InItState();
}

class _InItState extends State<InIt> {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box("info");
    final info = box.get("info", defaultValue: false);
    final dataBox = Hive.box("data");
    if (info == false) {
      return const CollectInfoResponsive(pageNumber: 0);
    }

    if (!(dataBox.get('quran_info', defaultValue: false) &&
        dataBox.get('quran', defaultValue: false) &&
        dataBox.get('translation', defaultValue: false) &&
        dataBox.get('tafseer', defaultValue: false))) {
      return const DownloadData();
    }
    return const HomeMobile();
  }
}
