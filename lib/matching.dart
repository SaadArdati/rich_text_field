import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'rich_text_controller.dart';
import 'utils.dart';

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
class RichMatch with EquatableMixin {
  /// The [RegExpMatch] that this class wraps.
  final RegExpMatch match;

  /// The entire selection of this match, relative to the entire text.
  final TextSelection completeSelection;

  /// A helper getter that returns the full text of the match from the
  /// [match] that this class wraps.
  String get fullText => match.group(0)!;

  /// Creates a new [RichMatch] instance given a [match].
  RichMatch(this.match, {required this.completeSelection});

  @override
  String toString() => "RichMatch(match: $fullText)";

  @override
  List<Object?> get props => [match.start, match.end, fullText];
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
  }) : super(
          completeSelection: TextSelection(
            baseOffset: opening.selection.start,
            extentOffset: closing.selection.end,
          ),
        );
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
  }) : super(
          completeSelection: TextSelection(
            baseOffset: opening.selection.start,
            extentOffset: content.selection.end,
          ),
        );
}

/// A typedef that allows conversion of a given [match] to any specific
/// subtype of [RichMatch].
typedef MatchBuilder<T extends RichMatch> = T Function(RegExpMatch match);

/// A default match builder that simply returns a [RichMatch] instance given
/// a [match]. No subtyping is done.
T defaultMatchBuilder<T extends RichMatch>(
        RegExpMatch match, int selectionOffset) =>
    RichMatch(
      match,
      completeSelection: TextSelection(
        baseOffset: match.start,
        extentOffset: match.end,
      ).shift(selectionOffset),
    ) as T;

typedef EncapsulatedMatchTypeConverter<T extends RichMatch> = T Function(
    EncapsulatedMatch match);

T defaultEncapsulatedMatchBuilder<T extends EncapsulatedMatch>(
  RegExpMatch match,
  List<String> groupNames,
  EncapsulatedMatchTypeConverter<T> converter, {
  required int selectionOffset,
}) {
  assert(groupNames.length == 3);
  final openingChar = match.namedGroup(groupNames[0])!;
  final contentString = match.namedGroup(groupNames[1])!;
  final closingChar = match.namedGroup(groupNames[2])!;

  // print('selectionOffset: $selectionOffset');

  final opening = TextEditingValue(
    text: openingChar,
    selection: TextSelection(
      baseOffset: match.start,
      extentOffset: match.start + 1,
    ).shift(selectionOffset),
  );
  final content = TextEditingValue(
    text: contentString,
    selection: TextSelection(
      baseOffset: match.start + 1,
      extentOffset: match.end - 1,
    ).shift(selectionOffset),
  );
  final closing = TextEditingValue(
    text: closingChar,
    selection: TextSelection(
      baseOffset: match.end - 1,
      extentOffset: match.end,
    ).shift(selectionOffset),
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
  TextEditingValue value,
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
/// passed to [inlineStyleBuilder].
///
/// [StyleBuilder] is used to convert the resulting [RichMatch] to a list of
/// [TextSpan]s to format the match.
abstract class RichMatcher<T extends RichMatch> {
  /// The [RegExp] to match any given text.
  final RegExp regex;

  /// The group names that the [regex] collects in encapsulating group matchers.
  /// The [regex] *must* contain a named group.
  final List<String> groupNames;

  /// Creates a new [RichMatcher] instance given a [regex], [inlineStyleBuilder],
  /// and [mapMatch].
  const RichMatcher({
    required this.regex,
    required this.groupNames,
  });

  /// Whether this matcher allows recursive matches. If true, then the matcher
  /// will be run on the resulting matches of this matcher. If false, then the
  /// matcher will stop formatting at itself.
  bool allowRecursiveMatches() => true;

  /// The [MatchBuilder] to convert the resulting [RegExpMatch] to a specific
  /// type of [RichMatch] if necessary for richer match data-parsing that gets
  /// passed to [inlineStyleBuilder].
  T mapMatch(
    RegExpMatch match, {
    required int selectionOffset,
  }) =>
      defaultMatchBuilder(match, selectionOffset);

  /// The [StyleBuilder] to convert the resulting [RichMatch] to a list of
  /// [TextSpan]s to format the match.
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    T match,
    RecurMatchBuilder recurMatch,
  );

  /// The [StyleBuilder] to convert the resulting [RichMatch] to a list of
  /// [TextSpan]s to format the match but without any formatting symbols
  /// included in the result.
  List<InlineSpan> styleBuilder(
    BuildContext context,
    T match,
    RecurMatchBuilder recurMatch,
  );

  void applyFormatting(RichTextEditingController controller) {}

  Widget? contextMenuButton(
    BuildContext context,
    RichTextEditingController controller,
  ) =>
      null;

  Widget? toolbarButton(BuildContext context, VoidCallback onPressed) => null;
}
