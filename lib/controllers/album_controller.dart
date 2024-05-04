import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/models/album.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/models/artist.dart';

class AlbumController {
    var albums = <Album>[];
    String? artistId;
    final int currentArtistIndex = 0;
    String? albumId;
    late Artists artistInfo = Artists();
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
   // ApiController apiController = ApiController();
    var apiController = GetIt.instance<ApiController>();
    AlbumsHelper albumHelper = AlbumsHelper();
    ArtistsHelper artistsHelper = ArtistsHelper();
    JellyfinHandler jellyfinHandler = JellyfinHandler();

     Future<List<Album>> onInit() async {
    try {
      await getArtistInfo();
      await albumHelper.openBox();
      albums =  _getAlbumsFromBox(artistId!);
      return albums;
    } catch (error) {
      rethrow; // Rethrow the error if necessary
    }
  }

  Future<Artists> getArtistInfo()async{
     await artistsHelper.openBox();
     var artistRaw = artistsHelper.returnArtist(artistId!);
     artistInfo.id = artistRaw!.id;
     artistInfo.name = artistRaw.name;
     artistInfo.picture = artistRaw.picture;
     artistInfo.favourite = artistRaw.favourite;
     return artistInfo;
  }

  toggleArtistFavourite(String itemId, bool current)async{
    await jellyfinHandler.updateFavouriteStatus(artistInfo.id!, current);
    artistsHelper.openBox();
    artistsHelper.updateFavouriteStatus(itemId);
  }

  Future<List<Album>> returnSimilar()async{
    await albumHelper.openBox();
    var album = albumHelper.returnAlbum(artistId!, albumId!);
    
    var albumsRaw = await apiController.getSimilarItems(album!.id);
    //Future<List<Album>> returnList;
    List<Album> albumsList = [];
    for(var album in albumsRaw["Items"]){
          String albumId = album["Id"];
        //  Albums? albumGot = albumHelper.returnAlbum(artist, title);
      var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      albumsList.add(Album(id: album["Id"], title: album["Name"],artist: album["AlbumArtist"], year: album["ProductionYear"] ?? 1900, picture: imgUrl));
  
    }
    return albumsList;

  }


  List<Album> _getAlbumsFromBox(String artistIdVal){
      List<Albums> albumsRaw = [];
      albumsRaw = albumHelper.returnAlbumsForArtist(artistIdVal);
     
      List<Album> albumsList = [];
      for(var album in albumsRaw){
        String albumId = album.id;
        var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
        albumsList.add(Album(id: album.id, title: album.name,artist: album.artist, year: int.parse(album.year!), picture: imgUrl));
      }

      albumsList.sort((a, b) => a.year!.compareTo(b.year!));
      return albumsList;
  }

   _getAlbumData(String artistIdVal) async{
      try {

        String artistId = artistIdVal;
        var accessToken = GetStorage().read('accessToken');
        var userId = GetStorage().read('userId');
        
          Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'X-MediaBrowser-Token': '$accessToken',
          'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
        };
      String url = "$baseServerUrl/Users/$userId/Items?recursive=true&includeItemTypes=MusicAlbum&artistIds=$artistId&videoTypes=&enableTotalRecordCount=true&enableImages=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      //  var test = (result as List).map((e) => DailyModel.fromJson(e)).toList();
      //  _isLoading = false;
       // setState(() {});
      }
    } catch (e) {
      rethrow;
    }
   }

  Future<List<Album>> fetchAlbums(String artistId) async{
    var albumsRaw = await _getAlbumData(artistId);

    List<Album> albumsList = [];

    for(var album in albumsRaw["Items"]){
      String albumId = album["Id"];
      var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      albumsList.add(Album(id: album["Id"], title: album["Name"],artist: album["AlbumArtist"], year: album["ProductionYear"] ?? 1900, picture: imgUrl));
    }

    return albumsList;
  }


}
