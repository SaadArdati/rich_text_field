import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class ItalicMatch extends EncapsulatedMatch {
  const ItalicMatch(
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
              text: match.opening.text,
              style: const TextStyle(color: Colors.grey),
            ),
            TextSpan(
              text: match.content.text,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            TextSpan(
              text: match.closing.text,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
          rasterizedStyleBuilder: (context, match, style) => [
            TextSpan(
              text: match.content.text,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
          matchBuilder: (match) => defaultEncapsulatedMatchBuilder(
            match,
            ItalicMatch.from,
          ),
        );
}
