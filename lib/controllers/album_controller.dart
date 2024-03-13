import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/models/album.dart';
import 'package:get_storage/get_storage.dart';


class AlbumController {
    var albums = <Album>[];
    String? artistId;
    final int currentArtistIndex = 0;
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    AlbumsHelper albumHelper = AlbumsHelper();

     Future<List<Album>> onInit() async {
    try {
   //   albums = await fetchAlbums(artistId!);
      await albumHelper.openBox();
      albums = await _getAlbumsFromBox(artistId!);
      return albums;
    } catch (error) {
      // Handle errors if needed
    //  print('Error fetching artists: $error');
      rethrow; // Rethrow the error if necessary
    }
  }

  List<Album> _getAlbumsFromBox(String artistIdVal){
      var albumsRaw = albumHelper.returnAlbumsForArtist(artistIdVal);
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
        
          Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'X-MediaBrowser-Token': '$accessToken',
          'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
        };
      String url = "$baseServerUrl/Users/D8B7A1C3-8440-4C88-80A1-04F7119FAA7A/Items?recursive=true&includeItemTypes=MusicAlbum&artistIds=$artistId&videoTypes=&enableTotalRecordCount=true&enableImages=true";
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
