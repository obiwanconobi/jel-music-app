import 'dart:convert';

import 'package:http/http.dart' as http;

class LrclibHandler{

  String baseUrl = "https://lrclib.net/api";
  Map<String, String> requestHeaders = {
    'User-Agent':'PanAudio 1.3.3'
  };
  getLyrics(String artist, String song)async{
    try {
      //  var userId = GetStorage().read('userId');

      //var requestHeaders = await apiHelper.returnJellyfinHeaders();
      String url = "$baseUrl/get?artist_name=$artist&track_name=$song";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

}