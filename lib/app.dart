import 'dart:convert';

import 'package:aptasutra/aptasutra.dart';
import 'package:aptasutra/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  static const starredListSharedPrefKey = 'starred_list';
  static const lastViewedAptasutraNoSharedPrefKey = 'last_viewed_aptasutra_no';

  static late final SharedPreferences sharedPrefs;
  static List<Aptasutra> sutraList = [];
  static int currentIndex = 0;
  static List<int> starredList = [];

  static initApp() async {
    sharedPrefs = await SharedPreferences.getInstance();
    await getStarredList();
  }

  static Future<void> loadQuotes() async {
    final jsonString = await rootBundle.loadString('assets/aptasutra.json');

    final List data = json.decode(jsonString);


      App.sutraList = data.map((e) => Aptasutra.fromJson(e)).toList();
    
  }

  static addToStarredList(int qn) {
    if (!starredList.contains(qn)) {
      starredList.add(qn);
      setStarredList();
    }
  }

  static removeFromStarredList(int qn) {
    if (starredList.contains(qn)) {
      starredList.remove(qn);
      setStarredList();
    }
  }

  static setStarredList() async {
    String jsonString = starredList.join(',');
    await sharedPrefs.setString(starredListSharedPrefKey, jsonString);
  }

  static getStarredList() async {
    String? csvString = sharedPrefs.getString(starredListSharedPrefKey);

    if (Utils.isNullOrEmpty(csvString)) {
      starredList = [];
    } else {
      starredList = csvString!.split(',').map((e) => int.parse(e)).toList();
    }
  }

  static setLastViewedAptasutraNo(int n) async {
    await sharedPrefs.setInt(lastViewedAptasutraNoSharedPrefKey, n);
  }

  static getLastViewedAptasutraNo() async {
    int? n = sharedPrefs.getInt(lastViewedAptasutraNoSharedPrefKey);

    return n ?? 0;
  }
}
