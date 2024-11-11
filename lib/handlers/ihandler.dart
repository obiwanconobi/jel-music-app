
import 'package:jel_music/hive/classes/artists.dart';
import 'package:jel_music/models/album.dart';

abstract class IHandler {
  updateFavouriteStatus(String itemId, bool current);
  Future<List<Album>>  returnLatestAlbums();
  Future<List<Artists>> fetchArtists();
  returnSongs();
  returnSongsFromPlaylist(String playlistId);
  addSongToPlaylist(String songId, String playlistId);
  deleteSongFromPlaylist(String songId, String playlistId);
}
