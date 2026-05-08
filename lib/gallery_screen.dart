import 'dart:math';

import 'package:aptasutra/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const String baseUrl = 'https://download.dadabhagwan.org/Quote_of_day/aptsutra_images/';
  List<String> dadaImgList = <String>[];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    generateImages();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => isLoading = false);
    });
  }

  generateImages() {
    // Vert_001.jpg to Vert_099.jpg
    for (int i = 2; i <= 99; i++) {
      dadaImgList.add('${baseUrl}Vert_${i.toString().padLeft(3, '0')}.jpg');
    }

    // dada_2.jpg to dada_140.jpg
    for (int i = 1; i <= 140; i++) {
      dadaImgList.add('${baseUrl}dada_$i.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 70;

    return 
    isLoading
        ? Scaffold(
            backgroundColor: const Color(0xFF111111),
            body: Center(child: CircularProgressIndicator(color: Colors.white24)),
          )
        :
    Scaffold(
      appBar: AppBar(title: const Text('Dada Nididhyasan')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: dadaImgList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GalleryViewer(images: dadaImgList, initialIndex: index),
                ),
              );
            },
            child: Hero(
              tag: dadaImgList[index],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: dadaImgList[index],
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) {
                    return Icon(Icons.image, size: iconSize, color: Colors.white24);
                  },
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryViewer({super.key, required this.images, required this.initialIndex});

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late final PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (_, index) {
                final q = widget.images[index];

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Center(
                    child: Container(
                      // color: Colors.blue,
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 5,
                        child: Hero(
                          tag: widget.images[index],
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: CachedNetworkImage(
                              imageUrl: widget.images[index],
                              // fit: BoxFit.fitHeight,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                                ),
                              ),
                              placeholder: (context, url) => Icon(Icons.image, size: 70, color: Colors.white24),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

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
          ],
        ),
      ),
    );
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
    final index = Random().nextInt(widget.images.length);
    goToQuote(index);
  }
}
