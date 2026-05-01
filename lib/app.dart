import 'dart:convert';

import 'package:aptasutra/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  static const starredListSharedPrefKey = 'starred_list';

  static late final SharedPreferences sharedPrefs;
  static List<int> starredList = [];

  static initApp() async {
    sharedPrefs = await SharedPreferences.getInstance();
    await getStarredList();
  }

  static addToStarredList(int qn) {
    if (!starredList.contains(qn)) {
      starredList.add(qn);
      saveStarredList();
    }
  }

  static removeFromStarredList(int qn) {
    if (starredList.contains(qn)) {
      starredList.remove(qn);
      saveStarredList();
    }
  }

  static saveStarredList() async {
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
}
