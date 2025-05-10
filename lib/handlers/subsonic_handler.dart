import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/helpers/apihelper.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/models/log.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/repos/subsonic_repo.dart';
import '../helpers/conversions.dart';
import '../hive/classes/artists.dart';
import 'ihandler.dart';

class SubsonicHandler implements IHandler{

  late SubsonicRepo subsonicRepo;
  Conversions conversions = Conversions();
  LogHandler logger = LogHandler();
  ApiHelper apiHelper = ApiHelper();
  AlbumsHelper albumsHelper = AlbumsHelper();
  SongsHelper songsHelper = SongsHelper();
  Mappers mappers = Mappers();
  var baseServerUrl = "";
  String lastLoggedId = "";
  SubsonicHandler(){
    subsonicRepo = GetIt.instance<SubsonicRepo>();
    baseServerUrl = GetStorage().read('serverUrl') ?? "";
    openBox();
  }

  @override
  scan()async{
  await subsonicRepo.scan();
  }

  openBox()async{
    await albumsHelper.openBox();
    await songsHelper.openBox();
  }

  Future<List<Songs>> getSongsForAlbum(String id)async{
    List<Songs> songsList = [];
    var rawSongs = await subsonicRepo.getSongsForAlbum(id);
    final songData = rawSongs["subsonic-response"]["album"]["song"];
    for(var songs in songData){
      var title = songs["title"];
        try{
          songsList.add(Songs(name: songs["title"], id: songs["id"], artist: songs["artist"], artistId: songs["artistId"] ?? "N/A", albumId: id, album: songs["album"], index: songs["track"] ?? 0, year: songs["year"] ?? 1900, length: conversions.returnSecondsToTimestampString(songs["duration"]), favourite: songs["starred"] != null, discIndex: songs["discNumber"] ?? 0, codec: songs["suffix"], playCount: songs["playCount"] ?? 0));
        }catch(e){
          await logger.openBox();
          await logger.addToLog(LogModel(logType: "Error", logMessage: "Error adding song: $title: $e", logDateTime: DateTime.now()));
        }
      }
    return songsList;
  }

  Future<List<Albums>> getAlbumsForArtist(String id)async{
    baseServerUrl = GetStorage().read('serverUrl') ?? "";
    List<Albums> albums = [];
    var rawAlbums = await subsonicRepo.getAlbumsForArtist(id);
    final albumData = rawAlbums["subsonic-response"]["artist"]["album"];
    for(var album in albumData){
      var coverArt = "$baseServerUrl/rest/getCoverArt?id=${album["id"]}&${apiHelper.returnSubsonicHeaders()}";
      var albumName = album["name"].toString();
      albumName = albumName.replaceAll("â", "-");
      var albumYear = album["year"];
      albumYear ??= "0";
      albums.add(Albums(id: album["id"], name: albumName, picture: coverArt, favourite: album["starred"] != null, artistId: id, artist: album["artist"], year: albumYear.toString(), playCount: 0,));
    }
    return albums;
  }

 Future<List<Artists>> getArtists()async{
    var rawArtists = await subsonicRepo.getArtistData();
    final artistsData = rawArtists["subsonic-response"]["artists"]["index"];
    List<Artists> artistsList = [];

    for (var index in artistsData) {
      for (var artist in index['artist']) {

        var test = artist['name'].toString();
        if(test.startsWith("Jack")){
          print('stp[');
        }

        artistsList.add(Artists(
          id: artist['id'],
          name: artist['name'],
          picture: artist['artistImageUrl'],
          favourite: artist['starred'] != null,
          overview: null, // Left as null as per your request
          playCount: 0
        ));

        var album = await getAlbumsForArtist(artist['id']);
      }
    }
    return artistsList;
  }

  @override
  addSongToPlaylist(String songId, String playlistId) async{
    // TODO: implement addSongToPlaylist
   var result = await subsonicRepo.addToPlaylist(playlistId, songId);
   if(result["subsonic-response"]["status"] == "ok")return true;
  }

  @override
  deleteSongFromPlaylist(String songId, String playlistId) async {
    // TODO: implement deleteSongFromPlaylist
    List<ModelSongs> playlist = await returnSongsFromPlaylist(playlistId);
    var index = playlist.indexWhere((element) => element.id == songId);
    var result = await subsonicRepo.deleteFromPlaylist(playlistId, index.toString());
    if(result["subsonic-response"]["status"] == "ok")return true;

  }

