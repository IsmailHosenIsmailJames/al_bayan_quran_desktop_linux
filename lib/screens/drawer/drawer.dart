import 'package:al_bayan_quran/auth/account_info/account_info.dart';
import 'package:al_bayan_quran/auth/login/login.dart';
import 'package:al_bayan_quran/screens/drawer/settings_with_appbar.dart';
import 'package:al_bayan_quran/screens/favorite_bookmark_notes/book_mark.dart';
import 'package:al_bayan_quran/screens/favorite_bookmark_notes/notes_v.dart';
import 'package:al_bayan_quran/screens/home_mobile.dart';
import 'package:al_bayan_quran/theme/theme_controller.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../theme/theme_icon_button.dart';
import '../favorite_bookmark_notes/favorite.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                        Scaffold.of(context).closeDrawer();
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
              Get.offAll(() => const HomeMobile());
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

              Get.to(
                () => const Favorite(),
              );
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

              Get.to(() => const BookMark());
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
              Get.to(() => const NotesView());
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

              Get.to(() => const SettingsWithAppbar());
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
  }
}
