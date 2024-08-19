
import 'package:jel_music/handlers/subsonic_handler.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';

class SubsonicSyncHelper{

  SongsHelper songsHelper = SongsHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
  ArtistsHelper artistsHelper = ArtistsHelper();
  SubsonicHandler subsonicHandler = SubsonicHandler();

  runSync()async{
    await songsHelper.openBox();
    await albumsHelper.openBox();
    await artistsHelper.openBox();

    var artists = await subsonicHandler.getArtists();
    for(var artist in artists){
      await artistsHelper.addArtistToBox(artist);
      await syncAlbumsForArtist(artist.id);
    }
  }

  syncAlbumsForArtist(id)async{
    var albums = await subsonicHandler.getAlbumsForArtist(id);
    for(var album in albums){
      await albumsHelper.addAlbumToBox(album);
      await syncSongsForAlbum(album.id);
    }
  }

  syncSongsForAlbum(id)async{
    var songs = await subsonicHandler.getSongsForAlbum(id);
    for(var song in songs){
      await songsHelper.addSongToBox(song);
    }
  }

}