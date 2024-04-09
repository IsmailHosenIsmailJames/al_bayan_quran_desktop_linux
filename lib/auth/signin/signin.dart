import 'package:al_bayan_quran/auth/account_info/account_info.dart';
import 'package:al_bayan_quran/screens/home_mobile.dart';
import 'package:al_bayan_quran/theme/theme_icon_button.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

import '../../theme/theme_controller.dart';
import '../login/login.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final signUpValidationKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final name = TextEditingController();
  final confirmPass = TextEditingController();
  final password = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode confirmFocusNode = FocusNode();
  final accountInfo = Get.put(AccountInfo());

  Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("albayanquran")
      .setSelfSigned(status: true);
  late Account account;

  Future<void> register(String email, String password, String name) async {
    String userID = ID.unique();
    final user = await account.create(
      userId: userID,
      email: email.trim(),
      password: password,
      name: name.trim(),
    );

    if (user.status) {
      await account.createEmailPasswordSession(
          email: email, password: password);
      final user = await account.get();

      if (user.status) {
        accountInfo.name.value = name;
        accountInfo.uid.value = userID;
        accountInfo.email.value = email;

        final accountInfoHiveBox = await Hive.openBox("accountInfo");
        accountInfoHiveBox.put("name", name.trim());
        accountInfoHiveBox.put("uid", userID);
        accountInfoHiveBox.put("email", email.trim());

        setState(() {
          isLoogedIn = true;
        });

        Get.offAll(() => const HomeMobile());
      }
    }
  }

  models.User? loggedInUser;

  @override
  void initState() {
    account = Account(client);
    super.initState();
  }

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
                      "Sign Up",
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
                        child: themeIconButton),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                    left: 10,
                    bottom: 30,
                  ),
                  child: Form(
                    key: signUpValidationKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(emailFocusNode);
                          },
                          validator: (value) {
                            if (value!.length >= 3) {
                              return null;
                            } else {
                              return "Your name is not correct...";
                            }
                          },
                          controller: name,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(width: 3),
                            ),
                            labelText: "Name",
                            hintText: "Type your name here...",
                          ),
                        ),
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
                          focusNode: emailFocusNode,
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
                          onEditingComplete: () {
                            FocusScope.of(context)
                                .requestFocus(confirmFocusNode);
                          },
                          validator: (value) {
                            if (value!.length >= 8) {
                              return null;
                            } else {
                              return "Password leangth should be at least 8...";
                            }
                          },
                          controller: password,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          focusNode: passwordFocusNode,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(width: 3),
                            ),
                            labelText: "Password",
                            hintText: "Type your password here...",
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          onEditingComplete: () async {
                            await register(
                                email.text, password.text, name.text);
                          },
                          validator: (value) {
                            if (password.text == confirmPass.text &&
                                password.text != "") {
                              return null;
                            } else {
                              return "Password leangth should be at least 8...";
                            }
                          },
                          controller: confirmPass,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          focusNode: confirmFocusNode,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(width: 3),
                            ),
                            labelText: "Confirm Password",
                            hintText: "Type your password here again...",
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
                            register(email.text, password.text, name.text);
                          },
                          child: const Text(
                            "Sign In",
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
                            const Text("Have already an account?"),
                            TextButton(
                              onPressed: () {
                                Get.off(() => const LogIn());
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
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
