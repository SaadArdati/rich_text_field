import 'package:flutter/material.dart';

class RichSpan {
  final RichMatcher? matcher;
  final TextSelection selection;
  final String text;
  final TextStyle style;

  const RichSpan({
    required this.text,
    required this.matcher,
    required this.selection,
    required this.style,
  });

  RichSpan copyWith({
    RichMatcher? matcher,
    TextSelection? selection,
    String? text,
    TextStyle? style,
  }) =>
      RichSpan(
        matcher: matcher ?? this.matcher,
        selection: selection ?? this.selection,
        text: text ?? this.text,
        style: style ?? this.style,
      );

  @override
  String toString() =>
      "RichSpan(text: $text, selection: $selection, style: $style)";
}

/// A class that wraps a [RegExpMatch]. It's main purpose is to be extended
/// by other classes that represent a specific type of match if type match
/// differentiation is necessary.
///
/// If the match type is not important, then this class can be used directly.
class RichMatch {
  /// The [RegExpMatch] that this class wraps.
  final RegExpMatch match;

  /// [returns] the [TextSelection] of the [match] that
  /// this class wraps.
  late final TextSelection selection = TextSelection(
    baseOffset: match.start,
    extentOffset: match.end,
  );

  /// A helper getter that returns the full text of the match from the
  /// [match] that this class wraps.
  String get fullText => match.group(0)!;

  /// Creates a new [RichMatch] instance given a [match].
  RichMatch(this.match);

  @override
  String toString() => "RichMatch(match: $fullText)";
}

/// A default implementation of a match that was made using an opening and
/// closing text section, with content in between.
class EncapsulatedMatch extends RichMatch {
  final TextEditingValue opening;
  final TextEditingValue closing;
  final TextEditingValue content;

  EncapsulatedMatch(
    super.match, {
    required this.opening,
    required this.closing,
    required this.content,
  });
}

/// A default implementation of a match that was made using an opening text
/// section only, with content after it.
class StartMatch extends RichMatch {
  final TextEditingValue opening;
  final TextEditingValue content;

  StartMatch(
    super.match, {
    required this.opening,
    required this.content,
  });
}

/// A typedef that allows conversion of a given [match] to any specific
/// subtype of [RichMatch].
typedef MatchBuilder<T extends RichMatch> = T Function(RegExpMatch match);

/// A default match builder that simply returns a [RichMatch] instance given
/// a [match]. No subtyping is done.
T defaultMatchBuilder<T extends RichMatch>(RegExpMatch match) =>
    RichMatch(match) as T;

typedef EncapsulatedMatchTypeConverter<T extends RichMatch> = T Function(
    EncapsulatedMatch match);

T defaultEncapsulatedMatchBuilder<T extends EncapsulatedMatch>(
  RegExpMatch match,
  List<String> groupNames,
  EncapsulatedMatchTypeConverter<T> converter,
) {
  assert(groupNames.length == 3);
  print('groups: ${match.groupCount}');
  print('group names: ${match.groupNames.join(', ')}');
  print('group contents: ${match.groups([
        for (var i = 0; i < match.groupCount; i++) i
      ])}');
  final openingChar = match.namedGroup(groupNames[0])!;
  final contentString = match.namedGroup(groupNames[1])!;
  final closingChar = match.namedGroup(groupNames[2])!;

  final opening = TextEditingValue(
    text: openingChar,
    selection: TextSelection(
      baseOffset: match.start,
      extentOffset: match.start + 1,
    ),
  );
  final content = TextEditingValue(
    text: contentString,
    selection: TextSelection(
      baseOffset: match.start + 1,
      extentOffset: match.end - 1,
    ),
  );
  final closing = TextEditingValue(
    text: closingChar,
    selection: TextSelection(
      baseOffset: match.end - 1,
      extentOffset: match.end,
    ),
  );

  final encapsulatedMatch = EncapsulatedMatch(
    match,
    opening: opening,
    closing: closing,
    content: content,
  );

  return converter.call(encapsulatedMatch);
}

typedef RecurMatchBuilder = List<InlineSpan> Function(
  BuildContext context,
  String text,
);

/// A class that wraps a [StyleBuilder] function to convert a given [RichMatch]
/// or any of its subtypes to a list of [TextSpan]s to format the match.
///
/// This wrapper class is necessary to enforce proper type casting.
///
/// Function parameters are contravariant, and return types are covariant,
/// meaning that Dart cannot ensure type-safety when using generic types in
/// function parameters and will crash.
///
/// This class is used to enforce type-safety when using generic types in
/// function parameters by checking and casting the input to the correct type.
///
/// Reference: https://github.com/dart-lang/sdk/issues/52943
class StyleBuilder<T extends RichMatch> {
  /// The internal [StyleBuilder] function that this class wraps.
  final List<RichSpan> Function(BuildContext, T, TextStyle?) _builder;

