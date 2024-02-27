import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timerize/ui/input_decorations.dart';

class IncrementDecrement extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final String? labelText;
  final TextStyle? style;
  final int minValue;
  final int maxValue;
  final int? step;
  final TextEditingController controller;
  final Function? onChange;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  IncrementDecrement({
    super.key,
    this.padding,
    this.labelText,
    this.style,
    required this.minValue,
    required this.maxValue,
    this.step = 1,
    required this.controller,
    this.onChange,
    this.validator,
    focusNode,
  }) : focusNode = focusNode ?? FocusNode();

  @override
  State<IncrementDecrement> createState() => _IncrementDecrementState();
}

class _IncrementDecrementState extends State<IncrementDecrement> {
  @override
  void initState() {
    super.initState();

    if (widget.controller.text.isEmpty) {
      widget.controller.text = widget.minValue.toString();
    }

    widget.focusNode?.addListener(() {
      if (!widget.focusNode!.hasFocus) {
        _onLostFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Timer? timer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          style: widget.style,
          validator: widget.validator != null
              ? (value) => widget.validator!(value)
              : null,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
          focusNode: widget.focusNode,
          controller: widget.controller,
          keyboardType:
              Platform.isIOS ? TextInputType.none : TextInputType.number,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          maxLength: widget.maxValue.toString().characters.length,
          buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) =>
              null,
          onFieldSubmitted: (value) {
            widget.focusNode!.unfocus();
          },
          onChanged: (value) {
            if (widget.controller.text.isEmpty) {
              _setNewValue(value);
            } else if (int.parse(widget.controller.text) > widget.maxValue) {
              _setNewValue(widget.maxValue.toString());
            }

            if (widget.onChange != null) {
              widget.onChange!.call(widget.controller.text);
            }
          },
          decoration: InputDecorations.authInputDecoration(
            context,
            hintText: '',
            labelText: widget.labelText,
            prefix: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: InkWell(
                onTap: () {
                  widget.focusNode?.requestFocus();
                  _decrease();
                },
                child: GestureDetector(
                    onLongPress: () {
                      widget.focusNode?.requestFocus();
                      timer = Timer.periodic(const Duration(milliseconds: 50),
                          (timer) {
                        _decrease();
                      });
                    },
                    onLongPressUp: () {
                      timer?.cancel();
                    },
                    child: Padding(
                      padding: Platform.isIOS
                          ? const EdgeInsets.only(left: 8.0)
                          : EdgeInsets.zero,
                      child: Icon(
                        Icons.remove,
                        color: Theme.of(context).primaryColor,
                      ),
                    )),
              ),
            ),
            suffix: InkWell(
              onTap: () {
                widget.focusNode?.requestFocus();
                _increase();
              },
              child: GestureDetector(
                  onLongPress: () {
                    widget.focusNode?.requestFocus();
                    timer = Timer.periodic(const Duration(milliseconds: 50),
                        (timer) {
                      _increase();
                    });
                  },
                  onLongPressUp: () {
                    timer?.cancel();
                  },
                  child: Padding(
                    padding: Platform.isIOS
                        ? const EdgeInsets.only(right: 8.0)
                        : EdgeInsets.zero,
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                  )),
            ),
          ),
        ),
        Padding(
          padding: Platform.isIOS
              ? const EdgeInsets.only(top: 15.0)
              : EdgeInsets.zero,
        )
      ],
    );
  }

  _increase() {
    if (widget.controller.text.isEmpty) {
      _setNewValue((widget.minValue - widget.step!).toString());
    }

    var newValue = '';
    if (int.parse(widget.controller.text) < widget.maxValue) {
      newValue = (int.parse(widget.controller.text) + widget.step!).toString();
    } else {
      newValue = widget.maxValue.toString();
    }

    _setNewValue(newValue);

    if (widget.onChange != null) {
      widget.onChange!.call(newValue);
    }
  }

  _decrease() {
    if (widget.controller.text.isEmpty) {
      _setNewValue((widget.minValue + widget.step!).toString());
    }

    var newValue = '';
    if (int.parse(widget.controller.text) > widget.minValue) {
      newValue = (int.parse(widget.controller.text) - widget.step!).toString();

      _setNewValue(newValue);
    }

    if (widget.controller.text.isEmpty) {
      widget.controller.text = widget.minValue.toString();
    }

    if (widget.onChange != null) {
      widget.onChange!.call(newValue);
    }
  }

  void _onLostFocus() {
    int? value = int.tryParse(widget.controller.text) ?? widget.minValue;

    if ((widget.controller.text.isEmpty) || value < widget.minValue) {
      widget.controller.text = widget.minValue.toString();
    }

    if (widget.onChange != null) {
      widget.onChange!.call(widget.controller.text);
    }
  }

  void _setNewValue(String newValue) {
    widget.controller.value = widget.controller.value.copyWith(
      text: newValue,
      selection: TextSelection.collapsed(offset: newValue.length),
    );
  }
}
