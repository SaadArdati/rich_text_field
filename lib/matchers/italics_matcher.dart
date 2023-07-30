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
  ItalicMatch mapMatch(RegExpMatch match) => defaultEncapsulatedMatchBuilder(
        match,
        groupNames,
        ItalicMatch.from,
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
          children: recurMatch(context, match.content.text),
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
          children: recurMatch(context, match.content.text),
        ),
        TextSpan(
          text: match.closing.text,
          style: const TextStyle(color: Colors.grey),
        ),
      ];
}
