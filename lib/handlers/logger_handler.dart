import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/hive/helpers/log_hive_helper.dart';
import 'package:jel_music/models/log.dart';
import 'package:uuid/uuid.dart';


class LogHandler{

  LogHelper logHelper = LogHelper();
  Conversions conversions = Conversions();

  listLogsFromBox(){
    return logHelper.listFromLog();
  }

  addToLog(LogModel log){
    log.id = const Uuid().v4().toString();
    logHelper.openBox();
    logHelper.addToLog(conversions.returnLogFromLogModel(log));
   // logHelper.addToLog(Log(id: log.id!, logType: log.logType!, logMessage: log.logMessage!, logDateTime: log.logDateTime! ));
  }

  listFromLog(){
    logHelper.openBox();
    List<LogModel> logModelList = [];
    var logRaw = logHelper.listFromLog();
    for(var log in logRaw){
      logModelList.add(conversions.returnLogModelFromLog(log));
    }
    return logModelList;
  }



}