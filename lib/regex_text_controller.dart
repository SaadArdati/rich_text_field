import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'rich_regexes.dart';
import 'utils.dart';

typedef MatchValidator = bool Function(String match, int start, int end);

typedef StyleBuilder = TextStyle? Function(TextStyle? style);

class AlwaysTrueMatchValidator {
  const AlwaysTrueMatchValidator();

  bool call(String match, int start, int end) => true;
}

class DefaultStyleBuilder {
  final Color? color;

  const DefaultStyleBuilder([this.color]);

  TextStyle? call(TextStyle? style) => style?.copyWith(color: color);
}

/// Represents configuration for text highlighting in [RegexTextEditingController].
///
/// [matchValidator] gives advanced control on whether a match should be
/// highlighted or not.
/// e.g When highlighting tagged usernames, a tag would match given regex but if
/// there is no user linked to it then it should not be highlighted.
///
/// Use [matchValidator] when you want to only modify a few properties of the
/// default style to create highlighting style. This allows to adapt to any
/// style changes to the input field. [matchValidator] exposes the default
/// style used in the input field.
class RegexTextHighlighter<T extends RichMatch> with EquatableMixin {
  final RegExp regex;
  final MatchValidator? matchValidator;
  final List<TextSpan> Function(T match) styleBuilder;

  const RegexTextHighlighter({
    required this.regex,
    required this.styleBuilder,
    this.matchValidator,
  });

  @override
  List<Object?> get props => [regex];
}

class RegexMatch {
  final Match match;
  final RichMatcher matcher;

  const RegexMatch(this.match, this.matcher);
}

bool _defaultShouldDebounceFormatting(String text) => text.length > 1000;

/// A [TextEditingController] that can highlight regex matched text with
/// different styles.
/// [matchers] defines configuration for regexes and styles.
class RegexTextEditingController extends TextEditingController {
  final List<RichMatcher> matchers;
  final bool Function(String text) shouldDebounceFormatting;

  // final DeBouncer _debouncer = DeBouncer(Duration(milliseconds: 300));
  String? _lastText;
  TextStyle _style = const TextStyle();
  TextSpan? _span;

  RegexTextEditingController({
    this.matchers = const [],
    super.text = '',
    this.shouldDebounceFormatting = _defaultShouldDebounceFormatting,
  });

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

  TextSpan format({
    TextStyle? style,
  }) {
    if (matchers.isEmpty) {
      // don't proceed further if no highlighters are provided.
      onAllMatchesFound([]);
      return TextSpan(text: text, style: style);
    }

    final List<InlineSpan> children = [];
    final List<RichMatch> allMatches = [];

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
        print('matchBuilder: ${matcher.matchBuilder.runtimeType}');
        print('   richMatch: ${richMatch.runtimeType}');
        print('styleBuilder: ${matcher.styleBuilder.runtimeType}');
        // children.addAll(onMatch(matcher, richMatch, style));
        print('successful match on $textPart');
        allMatches.add(richMatch);
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
      return format(style: style);
    }

    if (style != _style) {
      _style = style ?? const TextStyle();
      _span = format(style: _style);
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

  @protected
  List<TextSpan> getHighlightingStyle<T extends RichMatch>(
    RichMatcher<T> matcher,
    T match,
    TextStyle? style,
  ) {
    print('       match: ${match.runtimeType}');
    final style = matcher.styleBuilder(match);

    return style;
  }

  /// Called when a match is found in [text] that matches one of the regexes.
  /// A highlighted [TextSpan] should be returned which will be displayed in
  /// the input field.
  @protected
  List<TextSpan> onMatch<T extends RichMatch>(
      RichMatcher<T> matcher, T match, TextStyle? style) {
    return getHighlightingStyle(matcher, match, style);
  }

  /// Called for parts of [text] that does not match with any regexes.
  @protected
  InlineSpan onNonMatch(String span, TextStyle? style) =>
      TextSpan(text: span, style: style);

  /// Called when all regex matching is done and all the matches have
  /// been collected.
  /// This can be used to collect and manage all matching texts.
  @protected
  void onAllMatchesFound(List<RichMatch> matches) {}
}