  @override
  Future<List<Artists>> fetchArtists() async{
    // TODO: implement fetchArtists
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
            playCount: 0
        ));

        var album = await getAlbumsForArtist(artist['id']);
      }
    }
    return artistsList;
  }

  @override
  getPlaybackByArtists(DateTime inOldDate, DateTime inCurDate) {
    // TODO: implement getPlaybackByArtists
    throw UnimplementedError();
  }

  @override
  getPlaybackByDays(DateTime inOldDate, DateTime inCurDate) {
    // TODO: implement getPlaybackByDays
    throw UnimplementedError();
  }

  @override
  getPlaybackForDay(DateTime day) {
    // TODO: implement getPlaybackForDay
    throw UnimplementedError();
  }

  @override
  returnArtistBio(String artistName) {
    // TODO: implement returnArtistBio
    throw UnimplementedError();
  }

  @override
  Future<List<Album>> returnLatestAlbums() async{
    // TODO: implement returnLatestAlbums
    await openBox();
    List<Album> albums = [];
    var albumsRaw = await subsonicRepo.getLatestAlbums();
    var albumData = albumsRaw["subsonic-response"]["albumList"]["album"];
    for(var album in albumData){
      var value = albumsHelper.returnAlbum(album["artist"], album["name"]);
      if(album != null){
        albums.add(Album(id: album["id"], title: album["name"], artist: album["artist"], year: album["year"] ?? 0, picture: value?.picture));
      }

    }

    return albums;

  }

  @override
  Future<List<Playlists>> returnPlaylists() async{
    // TODO: implement returnPlaylists
    List<Playlists> playlistList = [];
    var playlistsRaw = await subsonicRepo.getPlaylists();
    var playlistData = playlistsRaw["subsonic-response"]["playlists"]["playlist"];
    for(var playlistRaw in playlistData){
      playlistList.add(Playlists(id: playlistRaw["id"], name: playlistRaw["name"], runtime: playlistRaw["duration"].toString()));
    }
    return playlistList;
  }

  @override
  returnSongs() {
    // TODO: implement returnSongs
    throw UnimplementedError();
  }

  @override
  returnSongsFromPlaylist(String playlistId)async {
    // TODO: implement returnSongsFromPlaylist
    var playlistSongs = await subsonicRepo.getPlaylist(playlistId);
    List<ModelSongs> listSongs = [];
    var playlist = playlistSongs["subsonic-response"]["playlist"]["entry"];
    for(var song in playlist){
      var dbSong = songsHelper.returnSongById(song["id"]);
      var mappedSong = await mappers.convertHiveSongToModelSong(dbSong);
      listSongs.add(mappedSong);
    }
    return listSongs;

  }

  @override
  startPlaybackReporting(String songId, String? userId) {
    // TODO: implement startPlaybackReporting

  }

  @override
  stopPlaybackReporting(String songId, String userId) {
    // TODO: implement stopPlaybackReporting
    throw UnimplementedError();
  }

  @override
  tryGetArt(String artist, String album) {
    // TODO: implement tryGetArt
    throw UnimplementedError();
  }

  @override
  updateFavouriteAlbum(String albumId, bool current) async{
    // TODO: implement updateFavouriteAlbum
    if(!current){
      await subsonicRepo.unStarItem(albumId);
    }else{
      await subsonicRepo.starItem(albumId);
    }
  }

  @override
  updateFavouriteArtist(String artistId, bool current)async {
    // TODO: implement updateFavouriteArtist
    if(!current){
      await subsonicRepo.unStarItem(artistId);
    }else{
      await subsonicRepo.starItem(artistId);
    }
  }

  @override
  updateFavouriteStatus(String itemId, bool current) async{
    // TODO: implement updateFavouriteStatus
    if(!current){
      await subsonicRepo.unStarItem(itemId);
    }else{
      await subsonicRepo.starItem(itemId);
    }
  }

  @override
  updatePlaybackProgress(String songId, String? userId, bool paused, int ticks) async{
    // TODO: implement updatePlaybackProgress
    var seconds = ticks / 10000000;
    if(seconds > 40 && songId != lastLoggedId){
      lastLoggedId = songId;
      await subsonicRepo.logPlayback(songId);
    }
  }

  @override
  uploadArt(String albumId, File image) {
    // TODO: implement uploadArt
    throw UnimplementedError();
  }

}