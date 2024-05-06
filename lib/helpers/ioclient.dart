import 'dart:io';

import 'package:http/http.dart' as http;

class IoClient {
  static Future<String?> download(
      {required String url, required String path}) async {
    try {
      final res = await http.get(
        Uri.parse(url),
      );
      if (res.statusCode == 200) {
        final bytes = res.bodyBytes;
        final file = File(path);
        await file.writeAsBytes(bytes);
        return path;
      } else {
        return null;
      }
    } on IOException {
      return null;
    } catch(e) {
     
      return null;
    }
  }
}
