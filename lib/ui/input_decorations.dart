import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration authInputDecoration(
    BuildContext context, {
    EdgeInsets? contentPadding,
    String? hintText,
    String? labelText,
    String? counterText,
    Widget? prefix,
    Widget? suffix,
    BorderRadius? borderRadius,
  }) {
    return InputDecoration(
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
      labelText: labelText,
      hintText: hintText,
      counterText: counterText,
      filled: true,
      fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        fontSize: 14.0,
        color: Theme.of(context).primaryColor,
      ),
      hintStyle: const TextStyle(
        fontSize: 14.0,
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
        borderSide:
            BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
    );
  }
}
