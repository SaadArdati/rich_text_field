// import 'package:flutter/material.dart';
// import 'package:string_scanner/string_scanner.dart';
//
// import 'matching.dart';
//
// class DartSyntaxHighlighter {
//   final List<RichMatcher> matchers;
//
//   DartSyntaxHighlighter({
//     required TextStyle style,
//     required this.matchers,
//   }) : _style = style;
//
//   final TextStyle _style;
//
//   late String _src;
//   late StringScanner _scanner;
//
//   final List<RichSpan> _spans = [];
//
//   TextSpan format(String src, {Map<String, Object> options = const {}}) {
//     _src = src;
//     _scanner = StringScanner(_src);
//     _spans.clear();
//
//     if (_generateSpans()) {
//       // Successfully parsed the code
//       final List<TextSpan> formattedText = <TextSpan>[];
//       int currentPosition = 0;
//
//       for (RichSpan span in _spans) {
//         if (currentPosition != span.selection.start) {
//           formattedText
//               .add(TextSpan(text: _src.substring(currentPosition, span.selection.start)));
//         }
//
//         formattedText.add(TextSpan(
//             style: span.style, text: span.text));
//
//         currentPosition = span.selection.end;
//       }
//
//       if (currentPosition != _src.length) {
//         formattedText
//             .add(TextSpan(text: _src.substring(currentPosition, _src.length)));
//       }
//
//       return TextSpan(style: _style, children: formattedText);
//     } else {
//       // Parsing failed, return with only basic formatting
//       return TextSpan(style: _style, text: src);
//     }
//   }
//
//   bool _generateSpans() {
//     int lastLoopPosition = _scanner.position;
//
//     while (!_scanner.isDone) {
//       // Skip White space
//       _scanner.scan(RegExp(r'\s+'));
//
//       // Block comments
//       if (_scanner.scan(RegExp(r'/\*(.|\n)*\*/'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.comment,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Line comments
//       if (_scanner.scan('//')) {
//         final int startComment = _scanner.lastMatch!.start;
//
//         bool eof = false;
//         int endComment;
//         if (_scanner.scan(RegExp(r'.*\n'))) {
//           endComment = _scanner.lastMatch!.end - 1;
//         } else {
//           eof = true;
//           endComment = _src.length;
//         }
//
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.comment,
//           startComment,
//           endComment,
//         ));
//
//         if (eof) break;
//
//         continue;
//       }
//
//       // Raw r"String"
//       if (_scanner.scan(RegExp(r'r".*"'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.string,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Raw r'String'
//       if (_scanner.scan(RegExp(r"r'.*'"))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.string,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Multiline """String"""
//       if (_scanner.scan(RegExp(r'"""(?:[^"\\]|\\(.|\n))*"""'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.string,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Multiline '''String'''
//       if (_scanner.scan(RegExp(r"'''(?:[^'\\]|\\(.|\n))*'''"))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.string,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // "String"
//       if (_scanner.scan(RegExp(r'"(?:[^"\\]|\\.)*"'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.string,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // 'String'
//       if (_scanner.scan(RegExp(r"'(?:[^'\\]|\\.)*'"))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.string,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Color parameter
//       if (_scanner.scan(RegExp(r'0x[a-zA-Z0-9]{8}'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.number,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Double
//       if (_scanner.scan(RegExp(r'\d+\.\d+'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.number,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Integer
//       if (_scanner.scan(RegExp(r'\d+'))) {
//         _spans.add(BaseHighlightSpan(BaseHighlightType.number,
//             _scanner.lastMatch!.start, _scanner.lastMatch!.end));
//         continue;
//       }
//
//       // matches name of an enum, a variable or a class name on which some data
//       // is being accessed.
//       // e.g.
//       // EdgeInsets., FontWeight., model.,
//       if (_scanner.scan(RegExp(r': ([a-zA-Z_]+)[a-zA-Z0-9_]+\.'))) {
//         if (_scanner.lastMatch!
//             .group(1)
//             .toString()
//             .startsWith(RegExp(r'[A-Z]'))) {
//           // It could be a static method call, a constructor, an enum, etc.
//           _spans.add(BaseHighlightSpan(
//             BaseHighlightType.klass,
//             _scanner.lastMatch!.start,
//             _scanner.lastMatch!.end - 1,
//           ));
//         } else {
//           _spans.add(BaseHighlightSpan(
//             BaseHighlightType.base,
//             _scanner.lastMatch!.start,
//             _scanner.lastMatch!.end - 1,
//           ));
//         }
//         _scanner.position = _scanner.lastMatch!.end - 1;
//         continue;
//       }
//
//       // // Variable
//       if (_scanner.scan(RegExp(r'\.\w+'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.punctuation,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.start + 1,
//         ));
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.variable,
//           _scanner.lastMatch!.start + 1,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Punctuation
//       if (_scanner.scan(RegExp(r'[\[\]{}().!=<>&\|\?\+\-\*/%\^~;:,]'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.punctuation,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Meta data
//       if (_scanner.scan(RegExp(r'@\w+'))) {
//         _spans.add(BaseHighlightSpan(
//           BaseHighlightType.keyword,
//           _scanner.lastMatch!.start,
//           _scanner.lastMatch!.end,
//         ));
//         continue;
//       }
//
//       // Words
//       if (_scanner.scan(RegExp(r'\w+'))) {
//         BaseHighlightType? type;
//
//         String word = _scanner.lastMatch![0]!;
//         if (word.startsWith('_')) word = word.substring(1);
//
//         if (_keywords.contains(word)) {
//           type = BaseHighlightType.keyword;
//         } else if (_builtInTypes.contains(word)) {
//           type = BaseHighlightType.keyword;
//         } else if (_firstLetterIsUpperCase(word)) {
//           type = BaseHighlightType.klass;
//         } else if (word.length >= 2 &&
//             word.startsWith('k') &&
//             _firstLetterIsUpperCase(word.substring(1))) {
//           type = BaseHighlightType.constant;
//         }
//
//         if (type != null) {
//           _spans.add(BaseHighlightSpan(
//             type,
//             _scanner.lastMatch!.start,
//             _scanner.lastMatch!.end,
//           ));
//         }
//       }
//
//       // Check if this loop did anything
//       if (lastLoopPosition == _scanner.position) {
//         // Failed to parse this file, abort gracefully
//         return false;
//       }
//       lastLoopPosition = _scanner.position;
//     }
//
//     _simplify();
//     return true;
//   }
//
//   void _simplify() {
//     for (int i = _spans.length - 2; i >= 0; i -= 1) {
//       if (_spans[i].type == _spans[i + 1].type &&
//           _spans[i].selection.end == _spans[i + 1].selection.start) {
//         _spans[i] = BaseHighlightSpan(
//           _spans[i].type,
//           _spans[i].selection.start,
//           _spans[i + 1].selection.end,
//         );
//         _spans.removeAt(i + 1);
//       }
//     }
//   }
//
//   bool _firstLetterIsUpperCase(String str) {
//     if (str.isNotEmpty) {
//       final String first = str.substring(0, 1);
//       return first == first.toUpperCase();
//     }
//     return false;
//   }
// }
