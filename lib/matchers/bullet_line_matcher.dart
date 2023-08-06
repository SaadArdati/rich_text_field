import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';
import '../utils.dart';

class BulletLineMatch extends StartMatch {
  BulletLineMatch(
    super.match, {
    required super.opening,
    required super.content,
  });
}

class BulletLineMatcher extends RichMatcher<BulletLineMatch> {
  BulletLineMatcher()
      : super(
          regex: bulletLineRegex,
          groupNames: ['bulletLineBullet', 'bulletLineContent'],
        );

  @override
  BulletLineMatch mapMatch(RegExpMatch match, {
    required int selectionOffset,
  }) {
    final opening = match.namedGroup('bulletLineBullet')!;
    final contentString = match.namedGroup('bulletLineContent')!;

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
    return BulletLineMatch(
      match,
      opening: openingVal,
      content: contentVal,
    );
  }

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    BulletLineMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    final blockNestingCount = match.opening.text.trimRight().length - 1;

    return [
      WidgetSpan(
        child: Row(
          children: [
            Container(
              width: 5.5,
              height: 5.5,
              margin:
                  EdgeInsets.only(left: blockNestingCount * 8 + 8, right: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
            Text.rich(
              TextSpan(
                children: recurMatch(context, match.content),
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
    BulletLineMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.opening.text,
          style: const TextStyle(color: Colors.grey),
        ),
        TextSpan(
          children: recurMatch(context, match.content),
        ),
      ];
}
