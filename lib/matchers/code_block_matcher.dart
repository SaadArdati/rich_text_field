import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../default_regexes.dart';
import '../matching.dart';

class CodeBlockMatch extends EncapsulatedMatch {
  final TextEditingValue language;

  const CodeBlockMatch(
    super.match, {
    required super.opening,
    required this.language,
    required super.content,
    required super.closing,
  });
}

class CodeBlockMatcher extends RichMatcher<CodeBlockMatch> {
  CodeBlockMatcher()
      : super(
          regex: codeBlockRegex,
          formatSelection: (TextEditingValue value, String selectedText) =>
              value.copyWith(
            text: value.text
                .replaceFirst(selectedText, '```\n$selectedText\n```'),
            selection: value.selection.copyWith(
              baseOffset: value.selection.baseOffset + 3,
              extentOffset: value.selection.extentOffset + 3,
            ),
          ),
          styleBuilder: (context, match, style) {
            return [
              TextSpan(
                text: match.opening.text,
                style: GoogleFonts.sourceCodePro(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              if (match.language.text.isNotEmpty)
                TextSpan(
                  text: match.language.text,
                  style: GoogleFonts.sourceCodePro(
                    color: Colors.green,
                    fontSize: 11,
                  ),
                ),
              TextSpan(
                text: match.content.text,
                style: GoogleFonts.sourceCodePro(
                  fontSize: 11,
                ),
              ),
              TextSpan(
                text: match.closing.text,
                style: GoogleFonts.sourceCodePro(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ];
          },
          rasterizedStyleBuilder: (context, match, style) {
            return [
              WidgetSpan(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: match.content.text,
                    ),
                    style: GoogleFonts.sourceCodePro(),
                  ),
                ),
              ),
            ];
          },
          matchBuilder: (RegExpMatch match) {
            final startQuote = match.group(1)!;
            final language = match.group(2)!;
            final contentString = match.group(3)!;
            final endQuote = match.group(4)!;

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
          },
        );
}
