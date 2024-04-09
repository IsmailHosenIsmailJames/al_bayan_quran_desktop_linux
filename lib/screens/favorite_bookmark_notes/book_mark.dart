import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import '../home_mobile.dart';
import 'get_data.dart';

class BookMark extends StatelessWidget {
  const BookMark({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> list = buildWidgetForFavBook(
      "bookmark",
    );
    return Scaffold(
      body: Row(
        children: [
          SideBar(
            sidebarXController: SidebarXController(
              selectedIndex: 2,
            ),
          ),
          Expanded(
            child: ListView(
              children: list.isEmpty
                  ? [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: Text("No Book Mark Found"),
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
