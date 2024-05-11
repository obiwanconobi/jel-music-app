import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/helpers/apihelper.dart';

class JellyfinRepo{
  late String accessToken;
  late String baseServerUrl;
  late String userId;
  ApiHelper apiHelper = ApiHelper();

  JellyfinRepo(){
    accessToken = GetStorage().read('accessToken') ?? "";
    baseServerUrl = GetStorage().read('serverUrl') ?? "";
    userId = GetStorage().read('userId') ?? "";
     
  }

  getArtistBio(String artistName)async{
    try {
    //  var userId = GetStorage().read('userId');
    
     var requestHeaders = apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/Artists/$artistName";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  getArtistData() async{
    try {
      var userId = GetStorage().read('userId');
    
       var requestHeaders = apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/Artists/AlbumArtists?enableUserData=true&userId=$userId&enableImages=true&enableTotalRecordCount=true&isFavorite=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSongToPlaylist(String songId, String playlistId)async{
       var requestHeaders = apiHelper.returnJellyfinHeaders();
              String url = "$baseServerUrl/Playlists/$playlistId/Items?ids=$songId&userId=$userId";
              
              http.Response res = await http.post(Uri.parse(url), headers: requestHeaders);
              if (res.statusCode == 200) {
                return json.decode(res.body);
              }
  }

  startPlaybackReporting(String songId, String userId)async{
       var requestHeaders = apiHelper.returnJellyfinHeaders();
       String url = "$baseServerUrl/Users/$userId/PlayingItems/$songId";
      try{
        http.Response res = await http.post(Uri.parse(url), headers: requestHeaders);
              if (res.statusCode == 204) {
                return res.statusCode;
              }      
      }catch(e){
        //Log Error
        rethrow;
      }
  }
   stopPlaybackReporting(String songId, String userId)async{
       var requestHeaders = apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/Users/$userId/PlayingItems/$songId";
      try{
        http.Response res = await http.delete(Uri.parse(url), headers: requestHeaders);
              if (res.statusCode == 204) {
                return res.statusCode;
              }      
      }catch(e){
        //Log Error
        rethrow;
      }
  }

  deleteSongFromPlaylist(String songId, String playlistId)async{
       var requestHeaders = apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/Playlists/$playlistId/Items?entryIds=$songId&userId=$userId";
      try{
        http.Response res = await http.delete(Uri.parse(url), headers: requestHeaders);
              if (res.statusCode == 204) {
                return res.statusCode;
              }      
      }catch(e){
        //Log Error
      }
        
  }

  getLatestAlbums()async{
    //Users/D8B7A1C3-8440-4C88-80A1-04F7119FAA7A/Items?includeItemTypes=MusicAlbum&fields=DateCreated&sortBy=DateCreated&enableTotalRecordCount=true&enableImages=true&recursive=true&sortOrder=Descending&limit=20
    try{
         var requestHeaders = apiHelper.returnJellyfinHeaders();
         String url = "$baseServerUrl/Users/$userId/Items?includeItemTypes=MusicAlbum&fields=DateCreated&sortBy=DateCreated&enableTotalRecordCount=true&enableImages=true&recursive=true&sortOrder=Descending&limit=20";
        http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
        if (res.statusCode == 200) {
          return json.decode(res.body);
        }
    }catch (e) {
          rethrow;
        }
  }

  getPlaylists()async{
       try {
           var requestHeaders = apiHelper.returnJellyfinHeaders();
          String url = "$baseServerUrl/Items?includeItemTypes=Playlist&enableTotalRecordCount=true&enableImages=true&recursive=true";
          http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
          if (res.statusCode == 200) {
            return json.decode(res.body);
          }
        } catch (e) {
          rethrow;
        }
  }

  getPlaylistSongs(String playlistId)async{
      try {
             var requestHeaders = apiHelper.returnJellyfinHeaders();
          String url = "$baseServerUrl/Playlists/$playlistId/Items?fields=MediaStreams&userId=$userId";
          http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
          if (res.statusCode == 200) {
            return json.decode(res.body);
          }
        } catch (e) {
          rethrow;
        }
  }

  getUser()async{
        try {
             var requestHeaders = apiHelper.returnJellyfinHeaders();
          String url = "$baseServerUrl/Users/me";
          http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
          if (res.statusCode == 200) {
            return json.decode(res.body);
          }
        } catch (e) {
          rethrow;
        }
  }

  getSimilarItems(String itemId)async{
        try {
              var requestHeaders = apiHelper.returnJellyfinHeaders();
          String url = "$baseServerUrl/Items/$itemId/Similar?limit=10";
          http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
          if (res.statusCode == 200) {
            return json.decode(res.body);
          }
        } catch (e) {
          rethrow;
        }
  }

    Future<void> updateFavouriteStatus(String input, bool current) async {

       String itemId = '${input.substring(0, 8)}-${input.substring(8, 12)}-${input.substring(12, 16)}-${input.substring(16, 20)}-${input.substring(20)}';

        if(current){
          unFavouriteItem(itemId);
        }else{
          favouriteItem(itemId);
        }
    }

    Future<void> favouriteItem(String itemId) async {              
                  var requestHeaders = apiHelper.returnJellyfinHeaders();
              String url = "$baseServerUrl/Users/$userId/FavoriteItems/$itemId";
              
              http.Response res = await http.post(Uri.parse(url), headers: requestHeaders);
              if (res.statusCode == 200) {
                return json.decode(res.body);
              }
    }

    Future<void> unFavouriteItem(String itemId) async {
                  var requestHeaders = apiHelper.returnJellyfinHeaders();
              String url = "$baseServerUrl/Users/$userId/FavoriteItems/$itemId";
              
              http.Response res = await http.delete(Uri.parse(url), headers: requestHeaders);
              if (res.statusCode == 200) {
                return json.decode(res.body);
              }
    }

}