import 'dart:math';

import 'package:hive/hive.dart';
import 'package:jel_music/hive/classes/log.dart';

class LogHelper{

  late Box<Log> logBox;

   Future<void> openBox()async{
     await Hive.openBox<Log>('albums');
     logBox = Hive.box('albums');
  }

  addToLog(Log log){
    logBox.add(log);
  }

  List<Log> listFromLog(){
    return logBox.values.toList();
  }

  clearLog(){
    logBox.clear();
  }
}