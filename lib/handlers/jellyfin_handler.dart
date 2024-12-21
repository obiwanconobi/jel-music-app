import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/models/log.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/repos/jellyfin_repo.dart';

class JellyfinHandler implements IHandler{

  JellyfinRepo jellyfinRepo = GetIt.instance<JellyfinRepo>();
  Conversions conversions = Conversions();
  Mappers mapper = Mappers();
  LogHandler logger = LogHandler();
  JellyfinHandler(){
    //jellyfinRepo =
  }

  @override
  updateFavouriteStatus(String itemId, bool current)async{
    await jellyfinRepo.updateFavouriteStatus(itemId, !current);
  }

  @override
  returnArtistBio(String artistName)async{
    return await jellyfinRepo.getArtistBio(artistName);
  }


  @override
  Future<List<Album>>  returnLatestAlbums()async{
    var albumsRaw =  await jellyfinRepo.getLatestAlbums();
    return await mapper.mapAlbumFromRaw(albumsRaw);
  }

  @override
  Future<List<Artists>> fetchArtists()async{

      var artistRaw = await jellyfinRepo.getArtistData();
      

      List<Artists> artistList = [];

      for(var artist in artistRaw["Items"]){  
        String test = artist["Name"];
          if(test.contains('blink')){
          
          }    
          artistList.add(Artists(id: artist["Id"], name: artist["Name"], favourite: artist["UserData"]["IsFavorite"], picture: artist["Id"], playCount: 0));
      }
      return artistList;
  }

  @override
  returnSongs()async{
    return await jellyfinRepo.getSongsDataRaw();
    //return await mapper.mapListSongsFromRaw(songsRaw);
  }

  @override
  Future<List<Playlists>> returnPlaylists()async{
    var playlistsRaw = await jellyfinRepo.getPlaylists();
    List<Playlists> playlistList = [];
    for(var playlistRaw in playlistsRaw["Items"]){
      
      playlistList.add(Playlists(id: playlistRaw["Id"], name: playlistRaw["Name"], runtime: conversions.returnTicksToTimestampString(playlistRaw["RunTimeTicks"] ?? 0)));
    }
    return playlistList;
  }

  @override
  uploadArt(String albumId, File image){

  }
  @override
  updateFavouriteAlbum(String albumId, bool current)async{

  }
  @override
  updateFavouriteArtist(String artistId, bool current)async{

  }
  @override
  Future<List<Songs>> returnSongsFromPlaylist(String playlistId)async{
    var songsRaw = await jellyfinRepo.getPlaylistSongs(playlistId);
    var mappedSongs = await mapper.mapSongFromRaw(songsRaw["Items"]);
    return mappedSongs;
  }

  @override
  addSongToPlaylist(String songId, String playlistId)async{
    await jellyfinRepo.addSongToPlaylist(songId, playlistId);
  }

  @override
  deleteSongFromPlaylist(String songId, String playlistId)async{
    await jellyfinRepo.deleteSongFromPlaylist(songId, playlistId);
  }

  @override
  startPlaybackReporting(String songId, String userId)async{
    try{
      await jellyfinRepo.startPlaybackReporting(songId, userId);
    }catch(e){
      await logger.addToLog(LogModel(logType: "Error", logMessage: "Error starting playback: $songId", logDateTime: DateTime.now()));
    }

  }

  @override
  updatePlaybackProgress(String songId, String userId, bool paused, int ticks)async{
    await jellyfinRepo.updatePlaybackProgress(songId, userId, paused, ticks);
  }

  @override
  stopPlaybackReporting(String songId, String userId)async{
    await jellyfinRepo.stopPlaybackReporting(songId, userId);
  }

  @override
  tryGetArt(String artist, String album) {
    // TODO: implement tryGetArt
    throw UnimplementedError();
  }

  @override
  getPlaybackByDays(DateTime inOldDate, DateTime inCurDate) {
    // TODO: implement getPlaybackByDays
    throw UnimplementedError();
  }

  @override
  getPlaybackByArtists(DateTime inOldDate, DateTime inCurDate) {
    // TODO: implement getPlaybackByArtists
    throw UnimplementedError();
  }

  @override
  getPlaybackForDay(DateTime day) {
    // TODO: implement getPlaybackForDay
    throw UnimplementedError();
  }

  

}