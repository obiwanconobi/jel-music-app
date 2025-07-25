import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/panaudiomappers.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/repos/panaudio_repo.dart';

class PanaudioHandler implements IHandler{

  PanaudioMappers mapper = PanaudioMappers();
  String lastUpdateId = "TT";
  PanaudioRepo repo = GetIt.instance<PanaudioRepo>();
  PanaudioHandler(){
   // repo =
  }

  @override
  scan()async{
    await repo.scan();
  }

  @override
  getPlaybackByDays(DateTime inOldDate, DateTime inCurDate)async{
    return await repo.getPlaybackDays(inOldDate, inCurDate);
  }

  @override
  tryGetArt(String artist, String album)async{
    await repo.tryGetArt(artist, album);
  }

 Future<List<Album>> returnFavouriteAlbums()async{
    var albums = await repo.getFavouriteAlbums();
    return await mapper.mapAlbumFromRaw(albums);
  }
  Future<List<String>> returnFavouriteArtists()async{
    var artists = await repo.getFavouriteArtists();
      return await mapper.mapArtistIdsFromRaw(artists);

  }

  @override
  Future<List<Album>> returnLatestAlbums()async{
    var latestAlbums =  await repo.getLatestAlbums();
    return await mapper.mapAlbumFromRaw(latestAlbums);
  }

  @override
  updateFavouriteAlbum(String albumId, bool current)async{
    await repo.updateFavouriteAlbumStatus(albumId, current);
  }

  @override
  updateFavouriteStatus(String itemId, bool current)async{
   await repo.updateFavouriteStatus(itemId, current);
  }

  @override
  updateFavouriteArtist(String artistId, bool current)async{
    await repo.updateFavouriteArtistStatus(artistId, current);
  }

  @override
  uploadArt(String albumId, File image){
    return  repo.uploadArt(albumId, image);
  }

  @override
  Future<List<Artists>> fetchArtists()async{
    return [];
  }

  @override
  returnSongs()async{
    return await repo.getSongsDataRaw();
    //return await mapper.mapListSongsFromRaw(songsRaw);
  }

  returnArtist()async{

  }

  @override
  addSongToPlaylist(String songId, String playlistId) async{
    // TODO: implement addSongToPlaylist
    return await repo.addSongToPlaylist(playlistId, songId);
  }

  @override
  deleteSongFromPlaylist(String songId, String playlistId) async{
    // TODO: implement deleteSongFromPlaylist
    await repo.deleteSongFromPlaylist(playlistId, songId);
  }

  @override
  returnSongsFromPlaylist(String playlistId)async {
    // TODO: implement returnSongsFromPlaylist
    var songsRaw = await repo.getPlaylistSongs(playlistId);
    var mappedSongs = await mapper.mapSongFromRaw(songsRaw["playlistItems"]);
    return mappedSongs;
  }

  @override
  Future<List<Playlists>> returnPlaylists()async{
    // TODO: implement returnPlaylists
    var playlistsRaw = await repo.getPlaylists();
    List<Playlists> playlistList = [];
    for(var playlistRaw in playlistsRaw){

      playlistList.add(Playlists(id: playlistRaw["playlistId"], name: playlistRaw["playlistName"], runtime: "0"));
    }
    return playlistList;
  }

  @override
  returnArtistBio(String artistName) {
    // TODO: implement returnArtistBio
    throw UnimplementedError();
  }

  @override
  startPlaybackReporting(String songId, String? userId) async{
    // TODO: implement startPlaybackReporting
    await repo.startPlaybackReporting(songId);
  }

  @override
  stopPlaybackReporting(String songId, String userId) {
    // TODO: implement stopPlaybackReporting
   // throw UnimplementedError();
  }

  @override
  updatePlaybackProgress(String songId, String? userId, bool paused, int ticks) {
    // TODO: implement updatePlaybackProgress
    //throw UnimplementedError();
  }

  @override
  getPlaybackByArtists(DateTime inOldDate, DateTime inCurDate)async {
    // TODO: implement getPlaybackByArtists
    return await repo.getPlaybackArtists(inOldDate, inCurDate);
  }

  @override
  getPlaybackForDay(DateTime day)async {
    // TODO: implement getPlaybackForDay
    return await repo.getPlaybackForDay(day);
  }

  @override
  createPlaylist(String playlistName) async{
    // TODO: implement createPlaylist
    await repo.createPlaylist(playlistName);
  }

  @override
  getPlaybackSongsMonthly(DateTime inOldDate, DateTime inCurDate)async {
    // TODO: implement getPlaybackSongsMonthly
    return await repo.getPlaybackSongsMonthly(inOldDate, inCurDate);
  }
}