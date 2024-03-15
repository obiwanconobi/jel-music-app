import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';

class SyncHelper{
  SongsHelper songsHelper = SongsHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
  ArtistsHelper artistsHelper = ArtistsHelper();

  runSync()async{

    await songsHelper.addSongsToBox();
    albumsHelper.openBox();
    artistsHelper.openBox();
    List<Songs> listOfSongs = await songsHelper.returnSongs();

    for(var song in listOfSongs){
      
      var artist = await artistsHelper.returnArtist(song.artist);
      if(artist.isEmpty){
        await artistsHelper.addArtistToBox(Artists(id: song.artistId, name: song.artist, picture: song.artistId, favourite: false));
      }

      var album = await albumsHelper.returnAlbum(song.artist, song.album);
      
      if(album.isEmpty){
        
        await albumsHelper.addAlbumToBox(Albums(id: song.albumId, name: song.album, picture: song.albumId, favourite: false, artist: song.artist, artistId: song.artistId, year: song.year.toString()));
      }

      

    }

  }


}