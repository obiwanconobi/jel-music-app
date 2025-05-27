import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/helpers/apihelper.dart';

class SubsonicRepo{
  ApiHelper apiHelper = ApiHelper();
  String? baseServerUrl;
  SubsonicRepo(){
    setUrl();
  }

  setUrl(){
    baseServerUrl = GetStorage().read('serverUrl') ?? "";
  }


  createPlaylist(String playlistName)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/createPlaylist?name=$playlistName&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  scan()async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/startScan?$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  getSongsForAlbum(String id)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/getAlbum?id=$id&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  getLatestAlbums()async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/getAlbumList?type=newest&$requestHeaders";
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    }catch (e) {
      rethrow;
    }
  }

  getAlbumsForArtist(String id)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/getArtist?id=$id&$requestHeaders";

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
    setUrl();
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/getArtists?$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  getPlaylists()async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/getPlaylists?$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }
  getPlaylist(String id)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/getPlaylist?id=$id&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  addToPlaylist(String playlistId, String songId)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/updatePlaylist?playlistId=$playlistId&songIdToAdd=$songId&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  deleteFromPlaylist(String playlistId, String index)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/updatePlaylist?playlistId=$playlistId&songIndexToRemove=$index&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  getRecentAlbums()async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/getAlbumList?type=recent&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  starItem(String id)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/star?id=$id&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  unStarItem(String id)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/unstar?id=$id&$requestHeaders";

      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var test = json.decode(res.body);
        return test;
      }
    }catch(e){
      rethrow;
    }
  }

  logPlayback(String id)async{
    try{
      var requestHeaders = apiHelper.returnSubsonicHeaders();
      String url = "$baseServerUrl/rest/scrobble?id=$id&$requestHeaders";

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