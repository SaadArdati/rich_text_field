import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'utils.dart';

import 'matching.dart';
import 'rich_text_controller.dart';

class RichFocusNode extends FocusNode {
  final RichTextEditingController controller;
  final DeBouncer deBouncer;
  final GlobalKey textFieldKey;

  List<RichMatcher> get matchers => controller.matchers;

  RichFocusNode({
    required this.controller,
    required this.textFieldKey,
    required this.deBouncer,
  }) {
    controller.addListener(updateContextMenu);
    controller.selectionNotifier.addListener(updateContextMenu);
  }

  @override
  void dispose() {
    controller.selectionNotifier.removeListener(updateContextMenu);
    controller.removeListener(updateContextMenu);
    super.dispose();
  }

  late final EditableTextState? editableTextState =
      findEditableTextState(textFieldKey.currentContext!);

  void updateContextMenu() {
    if (editableTextState == null || !editableTextState!.context.mounted) {
      return;
    }

    final EditableTextState state = editableTextState!;
    final TextSelection selection = controller.selection;
    final bool shouldShowToolbar = !selection.isCollapsed &&
        selection.textInside(controller.text).trim().isNotEmpty;

    if (shouldShowToolbar) {
      deBouncer.run(() {
        if (!state.context.mounted) return;
        state.hideToolbar(false);
        state.showToolbar();
      });
    } else {
      state.hideToolbar(false);
    }
  }

  @override
  set onKeyEvent(FocusOnKeyEventCallback? onKeyEvent) {
    super.onKeyEvent = _handleKeyEvent;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Add an enclosing character if the inserted character is one that supports
    // enclosing.
    // if (_isOpeningChar(event.logicalKey.keyLabel)) {
    //   final enclosing = _getSisterChar(event.logicalKey.keyLabel);
    //
    //   final text = controller.text;
    //   final selection = controller.selection;
    //   final startPos = selection.start;
    //
    //   // If the character is { or [, we need to add a new line and indent.
    //   String newText = text.insert(selection.start, event.logicalKey.keyLabel);
    //   if (!isValidJson(newText)) {
    //     newText = newText.insert(selection.end + 1, enclosing);
    //   }
    //
    //   controller.text = newText;
    //   controller.selection = selection.copyWith(
    //     baseOffset: startPos + 1,
    //     extentOffset: startPos + 1,
    //   );
    //
    //   return KeyEventResult.handled;
    // }
    // // Backspace or delete need to removing the opposite enclosing character.
    // else if (event.logicalKey == LogicalKeyboardKey.delete ||
    //     event.logicalKey == LogicalKeyboardKey.backspace) {
    //   final text = controller.text;
    //   final selection = controller.selection;
    //   final startPos = selection.start;
    //   final endPos = selection.end;
    //
    //   if (startPos <= 0) return KeyEventResult.ignored;
    //   if (text.length <= startPos) return KeyEventResult.ignored;
    //
    //   final deletedChar = text[startPos - 1];
    //
    //   if (startPos == endPos && _isOpeningChar(deletedChar)) {
    //     final enclosing = _getSisterChar(deletedChar);
    //     final nextChar = text[startPos];
    //
    //     // Oh well. Delete the character.
    //     if (enclosing != nextChar) {
    //       final newText = text.replaceRange(startPos - 1, startPos, '');
    //
    //       controller.text = newText;
    //       controller.selection = selection.copyWith(
    //         baseOffset: startPos - 1,
    //         extentOffset: startPos - 1,
    //       );
    //       return KeyEventResult.handled;
    //     }
    //
    //     String newText = text.replaceRange(startPos - 1, startPos + 1, '');
    //
    //     // if (!isValidJson(newText)) {
    //     //   newText = text.replaceRange(startPos - 1, startPos, '');
    //     // }
    //
    //     controller.text = newText;
    //     controller.selection = selection.copyWith(
    //       baseOffset: startPos - 1,
    //       extentOffset: startPos - 1,
    //     );
    //     return KeyEventResult.handled;
    //   }
    // }
    // // Going to a new line should copy the last line's indentation.
    // else if (event.logicalKey == LogicalKeyboardKey.enter) {
    //   final text = controller.text;
    //   final selection = controller.selection;
    //   final startPos = selection.start;
    //
    //   if (text.length <= startPos) return KeyEventResult.ignored;
    //
    //   final subUntilNow = text.substring(0, startPos - 1);
    //   final lastNewLine = subUntilNow.lastIndexOf('\n');
    //   final lastLine = subUntilNow.substring(lastNewLine + 1, startPos - 1);
    //   // Get the last line's indentation
    //   final indent = RegExp(r'(^\s+)').firstMatch(lastLine)?.group(0) ?? '';
    //
    //   // If the last char is an opening character and the next char is a closing
    //   // character, we should add another new line with double indentation.
    //   final lastChar = text[startPos - 1];
    //
    //   final nextChar = text[startPos];
    //
    //   if (_isOpeningChar(lastChar) && _enclosingCharFor(nextChar)) {
    //     controller.text = text.insert(startPos, '\n$indent  \n$indent');
    //     controller.selection = selection.copyWith(
    //       baseOffset: startPos + indent.length + 3,
    //       extentOffset: startPos + indent.length + 3,
    //     );
    //   } else {
    //     controller.text = text.insert(startPos, '\n$indent');
    //     controller.selection = selection.copyWith(
    //       baseOffset: startPos + indent.length + 1,
    //       extentOffset: startPos + indent.length + 1,
    //     );
    //   }
    //
    //   return KeyEventResult.handled;
    // }
    return KeyEventResult.ignored;
  }
}

extension _StringInsert on String {
  String insert(int index, String other) {
    if (index < 0 || index > length) {
      return this;
    }
    return substring(0, index) + other + substring(index);
  }
}
