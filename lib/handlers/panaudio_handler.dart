import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/models/album.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/repos/panaudio_repo.dart';

class PanaudioHandler implements IHandler{

  Mappers mapper = Mappers();

  late PanaudioRepo repo = GetIt.instance<PanaudioRepo>();
  PanaudioHandler(){
   // repo =
  }



  @override
  Future<List<Album>> returnLatestAlbums()async{
    var latestAlbums =  await repo.getLatestAlbums();
    return await mapper.mapAlbumFromRawPA(latestAlbums);
  }

  @override
  updateFavouriteStatus(String itemId, bool current)async{
    await repo.updateFavouriteStatus(itemId, current);
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
  addSongToPlaylist(String songId, String playlistId) {
    // TODO: implement addSongToPlaylist
    throw UnimplementedError();
  }

  @override
  deleteSongFromPlaylist(String songId, String playlistId) {
    // TODO: implement deleteSongFromPlaylist
    throw UnimplementedError();
  }

  @override
  returnSongsFromPlaylist(String playlistId) {
    // TODO: implement returnSongsFromPlaylist
    throw UnimplementedError();
  }

  @override
  Future<List<Playlists>> returnPlaylists() {
    // TODO: implement returnPlaylists
    throw UnimplementedError();
  }

  @override
  returnArtistBio(String artistName) {
    // TODO: implement returnArtistBio
    throw UnimplementedError();
  }

  @override
  startPlaybackReporting(String songId, String userId) {
    // TODO: implement startPlaybackReporting
    throw UnimplementedError();
  }

  @override
  stopPlaybackReporting(String songId, String userId) {
    // TODO: implement stopPlaybackReporting
    throw UnimplementedError();
  }

  @override
  updatePlaybackProgress(String songId, String userId, bool paused, int ticks) {
    // TODO: implement updatePlaybackProgress
    throw UnimplementedError();
  }
}