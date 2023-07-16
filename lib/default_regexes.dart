import 'package:flutter/material.dart';

import 'matching.dart';

const String bold = r'''(\*)([^*\n]+)(\*)''';
const String italic = r'''(_)([^_\n]+)(_)''';
const String strikeThr = r'''(~)([^~\n]+)(~)''';
const String heading = r'''(#+)([^\n]+)''';
const String blockQuote = r'''((?:> ?)+)([^\n]+)''';
const String bulletLine = r'''( *[-+*]{1} +)(.+)''';
const String numberLine = r'''( *\d+\. +)(.+)''';
const String inlineCode = r'''(`)([^`\n]+)(`)''';
const String codeBlock = r'''(```)(\w*)(\n[^`]+)(```)''';

final RegExp boldRegex = RegExp(bold);
final RegExp italicRegex = RegExp(italic);
final RegExp strikeThroughRegex = RegExp(strikeThr);
final RegExp headingRegex = RegExp(heading);
final RegExp blockQuoteRegex = RegExp(blockQuote);
final RegExp bulletLineRegex = RegExp(bulletLine);
final RegExp numberLineRegex = RegExp(numberLine);
final RegExp inlineCodeRegex = RegExp(inlineCode);
final RegExp codeBlockRegex = RegExp(codeBlock);
