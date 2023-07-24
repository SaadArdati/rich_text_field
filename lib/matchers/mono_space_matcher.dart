import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../default_regexes.dart';
import '../matching.dart';

class MonoSpaceMatch extends EncapsulatedMatch {

  MonoSpaceMatch(
    super.match, {
    required super.opening,
    required super.content,
    required super.closing,
  });
}

class MonoSpaceMatcher extends RichMatcher<MonoSpaceMatch> {
  MonoSpaceMatcher()
      : super(
          regex: monoSpaceRegex,
          matchBuilder: (RegExpMatch match) {
            final startQuote = match.namedGroup('monoSpaceOpening')!;
            final contentString = match.namedGroup('monoSpaceContent')!;
            final endQuote = match.namedGroup('monoSpaceClosing')!;

            final TextEditingValue startQuoteVal = TextEditingValue(
              text: startQuote,
              selection: TextSelection(
                baseOffset: match.start,
                extentOffset: match.start + startQuote.length,
              ),
            );
            final TextEditingValue contentVal = TextEditingValue(
              text: contentString,
              selection: TextSelection(
                baseOffset: match.start + startQuote.length,
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
            return MonoSpaceMatch(
              match,
              opening: startQuoteVal,
              content: contentVal,
              closing: endQuoteVal,
            );
          },
        );

  @override
  bool canClaimMatch(String match) =>
      match.startsWith('`') && match.endsWith('`');

  @override
  List<InlineSpan> rasterizedStyleBuilder(
    BuildContext context,
    MonoSpaceMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        WidgetSpan(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text.rich(
              TextSpan(
                text: match.content.text,
              ),
              style: GoogleFonts.sourceCodePro(
                fontSize: 12,
              ),
            ),
          ),
        ),
      ];

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    MonoSpaceMatch match,
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
