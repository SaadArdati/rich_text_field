import 'package:flutter/material.dart';
import 'package:screwdriver/screwdriver.dart';

import 'matchers/italic_bold_matcher.dart';
import 'matchers/matchers.dart';
import 'matching.dart';
import 'utils.dart';

typedef SelectionChangedEvent = void Function(TextSelection newSelection);

bool _defaultShouldDebounceFormatting(String text) => text.length > 1000;

/// A [TextEditingController] that can highlight regex matched text with
/// different styles.
/// [matchers] defines configuration for regexes and styles.
class RichTextEditingController extends TextEditingController {
  final List<RichMatcher> matchers;

  // final bool Function(String text) shouldDebounceFormatting;

  final Map<RichMatcher, Set<RichMatch>> matches = {};

  // final DeBouncer _debouncer = DeBouncer(Duration(milliseconds: 300));

  String? _lastText;
  TextStyle _style = const TextStyle();
  TextSpan? _span;

  ValueNotifier<TextSelection?> selectionNotifier =
      ValueNotifier<TextSelection?>(null);
  TextSelection? _lastSelection;

  TextSelection? get lastSelection => _lastSelection;

  final SelectionChangedEvent? onSelectionChanged;

  RichTextEditingController({
    super.text = '',
    List<RichMatcher>? matchers,
    this.onSelectionChanged,
    // this.shouldDebounceFormatting = _defaultShouldDebounceFormatting,
  }) : matchers = matchers ??
            [
              BoldMatcher(),
              ItalicMatcher(),
              ItalicBoldMatcher(),
              StrikeThroughMatcher(),
              HeadingMatcher(),
              BlockQuoteMatcher(),
              CodeBlockMatcher(),
              MonoSpaceMatcher(),
              BulletLineMatcher(),
              LinkMatcher(),
              NumberedLineMatcher(),
              HorizontalLineMatcher(),
              EmojiMatcher(),
              SubscriptMatcher(),
              SuperscriptMatcher(),
            ];

  @override
  void dispose() {
    selectionNotifier.dispose();
    super.dispose();
  }

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
    selectionNotifier.value = newSelection;

    _lastSelection = selection;

    super.selection = newSelection;

    onSelectionChanged?.call(newSelection);
  }

  void restoreLastSelection() {
    if (_lastSelection != null) {
      selection = _lastSelection!;
    }
  }

  TextSpan buildRichFormattedSpan(
    BuildContext context, {
    required String text,
    required TextStyle style,
    bool rasterized = false,
  }) {
    matches.clear();

    if (matchers.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final String pattern =
        matchers.map((matcher) => matcher.regex.pattern).join('|');
    final RegExp regex = RegExp(pattern, multiLine: true);

    return TextSpan(
      children: _recursivelyBuildSpans(
        context,
        text,
        regex,
        rasterized: rasterized,
      ),
    );
  }

  List<InlineSpan> _recursivelyBuildSpans(
    BuildContext context,
    String text,
    RegExp regex, {
    required bool rasterized,
    int selectionOffset = 0,
  }) {
    final List<InlineSpan> spans = text.splitMap<InlineSpan>(
      regex,
      onMatch: (RegExpMatch match) {
        final RichMatcher matcher = matchers.firstWhere((matcher) {
          for (final String groupName in matcher.groupNames) {
            final String? value = match.namedGroup(groupName);

            if (value != null) return true;
          }

          return false;
        });

        final RichMatch richMatch = matcher.mapMatch(
          match,
          selectionOffset: selectionOffset,
        );

        return TextSpan(
          children: onMatch(
            context,
            matcher: matcher,
            match: richMatch,
            rasterized: rasterized,
            recurMatch: (context, value) => _recursivelyBuildSpans(
              context,
              value.text,
              regex,
              rasterized: rasterized,
              selectionOffset: value.start,
            ),
          ),
        );
      },
      onNonMatch: (nonMatch) {
        return TextSpan(text: nonMatch);
      },
    );

    return spans;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // if (!shouldDebounceFormatting(text)) {
    return buildRichFormattedSpan(
      context,
      text: text,
      style: style ?? const TextStyle(),
      rasterized: false,
    );
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
  }) {
    matches.putIfAbsent(matcher, () => {}).add(match);
    return rasterized
        ? matcher.styleBuilder(context, match, recurMatch)
        : matcher.inlineStyleBuilder(context, match, recurMatch);
  }

  /// Called for parts of [text] that does not match with any regexes.
  RichSpan onNonMatch(String span, TextSelection selection, TextStyle style) =>
      RichSpan(matcher: null, selection: selection, text: span, style: style);
}
