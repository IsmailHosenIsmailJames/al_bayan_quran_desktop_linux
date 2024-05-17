import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../screens/home_mobile.dart';
import '../../theme/theme_controller.dart';
import 'links.dart';

class DownloadData extends StatefulWidget {
  const DownloadData({super.key});

  @override
  State<DownloadData> createState() => _DownloadDataState();
}

class _DownloadDataState extends State<DownloadData> {
  double progressValue = 0.0;

  void getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      progressValue = 0.01;
    });
    if (!(connectivityResult.contains(ConnectivityResult.ethernet) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile))) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("No Internet Connection"),
          content: const Text(
              "We need to download required data.\nMake sure you are connected with internet."),
          actions: [
            TextButton(
              onPressed: () {
                Get.offAll(() => const DownloadData());
              },
              child: const Icon(
                Icons.restart_alt_outlined,
              ),
            ),
          ],
        ),
      );
    } else {
      final infoBox = Hive.box("info");
      final info = infoBox.get("info", defaultValue: false);
      if (info != false) {
        Map<String, String> preferance = {
          "translation_language": info['translation_language'],
          "translation_book_ID": info["translation_book_ID"],
          "tafseer_language": info['tafseer_language'],
          "tafseer_book_ID": info["tafseer_book_ID"],
          "recitation_ID": info['recitation_ID']
        };

        if (infoBox.get('quran_info', defaultValue: false) == false) {
          setState(() {
            progressValue = 0.02;
          });
          final quraninforbox = await Hive.openBox("quran_info");
          var url = Uri.parse(
              "https://raw.githubusercontent.com/IsmailHosenIsmailJames/quran_backend/main/public/infos.txt");
          var headers = {"Accept": "application/json"};

          var response = await http.get(url, headers: headers);
          if (response.statusCode == 200) {
            setState(() {
              progressValue += 0.40;
            });
            Map<String, String> jsonBody = Map<String, String>.from(
              jsonDecode(
                jsonDecode(response.body),
              ),
            );
            jsonBody.forEach((key, value) {
              quraninforbox.put(
                "info_${preferance['translation_book_ID']}/$key/text",
                jsonDecode(value),
              );
            });
            final dataBoox = Hive.box("data");
            dataBoox.put("quran_info", true);
            infoBox.put('quran_info', true);
          }
        }

        if (infoBox.get('quran_tajweed', defaultValue: false) == false &&
            infoBox.get('quran', defaultValue: false) == false &&
            infoBox.get('quran_indopak', defaultValue: false) == false &&
            infoBox.get('quran_uthmani_simple', defaultValue: false) == false &&
            infoBox.get('quran_imlaei', defaultValue: false) == false) {
          setState(() {
            progressValue = 0.41;
          });
          var url = Uri.parse(
              "https://api.quran.com/api/v4/quran/verses/uthmani_tajweed");
          var headers = {"Accept": "application/json"};

          http.Response response;
          if (infoBox.get('quran_tajweed', defaultValue: false) == false) {
            response = await http.get(url, headers: headers);
            if (response.statusCode == 200) {
              setState(() {
                progressValue = 0.45;
              });
              List<Map<String, dynamic>> listMap =
                  List<Map<String, dynamic>>.from(
                      jsonDecode(response.body)['verses']);
              final quranTajweed = await Hive.openBox("quran_tajweed");
              for (int i = 0; i < listMap.length; i++) {
                quranTajweed.put("$i", listMap[i]['text_uthmani_tajweed']);
              }
              infoBox.put('quran_tajweed', true);
            }
          }
          url = Uri.parse("https://api.quran.com/api/v4/quran/verses/uthmani");
          headers = {"Accept": "application/json"};

          if (infoBox.get('quran', defaultValue: false) == false) {
            response = await http.get(url, headers: headers);

            if (response.statusCode == 200) {
              setState(() {
                progressValue = 0.50;
              });
              List<Map<String, dynamic>> listMap =
                  List<Map<String, dynamic>>.from(
                      jsonDecode(response.body)['verses']);
              final quranTajweed = await Hive.openBox("quran");
              for (int i = 0; i < listMap.length; i++) {
                quranTajweed.put("$i", listMap[i]['text_uthmani']);
              }
              infoBox.put('quran', true);
            }
          }

          if (infoBox.get('quran_indopak', defaultValue: false) == false) {
            url =
                Uri.parse("https://api.quran.com/api/v4/quran/verses/indopak");
            headers = {"Accept": "application/json"};
            response = await http.get(url, headers: headers);
            if (response.statusCode == 200) {
              setState(() {
                progressValue = 0.55;
              });
              List<Map<String, dynamic>> listMap =
                  List<Map<String, dynamic>>.from(
                      jsonDecode(response.body)['verses']);
              final quranTajweed = await Hive.openBox("quran_indopak");
              for (int i = 0; i < listMap.length; i++) {
                quranTajweed.put("$i", listMap[i]['text_indopak']);
              }
              infoBox.put('quran_indopak', true);
            }
          }
          if (infoBox.get('quran_uthmani_simple', defaultValue: false) ==
              false) {
            url = Uri.parse(
                "https://api.quran.com/api/v4/quran/verses/uthmani_simple");
            headers = {"Accept": "application/json"};
            response = await http.get(url, headers: headers);
            if (response.statusCode == 200) {
              setState(() {
                progressValue = 0.55;
              });
              List<Map<String, dynamic>> listMap =
                  List<Map<String, dynamic>>.from(
                      jsonDecode(response.body)['verses']);
              final quranTajweed = await Hive.openBox("quran_uthmani_simple");
              for (int i = 0; i < listMap.length; i++) {
                quranTajweed.put("$i", listMap[i]['text_uthmani_simple']);
              }
              infoBox.put('quran_uthmani_simple', true);
            }
          }
          if (infoBox.get('quran_imlaei', defaultValue: false) == false) {
            url = Uri.parse("https://api.quran.com/api/v4/quran/verses/imlaei");
            headers = {"Accept": "application/json"};
            response = await http.get(url, headers: headers);
            if (response.statusCode == 200) {
              setState(() {
                progressValue = 0.65;
              });
              List<Map<String, dynamic>> listMap =
                  List<Map<String, dynamic>>.from(
                      jsonDecode(response.body)['verses']);
              final quranTajweed = await Hive.openBox("quran_imlaei");
              for (int i = 0; i < listMap.length; i++) {
                quranTajweed.put("$i", listMap[i]['text_imlaei']);
              }
              infoBox.put('quran_imlaei', true);
            }
          }

          final dataBoox = Hive.box("data");
          dataBoox.put("quran", true);
          infoBox.put('quran', true);
        } else {
          setState(() {
            progressValue = 0.74;
          });
        }

        if (infoBox.get('translation', defaultValue: false) == false ||
            infoBox.get('translation', defaultValue: false) !=
                preferance['translation_book_ID']) {
          var url = Uri.parse(
              "https://api.quran.com/api/v4/quran/translations/${preferance['translation_book_ID']}");
          var headers = {"Accept": "application/json"};

          var response = await http.get(url, headers: headers);

          if (response.statusCode == 200) {
            setState(() {
              progressValue = 0.80;
            });

            List<Map<String, dynamic>> translation =
                List<Map<String, dynamic>>.from(
                    json.decode(response.body)['translations']);

            setState(() {
              progressValue = 0.82;
            });
            final translationBox = await Hive.openBox("translation");

            for (int i = 0; i < translation.length; i++) {
              translationBox.put(
                "${preferance['translation_book_ID']}/$i",
                translation[i]['text'].toString(),
              );
            }
            setState(() {
              progressValue = 0.85;
            });

            final dataBoox = Hive.box("data");
            dataBoox.put("translation", true);
            infoBox.put('translation', preferance['translation_book_ID']);
          } else {
            setState(() {});
          }
        } else {
          setState(() {
            progressValue = 0.88;
          });
        }
        if (infoBox.get('tafseer', defaultValue: false) == false ||
            infoBox.get('tafseer', defaultValue: false) !=
                preferance['tafseer_book_ID']) {
          setState(() {
            progressValue = 0.90;
          });

          final tafseerBox = await Hive.openBox("tafseer");
          final url = Uri.parse(tafseerLinks[preferance['tafseer_book_ID']]!);
          final headers = {"Accept": "application/json"};
          final response = await http.get(url, headers: headers);
          setState(() {
            progressValue = 0.99;
          });
          if (response.statusCode == 200) {
            final tafseer = json.decode(response.body);
            for (int i = 0; i < 6236; i++) {
              String? ayah = tafseer['$i'];
              if (ayah != null) {
                tafseerBox.put(
                  "${preferance['tafseer_book_ID']}/$i",
                  tafseer["$i"],
                );
              }
            }
            final dataBoox = Hive.box("data");
            dataBoox.put("tafseer", true);
            infoBox.put('tafseer', preferance['tafseer_book_ID']);
          }
        }
        AppThemeData().initTheme();
        Get.offAll(() => const HomeMobile());
      }
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Please Wait\nDownloading...\nIt will take around 30 sec.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            CircularProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey.shade200,
              color: Colors.green,
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Progress : ${(progressValue * 100).toInt()}%"),
          ],
        ),
      ),
    );
  }
}
