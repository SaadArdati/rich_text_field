const String bold =
r'''(?<boldOpening>[*_]{2})(?<boldContent>[^*_\n]+)(?<boldClosing>[*_]{2})''';
const String italic =
    r'''(?<italicsOpening>[*_])(?<italicsContent>[^*_\n]+)(?<italicsClosing>[*_])''';
const String italicBold =
r'''(?<italicBoldOpening>[*_]{3,})(?<italicBoldContent>[^*_\n]+)(?<italicBoldClosing>[*_]{3,})''';
const String strikeThrough =
    r'''(?<strikeThroughOpening>~~)(?<strikeThroughContent>[^~\n]+)(?<strikeThroughClosing>~~)''';
const String subscript =
    r'''(?<subscriptOpening>~)(?<subscriptContent>[^~\n]+)(?<subscriptClosing>~)''';
const String superscript =
    r'''(?<superscriptOpening>\^)(?<superscriptContent>[^^\n]+)(?<superscriptClosing>\^)''';
const String heading = r'''^(?<headingHashtags>#+)(?<headingContent> [^\n]+)''';
const String blockQuote =
    r'''(?<blockQuoteArrow>(?:> ?)+)(?<blockQuoteContent>[^\n]*)''';
const String bulletLine =
    r'''^(?<bulletLineBullet> *[-+*]{1} +)(?<bulletLineContent>.+)''';
const String numberLine =
    r'''(?<numberLineNumber> *\d+[.-] +)(?<numberLineContent>.+)''';
const String monoSpace =
    r'''(?<!`)(?<monoSpaceOpening>`)(?<monoSpaceContent>[^`\n]+)(?<monoSpaceClosing>`)(?!`)''';
const String codeBlock =
    r'''(?<codeBlockOpening>``` *)(?<codeBlockLanguage>\w*\n)?(?<codeBlockContent>[^`]+)(?<codeBlockClosing>```)''';
const String link =
    r'''!?\[(?<linkText>[^[\]]*)]\((?<linkURL>[^() ]*) *"?(?<linkTitle>[^()"]*)"?\)''';
const String horizontalLine =
    r'''^(?<horizontalLine>-{3,}|\*{3,}|_{3,}|\+{3,}|~{3,}|={3,})$''';
const String emoji =
    r'''(?<emojiOpening>:)(?<emojiContent>[^: \s]+)(?<emojiClosing>:)''';

final RegExp boldRegex = RegExp(bold);
final RegExp italicRegex = RegExp(italic);
final RegExp italicBoldRegex = RegExp(italicBold);
final RegExp strikeThroughRegex = RegExp(strikeThrough);
final RegExp subscriptRegex = RegExp(subscript);
final RegExp superscriptRegex = RegExp(superscript);
final RegExp headingRegex = RegExp(heading);
final RegExp blockQuoteRegex = RegExp(blockQuote);
final RegExp bulletLineRegex = RegExp(bulletLine);
final RegExp numberLineRegex = RegExp(numberLine);
final RegExp monoSpaceRegex = RegExp(monoSpace);
final RegExp codeBlockRegex = RegExp(codeBlock);
final RegExp linkRegex = RegExp(link);
final RegExp horizontalLineRegex = RegExp(horizontalLine);
final RegExp emojiRegex = RegExp(emoji);
