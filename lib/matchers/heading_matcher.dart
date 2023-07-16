import 'dart:math';

import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class HeadingMatch extends RichMatch {
  final TextEditingValue hashtags;
  final TextEditingValue content;

  const HeadingMatch(
    super.match, {
    required this.hashtags,
    required this.content,
  });
}

class HeadingMatcher extends RichMatcher<HeadingMatch> {
  HeadingMatcher()
      : super(
          regex: headingRegex,
          formatSelection: (TextEditingValue value, String selectedText) =>
              value.copyWith(
            text: value.text.replaceFirst(selectedText, '# $selectedText'),
            selection: value.selection.copyWith(
              baseOffset: value.selection.baseOffset + 1,
              extentOffset: value.selection.extentOffset + 1,
            ),
          ),
          styleBuilder: (context, match, style) {
            final hashtagCount =
                min(6, match.hashtags.text.replaceAll(' ', '').length);

            // font size should be inverse of hashtag count. maximum hashtags for
            // smallest title is 6.
            final fontSize = 16 + (6 - hashtagCount) * 2.0;

            return [
              TextSpan(
                text: match.hashtags.text,
                style: const TextStyle(color: Colors.grey),
              ),
              TextSpan(
                text: match.content.text,
                style: TextStyle(fontSize: fontSize),
              ),
            ];
          },
          rasterizedStyleBuilder: (context, match, style) {
            final hashtagCount =
                min(6, match.hashtags.text.replaceAll(' ', '').length);

            // font size should be inverse of hashtag count. maximum hashtags for
            // smallest title is 6.
            final fontSize = 16 + (6 - hashtagCount) * 2.0;
            return [
              TextSpan(
                text: match.content.text,
                style: TextStyle(fontSize: fontSize),
              ),
            ];
          },
          matchBuilder: (RegExpMatch match) {
            final hashtagsString = match.group(1)!;
            final contentString = match.group(2)!;

            final TextEditingValue hashtags = TextEditingValue(
              text: hashtagsString,
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

            return HeadingMatch(match, hashtags: hashtags, content: content);
          },
        );
}
