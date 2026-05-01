import 'package:aptasutra/app.dart';

class Aptasutra {
  final int n;
  final String g;
  bool isStarred;

  Aptasutra({required this.n, required this.g, required this.isStarred});

  factory Aptasutra.fromJson(Map<String, dynamic> json) {
    return Aptasutra(n: json['n'], g: json['g'], isStarred: App.starredList.contains(json['n']));
  }
}
