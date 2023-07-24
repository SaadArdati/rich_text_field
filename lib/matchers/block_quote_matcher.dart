import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class BlockQuoteMatch extends StartMatch {
  BlockQuoteMatch(
    super.match, {
    required super.opening,
    required super.content,
  });
}

class BlockQuoteMatcher extends RichMatcher<BlockQuoteMatch> {
  BlockQuoteMatcher()
      : super(
          regex: blockQuoteRegex,
          matchBuilder: (RegExpMatch match) {
            final opening = match.namedGroup('blockQuoteArrow')!;
            final contentString = match.namedGroup('blockQuoteContent')!;

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

  @override
  bool canClaimMatch(String match) => match.startsWith('>');

  @override
  List<InlineSpan> rasterizedStyleBuilder(
    BuildContext context,
    BlockQuoteMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    final blockNestingCount = match.opening.text.replaceAll(' ', '').length;

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
                  children: recurMatch(context, match.content.text),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    BlockQuoteMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.opening.text,
          style: const TextStyle(color: Colors.grey),
        ),
        TextSpan(
          text: match.content.text,
        ),
      ];
}
