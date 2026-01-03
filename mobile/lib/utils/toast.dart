import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({
  required String message,
  bool isSuccess = true,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    backgroundColor: isSuccess ? const Color(0xFF1ED760) : Colors.red,
    textColor: Colors.white,
    fontSize: 14,
  );
}
