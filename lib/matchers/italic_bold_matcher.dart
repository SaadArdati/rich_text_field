import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';
import '../utils.dart';

class ItalicBoldMatch extends EncapsulatedMatch {
  final TextEditingValue asymmetricOpening;
  final TextEditingValue asymmetricClosing;

  bool get validMatch =>
      !opening.selection.isCollapsed && !closing.selection.isCollapsed;

  bool get hasAsymmetricOpening => !asymmetricOpening.selection.isCollapsed;

  bool get hasAsymmetricClosing => !asymmetricClosing.selection.isCollapsed;

  bool get doesItalicize => opening.text.length % 2 == 1;

  ItalicBoldMatch(
    super.match, {
    required super.opening,
    required super.closing,
    required super.content,
    required this.asymmetricOpening,
    required this.asymmetricClosing,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        asymmetricOpening,
        asymmetricClosing,
      ];
}

class ItalicBoldMatcher extends RichMatcher<ItalicBoldMatch> {
  ItalicBoldMatcher()
      : super(
          regex: italicBoldRegex,
          groupNames: const [
            'italicBoldOpening',
            'italicBoldContent',
            'italicBoldClosing'
          ],
        );

  @override
  ItalicBoldMatch mapMatch(
    RegExpMatch match, {
    required int selectionOffset,
  }) {
    assert(groupNames.length == 3);
    final rawOpeningText = match.namedGroup(groupNames[0])!;
    final contentText = match.namedGroup(groupNames[1])!;
    final rawClosingText = match.namedGroup(groupNames[2])!;
    final ({
      TextSelection asymA,
      TextSelection asymB,
      TextSelection symmA,
      TextSelection symmB,
    }) result = findAsymmetry(rawOpeningText, rawClosingText);

    final asymOpening = result.asymA.isCollapsed
        ? TextEditingValue.empty
        : TextEditingValue(
            text: result.asymA.textInside(rawOpeningText),
            selection: result.asymA.shift(selectionOffset),
          );
    final opening = result.symmA.isCollapsed
        ? TextEditingValue.empty
        : TextEditingValue(
            text: result.symmA.textInside(rawOpeningText),
            selection: result.symmA.shift(selectionOffset),
          );

    final asymClosing = result.asymB.isCollapsed
        ? TextEditingValue.empty
        : TextEditingValue(
            text: result.asymB.textInside(rawClosingText),
            selection: result.asymB.shift(selectionOffset),
          );
    final closing = result.symmB.isCollapsed
        ? TextEditingValue.empty
        : TextEditingValue(
            text: result.symmB.textInside(rawClosingText),
            selection: result.symmB.shift(selectionOffset),
          );

    final content = TextEditingValue(
      text: contentText,
      selection: TextSelection(
        baseOffset: match.start + 1,
        extentOffset: match.end - 1,
      ).shift(selectionOffset),
    );

    return ItalicBoldMatch(
      match,
      opening: opening,
      closing: closing,
      content: content,
      asymmetricOpening: asymOpening,
      asymmetricClosing: asymClosing,
    );
  }

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    ItalicBoldMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        if (match.hasAsymmetricOpening)
          TextSpan(
            text: match.asymmetricOpening.text,
          ),
        TextSpan(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle:
                match.doesItalicize ? FontStyle.italic : FontStyle.normal,
          ),
          children: recurMatch(context, match.content),
        ),
        if (match.hasAsymmetricClosing)
          TextSpan(
            text: match.asymmetricClosing.text,
          ),
      ];

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    ItalicBoldMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        if (match.hasAsymmetricOpening)
          TextSpan(
            text: match.asymmetricOpening.text,
          ),
        TextSpan(
          text: match.opening.text,
          style: const TextStyle(color: Colors.grey),
        ),
        TextSpan(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle:
                match.doesItalicize ? FontStyle.italic : FontStyle.normal,
          ),
          children: recurMatch(context, match.content),
        ),
        TextSpan(
          text: match.closing.text,
          style: const TextStyle(color: Colors.grey),
        ),
        if (match.hasAsymmetricClosing)
          TextSpan(
            text: match.asymmetricClosing.text,
          ),
      ];
}
