import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// de-bounces [run] method calls and runs it only once in given [milliseconds]
class DeBouncer {
  /// de-bounce period
  final Duration duration;

  Timer? _timer;

  /// Allows to create an instance with optional [Duration]
  DeBouncer([Duration? duration])
      : duration = duration ?? const Duration(milliseconds: 300);

  /// Runs [action] after debounced interval.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// alias for [run]
  void call(VoidCallback action) => run.call(action);

  /// Allows to cancel current timer.
  void cancel() {
    _timer?.cancel();
  }
}

EditableTextState? findEditableTextState(BuildContext context) {
  EditableTextState? result;

  void visitor(Element element) {
    final Widget widget = element.widget;
    if (widget is EditableText) {
      final StatefulElement editableTextElement = element as StatefulElement;

      result = editableTextElement.state as EditableTextState;
      return;
    }
    element.visitChildren(visitor);
  }

  context.visitChildElements(visitor);
  return result;
}

extension TextSpanHelper on TextSpan {
  TextSpan copyWith({
    String? text,
    List<TextSpan>? children,
    TextStyle? style,
    GestureRecognizer? recognizer,
    MouseCursor? mouseCursor,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
    String? semanticsLabel,
    Locale? locale,
    bool? spellOut,
  }) {
    return TextSpan(
      text: text ?? this.text,
      children: children ?? this.children,
      style: style ?? this.style,
      recognizer: recognizer ?? this.recognizer,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      onEnter: onEnter ?? this.onEnter,
      onExit: onExit ?? this.onExit,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
      locale: locale ?? this.locale,
      spellOut: spellOut ?? this.spellOut,
    );
  }

  TextSpan merge(TextSpan other) {
    return TextSpan(
      text: text,
      style: style?.merge(other.style) ?? other.style,
    );
  }
}

extension TextSelectionHelper on TextSelection {
  TextSelection shift(int offset) => copyWith(
        baseOffset: baseOffset + offset,
        extentOffset: extentOffset + offset,
      );

  bool containsSelection(TextSelection other) {
    return baseOffset <= other.baseOffset && extentOffset >= other.extentOffset;
  }

  /// Gets the text selection that is not contained in [other]
  TextSelection negative(TextSelection other) => TextSelection(
        baseOffset: min(baseOffset, other.baseOffset),
        extentOffset: max(extentOffset, other.extentOffset),
      );
}

extension TextEditingValueHelper on TextEditingValue {
  int get start => selection.start;

  int get end => selection.end;
}

/// Detects any asymmetry with * or _ in one of the strings. returns a
/// [TextSelection] that represents where the asymmetry is.
///
/// Example:
/// ***test***  -> TextSelection.collapsed(offset: -1)
/// *__test___ -> TextSelection(baseOffset: 9, extentOffset: 10)
/// __*test*__*  -> TextSelection(baseOffset: 10, extentOffset: 11)
/// *****test*** -> TextSelection(baseOffset: 0, extentOffset: 2)
/// ***test***** -> TextSelection(baseOffset: 10, extentOffset: 12)
///
/// Processing starts from string center and outwards. So from the end of [a]
/// to start of [a], and from start of [b] to end of [b].
///
/// Results are returned relative to [a] & [b]
({
  TextSelection symmA,
  TextSelection symmB,
  TextSelection asymA,
  TextSelection asymB
}) findAsymmetry(String a, String b) {
  if (a == b) {
    return (
      symmA: TextSelection(baseOffset: 0, extentOffset: a.length),
      symmB: TextSelection(baseOffset: 0, extentOffset: b.length),
      asymA: const TextSelection.collapsed(offset: -1),
      asymB: const TextSelection.collapsed(offset: -1),
    );
  }
  final int shortestLength = min(a.length, b.length);

  final List<String?> aList = [...a.characters];
  final List<String?> bList = [...b.characters];

  for (int i = 0; i <= shortestLength - 1; i++) {
    final aIndex = a.length - 1 - i;
    final bIndex = i;
    final aChar = a.characters.characterAt(aIndex);
    final bChar = b.characters.characterAt(bIndex);

    if (aChar == bChar) {
      aList[aIndex] = null;
      bList[bIndex] = null;
    } else {
      break;
    }
  }

  final int aLength = aList.whereNotNull().length;
  final int bLength = bList.whereNotNull().length;

  return (
    symmA: aLength == 0
        ? TextSelection(baseOffset: 0, extentOffset: a.length)
        : TextSelection(
            baseOffset: aLength,
            extentOffset: a.length,
          ),
    asymA: aLength == 0
        ? const TextSelection.collapsed(offset: -1)
        : TextSelection(
            baseOffset: 0,
            extentOffset: aLength,
          ),
    symmB: bLength == 0
        ? TextSelection(baseOffset: 0, extentOffset: b.length)
        : TextSelection(
            baseOffset: 0,
            extentOffset: b.length - bLength,
          ),
    asymB: bLength == 0
        ? const TextSelection.collapsed(offset: -1)
        : TextSelection(
            baseOffset: b.length - bLength,
            extentOffset: b.length,
          ),
  );
}
