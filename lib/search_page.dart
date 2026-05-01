import 'package:aptasutra/main.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final bool isStarredSearch;
  final List<Aptasutra> quotes;

  const SearchPage({super.key, required this.quotes, required this.isStarredSearch});

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
        title: widget.isStarredSearch
            ? Text('Starred Aptasutra')
            : TextField(
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
        itemCount: widget.isStarredSearch ? widget.quotes.length : results.length,
        itemBuilder: (_, i) {
          int n = 0;
          String q = '';

          if (widget.isStarredSearch) {
            n = widget.quotes[i].n;
            q = widget.quotes[i].g;
          } else {
            n = results[i].value.n;
            q = results[i].value.g;
          }

          return GestureDetector(
            onTap: () {
              // Return the quote number (1-based index) to the previous screen
              Navigator.pop(context, (n - 1));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHighlightedText(q, query),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${n}', style: TextStyle(fontSize: 22)),
                      const Text('~ દાદા ભગવાન', style: TextStyle(fontSize: 22)),
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
