import 'package:flutter/material.dart';

import 'default_regexes.dart';
import 'matchers/bold_matcher.dart';
import 'matchers/heading_matcher.dart';
import 'matchers/italics_matcher.dart';
import 'matchers/strike_through_matcher.dart';
import 'matching.dart';
import 'utils.dart';

bool _defaultShouldDebounceFormatting(String text) => text.length > 1000;

/// A [TextEditingController] that can highlight regex matched text with
/// different styles.
/// [matchers] defines configuration for regexes and styles.
class RichTextEditingController extends TextEditingController {
  final List<RichMatcher> matchers;
  final bool Function(String text) shouldDebounceFormatting;

  final Map<RichMatcher, List<RichMatch>> matches = {};

  // final DeBouncer _debouncer = DeBouncer(Duration(milliseconds: 300));

  String? _lastText;
  TextStyle _style = const TextStyle();
  TextSpan? _span;

  TextSelection? _lastSelection;

  RichTextEditingController({
    super.text = '',
    List<RichMatcher>? matchers,
    this.shouldDebounceFormatting = _defaultShouldDebounceFormatting,
  }) : matchers = matchers ??
            [
              boldMatcher,
              italicMatcher,
              strikeThroughMatcher,
              headingMatcher,
            ];

  @override
  set value(TextEditingValue newValue) {
    if (shouldDebounceFormatting(newValue.text)) {
      if (_lastText != newValue.text) {
        _span = null;
        _lastText = newValue.text;
        // _debouncer.run(() {
        //   _span = format(style: _style);
        //   if (hasListeners) {
        //     notifyListeners();
        //   }
        // });
      }
    }
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

  TextSpan getFormattedText(
    BuildContext context, {
    TextStyle? style,
    bool rasterized = false,
  }) {
    if (matchers.isEmpty) {
      // don't proceed further if no highlighters are provided.
      onAllMatchesFound({});
      return TextSpan(text: text, style: style);
    }

    final List<InlineSpan> children = [];
    final Map<RichMatcher, List<RichMatch>> allMatches = {};

    // Combines all the highlighter regex to create a single almighty regex.
    // List(start, end)
    final RegExp allRegex =
        RegExp(matchers.map((item) => item.regex.pattern).join('|'));
    text.splitMapJoinRegex(
      allRegex,
      onMatch: (RegExpMatch combinedMatch) {
        final String textPart = combinedMatch[0]!;

        final RichMatcher? matcher = matchers.firstWhereOrNull(
          (matcher) => matcher.regex
              .allMatches(text)
              .any((match) => match[0] == textPart),
        );

        if (matcher == null) {
          children.add(onNonMatch(textPart, style));
          return '';
        }

        final RegExpMatch subMatch = matcher.regex.firstMatch(textPart)!;
        final RichMatch richMatch = matcher.matchBuilder(subMatch);
        children.addAll(
          onMatch(
            context,
            matcher: matcher,
            match: richMatch,
            style: style,
            rasterized: rasterized,
          ),
        );
        allMatches.putIfAbsent(matcher, () => []).add(richMatch);
        return '';
      },
      onNonMatch: (span) {
        children.add(onNonMatch(span, style));
        return '';
      },
    );
    return TextSpan(style: style, children: children);
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

    final List<InlineSpan> children = [];
    final Map<RichMatcher, List<RichMatch>> allMatches = {};

    // Combines all the highlighter regex to create a single almighty regex.
    // List(start, end)
    final RegExp allRegex =
        RegExp(matchers.map((item) => item.regex.pattern).join('|'));
    text.splitMapJoinRegex(
      allRegex,
      onMatch: (RegExpMatch combinedMatch) {
        final String textPart = combinedMatch[0]!;

        final RichMatcher? matcher = matchers.firstWhereOrNull(
          (matcher) => matcher.regex
              .allMatches(text)
              .any((match) => match[0] == textPart),
        );

        if (matcher == null) {
          children.add(onNonMatch(textPart, style));
          return '';
        }

        final RegExpMatch subMatch = matcher.regex.firstMatch(textPart)!;
        final RichMatch richMatch = matcher.matchBuilder(subMatch);
        children.addAll(
          onMatch(
            context,
            matcher: matcher,
            match: richMatch,
            style: style,
            rasterized: rasterized,
          ),
        );
        allMatches.putIfAbsent(matcher, () => []).add(richMatch);
        return '';
      },
      onNonMatch: (span) {
        children.add(onNonMatch(span, style));
        return '';
      },
    );
    onAllMatchesFound(allMatches);

    return TextSpan(style: style, children: children);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (!shouldDebounceFormatting(text)) {
      return _format(context, style: style);
    }

    if (style != _style) {
      _style = style ?? const TextStyle();
      _span = _format(context, style: _style);
    }
    if (_span == null) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    return _span!;
  }

  /// Called when a match is found in [text] that matches one of the regexes.
  /// A highlighted [TextSpan] should be returned which will be displayed in
  /// the input field.
  List<InlineSpan> onMatch<T extends RichMatch>(
    BuildContext context, {
    required RichMatcher<T> matcher,
    required T match,
    TextStyle? style,
    bool rasterized = false,
  }) =>
      rasterized
          ? matcher.rasterizedStyleBuilder.build(context, match, style)
          : matcher.styleBuilder.build(context, match, style);

  /// Called for parts of [text] that does not match with any regexes.
  InlineSpan onNonMatch(String span, TextStyle? style) =>
      TextSpan(text: span, style: style);

  /// Called when all regex matching is done and all the matches have
  /// been collected.
  /// This can be used to collect and manage all matching texts.
  void onAllMatchesFound(Map<RichMatcher, List<RichMatch>> matches) {
    this.matches
      ..clear()
      ..addAll(matches);
  }
}
