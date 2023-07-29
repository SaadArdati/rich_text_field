import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../default_regexes.dart';
import '../matching.dart';

//const String link = r'''!?\[(?<linkText>[^[\]]*)]\((?<linkURL>[^() ]*) *"?(?<linkTitle>[^()"]*)"?\)''';
class NumberLineMatch extends RichMatch {
  final bool isImage;
  final TextEditingValue linkText;
  final TextEditingValue linkURL;
  final TextEditingValue linkTitle;

  NumberLineMatch(
    super.match, {
    required this.isImage,
    required this.linkText,
    required this.linkURL,
    required this.linkTitle,
  });
}

class NumberLineMatcher extends RichMatcher<NumberLineMatch> {
  NumberLineMatcher() : super(regex: linkRegex);

  @override
  bool canClaimMatch(String match) {
    return match.startsWith('!') || match.startsWith('[');
  }

  @override
  NumberLineMatch mapMatch(RegExpMatch match) {
    final String raw = match.group(0)!;
    final bool isImage = raw.startsWith('!');
    final String linkText = match.namedGroup('linkText')!;
    final String linkURL = match.namedGroup('linkURL')!;
    final String linkTitle = match.namedGroup('linkTitle')!;

    final TextEditingValue linkTextVal = TextEditingValue(
      text: linkText,
      selection: findSelection(raw, linkText),
    );
    final TextEditingValue linkURLVal = TextEditingValue(
      text: linkURL,
      selection: findSelection(raw, linkURL),
    );
    final TextEditingValue linkTitleVal = TextEditingValue(
      text: linkTitle,
      selection: findSelection(raw, linkTitle),
    );

    return NumberLineMatch(
      match,
      isImage: isImage,
      linkText: linkTextVal,
      linkURL: linkURLVal,
      linkTitle: linkTitleVal,
    );
  }

  TextSelection findSelection(String text, String match) {
    final int start = text.indexOf(match);
    final int end = start + match.length;
    return TextSelection(
      baseOffset: start,
      extentOffset: end,
    );
  }

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    NumberLineMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    if (match.isImage) {
      return [
        WidgetSpan(
          child: Image.network(
            match.linkURL.text,
            semanticLabel: match.linkTitle.text,
          ),
        ),
      ];
    } else {
      return [
        TextSpan(
          text: match.linkText.text,
          style: const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => launchUrlString(match.linkURL.text),
          semanticsLabel: match.linkTitle.text,
        ),
      ];
    }
  }

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    NumberLineMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        const TextSpan(
          text: '[',
          style: TextStyle(color: Colors.grey),
        ),
        TextSpan(
          text: match.linkText.text,
          style: const TextStyle(color: Colors.grey),
        ),
        const TextSpan(
          text: ']',
          style: TextStyle(color: Colors.grey),
        ),
        const TextSpan(
          text: '(',
          style: TextStyle(color: Colors.green),
        ),
        TextSpan(
          text: match.linkURL.text,
          style: const TextStyle(color: Colors.blue),
        ),
        TextSpan(
          text:
              match.linkTitle.text.isEmpty ? '' : ' "${match.linkTitle.text}"',
          style: const TextStyle(color: Colors.yellow),
        ),
        const TextSpan(
          text: ')',
          style: TextStyle(color: Colors.green),
        ),
      ];
}
