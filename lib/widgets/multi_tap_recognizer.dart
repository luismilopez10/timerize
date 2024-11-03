import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MultiTapRecognizer extends StatelessWidget {
  const MultiTapRecognizer({
    required this.taps,
    required this.onMultiTap,
    required this.child,
    super.key,
  });

  final int taps;
  final VoidCallback onMultiTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        SerialTapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<SerialTapGestureRecognizer>(
          SerialTapGestureRecognizer.new,
          (SerialTapGestureRecognizer instance) {
            instance.onSerialTapDown = (SerialTapDownDetails details) {
              if (details.count % taps == 0) {
                onMultiTap();
              }
            };
          },
        ),
      },
      child: child,
    );
  }
}
