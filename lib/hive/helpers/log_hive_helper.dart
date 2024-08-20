
import 'package:hive/hive.dart';
import 'package:jel_music/hive/classes/log.dart';

class LogHelper{

  late Box<Log> logBox;

   Future<void> openBox()async{
     await Hive.openBox<Log>('logs');
     logBox = Hive.box('logs');
  }

  addToLog(Log log){
    logBox.add(log);
  }

  List<Log> listFromLog(){
     // albumsBox.values.where((element) => element.artist == artist);
    var list = logBox.values.toList();
    list.sort((a,b) => -a.logDateTime.compareTo(b.logDateTime));
    return list;
  }

  clearLog(){
    logBox.clear();
  }
}