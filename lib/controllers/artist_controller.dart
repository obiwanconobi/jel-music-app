import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jel_music/controllers/api_controller.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/models/artist.dart';
import 'package:get_storage/get_storage.dart';



class ArtistController {
    var artistsList = <Artists>[];
    Future<List<Artists>>? futureList;
    final int currentArtistIndex = 0;
    String? baseServerUrl;
    bool? favourite;
    String? artistId;
    ArtistsHelper artistHelper = ArtistsHelper();
    ApiController apiController = ApiController();

  Future<List<Artists>> returnSimilar()async{
    baseServerUrl = GetStorage().read('serverUrl');
    await artistHelper.openBox();
    var artistFromBox = artistHelper.returnArtist(artistId!);

    

    var artistRaw = await apiController.getSimilarItems(artistFromBox!.id);
    List<Artists> artistsList = [];



      for(var artist in artistRaw["Items"]){

          String artistId = artist["Id"];
          var pictureUrl = "$baseServerUrl/Items/$artistId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
          
          artistsList.add(Artists(id: artist["Id"], name: artist["Name"], picture: pictureUrl));
      }
    
    return artistsList;

  }

    Future<List<Artists>> onInit() async {
    try {
      baseServerUrl = GetStorage().read('serverUrl');
      await artistHelper.openBox();
      artistsList = _getArtistsFromBox(favourite);
      return artistsList;
    } catch (error) {
      // Handle errors if needed
       rethrow;
    }
  }


    List<Artists> _getArtistsFromBox(bool? favourite){
      favourite ??= false;
       var artistsRaw = artistHelper.returnArtists(favourite);

      for(var artist in artistsRaw){
          String name = artist.name;
          if(name.contains("link")){
            print("tee");
          }
          String artistId = artist.id;
         var pictureUrl = "$baseServerUrl/Items/$artistId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
        artistsList.add(Artists(id: artist.id, name: artist.name, picture: pictureUrl));
      }

     // albumsList.sort((a, b) => a.year!.compareTo(b.year!));
     // artistsList.sort((a, b) => a.name!.substring(0,2).compareTo(b.name!.substring(0,2)));
      
    
     // artistsList.sorted((a, b) => a.name.compareTo(b.name));
      artistsList.sort((a, b) =>
      _removeSpecialCharacters(a.name!).compareTo(_removeSpecialCharacters(b.name!)));
  
      return artistsList;
    }

    String _removeSpecialCharacters(String str){
        if(str.contains("blink")){
          print("ss");
        }
        return str.replaceAll("‐", "").replaceAll(".", "").replaceAll("-", "").toLowerCase();
       // return str;
       // return returnStr.replaceAll('.', '');
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

    //  var artistRaw = await _getArtistData();


      List<Artists> artistList = [];

     /*  for(var artist in artistRaw["Items"]){

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
 */
      


      return _getArtistsFromBox(false);
  }

}
