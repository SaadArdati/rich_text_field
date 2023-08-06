import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../default_regexes.dart';
import '../matching.dart';
import '../rich_text_controller.dart';
import '../utils.dart';

class BoldMatch extends EncapsulatedMatch {
  BoldMatch(
    super.match, {
    required super.opening,
    required super.closing,
    required super.content,
  });

  BoldMatch.from(EncapsulatedMatch match)
      : this(
          match.match,
          opening: match.opening,
          closing: match.closing,
          content: match.content,
        );
}

class BoldMatcher extends RichMatcher<BoldMatch> {
  BoldMatcher()
      : super(
          regex: boldRegex,
          groupNames: const ['boldOpening', 'boldContent', 'boldClosing'],
        );

  @override
  BoldMatch mapMatch(
    RegExpMatch match, {
    required int selectionOffset,
  }) =>
      defaultEncapsulatedMatchBuilder(
        match,
        groupNames,
        BoldMatch.from,
        selectionOffset: selectionOffset,
      );

  @override
  List<InlineSpan> styleBuilder(
    BuildContext context,
    BoldMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: recurMatch(context, match.content),
        )
      ];

  @override
  List<InlineSpan> inlineStyleBuilder(
    BuildContext context,
    BoldMatch match,
    RecurMatchBuilder recurMatch,
  ) =>
      [
        TextSpan(
          text: match.opening.text,
          style: const TextStyle(color: Colors.grey),
        ),
        TextSpan(
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: recurMatch(context, match.content),
        ),
        TextSpan(
          text: match.closing.text,
          style: const TextStyle(color: Colors.grey),
        ),
      ];

  @override
  void applyFormatting(RichTextEditingController controller) {
    final input = controller.text;
    final selectedText = controller.selection.textInside(input);
    final boldMatches = controller.matches[this];

    final BoldMatch? selectedMatch = boldMatches?.firstWhereOrNull(
      (richMatch) =>
          richMatch.completeSelection.containsSelection(controller.selection),
    ) as BoldMatch?;

    final bool isFormatted = selectedMatch != null;

    if (isFormatted) {
      final TextEditingValue content = selectedMatch.content;
      final TextEditingValue opening = selectedMatch.opening;
      final TextEditingValue closing = selectedMatch.closing;

      // Remove the opening and closing symbols, then set the selection to the
      // content.
      final int contentLength = content.text.length;

      String currentText = controller.text;

      currentText = currentText
          .replaceRange(
            closing.start - 1,
            closing.end,
            '',
          )
          .replaceRange(
            opening.start,
            opening.end + 1,
            '',
          );

      controller.value = TextEditingValue(
        text: currentText,
        selection: TextSelection(
          baseOffset: opening.start,
          extentOffset: opening.start + contentLength,
        ),
      );
    } else {
      final TextEditingValue currentValue = controller.value;

      final String currentText = controller.text;
      final String selectedText =
          currentValue.selection.textInside(currentText);

      final String newText = currentText.replaceRange(
        currentValue.start,
        currentValue.end,
        '**$selectedText**',
      );

      controller.value = TextEditingValue(
        text: newText,
        selection: controller.selection.copyWith(
          baseOffset: currentValue.start + 2,
          extentOffset: currentValue.end + 2,
        ),
      );
    }
  }

  @override
  Widget? contextMenuButton(
    BuildContext context,
    RichTextEditingController controller,
  ) {
    final input = controller.text;
    final selectionValue = controller.value;
    final selectedText = selectionValue.selection.textInside(input);
    final boldMatches = controller.matches[this];

    final BoldMatch? selectedMatch = boldMatches?.firstWhereOrNull(
      (richMatch) =>
          richMatch.completeSelection.containsSelection(controller.selection),
    ) as BoldMatch?;

    final bool containsFormatting = selectedMatch != null;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SizedBox.square(
      dimension: kMinInteractiveDimension,
      child: FilledButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor:
              containsFormatting ? scheme.primary : scheme.background,
          shape: const RoundedRectangleBorder(),
          minimumSize:
              const Size(kMinInteractiveDimension, kMinInteractiveDimension),
        ),
        onPressed: () => applyFormatting(controller),
        child: Icon(
          Icons.format_bold,
          color: containsFormatting ? scheme.onPrimary : scheme.onBackground,
        ),
      ),
    );
  }

  @override
  Widget? toolbarButton(
    BuildContext context,
    VoidCallback onPressed,
  ) =>
      null;
}
