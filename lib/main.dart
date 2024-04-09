import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

import 'collect_info/init.dart';
import 'theme/theme_controller.dart';
import 'package:appwrite/appwrite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Client client = Client();
  client
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('albayanquran')
      .setSelfSigned(status: true);
  await Hive.initFlutter("al_bayan_quran");
  await Hive.openBox("info");
  await Hive.openBox("data");
  await Hive.openBox("accountInfo");
  await Hive.openBox("notes");
  await Hive.openBox("quran");
  await Hive.openBox("translation");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Al-Quran',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.grey.shade800),
      ),
      themeMode: ThemeMode.system,
      onInit: () async {
        final appTheme = Get.put(AppThemeData());
        appTheme.initTheme();
      },
      home: const StartUpPage(),
    );
  }
}

class StartUpPage extends StatefulWidget {
  const StartUpPage({super.key});

  @override
  State<StartUpPage> createState() => _StartUpPageState();
}

class _StartUpPageState extends State<StartUpPage> {
  @override
  Widget build(BuildContext context) {
    return const InIt();
  }
}
