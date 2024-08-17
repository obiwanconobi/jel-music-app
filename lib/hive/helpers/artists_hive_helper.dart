import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:jel_music/helpers/apihelper.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:http/http.dart' as http;

class ArtistsHelper{

  late Box<Artists> artistBox;
  var accessToken = GetStorage().read('accessToken');
  var baseServerUrl = GetStorage().read('serverUrl');
   ApiHelper apiHelper = ApiHelper();
  



  Future<void> openBox()async{
     await Hive.openBox<Artists>('artists');
     artistBox = Hive.box('artists');
  }

  List<Artists> returnArtists(){
    return artistBox.values.toList();
  }


  List<Artists> returnFavouriteArtists(bool favourite){
    return artistBox.values.where((artists) => artists.favourite == favourite).toList();
  }

  updateFavouriteStatus(String artistId){
    var artist =  artistBox.values.where((artists) => artists.id == artistId).first;
    if(artist.favourite == null || artist.favourite == false){
      artist.favourite = true;
    }else{
      artist.favourite = false;
    }
    artistBox.put(artist.key, artist);
  }
  
  clearArtists(){
    artistBox.clear();
  }

  addArtistToBox(Artists artist){
    artistBox.add(artist);
  }

  Artists? returnArtist(String name){
    return artistBox.values.where((artists) => artists.name == name).firstOrNull;
  }

  Artists? returnArtistById(String id){
    return artistBox.values.where((artists) => artists.id == id).firstOrNull;
  }
  
  void getAllArtists()async {

       // artistBox.clear();
      var artists = await fetchArtists();

      for(var artist in artists){

        try{
          artistBox.put(artist.id,artist);
        }catch(e){
          //log errr
         
        }
        
      }     

    }

  Future<List<Artists>> fetchArtists()async{

      var artistRaw = await _getArtistData();
      

      List<Artists> artistList = [];

      for(var artist in artistRaw["Items"]){  
        String test = artist["Name"];
          if(test.contains('blink')){
          
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
      var userId = GetStorage().read('userId');
    
       var requestHeaders = await apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/Artists/AlbumArtists?fields=Overview&enableUserData=true&userId=$userId&enableImages=true&enableTotalRecordCount=true&isFavorite=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }

       _getAlbumData() async{
        var userId = GetStorage().read('userId');
      try {
         var requestHeaders = await apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/Users/$userId/Items?recursive=true&includeItemTypes=MusicAlbum&videoTypes=&enableTotalRecordCount=true&enableImages=true";
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