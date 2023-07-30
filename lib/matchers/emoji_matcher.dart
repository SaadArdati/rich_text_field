import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class EmojiMatch extends EncapsulatedMatch {
  EmojiMatch(
    super.match, {
    required super.opening,
    required super.closing,
    required super.content,
  });

  EmojiMatch.from(EncapsulatedMatch match)
      : this(
          match.match,
          opening: match.opening,
          closing: match.closing,
          content: match.content,
        );
}

final EmojiParser _parser = EmojiParser();

class EmojiMatcher extends RichMatcher<EmojiMatch> {
  EmojiMatcher()
      : super(
          regex: emojiRegex,
          groupNames: ['emojiOpening', 'emojiContent', 'emojiClosing'],
        );

  @override
  EmojiMatch mapMatch(RegExpMatch match) => defaultEncapsulatedMatchBuilder(
        match,
        groupNames,
        EmojiMatch.from,
      );

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    EmojiMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    return [
      TextSpan(
        text: _parser.get(match.content.text.trim().toLowerCase()).code,
      ),
    ];
  }

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    EmojiMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.opening.text,
          style: const TextStyle(color: Colors.grey),
        ),
        TextSpan(
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.yellow,
          ),
          children: recurMatch(context, match.content.text),
        ),
        TextSpan(
          text: match.closing.text,
          style: const TextStyle(color: Colors.grey),
        ),
      ];
}
