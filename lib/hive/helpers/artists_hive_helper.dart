import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:http/http.dart' as http;

class ArtistsHelper{

  late Box<Artists> artistBox;
  var accessToken = GetStorage().read('accessToken');
  var baseServerUrl = GetStorage().read('serverUrl');
  



  Future<void> openBox()async{
     await Hive.openBox<Artists>('artists');
     artistBox = Hive.box('artists');
  }


  List<Artists> returnArtists(bool favourite){
    return artistBox.values.where((Artists) => Artists.favourite == favourite).toList();
  }
  
  clearArtists(){
    artistBox.clear();
  }

  addArtistToBox(Artists artist){
    artistBox.add(artist);
  }

  Artists? returnArtist(String name){
    return artistBox.values.where((Artists) => Artists.name == name).firstOrNull;
  }

  
  void getAllArtists()async {

       // artistBox.clear();
      var artists = await fetchArtists();

      for(var artist in artists){

        try{
          artistBox.put(artist.id,artist);
        }catch(e){
          //log errr
          print("error");
        }
        
      }     

    }

  Future<List<Artists>> fetchArtists()async{

      var artistRaw = await _getArtistData();
      

      List<Artists> artistList = [];

      for(var artist in artistRaw["Items"]){  
        String test = artist["Name"];
          if(test.contains('blink')){
            print('stop');
          }    
          artistList.add(Artists(id: artist["Id"], name: artist["Name"], favourite: artist["UserData"]["IsFavorite"], picture: artist["Id"]));
      }
      return artistList;
  }

    getArtistDataFavourite(){
      return _getArtistData();
    }

     _getArtistData() async{
    try {
      var userId = "D8B7A1C3-8440-4C88-80A1-04F7119FAA7A";
    
      Map<String, String> requestHeaders = {
       'Content-type': 'application/json',
       'X-MediaBrowser-Token': '$accessToken',
       'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
     };
      String url = "$baseServerUrl/Artists/AlbumArtists?enableUserData=true&userId=$userId&enableImages=true&enableTotalRecordCount=true&isFavorite=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

       _getAlbumData() async{
      try {
          Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'X-MediaBrowser-Token': '$accessToken',
          'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
        };
      String url = "$baseServerUrl/Users/D8B7A1C3-8440-4C88-80A1-04F7119FAA7A/Items?recursive=true&includeItemTypes=MusicAlbum&videoTypes=&enableTotalRecordCount=true&enableImages=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
   }

  Future<List<Albums>> fetchAlbums() async{
    var albumsRaw = await _getAlbumData();

    List<Albums> albumsList = [];

    for(var album in albumsRaw["Items"]){
      String albumId = album["Id"];
      var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      albumsList.add(Albums(id: album["Id"], name: album["Name"],artist: album["AlbumArtist"], year: album["ProductionYear"] ?? 1900, picture: imgUrl, favourite: album["UserData"]["IsFavorite"], artistId: album["artistId"]));
    }

    return albumsList;
  }


}