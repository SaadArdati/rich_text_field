import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class ItalicMatch extends EncapsulatedMatch {
  ItalicMatch(
    super.match, {
    required super.opening,
    required super.closing,
    required super.content,
  });

  ItalicMatch.from(EncapsulatedMatch match)
      : this(
          match.match,
          opening: match.opening,
          closing: match.closing,
          content: match.content,
        );
}

class ItalicMatcher extends RichMatcher<ItalicMatch> {
  ItalicMatcher()
      : super(
          regex: italicRegex,
          groupNames: ['italicsOpening', 'italicsContent', 'italicsClosing'],
        );

  @override
  ItalicMatch mapMatch(RegExpMatch match, {
    required int selectionOffset,
  }) => defaultEncapsulatedMatchBuilder(
        match,
        groupNames,
        ItalicMatch.from,
        selectionOffset: selectionOffset,
      );

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    ItalicMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          style: const TextStyle(fontStyle: FontStyle.italic),
          children: recurMatch(context, match.content),
        )
      ];

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    ItalicMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.opening.text,
          style: const TextStyle(color: Colors.grey),
        ),
        TextSpan(
          style: const TextStyle(fontStyle: FontStyle.italic),
          children: recurMatch(context, match.content),
        ),
        TextSpan(
          text: match.closing.text,
          style: const TextStyle(color: Colors.grey),
        ),
      ];
}
