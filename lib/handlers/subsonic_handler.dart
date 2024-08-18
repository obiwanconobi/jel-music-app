import 'package:get_it/get_it.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/repos/subsonic_repo.dart';

import '../helpers/conversions.dart';
import '../hive/classes/artists.dart';

class SubsonicHandler{

  late SubsonicRepo subsonicRepo;
  Conversions conversions = Conversions();
  SubsonicHandler(){
    subsonicRepo = GetIt.instance<SubsonicRepo>();

  }

  Future<List<Songs>> getSongsForAlbum(String id)async{
    List<Songs> songsList = [];
    var rawSongs = await subsonicRepo.getSongsForAlbum(id);
    final songData = rawSongs["subsonic-response"]["album"]["song"];
    for(var songs in songData){
      var title = songs["title"];
      songsList.add(Songs(name: songs["title"], id: songs["id"], artist: songs["artist"], artistId: songs["artistId"], albumId: id, album: songs["album"], index: songs["track"], year: songs["year"], length: conversions.returnSecondsToTimestampString(songs["duration"]), favourite: songs["starred"] != null, discIndex: songs["discNumber"], codec: songs["suffix"]));
    }
    return songsList;
  }

  Future<List<Albums>> getAlbumsForArtist(String id)async{
    List<Albums> albums = [];
    var rawAlbums = await subsonicRepo.getAlbumsForArtist(id);
    final albumData = rawAlbums["subsonic-response"]["artist"]["album"];
    for(var album in albumData){
      albums.add(Albums(id: album["id"], name: album["title"], picture: album["coverArt"], favourite: album["starred"] != null, artistId: id, artist: album["artist"], year: album["year"].toString(), ));
    }
    return albums;
  }

 Future<List<Artists>> getArtists()async{
    var rawArtists = await subsonicRepo.getArtistData();
    final artistsData = rawArtists["subsonic-response"]["artists"]["index"];
    List<Artists> artistsList = [];

    for (var index in artistsData) {
      for (var artist in index['artist']) {
        artistsList.add(Artists(
          id: artist['id'],
          name: artist['name'],
          picture: artist['artistImageUrl'],
          favourite: artist['starred'] != null,
          overview: null, // Left as null as per your request
        ));

        var album = await getAlbumsForArtist(artist['id']);
      }
    }
    return artistsList;
  }

}