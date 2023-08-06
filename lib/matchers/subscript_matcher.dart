import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class SubscriptMatch extends EncapsulatedMatch {
  SubscriptMatch(
    super.match, {
    required super.opening,
    required super.closing,
    required super.content,
  });

  SubscriptMatch.from(EncapsulatedMatch match)
      : this(
          match.match,
          opening: match.opening,
          closing: match.closing,
          content: match.content,
        );
}

class SubscriptMatcher extends RichMatcher<SubscriptMatch> {
  SubscriptMatcher()
      : super(
          regex: subscriptRegex,
          groupNames: [
            'subscriptOpening',
            'subscriptContent',
            'subscriptClosing'
          ],
        );

  @override
  SubscriptMatch mapMatch(RegExpMatch match, {
    required int selectionOffset,
  }) => defaultEncapsulatedMatchBuilder(
        match,
        groupNames,
        SubscriptMatch.from,
        selectionOffset: selectionOffset,
      );

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    SubscriptMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          style: const TextStyle(
            fontFeatures: [ui.FontFeature.subscripts()],
          ),
          children: recurMatch(context, match.content),
        )
      ];

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    SubscriptMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    return [
      TextSpan(
        text: match.opening.text,
        style: const TextStyle(color: Colors.grey),
      ),
      TextSpan(
        style: const TextStyle(
          fontFeatures: [ui.FontFeature.subscripts()],
        ),
        children: recurMatch(context, match.content),
      ),
      TextSpan(
        text: match.closing.text,
        style: const TextStyle(color: Colors.grey),
      ),
    ];
  }
}
