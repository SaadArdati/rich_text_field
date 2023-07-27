import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
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
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
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
  late LinkedScrollControllerGroup controllers;
  late ScrollController textFieldScrollController;
  late ScrollController previewScrollController;

  late final RichTextEditingController _controller =
      RichTextEditingController(text: markdownSample)
        ..addListener(() {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
            if (mounted) {
              setState(() {});
            }
          });
        });

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controllers = LinkedScrollControllerGroup();
    textFieldScrollController = controllers.addAndGet();
    previewScrollController = controllers.addAndGet();
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode.dispose();
    textFieldScrollController.dispose();
    previewScrollController.dispose();
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
            // Text(
            //   'Bold matches:\t${_controller.matches.values.expand((list) => list).whereType<BoldMatch>().map((boldMatch) => '[${boldMatch.content.text}]').join('\t')}',
            //   maxLines: 1,
            // ),
            // Text(
            //   'Italic matches:\t${_controller.matches.values.expand((list) => list).whereType<ItalicMatch>().map((boldMatch) => '[${boldMatch.content.text}]').join('\t')}',
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            // ),
            // Text(
            //   'StrikeThrough matches:\t${_controller.matches.values.expand((list) => list).whereType<StrikeThroughMatch>().map((boldMatch) => '[${boldMatch.content.text}]').join('\t')}',
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            // ),
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
                            scrollController: textFieldScrollController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(3.5),
                            ),
                            child: SelectionArea(
                              child: SingleChildScrollView(
                                controller: previewScrollController,
                                padding: const EdgeInsets.all(8),
                                child: Text.rich(
                                  _controller.getBetterFormattedText(
                                    context,
                                    rasterized: true,
                                    text: _controller.text,
                                    style: const TextStyle(),
                                  ),
                                ),
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

const String markdownSample = r'''---
You will like those projects!

---

# h1 Heading 8-)
## h2 Heading
### h3 Heading
#### h4 Heading
##### h5 Heading
###### h6 Heading


## Horizontal Rules

___

---

***


## Typographic replacements

Enable typographer option to see result.

(c) (C) (r) (R) (tm) (TM) (p) (P) +-

test.. test... test..... test?..... test!....

!!!!!! ???? ,,  -- ---

"Smartypants, double quotes" and 'single quotes'


## Emphasis

**This is bold text**

__This is bold text__

*This is italic text*

_This is italic text_

~~Strikethrough~~


## Blockquotes


> Blockquotes can also be nested...
>> ...by using additional greater-than signs right next to each other...
> > > ...or with spaces between arrows.


## Lists

Unordered

+ Create a list by starting a line with `+`, `-`, or `*`
+ Sub-lists are made by indenting 2 spaces:
  - Marker character change forces new list start:
    * Ac tristique libero volutpat at
    + Facilisis in pretium nisl aliquet
    - Nulla volutpat aliquam velit
+ Very easy!

Ordered

1. Lorem ipsum dolor sit amet
2. Consectetur adipiscing elit
3. Integer molestie lorem at massa


1. You can use sequential numbers...
1. ...or keep all the numbers as `1.`

Start numbering with offset:

57. foo
1. bar


## Code

Inline `code`

Indented code

    // Some comments
    line 1 of code
    line 2 of code
    line 3 of code


Block code "fences"

```
Sample text here...
```

Syntax highlighting

```js
var foo = function (bar) {
  return bar++;
};

console.log(foo(5));
```

## Tables

| Option | Description |
| ------ | ----------- |
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |

Right aligned columns

| Option | Description |
| ------:| -----------:|
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |


## Links

[link text](https://dev.nodeca.com)

[link with title](https://nodeca.github.io/pica/demo/ "title text!")

Autoconverted link https://github.com/nodeca/pica (enable linkify to see)


## Images

![Minion](https://octodex.github.com/images/minion.png)
![Stormtroopocat](https://octodex.github.com/images/stormtroopocat.jpg "The Stormtroopocat")

Like links, Images also have a footnote style syntax

![Alt text][id]

With a reference later in the document defining the URL location:

[id]: https://octodex.github.com/images/dojocat.jpg  "The Dojocat"


## Plugins

The killer feature of `markdown-it` is very effective support of
[syntax plugins](https://www.npmjs.org/browse/keyword/markdown-it-plugin).


### [Emojies](https://github.com/markdown-it/markdown-it-emoji)

> Classic markup: :wink: :crush: :cry: :tear: :laughing: :yum:
>
> Shortcuts (emoticons): :-) :-( 8-) ;)

see [how to change output](https://github.com/markdown-it/markdown-it-emoji#change-output) with twemoji.


### [Subscript](https://github.com/markdown-it/markdown-it-sub) / [Superscript](https://github.com/markdown-it/markdown-it-sup)

- 19^th^
- H~2~O


### [\<ins>](https://github.com/markdown-it/markdown-it-ins)

++Inserted text++


### [\<mark>](https://github.com/markdown-it/markdown-it-mark)

==Marked text==


### [Footnotes](https://github.com/markdown-it/markdown-it-footnote)

Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnote **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.


### [Definition lists](https://github.com/markdown-it/markdown-it-deflist)

Term 1

:   Definition 1
with lazy continuation.

Term 2 with *inline markup*

:   Definition 2

        { some code, part of Definition 2 }

    Third paragraph of definition 2.

_Compact style:_

Term 1
  ~ Definition 1

Term 2
  ~ Definition 2a
  ~ Definition 2b


### [Abbreviations](https://github.com/markdown-it/markdown-it-abbr)

This is HTML abbreviation example.

It converts "HTML", but keep intact partial entries like "xxxHTMLyyy" and so on.

*[HTML]: Hyper Text Markup Language

### [Custom containers](https://github.com/markdown-it/markdown-it-container)

::: warning
*here be dragons*
:::
''';
