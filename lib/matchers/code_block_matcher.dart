import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../default_regexes.dart';
import '../matching.dart';

class CodeBlockMatch extends EncapsulatedMatch {
  final TextEditingValue? language;

  CodeBlockMatch(
    super.match, {
    required super.opening,
    required this.language,
    required super.content,
    required super.closing,
  });
}

class CodeBlockMatcher extends RichMatcher<CodeBlockMatch> {
  CodeBlockMatcher() : super(regex: codeBlockRegex);

  @override
  bool canClaimMatch(String match) =>
      match.startsWith('```') && match.endsWith('```');

  @override
  CodeBlockMatch mapMatch(RegExpMatch match) {
    final startQuote = match.namedGroup('codeBlockOpening')!;
    final language = match.namedGroup('codeBlockLanguage')?.trim() ?? '';
    final contentString = match.namedGroup('codeBlockContent')!;
    final endQuote = match.namedGroup('codeBlockClosing')!;

    final TextEditingValue startQuoteVal = TextEditingValue(
      text: startQuote,
      selection: TextSelection(
        baseOffset: match.start,
        extentOffset: match.start + startQuote.length,
      ),
    );
    final TextEditingValue languageVal = TextEditingValue(
      text: language,
      selection: TextSelection(
        baseOffset: match.start + startQuote.length,
        extentOffset: match.start + startQuote.length + language.length,
      ),
    );
    final TextEditingValue contentVal = TextEditingValue(
      text: contentString,
      selection: TextSelection(
        baseOffset: match.start + startQuote.length + language.length,
        extentOffset: match.end - endQuote.length,
      ),
    );
    final TextEditingValue endQuoteVal = TextEditingValue(
      text: endQuote,
      selection: TextSelection(
        baseOffset: match.end - endQuote.length,
        extentOffset: match.end,
      ),
    );
    return CodeBlockMatch(
      match,
      opening: startQuoteVal,
      language: languageVal,
      content: contentVal,
      closing: endQuoteVal,
    );
  }

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    CodeBlockMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        WidgetSpan(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text.rich(
              TextSpan(
                text: match.content.text.trim(),
              ),
              style: GoogleFonts.sourceCodePro(
                fontSize: 12,
              ),
            ),
          ),
        ),
      ];

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    CodeBlockMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.opening.text,
          style: GoogleFonts.sourceCodePro(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        if (match.language != null)
          TextSpan(
            text: '${match.language!.text}\n',
            style: GoogleFonts.sourceCodePro(
              color: Colors.green,
              fontSize: 12,
            ),
          ),
        TextSpan(
          text: match.content.text,
          style: GoogleFonts.sourceCodePro(
            fontSize: 12,
          ),
        ),
        TextSpan(
          text: match.closing.text,
          style: GoogleFonts.sourceCodePro(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ];
}
