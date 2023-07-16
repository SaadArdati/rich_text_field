import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class BlockQuoteMatch extends StartMatch {
  const BlockQuoteMatch(
    super.match, {
    required super.opening,
    required super.content,
  });
}

class BlockQuoteMatcher extends RichMatcher<BlockQuoteMatch> {
  BlockQuoteMatcher()
      : super(
          regex: blockQuoteRegex,
          formatSelection: (TextEditingValue value, String selectedText) =>
              value.copyWith(
            text: value.text.replaceFirst(selectedText, '> $selectedText'),
            selection: value.selection.copyWith(
              baseOffset: value.selection.baseOffset + 3,
              extentOffset: value.selection.extentOffset + 3,
            ),
          ),
          styleBuilder: (context, match, style) {
            return [
              TextSpan(
                text: match.opening.text,
                style: const TextStyle(color: Colors.grey),
              ),
              TextSpan(
                text: match.content.text,
              ),
            ];
          },
          rasterizedStyleBuilder: (context, match, style) {
            final blockNestingCount =
                match.opening.text.replaceAll(' ', '').length;

            return [
              WidgetSpan(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < blockNestingCount; i++)
                      Positioned(
                        top: -2,
                        bottom: -2,
                        left: i * 16,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: blockNestingCount * 3 + blockNestingCount * 8 + 8,
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: match.content.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          matchBuilder: (RegExpMatch match) {
            final opening = match.group(1)!;
            final contentString = match.group(2)!;

            final TextEditingValue openingVal = TextEditingValue(
              text: opening,
              selection: TextSelection(
                baseOffset: match.start,
                extentOffset: match.start + opening.length,
              ),
            );
            final TextEditingValue contentVal = TextEditingValue(
              text: contentString,
              selection: TextSelection(
                baseOffset: match.start + opening.length + 1,
                extentOffset: match.end - 1,
              ),
            );
            return BlockQuoteMatch(
              match,
              opening: openingVal,
              content: contentVal,
            );
          },
        );
}
