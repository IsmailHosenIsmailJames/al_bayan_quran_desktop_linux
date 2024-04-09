// import 'package:al_bayan_quran/api/by_pages.dart';
// import 'package:al_bayan_quran/api/some_api_response.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';

// import '../surah_view.dart/sura_view.dart';

// class PagesList extends StatelessWidget {
//   const PagesList({super.key});
//   @override
//   Widget build(BuildContext context) {
//     ScrollController scrollController = ScrollController();
//     List<MapEntry<String, Map<String, dynamic>>> allPages =
//         byPages.entries.toList();
//     return Scrollbar(
//       controller: scrollController,
//       interactive: true,
//       radius: const Radius.circular(10),
//       thumbVisibility: true,
//       thickness: 10,
//       child: ListView.builder(
//         controller: scrollController,
//         padding: const EdgeInsets.only(bottom: 50),
//         scrollDirection: Axis.vertical,
//         itemCount: allPages.length,
//         itemBuilder: (context, index) {
//           final current = allPages[index];
//           List verse = current.value['v'];
//           List<String> firstVerseKey = verse[0]['vk'].toString().split(":");
//           List<String> lastVerseKey =
//               verse[verse.length - 1]['vk'].toString().split(':');

//           int ayahNumber = verse[verse.length - 1]['id'] - verse[0]['id'] + 1;
//           String allSurahInPage = "";
//           String surahRange = "";
//           int surahNumberUnderPage = 0;
//           if (firstVerseKey[0] == lastVerseKey[0]) {
//             allSurahInPage =
//                 allChaptersInfo[int.parse(firstVerseKey[0]) - 1]['name_simple'];
//             int temAyah =
//                 int.parse(lastVerseKey[1]) - int.parse(firstVerseKey[1]) + 1;
//             int realAyah = allChaptersInfo[int.parse(firstVerseKey[0]) - 1]
//                 ['verses_count'];
//             if (temAyah != realAyah) {
//               surahRange = "  ${firstVerseKey[1]} : ${lastVerseKey[1]}";
//             }
//           } else {
//             surahNumberUnderPage =
//                 int.parse(lastVerseKey[0]) - int.parse(firstVerseKey[0]);
//             String firstSurahName =
//                 allChaptersInfo[int.parse(firstVerseKey[0]) - 1]['name_simple'];
//             String lastSurahName =
//                 allChaptersInfo[int.parse(lastVerseKey[0]) - 1]['name_simple'];
//             int firestSurahAyahNumber =
//                 allChaptersInfo[int.parse(lastVerseKey[0]) - 1]['verses_count'];
//             allSurahInPage = "$firstSurahName - $lastSurahName";
//             int lastSurahLastAyah = int.parse(lastVerseKey[1]);
//             surahRange =
//                 "$firstSurahName(${firstVerseKey[1]} : $firestSurahAyahNumber) - $lastSurahName(0 : $lastSurahLastAyah)";
//           }
//           List<Widget> surahUnderPage = [const Divider()];
//           if (surahNumberUnderPage > 0) {
//             int surahNumber = int.parse(firstVerseKey[0]);
//             int start = int.parse(firstVerseKey[1]);
//             int end = allChaptersInfo[surahNumber - 1]['verses_count'];

//             String nameSimple = allChaptersInfo[surahNumber - 1]['name_simple'];
//             String revelationPlace =
//                 allChaptersInfo[surahNumber - 1]['revelation_place'];
//             int versesCount = end - start + 1;
//             String nameArabic = allChaptersInfo[surahNumber - 1]['name_arabic'];

//             surahUnderPage.add(
//               GestureDetector(
//                 onTap: () async {
//                   print("object");
//                   await Hive.openBox("translation");
//                   await Hive.openBox("quran");
//                   Get.to(() {
//                     return SuraView(
//                       surahNumber: surahNumber - 1,
//                       start: start - 1,
//                       end: end,
//                       surahName: nameSimple,
//                     );
//                   });
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(5),
//                   margin: const EdgeInsets.only(
//                       left: 5, right: 5, top: 2, bottom: 2),
//                   decoration: BoxDecoration(
//                       color: const Color.fromARGB(30, 125, 125, 125),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 25,
//                             backgroundColor:
//                                 const Color.fromARGB(195, 0, 84, 133),
//                             child: Center(
//                               child: Text(
//                                 surahNumber.toString(),
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             margin: const EdgeInsets.only(left: 15),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   nameSimple,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   revelationPlace,
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color.fromARGB(255, 136, 136, 136),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             nameArabic,
//                             style: const TextStyle(
//                               fontSize: 16,
//                             ),
//                           ),
//                           Text(
//                             "$versesCount Ayahs",
//                             style: const TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               color: Color.fromARGB(255, 136, 136, 136),
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//             surahNumber = int.parse(lastVerseKey[0]) - 1;
//             start = 0;
//             end = int.parse(lastVerseKey[1]);
//             nameSimple = allChaptersInfo[surahNumber - 1]['name_simple'];
//             revelationPlace =
//                 allChaptersInfo[surahNumber - 1]['revelation_place'];
//             versesCount = int.parse(lastVerseKey[1]);
//             nameArabic = allChaptersInfo[surahNumber - 1]['name_arabic'];
//             surahUnderPage.add(
//               GestureDetector(
//                 onTap: () async {
//                   print("object1");

