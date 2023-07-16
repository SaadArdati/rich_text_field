import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rich_text_field/default_matchers.dart';
import 'package:rich_text_field/rich_text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final RichTextEditingController _controller = RichTextEditingController(
    text: '_tialics_ *bold* and _more_ *bolding* ~strikeThrough~ awaw',
  )..addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {});
        }
      });
    });

  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Rich Text Editing Controller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bold matches:\t${_controller.matches.values.expand((list) => list).whereType<BoldMatch>().map((boldMatch) => '[${boldMatch.content.text}]').join('\t')}',
              maxLines: 1,
            ),
            Text(
              'Italic matches:\t${_controller.matches.values.expand((list) => list).whereType<ItalicMatch>().map((boldMatch) => '[${boldMatch.content.text}]').join('\t')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'StrikeThrough matches:\t${_controller.matches.values.expand((list) => list).whereType<StrikeThroughMatch>().map((boldMatch) => '[${boldMatch.content.text}]').join('\t')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            DropdownButton<FontStyle>(
              items: const [
                DropdownMenuItem(
                  value: FontStyle.italic,
                  child: Text('Focus is lost here!'),
                ),
                DropdownMenuItem(
                  value: FontStyle.normal,
                  child: Text('Bold'),
                ),
              ],
              onChanged: (FontStyle? fontStyle) {
                setState(() {
                  final TextSelection selection = _controller.selection;
                  final TextEditingValue value = _controller.value.copyWith(
                    text: _controller.text.replaceRange(
                      selection.start,
                      selection.end,
                      '*${_controller.text.substring(selection.start, selection.end)}*',
                    ),
                    selection: _controller.selection.copyWith(
                      baseOffset: selection.start + 1,
                      extentOffset: selection.end + 1,
                    ),
                  );
                  _controller.value = value;
                  focusNode.requestFocus();
                  _controller.selection = value.selection;
                });
              },
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RichTextField:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Expanded(
                          child: RichTextField(
                            controller: _controller,
                            focusNode: focusNode,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rasterized Preview:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(3.5),
                            ),
                            child: Text.rich(
                              _controller.getFormattedText(
                                context,
                                rasterized: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
