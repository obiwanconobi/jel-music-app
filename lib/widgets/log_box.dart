import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/log_box_controller.dart';
import 'package:jel_music/handlers/logger_handler.dart';
import 'package:jel_music/models/log.dart';

class LogBox extends StatefulWidget {
  const LogBox({super.key});

  @override
  State<LogBox> createState() => _LogBoxState();
}
enum SortOptions { all, error, log, }

class _LogBoxState extends State<LogBox> {

  var controller = GetIt.instance<LogBoxController>();
  SortOptions sortOptionsView = SortOptions.all;
  final _scrollController = ScrollController();
  late Future<List<LogModel>> logModelFuture;
  List<LogModel> logModelList = [];
  List<LogModel> filteredModelList = [];

  _sortList(SortOptions sort)async{
    if(sort == SortOptions.all){
      //filteredModelList.clear();
      logModelFuture = controller.onInit();
      //controller.orderByNameAsc();
    }else if(sort == SortOptions.error){
      setState(() {
        logModelFuture = controller.filterByErrors();
      });

     // filteredModelList = logModelList.where((element) => element.logType == "Error").toList();
     // controller.orderByNameDesc();
    }else{
      setState(() {
        logModelFuture =  controller.filterByLogs();
      });


     // controller.shuffleOrder();
    }
  }

  clearLog(){
    controller.clearLogs();
  }

  Color getColour(LogModel model){
    if(model.logType == "Error"){
      return Colors.red;
    }else if (model.logType == "Log"){
      return Colors.amber;
    }

    return Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    logModelFuture = controller.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
    Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Log Box', style: Theme.of(context).textTheme.bodyLarge), actions: [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 15, 0), child: IconButton(icon:  const Icon(Icons.delete_forever),
          onPressed: () { clearLog(); }))],),
      body: Column(children: [
        SegmentedButton<SortOptions>(
          style: ButtonStyle(backgroundColor:  WidgetStateProperty.all<Color>(Theme.of(context).canvasColor)),
          segments: <ButtonSegment<SortOptions>>[
            ButtonSegment<SortOptions>(
                value: SortOptions.all,
                label: Text('All', style: Theme.of(context).textTheme.bodySmall,),
                icon: const Icon(Icons.warning)),
            ButtonSegment<SortOptions>(
                value: SortOptions.error,
                label: Text('Errors', style: Theme.of(context).textTheme.bodyMedium),
                icon: const Icon(Icons.error)),
            ButtonSegment<SortOptions>(
                value: SortOptions.log,
                label: Text('Logs', style: Theme.of(context).textTheme.bodySmall,),
                icon: const Icon(Icons.note)),
          ],
          selected: <SortOptions>{sortOptionsView},
          onSelectionChanged: (Set<SortOptions> newSelection) {
            setState(() {
              // By default there is only a single segment that can be
              // selected at one time, so its value is always the first
              // item in the selected set.
              sortOptionsView = newSelection.first;
              _sortList(sortOptionsView);
            });
          },
        ),
        Expanded(
          child: FutureBuilder<List<LogModel>>(
              future: logModelFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    //child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No artists available.'),
                  );
                } else {
                  // Data is available, build the list
                  logModelList = snapshot.data!;
                  filteredModelList = logModelList.toList();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredModelList.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(8, 3, 8, 0),
                                child: Container(
                                    color: getColour(filteredModelList[index]),
                                    child: Text(filteredModelList[index].logMessage ?? "")),
                              );
                            }
                        )
                      ],),
                  );
                }
              }),
        )
        ]),
    ));}}