//                   await Hive.openBox("translation");
//                   await Hive.openBox("quran");
//                   Get.to(() {
//                     return SuraView(
//                       surahNumber: surahNumber,
//                       start: start,
//                       end: end,
//                       surahName: nameSimple,
//                     );
//                   });
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(5),
//                   margin: const EdgeInsets.only(
//                       left: 5, right: 5, top: 2, bottom: 2),
//                   decoration: BoxDecoration(
//                       color: const Color.fromARGB(30, 125, 125, 125),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 25,
//                             backgroundColor:
//                                 const Color.fromARGB(195, 0, 84, 133),
//                             child: Center(
//                               child: Text(
//                                 (surahNumber + 1).toString(),
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             margin: const EdgeInsets.only(left: 15),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   nameSimple,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   revelationPlace,
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color.fromARGB(255, 136, 136, 136),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             nameArabic,
//                             style: const TextStyle(
//                               fontSize: 16,
//                             ),
//                           ),
//                           Text(
//                             "$versesCount Ayahs",
//                             style: const TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               color: Color.fromARGB(255, 136, 136, 136),
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             );
//             if (surahNumberUnderPage == 2) {
//               surahNumber = int.parse(firstVerseKey[0]) - 1;
//               start = 0;
//               end = allChaptersInfo[surahNumber]['verses_count'];

//               nameSimple = allChaptersInfo[surahNumber]['name_simple'];
//               revelationPlace =
//                   allChaptersInfo[surahNumber]['revelation_place'];
//               versesCount = end;
//               nameArabic = allChaptersInfo[surahNumber]['name_arabic'];

//               surahUnderPage.insert(
//                 surahUnderPage.length - 1,
//                 GestureDetector(
//                   onTap: () async {
//                     print("object5");
//                     await Hive.openBox("translation");
//                     await Hive.openBox("quran");
//                     Get.to(() {
//                       return SuraView(
//                         surahNumber: surahNumber,
//                         start: start - 1,
//                         end: end,
//                         surahName: nameSimple,
//                       );
//                     });
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(5),
//                     margin: const EdgeInsets.only(
//                         left: 5, right: 5, top: 2, bottom: 2),
//                     decoration: BoxDecoration(
//                         color: const Color.fromARGB(30, 125, 125, 125),
//                         borderRadius: BorderRadius.circular(15)),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 25,
//                               backgroundColor:
//                                   const Color.fromARGB(195, 0, 84, 133),
//                               child: Center(
//                                 child: Text(
//                                   surahNumber.toString(),
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(left: 15),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     nameSimple,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     revelationPlace,
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color.fromARGB(255, 136, 136, 136),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               nameArabic,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                               ),
//                             ),
//                             Text(
//                               "$versesCount Ayahs",
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color.fromARGB(255, 136, 136, 136),
//                               ),
//                             ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }
//           }
//           return GestureDetector(
//             behavior: HitTestBehavior.translucent,
//             onTap: () async {
//               await Hive.openBox("translation");
//               await Hive.openBox('quran');
//               Get.to(
//                 () => SuraView(
//                   surahNumber: int.parse(firstVerseKey[0]) - 1,
//                   start: int.parse(firstVerseKey[1]) - 1,
//                   end: int.parse(lastVerseKey[1]),
//                 ),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               margin:
//                   const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
//               decoration: BoxDecoration(
//                   color: const Color.fromARGB(30, 125, 125, 125),
//                   borderRadius: BorderRadius.circular(20)),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 25,
//                             backgroundColor:
//                                 const Color.fromARGB(195, 0, 133, 4),
//                             child: Center(
//                               child: Text(
//                                 (index + 1).toString(),
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             margin: const EdgeInsets.only(left: 15),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   allSurahInPage,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 if (surahRange != "")
//                                   Text(
//                                     surahRange,
//                                     style: const TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   )
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             "$ayahNumber Ayahs",
//                             style: const TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               color: Color.fromARGB(255, 136, 136, 136),
//                             ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                   if (surahNumberUnderPage > 0)
//                     Column(children: surahUnderPage),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
