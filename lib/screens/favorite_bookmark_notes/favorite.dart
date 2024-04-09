import 'package:al_bayan_quran/screens/home_mobile.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import 'get_data.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  @override
  Widget build(BuildContext context) {
    List<Widget> list = buildWidgetForFavBook("favorite");
    return Scaffold(
      body: Row(
        children: [
          SideBar(
            sidebarXController: SidebarXController(
              selectedIndex: 1,
            ),
          ),
          Expanded(
            child: ListView(
              children: list.isEmpty
                  ? [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: Text("No Favorite Found."),
                        ),
                      )
                    ]
                  : list,
            ),
          ),
        ],
      ),
    );
  }
}
