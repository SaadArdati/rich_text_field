import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class StrikeThroughMatch extends EncapsulatedMatch {
  const StrikeThroughMatch(
    super.match, {
    required super.opening,
    required super.closing,
    required super.content,
  });

  StrikeThroughMatch.from(EncapsulatedMatch match)
      : this(
          match.match,
          opening: match.opening,
          closing: match.closing,
          content: match.content,
        );
}

class StrikeThroughMatcher extends RichMatcher<StrikeThroughMatch> {
  StrikeThroughMatcher()
      : super(
          regex: strikeThroughRegex,
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
              text: match.opening.text,
              style: const TextStyle(color: Colors.grey),
            ),
            TextSpan(
              text: match.content.text,
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ),
            TextSpan(
              text: match.closing.text,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
          rasterizedStyleBuilder: (context, match, style) => [
            TextSpan(
              text: match.content.text,
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ),
          ],
          matchBuilder: (match) => defaultEncapsulatedMatchBuilder(
            match,
            StrikeThroughMatch.from,
          ),
        );
}
