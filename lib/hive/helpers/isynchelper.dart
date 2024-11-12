
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';

abstract class ISyncHelper {
  openBox();
  clearSongs();
  runSync(bool check);
}
