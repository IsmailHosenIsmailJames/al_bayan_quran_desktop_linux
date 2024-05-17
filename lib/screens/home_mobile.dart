import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sidebarx/sidebarx.dart';

import '../api/all_recitation.dart';
import '../api/by_juzs.dart';
import '../api/some_api_response.dart';
import '../auth/account_info/account_info.dart';
import '../auth/login/login.dart';
import '../collect_info/getx/get_controller.dart';
import '../theme/theme_controller.dart';
import '../theme/theme_icon_button.dart';
import 'drawer/settings_with_appbar.dart';
import 'favorite_bookmark_notes/book_mark.dart';
import 'favorite_bookmark_notes/favorite.dart';
import 'favorite_bookmark_notes/notes_v.dart';
import 'profile/profile.dart';
import 'surah_view.dart/surah_with_translation.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> with TickerProviderStateMixin {
  final SidebarXController _sidebarXController =
      SidebarXController(selectedIndex: 0);
  int currentIndex = 0;
  bool isPlaying = false;
  String currentReciter = "";
  int playingIndex = -1;
  int surahNumber = -1;
  int currentPlayingAyahIndex = 0;
  int maxPlayingAyahIndex = 0;

  GlobalKey<ScaffoldState> drawerController = GlobalKey<ScaffoldState>();

  List<DropdownMenuEntry<Object>> dropdownList = [];

  List<int> expandedPosition = [];
  List<AnimationController> controller = [];
  List<Animation<double>> sizeAnimation = [];

  final infoController = Get.put(InfoController());
  final infoBox = Hive.box("info");

  @override
  void initState() {
    for (String recitor in allRecitation) {
      dropdownList.add(
        DropdownMenuEntry(
          value: recitor,
          label: recitor.split("(")[0],
        ),
      );
    }
    final info = infoBox.get("info", defaultValue: false);

    currentReciter = info['recitation_ID'];

    super.initState();
    for (int i = 0; i < 30; i++) {
      final tem = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );
      controller.add(tem);
      sizeAnimation.add(CurvedAnimation(parent: tem, curve: Curves.easeInOut));
      expandedPosition.add(-1);
    }

    _sidebarXController.extendStream.listen((event) {
      setState(() {
        isExtended = event;
      });
    });
    openBoxes();
  }

  bool isExtended = false;

  Future<void> openBoxes() async {
    final tem = Hive.box("info");
    if (Hive.isBoxOpen(
            tem.get("quranScriptType", defaultValue: "quran_tajweed")) ==
        false) {
      await Hive.openBox(
          tem.get("quranScriptType", defaultValue: "quran_tajweed"));
    }
  }

  List<Widget> listSurahProviderDesktop(length) {
    List<Widget> listSurah = [];

    for (int index = -1; index < length; index++) {
      if (index == -1) {
        listSurah.add(
          const Center(
            child: Text(
              "Surah",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        );
        continue;
      }
      String revelationPlace = allChaptersInfo[index]['revelation_place'];
      String nameSimple = allChaptersInfo[index]['name_simple'];
      String nameArabic = allChaptersInfo[index]['name_arabic'];
      int versesCount = allChaptersInfo[index]['verses_count'];
      listSurah.add(
        GestureDetector(
          onTap: () async {
            await openBoxes();
            await Hive.openBox("translation");
            await Hive.openBox("quran");
            final tem = Hive.box("info");
            await Hive.openBox(
                tem.get("quranScriptType", defaultValue: "quran_tajweed"));
            setState(() {
              isPlaying = false;
              playingIndex = -1;
            });
            await Get.to(() {
              return SuraView(
                surahNumber: index,
                surahName: nameSimple,
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
            decoration: BoxDecoration(
                color: const Color.fromARGB(30, 125, 125, 125),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color.fromARGB(195, 0, 133, 4),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameSimple,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            revelationPlace,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 136, 136, 136),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      nameArabic,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "$versesCount Ayahs",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 136, 136, 136),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
    return listSurah;
  }

  List<Widget> buildJuzs(int length) {
    List<Widget> toReturn = [];
    for (int index = -1; index < length; index++) {
      if (index == -1) {
        toReturn.add(const Center(
          child: Text(
            "Juzs",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ));
        continue;
      }
      int firstVerseId = byJuzs[index]['fvi'];
      int lastVerseId = byJuzs[index]['lvi'];

      String allSurahName = "";
      String lastSurahName = "";

      Map<String, String> myMap = Map<String, String>.from(byJuzs[index]['vm']);

      myMap.forEach((key, value) {
        int i = int.parse(key) - 1;

        if (allSurahName.isNotEmpty) {
          lastSurahName = allChaptersInfo[i]['name_simple'];
        } else {
          allSurahName += allChaptersInfo[i]['name_simple'];
        }
      });
      if (lastSurahName.isNotEmpty) {
        allSurahName = "$allSurahName - $lastSurahName";
      }
      allSurahName = allSurahName.replaceRange(
          allSurahName.length - 2, allSurahName.length - 1, "");

      toReturn.add(
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          decoration: BoxDecoration(
            color: const Color.fromARGB(20, 125, 125, 125),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  await openBoxes();

                  setState(() {
                    expandedPosition[index] == index
                        ? {
                            expandedPosition[index] = -1,
                            controller[index].reverse()
                          }
                        : {
                            expandedPosition[index] = index,
                            controller[index].forward()
                          };
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color.fromARGB(195, 0, 133, 4),
                          radius: 25,
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allSurahName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Total ${myMap.length} Surah",
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${lastVerseId - firstVerseId} Ayahs",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 136, 136, 136),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: index == expandedPosition[index]
                              ? const Icon(
                                  Icons.arrow_drop_down,
                                  key: Key("1"),
                                )
                              : const Icon(
                                  Icons.arrow_drop_up,
                                  key: Key("2"),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizeTransition(
                sizeFactor: sizeAnimation[index],
                axis: Axis.vertical,
                child: Column(
                  key: const Key("2"),
                  children: surahUnderJuzs(index),
                ),
              )
            ],
          ),
        ),
      );
    }
    return toReturn;
  }

  List<Widget> listSurahProvider(length) {
    List<Widget> listSurah = [];

    for (int index = 0; index < length; index++) {
      String revelationPlace = allChaptersInfo[index]['revelation_place'];
      String nameSimple = allChaptersInfo[index]['name_simple'];
      String nameArabic = allChaptersInfo[index]['name_arabic'];
      int versesCount = allChaptersInfo[index]['verses_count'];
      listSurah.add(
        GestureDetector(
          onTap: () async {
            setState(() {
              isPlaying = false;
              playingIndex = -1;
            });
            await Hive.openBox("translation");
            await Hive.openBox("quran");
            await openBoxes();
            await Get.to(() {
              return SuraView(
                surahNumber: index,
                surahName: nameSimple,
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
            decoration: BoxDecoration(
                color: const Color.fromARGB(20, 125, 125, 125),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color.fromARGB(195, 0, 133, 4),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameSimple,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            revelationPlace,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 136, 136, 136),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      nameArabic,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "$versesCount Ayahs",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 136, 136, 136),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
    return listSurah;
  }

  List<Widget> surahUnderJuzs(int index) {
    List<Widget> listOfWidget = [];
    Map<String, String> myMap = Map<String, String>.from(byJuzs[index]['vm']);
    myMap.forEach((key, value) {
      int surahNumber = int.parse(key) - 1;
      String revelationPlace = allChaptersInfo[surahNumber]['revelation_place'];
      String nameSimple = allChaptersInfo[surahNumber]['name_simple'];
      String nameArabic = allChaptersInfo[surahNumber]['name_arabic'];
      var versesCount = allChaptersInfo[surahNumber]['verses_count'];
      List<String> startEnd = value.split('-');
      int startEndDiffenrence =
          int.parse(startEnd[1]) - int.parse(startEnd[0]) + 1;
      if (startEndDiffenrence != versesCount) {
        versesCount = "${startEnd[0]} : ${startEnd[1]}";
      }
      listOfWidget.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          setState(() {
            isPlaying = false;
            playingIndex = -1;
          });
          List<String> splited =
              versesCount.toString().replaceAll(" ", "").split(":");
          int startFrom = 0;
          int endTo = 0;
          if (splited.length > 1) {
            startFrom = int.parse(splited[0]);
            endTo = int.parse(splited[1]);
          } else {
            endTo = int.parse(splited[0]);
          }
          await Hive.openBox("translation");
          await Hive.openBox("quran");

          await Get.to(() => SuraView(
                surahNumber: surahNumber,
                start: startFrom,
                end: endTo,
              ));
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          decoration: BoxDecoration(
              color: const Color.fromARGB(20, 125, 125, 125),
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color.fromARGB(195, 0, 168, 6),
                    child: Center(
                      child: Text(
                        (surahNumber + 1).toString(),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameSimple,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          revelationPlace,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 136, 136, 136),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    nameArabic,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "$versesCount Ayahs",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 136, 136, 136),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ));
    });
    return listOfWidget;
  }

  @override
  void dispose() async {
    for (int i = 0; i < 30; i++) {
      controller[i].dispose();
    }
    scrollController.dispose();
    super.dispose();
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Widget myDrawer = Drawer(
      child: ListView(
        padding: const EdgeInsets.only(
          right: 10,
          bottom: 20,
        ),
        children: [
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !isLoogedIn
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Get.to(() => const LogIn());
                              },
                              label: const Text(
                                "LogIn",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 30,
                                ),
                              ),
                              icon: const Icon(
                                Icons.login,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              "You Need to login for more Features.\nFor Example, you can save your notes in\ncloud and access it from any places.",
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.green,
                            child: GetX<AccountInfo>(
                              builder: (controller) => Text(
                                controller.name.value.substring(0, 1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GetX<AccountInfo>(
                                builder: (controller) => Text(
                                  controller.name.value.length > 10
                                      ? "${controller.name.value.substring(0, 10)}..."
                                      : controller.name.value,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GetX<AccountInfo>(
                                builder: (controller) => Text(
                                  controller.email.value.length > 20
                                      ? "${controller.email.value.substring(0, 15)}...${controller.email.value.substring(controller.email.value.length - 9, controller.email.value.length)}"
                                      : controller.email.value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              GetX<AccountInfo>(
                                builder: (controller) => Text(
                                  controller.uid.value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: "Close Drawer",
                      onPressed: () {
                        drawerController.currentState!.closeDrawer();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                    themeIconButton,
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(
                  Icons.home_rounded,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("Home")
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
            onPressed: () async {
              await Hive.openBox('quran');
              await Hive.openBox("translation");
              await Get.to(
                () => const Favorite(),
              );
              setState(() {
                playingIndex = -1;
              });
            },
            child: const Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("Favorite")
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
            onPressed: () async {
              await Hive.openBox('quran');
              await Hive.openBox("translation");
              await Get.to(() => const BookMark());
              setState(() {
                playingIndex = -1;
              });
            },
            child: const Row(
              children: [
                Icon(
                  Icons.bookmark_added,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("Book Mark")
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
            onPressed: () async {
              await Hive.openBox('quran');
              await Hive.openBox("translation");
              await Hive.openBox("notes");
              await Get.to(() => const NotesView());
              setState(() {
                playingIndex = -1;
              });
            },
            child: const Row(
              children: [
                Icon(
                  Icons.note_add,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("Notes")
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
            onPressed: () async {
              await Hive.openBox("translation");
              await Hive.openBox(quranScriptType);
              await Get.to(() => const SettingsWithAppbar());
            },
            child: const Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("Settings")
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          if (isLoogedIn)
            TextButton(
              onPressed: () async {
                Client client = Client()
                    .setEndpoint("https://cloud.appwrite.io/v1")
                    .setProject("albayanquran");
                Account account = Account(client);
                await account.deleteSession(sessionId: 'current');
                setState(() {
                  isLoogedIn = false;
                });
              },
              child: const Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("Log Out")
                ],
              ),
            ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );

    return Scaffold(
      bottomNavigationBar: MediaQuery.of(context).size.width > 650
          ? null
          : SalomonBottomBar(
              selectedItemColor: Colors.green,
              currentIndex: currentIndex,
              onTap: (i) => setState(() => currentIndex = i),
              items: [
                SalomonBottomBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Icon(
                      FontAwesomeIcons.bookOpen,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    "Quran",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SalomonBottomBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Icon(Icons.person),
                  ),
                  title: const Text(
                    "Profile",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
      body: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            key: drawerController,
            drawer: MediaQuery.of(context).size.width > 650 ? null : myDrawer,
            appBar: MediaQuery.of(context).size.width > 650
                ? null
                : AppBar(
                    title: const Text(
                      "Al Quran",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: const [
                      // IconButton(
                      //     onPressed: () {
                      //       showDialog(
                      //         useSafeArea: true,
                      //         context: context,
                      //         builder: (context) => AlertDialog(
                      //           title: const Row(
                      //             children: [
                      //               Icon(Icons.search),
                      //               SizedBox(
                      //                 width: 15,
                      //               ),
                      //               Text("Search")
                      //             ],
                      //           ),
                      //           content: Column(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               TextFormField(
                      //                 autofocus: true,
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.only(top: 8.0),
                      //                 child: Row(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.spaceAround,
                      //                     children: [
                      //                       TextButton(
                      //                         child: const Text("Quran"),
                      //                         onPressed: () {},
                      //                       ),
                      //                       TextButton(
                      //                           child: const Text("Translation"),
                      //                           onPressed: () {}),
                      //                       TextButton(
                      //                           child: const Text("Tafseer"),
                      //                           onPressed: () {}),
                      //                     ]),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //     icon: const Icon(Icons.search))
                    ],
                    bottom: MediaQuery.of(context).size.width > 650
                        ? null
                        : const TabBar(
                            tabs: [
                              Tab(
                                child: Text(
                                  "Surah",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Juzs',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              // Tab(
                              //   child: Text(
                              //     'Pages',
                              //     style: TextStyle(
                              //       fontSize: 20,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                  ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 720) {
                  return Row(
                    children: [
                      if (MediaQuery.of(context).size.width > 650)
                        SideBar(sidebarXController: _sidebarXController),
                      Expanded(
                        flex: 3,
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.only(bottom: 50),
                          children: listSurahProviderDesktop(114),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ListView(
                          controller: scrollController,
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.only(bottom: 50),
                          children: buildJuzs(byJuzs.length),
                        ),
                      ),
                    ],
                  );
                } else {
                  return TabBarView(
                    children: [
                      ListView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(bottom: 50, top: 5),
                        children: listSurahProvider(114),
                      ),
                      ListView.builder(
                        controller: scrollController,
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(bottom: 50),
                        itemCount: byJuzs.length,
                        itemBuilder: (context, index) {
                          int firstVerseId = byJuzs[index]['fvi'];
                          int lastVerseId = byJuzs[index]['lvi'];

                          String allSurahName = "";
                          String lastSurahName = "";

                          Map<String, String> myMap =
                              Map<String, String>.from(byJuzs[index]['vm']);

                          myMap.forEach((key, value) {
                            int i = int.parse(key) - 1;

                            if (allSurahName.isNotEmpty) {
                              lastSurahName = allChaptersInfo[i]['name_simple'];
                            } else {
                              allSurahName += allChaptersInfo[i]['name_simple'];
                            }
                          });
                          if (lastSurahName.isNotEmpty) {
                            allSurahName = "$allSurahName - $lastSurahName";
                          }
                          allSurahName = allSurahName.replaceRange(
                              allSurahName.length - 2,
                              allSurahName.length - 1,
                              "");

                          return Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(20, 125, 125, 125),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    setState(() {
                                      expandedPosition[index] == index
                                          ? {
                                              expandedPosition[index] = -1,
                                              controller[index].reverse()
                                            }
                                          : {
                                              expandedPosition[index] = index,
                                              controller[index].forward()
                                            };
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    195, 0, 133, 4),
                                            radius: 25,
                                            child: Center(
                                              child: Text(
                                                (index + 1).toString(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                allSurahName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "Total ${myMap.length} Surah",
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${lastVerseId - firstVerseId} Ayahs",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 136, 136, 136),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child:
                                                index == expandedPosition[index]
                                                    ? const Icon(
                                                        Icons.arrow_drop_down,
                                                        key: Key("1"),
                                                      )
                                                    : const Icon(
                                                        Icons.arrow_drop_up,
                                                        key: Key("2"),
                                                      ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizeTransition(
                                  sizeFactor: sizeAnimation[index],
                                  axis: Axis.vertical,
                                  child: Column(
                                    key: const Key("2"),
                                    children: surahUnderJuzs(index),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
        const Profile(),
      ].elementAt(currentIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: MediaQuery.of(context).size.width > 650
          ? FloatingActionButton.extended(
              onPressed: null,
              extendedPadding: EdgeInsets.zero,
              label: SalomonBottomBar(
                currentIndex: currentIndex,
                onTap: (i) => setState(() => currentIndex = i),
                selectedItemColor: const Color.fromARGB(255, 0, 207, 7),
                items: [
                  SalomonBottomBarItem(
                    icon: const Icon(FontAwesomeIcons.book),
                    title: const Text("Quran"),
                  ),
                  SalomonBottomBarItem(
                    icon: const Icon(Icons.person),
                    title: const Text("Profile"),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class SideBar extends StatelessWidget {
  final SidebarXController sidebarXController;
  const SideBar({super.key, required this.sidebarXController});

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: sidebarXController,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(10),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Color.fromARGB(255, 84, 235, 89),
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      footerDivider: divider,
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
            Get.to(() => const HomeMobile());
          },
        ),
        SidebarXItem(
          icon: Icons.favorite,
          label: 'Favorite',
          onTap: () {
            Get.to(() => const Favorite());
          },
        ),
        SidebarXItem(
          icon: Icons.bookmark_added,
          label: 'BookMark',
          onTap: () {
            Get.to(() => const BookMark());
          },
        ),
        SidebarXItem(
          icon: Icons.note_add,
          label: 'Notes',
          onTap: () {
            Get.to(() => const NotesView());
          },
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            Get.to(() => const SettingsWithAppbar());
          },
        ),
      ],
    );
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);
