import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rich_text_field/rich_regexes.dart';
import 'package:rich_text_field/rich_text_editing_controller.dart';

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
    text: '_tialics_ *bold* and _more_ *bolding*',
  )..addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {});
        }
      });
    });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Rich Text Editing Controller'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Bold:\n\t${_controller.richMatches.whereType<BoldMatch>().map((boldMatch) => '[${boldMatch.content.text}]').join('\n\t')}'),
            Expanded(
              child: Center(
                child: TextField(
                  controller: _controller,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
