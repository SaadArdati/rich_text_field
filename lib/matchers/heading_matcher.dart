import 'dart:math';

import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';
import '../utils.dart';

class HeadingMatch extends StartMatch {
  final TextEditingValue hashtags;

  HeadingMatch(
    super.match, {
    required this.hashtags,
    required super.content,
  }) : super(opening: hashtags);
}

class HeadingMatcher extends RichMatcher<HeadingMatch> {
  HeadingMatcher()
      : super(
          regex: headingRegex,
          groupNames: ['headingHashtags', 'headingContent'],
        );

  @override
  HeadingMatch mapMatch(
    RegExpMatch match, {
    required int selectionOffset,
  }) {
    final hashtagsString = match.namedGroup('headingHashtags')!;
    final contentString = match.namedGroup('headingContent')!.trim();

    final TextEditingValue hashtags = TextEditingValue(
      text: hashtagsString,
      selection: TextSelection(
        baseOffset: match.start,
        extentOffset: match.start + hashtagsString.length,
      ).shift(selectionOffset),
    );
    final TextEditingValue content = TextEditingValue(
      text: contentString,
      selection: TextSelection(
        baseOffset: match.start + hashtagsString.length,
        extentOffset: match.end,
      ).shift(selectionOffset),
    );

    return HeadingMatch(match, hashtags: hashtags, content: content);
  }

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    HeadingMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    final hashtagCount = min(6, match.hashtags.text.replaceAll(' ', '').length);

    // font size should be inverse of hashtag count. maximum hashtags for
    // smallest title is 6.
    final fontSize = 16 + (6 - hashtagCount) * 2.0;
    return [
      TextSpan(
        style: TextStyle(fontSize: fontSize),
        children: recurMatch(context, match.content),
      ),
    ];
  }

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    HeadingMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    final hashtagCount = min(6, match.hashtags.text.replaceAll(' ', '').length);

    // font size should be inverse of hashtag count. maximum hashtags for
    // smallest title is 6.
    final fontSize = 16 + (6 - hashtagCount) * 2.0;

    return [
      TextSpan(
        text: '${match.hashtags.text} ',
        style: const TextStyle(color: Colors.grey),
      ),
      TextSpan(
        style: TextStyle(fontSize: fontSize),
        children: recurMatch(context, match.content),
      ),
    ];
  }
}
