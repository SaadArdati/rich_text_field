import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class BoldMatch extends EncapsulatedMatch {
  BoldMatch(
    super.match, {
    required super.opening,
    required super.closing,
    required super.content,
  });

  BoldMatch.from(EncapsulatedMatch match)
      : this(
          match.match,
          opening: match.opening,
          closing: match.closing,
          content: match.content,
        );
}

class BoldMatcher extends RichMatcher<BoldMatch> {
  BoldMatcher()
      : super(
          regex: boldRegex,
          matchBuilder: (match) => defaultEncapsulatedMatchBuilder(
            match,
            ['boldOpening', 'boldContent', 'boldClosing'],
            BoldMatch.from,
          ),
        );

  @override
  bool canClaimMatch(String match) =>
      match.startsWith('*') && match.endsWith('*');

  @override
  List<InlineSpan> rasterizedStyleBuilder(
    BuildContext context,
    BoldMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: recurMatch(context, match.content.text),
        )
      ];

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    BoldMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.opening.text,
          style: const TextStyle(color: Colors.grey),
        ),
        TextSpan(
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: recurMatch(context, match.content.text),
        ),
        TextSpan(
          text: match.closing.text,
          style: const TextStyle(color: Colors.grey),
        ),
      ];
}
