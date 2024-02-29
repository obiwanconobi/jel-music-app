import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jel_music/models/artist.dart';
import 'package:get_storage/get_storage.dart';



class ArtistController {
    var artists = <Artists>[];
    Future<List<Artists>>? futureList;
    final int currentArtistIndex = 0;
    String? baseServerUrl;
    

    Future<List<Artists>> onInit() async {
    try {
      baseServerUrl = GetStorage().read('serverUrl');
      artists = await fetchArtists();
      return artists;
    } catch (error) {
      // Handle errors if needed
       rethrow;
    }
  }




    _getArtistData() async{
    try {

      var accessToken = GetStorage().read('accessToken');

      Map<String, String> requestHeaders = {
       'Content-type': 'application/json',
       'X-MediaBrowser-Token': '$accessToken',
       'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
     };
      String url = "$baseServerUrl/Artists/AlbumArtists?enableImages=true&enableTotalRecordCount=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<List<Artists>> fetchArtists() async{

      var artistRaw = await _getArtistData();


      List<Artists> artistList = [];

      for(var artist in artistRaw["Items"]){

          //could be used to minimise image errors 
          /* String? pictureTag;

          if(artist["ImageTags"] != null){
              var img = artist["ImageTags"];
              pictureTag = img["Primary"] ?? img["Banner"] ?? img["Logo"] ?? "";
          } */
          String artistId = artist["Id"];
          var pictureUrl = "$baseServerUrl/Items/$artistId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
          
          artistList.add(Artists(id: artist["Id"], name: artist["Name"], picture: pictureUrl));
      }

      artists = artistList;
      return artists;
  }

}
