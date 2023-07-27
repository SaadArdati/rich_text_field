import 'dart:math';

import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class NumberLineMatch extends StartMatch {
  NumberLineMatch(
    super.match, {
    required super.opening,
    required super.content,
  });
}

class NumberLineMatcher extends RichMatcher<NumberLineMatch> {
  NumberLineMatcher() : super(regex: numberLineRegex);

  @override
  bool canClaimMatch(String match) {
    if (!match.contains('.')) return false;

    final trimmed = match.trim().split('.')[0];
    return double.tryParse(trimmed) != null;
  }

  @override
  NumberLineMatch mapMatch(RegExpMatch match) {
    final opening = match.namedGroup('numberLineNumber')!;
    final contentString = match.namedGroup('numberLineContent')!;

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
    return NumberLineMatch(
      match,
      opening: openingVal,
      content: contentVal,
    );
  }

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    NumberLineMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    final blockNestingCount = max(
      0,
      match.opening.text.length - match.opening.text.trimLeft().length,
    );

    return [
      WidgetSpan(
        child: Row(
          children: [
            Container(
                margin: EdgeInsets.only(left: blockNestingCount * 4, right: 4),
                child: Text(
                  match.opening.text.trim(),
                  style: const TextStyle(color: Colors.grey),
                )),
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
    NumberLineMatch match,
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
