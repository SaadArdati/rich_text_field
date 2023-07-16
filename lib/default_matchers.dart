import 'package:flutter/material.dart';

import 'matching.dart';

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

final RichMatcher strikeThroughMatcher = RichMatcher<StrikeThroughMatch>(
  regex: strikeThrRegex,
  formatSelection: (TextEditingValue value, String selectedText) =>
      value.copyWith(
    text: value.text.replaceFirst(selectedText, '~$selectedText~'),
    selection: value.selection.copyWith(
      baseOffset: value.selection.baseOffset + 1,
      extentOffset: value.selection.extentOffset + 1,
    ),
  ),
  styleBuilder: (context, match, style) => [
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
  rasterizedStyleBuilder: (context, match, style) => [
    TextSpan(
      text: match.content.text,
      style: const TextStyle(decoration: TextDecoration.lineThrough),
    ),
  ],
  matchBuilder: (RegExpMatch match) {
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

    return StrikeThroughMatch(
      match,
      openingChar: opening,
      closingChar: closing,
      content: content,
    );
  },
);
final RichMatcher boldMatcher = RichMatcher<BoldMatch>(
  regex: boldRegex,
  formatSelection: (TextEditingValue value, String selectedText) =>
      value.copyWith(
    text: value.text.replaceFirst(selectedText, '*$selectedText*'),
    selection: value.selection.copyWith(
      baseOffset: value.selection.baseOffset + 1,
      extentOffset: value.selection.extentOffset + 1,
    ),
  ),
  styleBuilder: (context, match, style) => [
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
  rasterizedStyleBuilder: (context, match, style) => [
    TextSpan(
      text: match.content.text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ],
  matchBuilder: (RegExpMatch match) {
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

    return BoldMatch(
      match,
      openingChar: opening,
      closingChar: closing,
      content: content,
    );
  },
);
final RichMatcher italicMatcher = RichMatcher<ItalicMatch>(
  regex: italicRegex,
  formatSelection: (TextEditingValue value, String selectedText) =>
      value.copyWith(
    text: value.text.replaceFirst(selectedText, '_${selectedText}_'),
    selection: value.selection.copyWith(
      baseOffset: value.selection.baseOffset + 1,
      extentOffset: value.selection.extentOffset + 1,
    ),
  ),
  styleBuilder: (context, match, style) => [
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
  rasterizedStyleBuilder: (context, match, style) => [
    TextSpan(
      text: match.content.text,
      style: const TextStyle(fontStyle: FontStyle.italic),
    ),
  ],
  matchBuilder: (RegExpMatch match) {
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

    return ItalicMatch(
      match,
      openingChar: opening,
      closingChar: closing,
      content: content,
    );
  },
);

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

class StrikeThroughMatch extends EncapsulatedMatch {
  const StrikeThroughMatch(
    super.match, {
    required super.openingChar,
    required super.closingChar,
    required super.content,
  });
}
