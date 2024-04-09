import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import '../home_mobile.dart';
import 'notes_get_data.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> list = buildListOfWidgetForNotes();
    return Scaffold(
      body: Row(
        children: [
          SideBar(
            sidebarXController: SidebarXController(
              selectedIndex: 3,
            ),
          ),
          Expanded(
            child: ListView(
              children: list.isEmpty
                  ? [
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: Text("No Notes found"),
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
