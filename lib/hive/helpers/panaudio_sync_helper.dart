import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/panaudio_handler.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/isynchelper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/hive/helpers/sync_helper.dart';
import 'package:jel_music/models/album.dart';

class PanaudioSyncHelper implements ISyncHelper {

  PanaudioHandler panaudioHandler = PanaudioHandler();
  SongsHelper songsHelper = SongsHelper();
  ArtistsHelper artistHelper = ArtistsHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
  String baseUrl = GetStorage().read('serverUrl') ?? "ERROR";


  @override
  runSync(bool check)async{
   // baseUrl = await GetStorage().read('serverUrl');
    int count = 0;
    List<Album> favAlbums = await panaudioHandler.returnFavouriteAlbums();
    List<String> favArtists = await panaudioHandler.returnFavouriteArtists();
    try{
      await songsHelper.openBox();
      var songs = await panaudioHandler.returnSongs();
      for(var song in songs){
        var addSong = Songs(id: song["id"],name: song["title"], artist: song["artist"], artistId: song["artistId"], album: song["album"], albumId: song["albumId"], favourite: song["favourite"], index: song["trackNumber"], playCount: song["playCount"], length: song["length"], year: 1900, codec: "", bitdepth: "", discIndex: 0, downloaded: false, bitrate: "", samplerate: "");
        var result = songsHelper.returnSong(addSong.artist, addSong.name);
        if(result == null){
          songsHelper.addSongToBox(addSong);
          count++;
        }else{
          if(addSong.playCount > result.playCount){
           songsHelper.updateSongPlayCount(addSong.id, addSong.playCount);
          }
        }

      }
      if(count > 0) {
        var savedSongs = await songsHelper.returnSongs();

        for (var savedSong in savedSongs) {
          await artistHelper.openBox();
          //save artist
          var artist = artistHelper.returnArtist(savedSong.artist);
          bool artistFav = false;

          var fav = favArtists.any((e) => e.toString().contains(savedSong.artistId));

          if (artist == null) {
            artistHelper.addArtistToBox(Artists(name: savedSong.artist,
                id: savedSong.artistId,
                picture: "$baseUrl/api/artistArt?artistId=${savedSong.artistId}" ,
                favourite: fav,
                playCount: 0));
          }else{
            if(artist.favourite != fav){
              artist.favourite = fav;
              artistHelper.updateArtist(artist);
            }
          }

          //save album
          await albumsHelper.openBox();
          String picture = baseUrl +
              "/api/albumArt?albumId=${savedSong.albumId}";


          bool favAlbum = false;
          var fav2 = favAlbums.where((element) => element.id == savedSong.albumId).firstOrNull;
          if(fav2 != null){
            favAlbum = true;
          }


          var album = albumsHelper.returnAlbum(
              savedSong.artist, savedSong.album);

          if (album == null) {

            if(true){
              print(1);
            }



            albumsHelper.addAlbumToBox(Albums(id: savedSong.albumId,
              name: savedSong.album,
              artist: savedSong.artist,
              artistId: savedSong.artistId,
              playCount: 0,
              picture: picture,
              favourite: favAlbum,
              year: "1900",),);
          }else{

            if(album.favourite != favAlbum){
              album.favourite = favAlbum;
              albumsHelper.updateAlbum(album, album.key);
            }
          }
        }
      }
    }catch(e){
      print(e);
    }
  }

  @override
  openBox() async{
   await songsHelper.openBox();
  }
  @override
  clearSongs() {
    songsHelper.clearSongs();
  }


}