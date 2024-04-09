import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import '../home_mobile.dart';
import '../settings/settings.dart';

class SettingsWithAppbar extends StatelessWidget {
  const SettingsWithAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(
            sidebarXController: SidebarXController(
              selectedIndex: 4,
            ),
          ),
          const Expanded(
            child: Settings(
              showNavigator: false,
            ),
          ),
        ],
      ),
    );
  }
}
