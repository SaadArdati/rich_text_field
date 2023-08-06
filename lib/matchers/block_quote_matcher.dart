import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';
import '../utils.dart';

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
          groupNames: ['blockQuoteArrow', 'blockQuoteContent'],
        );

  @override
  BlockQuoteMatch mapMatch(
    RegExpMatch match, {
    required int selectionOffset,
  }) {
    final opening = match.namedGroup('blockQuoteArrow')!;
    final contentString = match.namedGroup('blockQuoteContent')!;

    final TextEditingValue openingVal = TextEditingValue(
      text: opening,
      selection: TextSelection(
        baseOffset: match.start,
        extentOffset: match.start + opening.length,
      ).shift(selectionOffset),
    );
    final TextEditingValue contentVal = TextEditingValue(
      text: contentString,
      selection: TextSelection(
        baseOffset: match.start + opening.length + 1,
        extentOffset: match.end - 1,
      ).shift(selectionOffset),
    );
    return BlockQuoteMatch(
      match,
      opening: openingVal,
      content: contentVal,
    );
  }

  @override
  List<InlineSpan> styleBuilder(
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
                  children: recurMatch(context, match.content),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    BlockQuoteMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.opening.text,
          style: const TextStyle(color: Colors.grey),
        ),
        ...recurMatch(context, match.content),
      ];
}
