import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme_controller.dart';

Widget themeIconButton = GetX<AppThemeData>(
  builder: (controller) => IconButton(
    color: Colors.green.shade600,
    tooltip: "Change Theme",
    onPressed: () {
      if (controller.themeModeName.value == "dark") {
        controller.setTheme("light");
      } else if (controller.themeModeName.value == "light") {
        controller.setTheme("system");
      } else {
        controller.setTheme("dark");
      }
    },
    icon: controller.themeModeName.value == 'dark'
        ? const Icon(Icons.dark_mode)
        : controller.themeModeName.value == 'light'
            ? const Icon(Icons.light_mode)
            : const Icon(Icons.brightness_4),
  ),
);
