import 'package:get_storage/get_storage.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/models/artist.dart';

class ArtistButtonController{
  late String artistId;
  ArtistsHelper artistHelper = ArtistsHelper();
  String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
  Future<Artists> onInit() async {
    await artistHelper.openBox();
    var artist = artistHelper.returnArtist(artistId);
  String artistIdValue = artist!.id;
   var pictureUrl = "$baseServerUrl/Items/$artistIdValue/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
         
    return Artists(id: artist!.id, name: artist.name, picture: pictureUrl, favourite: artist.favourite, overview: artist.overview);

  }
}