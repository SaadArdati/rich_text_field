import 'package:flutter/material.dart';
import 'package:screwdriver/screwdriver.dart';

import 'matchers/matchers.dart';
import 'matchers/mono_space_matcher.dart';
import 'matching.dart';

bool _defaultShouldDebounceFormatting(String text) => text.length > 1000;

/// A [TextEditingController] that can highlight regex matched text with
/// different styles.
/// [matchers] defines configuration for regexes and styles.
class RichTextEditingController extends TextEditingController {
  final List<RichMatcher> matchers;

  // final bool Function(String text) shouldDebounceFormatting;

  final Map<RichMatcher, List<RichMatch>> matches = {};

  // final DeBouncer _debouncer = DeBouncer(Duration(milliseconds: 300));

  String? _lastText;
  TextStyle _style = const TextStyle();
  TextSpan? _span;

  TextSelection? _lastSelection;

  RichTextEditingController({
    super.text = '',
    List<RichMatcher>? matchers,
    // this.shouldDebounceFormatting = _defaultShouldDebounceFormatting,
  }) : matchers = matchers ??
            [
              BoldMatcher(),
              ItalicMatcher(),
              StrikeThroughMatcher(),
              HeadingMatcher(),
              BlockQuoteMatcher(),
              CodeBlockMatcher(),
              MonoSpaceMatcher(),
            ];

  @override
  set value(TextEditingValue newValue) {
    // if (shouldDebounceFormatting(newValue.text)) {
    //   if (_lastText != newValue.text) {
    //     _span = null;
    //     _lastText = newValue.text;
    //     // _debouncer.run(() {
    //     //   _span = format(style: _style);
    //     //   if (hasListeners) {
    //     //     notifyListeners();
    //     //   }
    //     // });
    //   }
    // }
    super.value = newValue;
  }

  @override
  set selection(TextSelection newSelection) {
    _lastSelection = selection;

    super.selection = newSelection;
  }

  void restoreLastSelection() {
    if (_lastSelection != null) {
      selection = _lastSelection!;
    }
  }

  TextSpan getBetterFormattedText(
    BuildContext context, {
    required String text,
    required TextStyle style,
    bool rasterized = false,
  }) {
    if (matchers.isEmpty) {
      // don't proceed further if no highlighters are provided.
      onAllMatchesFound({});
      return TextSpan(text: text, style: style);
    }

    final String pattern =
        matchers.map((matcher) => matcher.regex.pattern).join('|');
    print('pattern: $pattern');
    final RegExp regex = RegExp(pattern, multiLine: true);

    return matchText(context, text, regex, rasterized: rasterized);
  }

  TextSpan matchText(
    BuildContext context,
    String text,
    RegExp regex, {
    required bool rasterized,
  }) {
    final List<InlineSpan> spans = text.splitMap<InlineSpan>(
      regex,
      onMatch: (match) {
        final String text = match[0]!;
        final RichMatcher matcher = matchers.firstWhere(
          (entry) => entry.canClaimMatch(text),
        );

        final RichMatch richMatch = matcher.mapMatch(match);

        return TextSpan(
          children: onMatch(
            context,
            matcher: matcher,
            match: richMatch,
            rasterized: rasterized,
            recurMatch: (context, text) => [
              matchText(context, text, regex, rasterized: rasterized),
            ],
          ),
        );
      },
      onNonMatch: (nonMatch) {
        return TextSpan(text: nonMatch);
      },
    );
    return TextSpan(children: spans);
  }

  TextSpan _format(
    BuildContext context, {
    TextStyle? style,
    bool rasterized = false,
  }) {
    if (matchers.isEmpty) {
      // don't proceed further if no highlighters are provided.
      onAllMatchesFound({});
      return TextSpan(text: text, style: style);
    }

    return getBetterFormattedText(
      context,
      text: text,
      style: style ?? const TextStyle(),
      rasterized: rasterized,
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // if (!shouldDebounceFormatting(text)) {
    return _format(context, style: style);
    // }

    // if (style != _style) {
    //   _style = style ?? const TextStyle();
    //   _span = _format(context, style: _style);
    // }
    // if (_span == null) {
    //   return super.buildTextSpan(
    //     context: context,
    //     style: style,
    //     withComposing: withComposing,
    //   );
    // }
    // return _span!;
  }

  /// Called when a match is found in [text] that matches one of the regexes.
  /// A highlighted [TextSpan] should be returned which will be displayed in
  /// the input field.
  List<InlineSpan> onMatch<T extends RichMatch>(
    BuildContext context, {
    required RichMatcher<T> matcher,
    required T match,
    required RecurMatchBuilder recurMatch,
    bool rasterized = false,
  }) =>
      rasterized
          ? matcher.styleBuilder(context, match, recurMatch)
          : matcher.inlineStyleBuilder(context, match, recurMatch);

  /// Called for parts of [text] that does not match with any regexes.
  RichSpan onNonMatch(String span, TextSelection selection, TextStyle style) =>
      RichSpan(matcher: null, selection: selection, text: span, style: style);

  /// Called when all regex matching is done and all the matches have
  /// been collected.
  /// This can be used to collect and manage all matching texts.
  void onAllMatchesFound(Map<RichMatcher, List<RichMatch>> matches) {
    this.matches
      ..clear()
      ..addAll(matches);
  }
}
