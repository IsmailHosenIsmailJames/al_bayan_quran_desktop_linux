import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showTwoestedMessage(String message) {
  if (Platform.isAndroid || Platform.isIOS || kIsWeb) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
      fontSize: 14.0,
    );
  }
}
