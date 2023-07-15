import 'package:flutter/material.dart';

import 'regex_text_controller.dart';

abstract class RichMatch {
  final RegExpMatch match;

  const RichMatch(this.match);
}

class EncapsulatedMatch extends RichMatch {
  final TextEditingValue openingChar;
  final TextEditingValue closingChar;
  final TextEditingValue content;

  const EncapsulatedMatch(
    super.match, {
    required this.openingChar,
    required this.closingChar,
    required this.content,
  });
}

class BoldMatch extends EncapsulatedMatch {
  const BoldMatch(
    super.match, {
    required super.openingChar,
    required super.closingChar,
    required super.content,
  });
}

class ItalicMatch extends EncapsulatedMatch {
  const ItalicMatch(
    super.match, {
    required super.openingChar,
    required super.closingChar,
    required super.content,
  });
}

typedef StyleBuilder<T extends RichMatch> = List<TextSpan> Function(T match);
typedef MatchBuilder<T extends RichMatch> = T Function(RegExpMatch match);

class RichMatcher<T extends RichMatch> {
  final RegExp regex;
  final StyleBuilder<T> styleBuilder;
  final MatchBuilder<T> matchBuilder;
  final MatchValidator? matchValidator;

  RichMatcher({
    required this.regex,
    required this.styleBuilder,
    required this.matchBuilder,
    this.matchValidator,
  });
}

const String bold = r'''(\*)([^*\n]+)(\*)''';
const String italic = r'''(_)([^_\n]+)(_)''';
const String strikeThr = r'''(~)([^~\n]+)(~)''';
const String link = r'''(\[)([^\]]+)(\]\()([^)]+)(\))''';
const String image = r'''(\!\[)([^\]]+)(\]\()([^)]+)(\))''';
const String code = r'''(`)([^`\n]+)(`)''';

final RegExp boldRegex = RegExp(bold);
final RegExp italicRegex = RegExp(italic);
final RegExp strikeThrRegex = RegExp(strikeThr);
final RegExp linkRegex = RegExp(link);
final RegExp imageRegex = RegExp(image);
final RegExp codeRegex = RegExp(code);

EncapsulatedMatch encapsulatedMatchBuilder(RegExpMatch match) {
  final openingChar = match.group(1)!;
  final contentString = match.group(2)!;
  final closingChar = match.group(3)!;

  final TextEditingValue opening = TextEditingValue(
    text: openingChar,
    selection: TextSelection.collapsed(
      offset: match.start,
    ),
  );
  final TextEditingValue content = TextEditingValue(
    text: contentString,
    selection: TextSelection.collapsed(
      offset: match.start + match.end - 2,
    ),
  );
  final TextEditingValue closing = TextEditingValue(
    text: closingChar,
    selection: TextSelection.collapsed(
      offset: match.end - 1,
    ),
  );

  return EncapsulatedMatch(
    match,
    openingChar: opening,
    closingChar: closing,
    content: content,
  );
}

final RichMatcher strikeThroughMatcher = RichMatcher<EncapsulatedMatch>(
  regex: strikeThrRegex,
  styleBuilder: (EncapsulatedMatch match) => [
    TextSpan(
      text: match.openingChar.text,
      style: const TextStyle(color: Colors.grey),
    ),
    TextSpan(
      text: match.content.text,
      style: const TextStyle(decoration: TextDecoration.lineThrough),
    ),
    TextSpan(
      text: match.closingChar.text,
      style: const TextStyle(color: Colors.grey),
    ),
  ],
  matchBuilder: encapsulatedMatchBuilder,
);
final RichMatcher boldMatcher = RichMatcher<EncapsulatedMatch>(
  regex: boldRegex,
  styleBuilder: (EncapsulatedMatch match) => [
    TextSpan(
      text: match.openingChar.text,
      style: const TextStyle(color: Colors.grey),
    ),
    TextSpan(
      text: match.content.text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    TextSpan(
      text: match.closingChar.text,
      style: const TextStyle(color: Colors.grey),
    ),
  ],
  matchBuilder: encapsulatedMatchBuilder,
);

final RichMatcher italicMatcher = RichMatcher<EncapsulatedMatch>(
  regex: italicRegex,
  styleBuilder: (EncapsulatedMatch match) => [
    TextSpan(
      text: match.openingChar.text,
      style: const TextStyle(color: Colors.grey),
    ),
    TextSpan(
      text: match.content.text,
      style: const TextStyle(fontStyle: FontStyle.italic),
    ),
    TextSpan(
      text: match.closingChar.text,
      style: const TextStyle(color: Colors.grey),
    ),
  ],
  matchBuilder: encapsulatedMatchBuilder,
);
