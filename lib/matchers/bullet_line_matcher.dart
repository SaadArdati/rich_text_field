import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class BulletLineMatch extends StartMatch {
  BulletLineMatch(
    super.match, {
    required super.opening,
    required super.content,
  });
}

class BulletLineMatcher extends RichMatcher<BulletLineMatch> {
  BulletLineMatcher() : super(regex: bulletLineRegex);

  @override
  bool canClaimMatch(String match) {
    final trimmed = match.trim();
    return trimmed.startsWith('*') ||
        trimmed.startsWith('-') ||
        trimmed.startsWith('+');
  }

  @override
  BulletLineMatch mapMatch(RegExpMatch match) {
    final opening = match.namedGroup('bulletLineBullet')!;
    final contentString = match.namedGroup('bulletLineContent')!;

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
              width: 6,
              height: 6,
              margin: EdgeInsets.only(left: blockNestingCount * 8, right: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
            Text.rich(
              TextSpan(
                children: recurMatch(context, match.content.text),
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
          text: match.content.text,
        ),
      ];
}
