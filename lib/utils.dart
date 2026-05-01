import 'package:aptasutra/constants.dart';
import 'package:share_plus/share_plus.dart';

class Utils {
  static bool isNullOrEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  static shareAptasutra(String title, String content) async {
    var shareText = '$title\n\n$content\n\n${Constants.footerTextForShare}';
    SharePlus.instance.share(ShareParams(text: shareText, subject: title));
  }
}