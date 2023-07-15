import 'package:flutter/material.dart';

import 'regex_text_controller.dart';
import 'rich_regexes.dart';

class RichTextEditingController extends RegexTextEditingController {
  final List<RichMatch> richMatches = [];

  RichTextEditingController({
    super.text,
    List<RichMatcher>? matchers,
  }) : super(
          matchers: matchers ??
              [
                boldMatcher,
                // italicMatcher,
                // strikeThroughMatcher,
              ],
        );

  @override
  @mustCallSuper
  void onAllMatchesFound(List<RichMatch> matches) {
    richMatches
      ..clear()
      ..addAll(matches);
  }
}
