import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/helpers/apihelper.dart';

class SubsonicRepo{
  ApiHelper apiHelper = ApiHelper();
  String? baseServerUrl;
  SubsonicRepo(){
    baseServerUrl = GetStorage().read('serverUrl') ?? "";
  }

  getSongsForAlbum(String id)async{
    try{
      var requestHeaders = await apiHelper.returnSubsonicHeaders();
      String url = "http://192.168.1.15:4533/rest/getAlbum?id=$id&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  getAlbumsForArtist(String id)async{
    try{
      var requestHeaders = await apiHelper.returnSubsonicHeaders();
      String url = "http://192.168.1.15:4533/rest/getArtist?id=$id&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  getArtistData()async{
    try{
      var requestHeaders = await apiHelper.returnSubsonicHeaders();
      String url = "http://192.168.1.15:4533/rest/getArtists?$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

}