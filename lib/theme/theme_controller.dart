import 'package:al_bayan_quran/auth/account_info/account_info.dart';
import 'package:al_bayan_quran/screens/getx_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

bool isLoogedIn = false;
String quranScriptType = "quran_tajweed";

class AppThemeData extends GetxController {
  RxString themeModeName = 'system'.obs;
  RxBool isDark = true.obs;

  void initTheme() async {
    final accountBox = Hive.box("accountInfo");
    final accountController = Get.put(AccountInfo());
    accountController.email.value = accountBox.get("email") ?? "";

    isLoogedIn =
        accountBox.get("email") != "" && accountBox.get("email") != null;
    accountController.name.value = accountBox.get("name") ?? "";
    accountController.uid.value = accountBox.get("uid") ?? "";
    final infoBox = Hive.box("info");
    final fonsize = Get.put(ScreenGetxController());

    fonsize.fontSizeArabic.value =
        infoBox.get("fontSizeArabic", defaultValue: 24.0);
    fonsize.fontSizeTranslation.value =
        infoBox.get("fontSizeTranslation", defaultValue: 15.0);
    quranScriptType =
        infoBox.get("quranScriptType", defaultValue: "quran_tajweed");
    fonsize.quranScriptTypeGetx.value =
        infoBox.get("quranScriptType", defaultValue: "quran_tajweed");

    final themePrefer = await Hive.openBox("theme");
    final String? userTheme = themePrefer.get('theme_preference');
    if (userTheme != null) {
      if (userTheme == 'light') {
        isDark.value = false;
        Get.changeThemeMode(ThemeMode.light);
        themeModeName.value = 'light';
        await themePrefer.put("theme_preference", themeModeName.value);
      } else if (userTheme == 'dark') {
        isDark.value = true;

        Get.changeThemeMode(ThemeMode.dark);
        themeModeName.value = 'dark';
        await themePrefer.put("theme_preference", themeModeName.value);
      } else if (userTheme == 'system') {
        Get.changeThemeMode(ThemeMode.system);
        themeModeName.value = 'system';
        Get.changeThemeMode(ThemeMode.system);
      }
    } else {
      await themePrefer.put('theme_preference', 'system');
      initTheme();
    }
  }

  void setTheme(String themeToChange) async {
    final themePrefer = await Hive.openBox("theme");
    if (themeToChange == 'light') {
      isDark.value = false;

      Get.changeThemeMode(ThemeMode.light);
      themeModeName.value = 'light';
      await themePrefer.put('theme_preference', themeModeName.value);
    } else if (themeToChange == 'dark') {
      isDark.value = true;

      themeModeName.value = 'dark';
      Get.changeThemeMode(ThemeMode.dark);
      await themePrefer.put('theme_preference', 'dark');
    } else if (themeToChange == 'system') {
      themeModeName.value = 'system';
      Get.changeThemeMode(ThemeMode.system);
      await themePrefer.put('theme_preference', 'system');
    }
  }
}
