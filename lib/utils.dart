import 'dart:async';

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
}

extension TextEditingValueHelper on TextEditingValue {
  int get start => selection.start;

  int get end => selection.end;
}