  /// Creates a new [StyleBuilder] instance given a [builder].
  const StyleBuilder(this._builder);

  /// Builds a [TextSpan] given an [input]. If the [input] is not of type [T],
  /// then an [ArgumentError] is thrown. This will properly cast [input] to [T]
  /// if it is of type [T].
  List<RichSpan> build(BuildContext context, Object? input, TextStyle? style) {
    if (input is! T) throw ArgumentError.value(input, "input", "Not a $T");
    return _builder(context, input, style);
  }
}

/// A typedef that allows conversion of a given [value] to one that has format
/// symbols inserted into it to allow format detection.
///
/// It also allows adjustment of the selection position to account for the
/// inserted format symbols and ensure that the cursor is placed in the correct
/// position.
typedef SelectionFormatter = TextEditingValue Function(
  TextEditingValue value,
  String selectedText,
);

/// Holds information on the [RegExp] to match any given text.
///
/// [MatchBuilder] is used to convert the resulting [RegExpMatch] to a specific
/// type of [RichMatch] if necessary for richer match data-parsing that gets
/// passed to [styleBuilder].
///
/// [StyleBuilder] is used to convert the resulting [RichMatch] to a list of
/// [TextSpan]s to format the match.
abstract class RichMatcher<T extends RichMatch> {
  /// The [RegExp] to match any given text.
  final RegExp regex;

  /// The [MatchBuilder] to convert the resulting [RegExpMatch] to a specific
  /// type of [RichMatch] if necessary for richer match data-parsing that gets
  /// passed to [styleBuilder].
  final MatchBuilder<T> matchBuilder;

  /// Creates a new [RichMatcher] instance given a [regex], [styleBuilder],
  /// and [matchBuilder].
  RichMatcher({
    required this.regex,
    T Function(RegExpMatch match)? matchBuilder,
  }) : matchBuilder = matchBuilder ?? defaultMatchBuilder;

  /// Whether this matcher allows recursive matches. If true, then the matcher
  /// will be run on the resulting matches of this matcher. If false, then the
  /// matcher will stop formatting at itself.
  bool allowRecursiveMatches() => true;

  /// Given an arbitrarily [match]ed string, usages of this function ask this
  /// matcher whether the match can be claimed by this matcher. In other words,
  /// if the match can be formatted by this matcher.
  ///
  /// This is in contrast to regex-based matchers in that instead of returning a
  /// match from the [regex], this function is used by a splitMap operation that
  /// holds a large mixture of multiple regexes to identify which regex/matcher
  /// the match result came from instead of looping through every matcher to
  /// find the correct one, which can be horribly inefficient.
  bool canClaimMatch(String match);

  int numberOfGroups() => 3;

  /// The [StyleBuilder] to convert the resulting [RichMatch] to a list of
  /// [TextSpan]s to format the match.
  List<InlineSpan> styleBuilder(
    BuildContext context,
    T match,
    RecurMatchBuilder recurMatch,
  );

  /// The [StyleBuilder] to convert the resulting [RichMatch] to a list of
  /// [TextSpan]s to format the match but without any formatting symbols
  /// included in the result.
  List<InlineSpan> rasterizedStyleBuilder(
    BuildContext context,
    T match,
    RecurMatchBuilder recurMatch,
  );

  (RichSpan, RichSpan) splitSpan(RichSpan span, int index) {
    final first = span.copyWith(
      text: span.text.substring(0, index),
      selection: span.selection.copyWith(
        extentOffset: span.selection.start + index,
      ),
    );
    final second = span.copyWith(
      text: span.text.substring(index),
      selection: span.selection.copyWith(
        baseOffset: span.selection.start + index,
      ),
    );

    return (first, second);
  }

  (RichSpan, RichSpan, RichSpan) spliceSpan(
      RichSpan span, int index1, int index2) {
    final first = span.copyWith(
      text: span.text.substring(0, index1),
      selection: span.selection.copyWith(
        extentOffset: span.selection.start + index1,
      ),
    );
    final second = span.copyWith(
      text: span.text.substring(index1, index2),
      selection: span.selection.copyWith(
        baseOffset: span.selection.start + index1,
        extentOffset: span.selection.start + index2,
      ),
    );
    final third = span.copyWith(
      text: span.text.substring(index2),
      selection: span.selection.copyWith(
        baseOffset: span.selection.start + index2,
      ),
    );

    return (first, second, third);
  }
}
