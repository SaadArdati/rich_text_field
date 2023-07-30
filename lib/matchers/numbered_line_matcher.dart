import 'dart:math';

import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class NumberedLineMatch extends StartMatch {
  NumberedLineMatch(
    super.match, {
    required super.opening,
    required super.content,
  });
}

class NumberedLineMatcher extends RichMatcher<NumberedLineMatch> {
  NumberedLineMatcher()
      : super(
          regex: numberLineRegex,
          groupNames: ['numberLineNumber', 'numberLineContent'],
        );

  @override
  NumberedLineMatch mapMatch(RegExpMatch match) {
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
    return NumberedLineMatch(
      match,
      opening: openingVal,
      content: contentVal,
    );
  }

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    NumberedLineMatch match,
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
                margin:
                    EdgeInsets.only(left: blockNestingCount * 4 + 8, right: 4),
                child: SelectionContainer.disabled(
                  child: Text(
                    match.opening.text.trim(),
                    style: const TextStyle(color: Colors.grey),
                  ),
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
    NumberedLineMatch match,
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
