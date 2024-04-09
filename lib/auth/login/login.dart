import 'dart:convert';

import 'package:al_bayan_quran/screens/home_mobile.dart';
import 'package:al_bayan_quran/theme/theme_controller.dart';
import 'package:appwrite/appwrite.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../theme/theme_icon_button.dart';
import '../account_info/account_info.dart';
import '../signin/signin.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("albayanquran")
      .setSelfSigned(status: true);
  late Account account;
  final accountInfo = Get.put(AccountInfo());

  Future<void> login(String email, String password) async {
    try {
      await account.createEmailPasswordSession(
          email: email, password: password);
      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      );
      final user = await account.get();
      if (user.status) {
        try {
          accountInfo.name.value = user.name;
          accountInfo.uid.value = user.$id;
          accountInfo.email.value = user.email;

          final accountInfoHiveBox = await Hive.openBox("accountInfo");
          accountInfoHiveBox.put("name", user.name.trim());
          accountInfoHiveBox.put("uid", user.$id);
          accountInfoHiveBox.put("email", email.trim());
          setState(() {
            isLoogedIn = true;
          });
          Databases databases = Databases(client);
          final document = await databases.getDocument(
              databaseId: "65bf585cdf62317b4d91",
              collectionId: "65bfa12aa542dc981ea8",
              documentId: user.$id);
          List listOfKey = jsonDecode(document.data['allnotes'] ?? "[]") ?? [];
          List<String> favorite = List<String>.from(
              jsonDecode(document.data['favorite'] ?? "[]") ?? []);
          List<String> bookmaek = List<String>.from(
              jsonDecode(document.data['bookmark'] ?? "[]") ?? []);

          final boxinf = Hive.box("info");
          boxinf.put("favorite", favorite);
          boxinf.put("bookmark", bookmaek);
          boxinf.put("bookmarkUploaded", true);
          boxinf.put("favoriteUploaded", true);

          final box = await Hive.openBox("notes");
          for (final key in listOfKey) {
            final singleNote = await databases.getDocument(
                databaseId: "65bf585cdf62317b4d91",
                collectionId: "65d1ca40a427099b17f1",
                documentId: user.$id + key);
            String boxKeyForTitle = "${key}title";
            String boxKeyForNote = "${key}note";
            String boxKeyForUpload = "${key}upload";

            box.put(boxKeyForNote, singleNote.data['note']);
            box.put(boxKeyForTitle, singleNote.data['title']);
            box.put(boxKeyForUpload, true);
          }
        } catch (e) {
          debugPrint(e.toString());
          Get.offAll(() => const HomeMobile());
        }

        Get.offAll(() => const HomeMobile());
      } else {
        // print("Failed while login");
      }
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("An Error Occoured!"),
          content: const Text(
              "Make Sure you have stable internet connection or already have an account."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    account = Account(client);

    super.initState();
  }

  FocusNode passwordFocusNode = FocusNode();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final validationKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 340,
            decoration: BoxDecoration(
              color: const Color.fromARGB(50, 150, 150, 150),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(120, 76, 175, 79),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      height: 50,
                      width: 50,
                      child: themeIconButton,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                    left: 10,
                    bottom: 30,
                  ),
                  child: Form(
                    key: validationKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          onEditingComplete: () {
                            FocusScope.of(context)
                                .requestFocus(passwordFocusNode);
                          },
                          validator: (value) {
                            if (EmailValidator.validate(value!)) {
                              return null;
                            } else {
                              return "Your email is not correct...";
                            }
                          },
                          controller: email,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(width: 3),
                            ),
                            labelText: "Email",
                            hintText: "Type your email here...",
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          onEditingComplete: () async {
                            await login(email.text, password.text);
                          },
                          validator: (value) {
                            if (value!.length >= 8) {
                              return null;
                            } else {
                              return "Password leangth should be at least 8...";
                            }
                          },
                          controller: password,
                          obscureText: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          focusNode: passwordFocusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: "Password",
                            hintText: "Type your password here...",
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            maximumSize: const Size(380, 50),
                            minimumSize: const Size(380, 50),
                          ),
                          onPressed: () async {
                            await login(email.text, password.text);
                          },
                          child: const Text(
                            "LogIn",
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Haven't account?"),
                            TextButton(
                              onPressed: () {
                                Get.off(() => const SignIn());
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
