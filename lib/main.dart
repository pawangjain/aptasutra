import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AptasutraApp());
}

class AptasutraApp extends StatelessWidget {
  const AptasutraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const AptasutraScreen());
  }
}

class Aptasutra {
  final int n;
  final String g;

  Aptasutra({required this.n, required this.g});

  factory Aptasutra.fromJson(Map<String, dynamic> json) {
    return Aptasutra(n: json['n'], g: json['g']);
  }
}

class AptasutraScreen extends StatefulWidget {
  const AptasutraScreen({super.key});

  @override
  State<AptasutraScreen> createState() => _AptasutraScreenState();
}

class _AptasutraScreenState extends State<AptasutraScreen> {
  final PageController _controller = PageController();

  List<Aptasutra> quotes = [];
  int currentIndex = 0;

  static const double _fontSize = 28;

  Color _iconColor = Colors.grey[400]!;

  @override
  void initState() {
    super.initState();
    loadQuotes();
  }

  Future<void> loadQuotes() async {
    final jsonString = await rootBundle.loadString('assets/aptasutra.json');

    final List data = json.decode(jsonString);

    setState(() {
      quotes = data.map((e) => Aptasutra.fromJson(e)).toList();
    });
  }

  void goToQuote(int index) {
    _controller.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void goToPrevious() {
    _controller.animateToPage(currentIndex - 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void goToNext() {
    _controller.animateToPage(currentIndex + 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void randomQuote() {
    final index = Random().nextInt(quotes.length);
    goToQuote(index);
  }

  Future<void> openSearch() async {
    final result = await Navigator.push<int>(context, MaterialPageRoute(builder: (_) => SearchPage(quotes: quotes)));

    if (result != null) {
      goToQuote(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) {
                setState(() => currentIndex = i);
              },
              itemCount: quotes.length,
              itemBuilder: (_, index) {
                final q = quotes[index];

                return Container(
                  decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SelectableText(
                            q.g,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: _fontSize, height: 1.8),
                          ),
                        ),
                      ),
                      // const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText('#${q.n}', style: const TextStyle(fontSize: 20)),
                          const SelectableText(
                            '~ દાદા ભગવાન',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  onPressed: openSearch,
                  icon: Icon(Icons.share, color: Theme.of(context).dividerColor),
                ),
                IconButton(
                  onPressed: openSearch,
                  icon: Icon(Icons.search, color: Theme.of(context).dividerColor),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: goToPrevious,
                    icon: Icon(Icons.keyboard_arrow_left, color: Theme.of(context).dividerColor),
                  ),
                  IconButton(
                    onPressed: randomQuote,
                    icon: Icon(Icons.loop, color: Theme.of(context).dividerColor),
                  ),
                  IconButton(
                    onPressed: goToNext,
                    icon: Icon(Icons.keyboard_arrow_right, color: Theme.of(context).dividerColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final List<Aptasutra> quotes;

  const SearchPage({super.key, required this.quotes});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';

  List<MapEntry<int, Aptasutra>> get results {
    if (query.isEmpty) return [];

    final isNumber = int.tryParse(query) != null;

    return widget.quotes.asMap().entries.where((entry) {
      if (isNumber) {
        return entry.value.n.toString().contains(query);
      }

      return entry.value.g.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search Aptasutra...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (v) {
            setState(() => query = v);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: results.length,
        itemBuilder: (_, i) {
          final item = results[i];

          return GestureDetector(
            onTap: () {
              Navigator.pop(context, item.key);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHighlightedText(item.value.g, query),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${item.value.n}'),
                      const Text('~ દાદા ભગવાન', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildHighlightedText(String text, String query) {
    if (query.isEmpty || int.tryParse(query) != null) {
      return Text(text, style: const TextStyle(fontSize: 22, height: 1.8));
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);

      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(backgroundColor: Colors.orange, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 22, height: 1.8, color: Colors.white),
        children: spans,
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
