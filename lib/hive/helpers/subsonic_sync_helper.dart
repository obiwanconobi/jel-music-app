
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/handlers/subsonic_handler.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/artists_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/log.dart';

class SubsonicSyncHelper{

  SongsHelper songsHelper = SongsHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
  ArtistsHelper artistsHelper = ArtistsHelper();
  SubsonicHandler subsonicHandler = SubsonicHandler();
  LogHandler logger = LogHandler();

  runSync()async{
    await songsHelper.openBox();
    await albumsHelper.openBox();
    await artistsHelper.openBox();

    var artists = await subsonicHandler.getArtists();
    for(var artist in artists){
      try{
        await artistsHelper.addArtistToBox(artist);
      }catch(e){
        await logger.addToLog(LogModel(logType: "Error", logMessage: "Error adding artist: ${artist.name}", logDateTime: DateTime.now()));
      }

      await syncAlbumsForArtist(artist.id);
    }
  }

  syncAlbumsForArtist(id)async{
    var albums = await subsonicHandler.getAlbumsForArtist(id);
    for(var album in albums){
      try{
        await albumsHelper.addAlbumToBox(album);
      }catch(e){
        await logger.addToLog(LogModel(logType: "Error", logMessage: "Error adding album: ${album.name}", logDateTime: DateTime.now()));
      }

      await syncSongsForAlbum(album.id);
    }
  }

  syncSongsForAlbum(id)async{
    var songs = await subsonicHandler.getSongsForAlbum(id);
    for(var song in songs){
      try{
        await songsHelper.addSongToBox(song);
      }catch(e){
        await logger.addToLog(LogModel(logType: "Error", logMessage: "Error adding song: ${song.name}", logDateTime: DateTime.now()));

      }

    }
  }

}