import 'dart:convert';
import 'dart:math';

import 'package:aptasutra/app.dart';
import 'package:aptasutra/aptasutra.dart';
import 'package:aptasutra/aptasutra_screen.dart';
import 'package:aptasutra/constants.dart';
import 'package:aptasutra/gallery_screen.dart';
import 'package:aptasutra/search_page.dart';
import 'package:aptasutra/star_button.dart';
import 'package:aptasutra/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aptasutra/main.dart';
import 'package:flutter/material.dart';

class AptasutraScreen extends StatefulWidget {
  const AptasutraScreen({super.key});

  @override
  State<AptasutraScreen> createState() => _AptasutraScreenState();
}

class _AptasutraScreenState extends State<AptasutraScreen> {
  final PageController _controller = PageController();
  static const double _fontSize = 28;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await App.initApp();
      await App.loadQuotes();
      setState(() {});
      int lastViewedNo = await App.getLastViewedAptasutraNo();
      await Future.delayed(const Duration(milliseconds: 900));
      goToQuote(lastViewedNo);
    });
  }

  void goToQuote(int index) {
    _controller.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void goToPrevious() {
    _controller.animateToPage(App.currentIndex - 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void goToNext() {
    _controller.animateToPage(App.currentIndex + 1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void randomQuote() {
    final index = Random().nextInt(App.sutraList.length);
    goToQuote(index);
  }

  Future<void> openSearch() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => SearchPage(sutraList: App.sutraList, isStarredSearch: false)),
    );

    if (result != null) {
      goToQuote(result);
    }
  }

  Future<void> openStarredPage() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(sutraList: App.sutraList.where((u) => u.isStarred).toList(), isStarredSearch: true),
      ),
    );

    if (result != null) {
      goToQuote(result);
    }
  }

  Future<void> openGallery() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (App.sutraList.isEmpty) {
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
                setState(() {
                  App.currentIndex = i;
                  App.setLastViewedAptasutraNo(App.currentIndex);
                });
              },
              itemCount: App.sutraList.length,
              itemBuilder: (_, index) {
                final q = App.sutraList[index];

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    decoration: BoxDecoration(color: Constants.cardColor, borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.all(18),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SelectableText(
                                      q.g,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: _fontSize, height: 1.8),
                                    ),
                                    SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SelectableText(
                                                // '#${q.n}',
                                                '${q.n}',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  color: dividerColor,
                                                  // fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              StarButton(aptasutra: q),
                                            ],
                                          ),
                                          const SelectableText(
                                            '~ દાદા ભગવાન',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  IconButton(
                    onPressed: openGallery,
                    icon: Icon(Icons.image_outlined, color: Theme.of(context).dividerColor),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    onPressed: openStarredPage,
                    icon: Icon(Icons.star_half_rounded, color: Theme.of(context).dividerColor),
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
    Utils.shareAptasutra(
      'Aptasutra #${App.sutraList[App.currentIndex].n}',
      '${App.sutraList[App.currentIndex].g} ~ દાદા ભગવાન',
    );
  }
}

class LinkText extends StatelessWidget {
  final String url = "https://www.dadabhagwan.org";

  Future<void> _launchUrl() async {
    // final Uri uri = Uri.parse(url);

    // if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    //   throw 'Could not launch $url';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: Text('dadabhagwan.org', style: TextStyle(color: const Color.fromARGB(255, 100, 100, 100), fontSize: 13.5)),
    );
  }
}
