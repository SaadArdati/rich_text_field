

const String bold = r'''(?<boldOpening>\*)(?<boldContent>[^*\n]+)(?<boldClosing>\*)''';
const String italic = r'''(?<italicsOpening>\*)(?<italicsContent>[^*\n]+)(?<italicsClosing>\*)''';
const String strikeThrough = r'''(?<strikeThroughOpening>~)(?<strikeThroughContent>[^~\n]+)(?<strikeThroughClosing>~)''';
const String heading = r'''^(?<headingHashtags>#+)(?<headingContent> [^\n]+)''';
const String blockQuote = r'''(?<blockQuoteArrow>(?:> ?)+)(?<blockQuoteContent>[^\n]*)''';
const String bulletLine = r'''^^(?<bulletLineBullet> *[-+*]{1} +)(?<bulletLineContent>.+)''';
const String numberLine = r'''(?<numberLineNumber> *\d+[.-] +)(?<numberLineContent>.+)''';
const String monoSpace = r'''(?<!`)(?<monoSpaceOpening>`)(?<monoSpaceContent>[^`\n]+)(?<monoSpaceClosing>`)(?!`)''';
const String codeBlock = r'''(?<codeBlockOpening>``` *)(?<codeBlockLanguage>\w*\n)?(?<codeBlockContent>[^`]+)(?<codeBlockClosing>```)''';

final RegExp boldRegex = RegExp(bold);
final RegExp italicRegex = RegExp(italic);
final RegExp strikeThroughRegex = RegExp(strikeThrough);
final RegExp headingRegex = RegExp(heading);
final RegExp blockQuoteRegex = RegExp(blockQuote);
final RegExp bulletLineRegex = RegExp(bulletLine);
final RegExp numberLineRegex = RegExp(numberLine);
final RegExp monoSpaceRegex = RegExp(monoSpace);
final RegExp codeBlockRegex = RegExp(codeBlock);
