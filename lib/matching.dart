import 'package:flutter/material.dart';

/// A class that wraps a [RegExpMatch]. It's main purpose is to be extended
/// by other classes that represent a specific type of match if type match
/// differentiation is necessary.
///
/// If the match type is not important, then this class can be used directly.
class RichMatch {
  /// The [RegExpMatch] that this class wraps.
  final RegExpMatch match;

  /// A helper getter that returns the full text of the match from the
  /// [match] that this class wraps.
  String get fullText => match.group(0)!;

  /// Creates a new [RichMatch] instance given a [match].
  const RichMatch(this.match);
}

/// A typedef that allows conversion of a given [match] to any specific
/// subtype of [RichMatch].
typedef MatchBuilder<T extends RichMatch> = T Function(RegExpMatch match);

/// A default match builder that simply returns a [RichMatch] instance given
/// a [match]. No subtyping is done.
T defaultMatchBuilder<T extends RichMatch>(RegExpMatch match) =>
    RichMatch(match) as T;

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
  final List<InlineSpan> Function(BuildContext, T, TextStyle?) _builder;

  /// Creates a new [StyleBuilder] instance given a [builder].
  const StyleBuilder(this._builder);

  /// Builds a [TextSpan] given an [input]. If the [input] is not of type [T],
  /// then an [ArgumentError] is thrown. This will properly cast [input] to [T]
  /// if it is of type [T].
  List<InlineSpan> build(BuildContext context, Object? input, TextStyle? style) {
    if (input is! T) throw ArgumentError.value(input, "input", "Not a $T");
    return _builder(context, input, style);
  }
}

/// Holds information on the [RegExp] to match any given text.
///
/// [MatchBuilder] is used to convert the resulting [RegExpMatch] to a specific
/// type of [RichMatch] if necessary for richer match data-parsing that gets
/// passed to [styleBuilder].
///
/// [StyleBuilder] is used to convert the resulting [RichMatch] to a list of
/// [TextSpan]s to format the match.
class RichMatcher<T extends RichMatch> {
  /// The [RegExp] to match any given text.
  final RegExp regex;

  /// The [StyleBuilder] to convert the resulting [RichMatch] to a list of
  /// [TextSpan]s to format the match.
  final StyleBuilder<T> styleBuilder;

  /// The [MatchBuilder] to convert the resulting [RegExpMatch] to a specific
  /// type of [RichMatch] if necessary for richer match data-parsing that gets
  /// passed to [styleBuilder].
  final MatchBuilder<T> matchBuilder;

  /// Creates a new [RichMatcher] instance given a [regex], [styleBuilder],
  /// and [matchBuilder].
  RichMatcher({
    required this.regex,
    required List<InlineSpan> Function(BuildContext, T, TextStyle?) styleBuilder,
    T Function(RegExpMatch match)? matchBuilder,
  })  : styleBuilder = StyleBuilder(styleBuilder),
        matchBuilder = matchBuilder ?? defaultMatchBuilder;
}
