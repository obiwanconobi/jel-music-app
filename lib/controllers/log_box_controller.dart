import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/models/log.dart';

class LogBoxController{
  List<LogModel> fullLogModels = [];
  List<LogModel> logModels = [];
  var logger = GetIt.instance<LogHandler>();

  Future<List<LogModel>> onInit()async{
    await logger.openBox();
    logModels = logger.listFromLog();
    fullLogModels = logModels.toList();
    return logModels;
  }

  Future<List<LogModel>> filterByErrors()async{
    logModels.clear();
    var flogModels = fullLogModels.where((element) => element.logType == "Error").toList();
    return flogModels.toList();
  }

  Future<List<LogModel>> filterByLogs()async{
    logModels.clear();
    return fullLogModels.where((element) => element.logType == "Log").toList();
  }

  clearLogs()async{
    await logger.clearLogs();
  }
}