import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class Helpers {
  static String formatTimeText(int totalTimeInSeconds) {
    return '';
  }

  static void displayToast(String message, BuildContext context) {
    showToast(
      message,
      context: context,
      animation: StyledToastAnimation.slideFromBottom,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.bottom,
      animDuration: const Duration(milliseconds: 500),
      duration: const Duration(seconds: 3),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
      // backgroundColor: Theme.of(context).primaryColorDark,
    );
  }
}
