import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/apihelper.dart';
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
    ApiHelper apiHelper = ApiHelper();
    String baseServerUrl = "";
   // ApiController apiController = ApiController();
    var apiController = GetIt.instance<ApiController>();
    AlbumsHelper albumHelper = AlbumsHelper();
    ArtistsHelper artistsHelper = ArtistsHelper();
    late IHandler jellyfinHandler;

     Future<List<Album>> onInit() async {
       String serverType = GetStorage().read('ServerType');
       jellyfinHandler = GetIt.instance<IHandler>(instanceName: serverType);
    try {
      baseServerUrl = GetStorage().read('serverUrl');
      await getArtistInfo();
      await albumHelper.openBox();
      albums =  _getAlbumsFromBox(artistId!);
      return albums;
    } catch (error) {
      rethrow; // Rethrow the error if necessary
    }
  }

  playAllSongsFromArtist()async{

  }

  Future<Artists> getArtistInfo()async{
     await artistsHelper.openBox();
     String artistIds = "";
     var artistRaw = artistsHelper.returnArtist(artistId!);

     artistInfo.id = artistRaw!.id;
     artistIds = artistRaw.id;
     artistInfo.name = artistRaw.name;
    var pictureUrl = "$baseServerUrl/Items/$artistIds/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
         
     artistInfo.picture = pictureUrl;
     artistInfo.favourite = artistRaw.favourite;
     artistInfo.overview = artistRaw.overview;
     return artistInfo;
  }

  toggleArtistFavourite(String itemId, bool current)async{
    var serverType = GetStorage().read('ServerType') ?? "ERROR";
    if(serverType == "Jellyfin"){
      jellyfinHandler.updateFavouriteStatus(itemId, !current);
    }else if(serverType == "PanAudio"){
      jellyfinHandler.updateFavouriteArtist(itemId, !current);
    }
    artistsHelper.openBox();
    artistsHelper.updateFavouriteStatus(itemId);
  }

  Future<List<Album>> returnSimilar()async{

    String serverType = GetStorage().read('ServerType');
    if(serverType == "PanAudio")return [];
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
        albumsList.add(Album(id: album.id, title: album.name,artist: album.artist, year: int.parse(album.year!), picture: album.picture));
      }

      albumsList.sort((a, b) => a.year!.compareTo(b.year!));
      return albumsList;
  }

   _getAlbumData(String artistIdVal) async{
      try {

        String artistId = artistIdVal;
        var accessToken =await GetStorage().read('accessToken');
        var userId =await  GetStorage().read('userId');
        var deviceId = await GetStorage().read('deviceId');
        
          var requestHeaders = await apiHelper.returnJellyfinHeaders();
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
