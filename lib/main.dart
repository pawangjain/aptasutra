import 'dart:convert';
import 'dart:math';

import 'package:aptasutra/app.dart';
import 'package:aptasutra/search_page.dart';
import 'package:aptasutra/star_button.dart';
import 'package:aptasutra/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
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
  bool isStarred;

  Aptasutra({required this.n, required this.g, required this.isStarred});

  factory Aptasutra.fromJson(Map<String, dynamic> json) {
    return Aptasutra(n: json['n'], g: json['g'], isStarred: App.starredList.contains(json['n']));
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

  String tt =
      'The lyrics button is not focusable using keypad. Also the Lyrics dialog should be focused such that, when the back/escape key is pressed the dialog should close instead of the audio player being closed.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await App.initApp();
      loadQuotes();
    });
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
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => SearchPage(quotes: quotes, isStarredSearch: false)),
    );

    if (result != null) {
      goToQuote(result);
    }
  }

  Future<void> openStarredPage() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(quotes: quotes.where((u) => u.isStarred).toList(), isStarredSearch: true),
      ),
    );

    if (result != null) {
      goToQuote(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var dividerColor = Theme.of(context).dividerColor;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (i) {
                setState(() => currentIndex = i);
              },
              itemCount: quotes.length,
              itemBuilder: (_, index) {
                final q = quotes[index];

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SelectableText(
                                  q.g + tt,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: _fontSize, height: 1.8),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SelectableText('#${q.n}', style: TextStyle(fontSize: 20, color: dividerColor)),

                                        StarButton(aptasutra: q),
                                      ],
                                    ),
                                    const SelectableText(
                                      '~ દાદા ભગવાન',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // const Divider(),
                      ],
                    ),
                  ),
                );
              },
            ),

            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    onPressed: openStarredPage,
                    icon: Icon(Icons.list, color: Theme.of(context).dividerColor),
                  ),
                  IconButton(
                    onPressed: shareAptasutra,
                    icon: Icon(Icons.share, color: dividerColor, size: 22),
                  ),
                  IconButton(
                    onPressed: openSearch,
                    icon: Icon(Icons.search, color: dividerColor),
                  ),
                ],
              ),
            ),

            // Positioned(
            //   bottom: 8,
            //   left: 0,
            //   right: 0,
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //
            //     ],
            //   ),
            // ),
            Positioned(
              bottom: 8,
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
            Positioned(
              bottom: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Padding(padding: const EdgeInsets.all(20.0), child: LinkText())],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void shareAptasutra() {
    Utils.shareAptasutra('Aptasutra #${quotes[currentIndex].n}', '${quotes[currentIndex].g} ~ દાદા ભગવાન');
  }
}

class LinkText extends StatelessWidget {
  final String url = "https://www.dadabhagwan.org";

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: Text('dadabhagwan.org', style: TextStyle(color: Colors.blue[300], fontSize: 16)),
    );
  }
}
