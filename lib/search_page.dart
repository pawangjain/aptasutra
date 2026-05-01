import 'package:aptasutra/app.dart';
import 'package:aptasutra/aptasutra.dart';
import 'package:aptasutra/utils.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final bool isStarredSearch;
  final List<Aptasutra> sutraList;

  const SearchPage({super.key, required this.sutraList, required this.isStarredSearch});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';

  List<MapEntry<int, Aptasutra>> get results {
    if (query.isEmpty) return [];

    final isNumber = int.tryParse(query) != null;

    return widget.sutraList.asMap().entries.where((entry) {
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
        actions: widget.isStarredSearch
            ? [
                Text(widget.sutraList.length.toString() + ' ', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.call_made),
                  onPressed: () {
                    Utils.shareAptasutra('Exported Aptasutra Starred List', App.starredList.join(','));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.call_received),
                  onPressed: () {
                    _importStarredApsNoCsvDialog(context);
                  },
                ),
              ]
            : [Text(results.length.toString() + ' ', style: const TextStyle(fontSize: 18))],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: widget.isStarredSearch ? widget.sutraList.length : results.length,
        itemBuilder: (_, i) {
          int n = 0;
          String q = '';

          if (widget.isStarredSearch) {
            n = widget.sutraList[i].n;
            q = widget.sutraList[i].g;
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
              decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(16)),
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

  void _importStarredApsNoCsvDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Comma Separated Aptasutra Numbers'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Starred Aptasutra Numbers CSV (e.g. 1,5,9)',
              border: OutlineInputBorder(), // default
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
            ),
            minLines: 10,
            maxLines: null, // allows it to grow beyond 10 lines
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = controller.text.trim();

                debugPrint('Entered value: $value'); // ✅ log output

                if (value.isEmpty) return;

                // 👉 show confirmation dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm'),
                      content: Text('Are you sure you want to overwrite the current starred list?\n\n$value'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  try {
                    App.starredList = value.split(',').map((e) => int.parse(e.trim())).toList();
                    App.setStarredList();
                    await App.loadQuotes();
                  } catch (e) {
                    debugPrint('Error parsing input: $e'); // ✅ log output
                  }

                  Navigator.pop(context);
                  Navigator.pop(context);
                  // rebuild home screen to reflect changes
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
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
