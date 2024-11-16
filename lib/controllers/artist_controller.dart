import 'package:get_it/get_it.dart';
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
    //ApiController apiController = ApiController();
    var apiController = GetIt.instance<ApiController>();

  clearList(){
    artistsList.clear();
  }

  Future<List<Artists>> onInit() async {
    try {
      baseServerUrl = GetStorage().read('serverUrl');
      await artistHelper.openBox();
      clearList();
      artistsList = _getArtistsFromBox(favourite);
      return artistsList;
    } catch (error) {
      // Handle errors if needed
       rethrow;
    }
  }



  //returns similar artists from Jellyfin api
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

  


  List<Artists> _getArtistsFromBox(bool? favourite){
      favourite ??= false;
      clearList();
      var artistsRaw = [];
      if(favourite == true){
         artistsRaw = artistHelper.returnFavouriteArtists(true);
      }else{
        artistsRaw = artistHelper.returnArtists();
      }
      for(var artist in artistsRaw){
          String artistId = artist.id;
         var pictureUrl = "$baseServerUrl/Items/$artistId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
        artistsList.add(Artists(id: artist.id, name: artist.name, picture: artist.picture , favourite: artist.favourite));
      }

   
      artistsList.sort((a, b) =>
      _removeSpecialCharacters(a.name!).compareTo(_removeSpecialCharacters(b.name!)));

      return artistsList;
    }

    String _removeSpecialCharacters(String str){
        return str.replaceAll("", "").replaceAll(".", "").replaceAll("-", "").toLowerCase();
    }

}
