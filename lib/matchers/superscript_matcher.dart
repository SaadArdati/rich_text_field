import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';

class SuperscriptMatch extends EncapsulatedMatch {
  SuperscriptMatch(
    super.match, {
    required super.opening,
    required super.closing,
    required super.content,
  });

  SuperscriptMatch.from(EncapsulatedMatch match)
      : this(
          match.match,
          opening: match.opening,
          closing: match.closing,
          content: match.content,
        );
}

class SuperscriptMatcher extends RichMatcher<SuperscriptMatch> {
  SuperscriptMatcher()
      : super(
          regex: superscriptRegex,
          groupNames: [
            'superscriptOpening',
            'superscriptContent',
            'superscriptClosing'
          ],
        );

  @override
  SuperscriptMatch mapMatch(
    RegExpMatch match, {
    required int selectionOffset,
  }) =>
      defaultEncapsulatedMatchBuilder(
        match,
        groupNames,
        SuperscriptMatch.from,
        selectionOffset: selectionOffset,
      );

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    SuperscriptMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          style: const TextStyle(
            fontFeatures: [ui.FontFeature.superscripts()],
          ),
          children: recurMatch(context, match.content),
        )
      ];

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    SuperscriptMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    return [
      TextSpan(
        text: match.opening.text,
        style: const TextStyle(color: Colors.grey),
      ),
      TextSpan(
        style: const TextStyle(
          fontFeatures: [ui.FontFeature.superscripts()],
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
