import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

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

extension StringExt on String {
  /// [String.splitMapJoin] is limited to [Pattern] which can only do [Match]
  /// and not [RegExpMatch]. Because of this, you can't access named groups
  /// inside the pattern. This function fixes that.
  /// Ref: https://github.com/dart-lang/sdk/issues/52721
  String splitMapJoinRegex(
    RegExp pattern, {
    String Function(RegExpMatch match)? onMatch,
    String Function(String text)? onNonMatch,
  }) {
    return splitMapJoin(
      pattern,
      onMatch: onMatch != null
          ? (match) {
              match as RegExpMatch;
              return onMatch(match);
            }
          : null,
      onNonMatch: onNonMatch != null
          ? (text) {
              return onNonMatch(text);
            }
          : null,
    );
  }

  Iterable<R> splitMap<R>(
    RegExp pattern, {
    R Function(RegExpMatch match)? onMatch,
    R Function(String text)? onNonMatch,
  }) {
    List<R> result = [];
    splitMapJoinRegex(
      pattern,
      onMatch: onMatch != null
          ? (match) {
              result.add(onMatch(match));
              return match[0]!;
            }
          : null,
      onNonMatch: onNonMatch != null
          ? (text) {
              result.add(onNonMatch(text));
              return text;
            }
          : null,
    );
    return result;
  }
}
