import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../default_regexes.dart';
import '../matching.dart';
import '../utils.dart';

class LinkMatch extends RichMatch {
  final bool isImage;
  final TextEditingValue linkText;
  final TextEditingValue linkURL;
  final TextEditingValue linkTitle;

  LinkMatch(
    super.match, {
    required this.isImage,
    required this.linkText,
    required this.linkURL,
    required this.linkTitle,
  }) : super(
          completeSelection: TextSelection(
            baseOffset: match.start,
            extentOffset: match.end,
          ),
        );
}

class LinkMatcher extends RichMatcher<LinkMatch> {
  LinkMatcher()
      : super(
          regex: linkRegex,
          groupNames: ['linkText', 'linkURL', 'linkTitle'],
        );

  @override
  LinkMatch mapMatch(
    RegExpMatch match, {
    required int selectionOffset,
  }) {
    final String raw = match.group(0)!;
    final bool isImage = raw.startsWith('!');
    final String linkText = match.namedGroup('linkText')!;
    final String linkURL = match.namedGroup('linkURL')!;
    final String linkTitle = match.namedGroup('linkTitle')!;

    final TextEditingValue linkTextVal = TextEditingValue(
      text: linkText,
      selection: findSelection(raw, linkText).shift(selectionOffset),
    );
    final TextEditingValue linkURLVal = TextEditingValue(
      text: linkURL,
      selection: findSelection(raw, linkURL).shift(selectionOffset),
    );
    final TextEditingValue linkTitleVal = TextEditingValue(
      text: linkTitle,
      selection: findSelection(raw, linkTitle).shift(selectionOffset),
    );

    return LinkMatch(
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
    LinkMatch match,
    RecurMatchBuilder recurMatch,
  ) {
    if (match.isImage) {
      return [
        WidgetSpan(
          child: Image.network(
            match.linkURL.text,
            semanticLabel: match.linkTitle.text,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
              );
            },
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
    LinkMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        if(match.isImage)
        const TextSpan(
          text: '!',
          style: TextStyle(color: Colors.yellow),
        ),
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
