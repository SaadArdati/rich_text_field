import 'dart:math';

import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class HorizontalLineMatcher extends RichMatcher<RichMatch> {
  HorizontalLineMatcher()
      : super(
          regex: horizontalLineRegex,
          groupNames: ['horizontalLine'],
        );

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    RichMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    return [
      WidgetSpan(
        child: Container(
          height: 1,
          color: Colors.grey,
        ),
      ),
    ];
  }

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    RichMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.fullText,
          style: const TextStyle(color: Colors.grey),
        ),
      ];
}
