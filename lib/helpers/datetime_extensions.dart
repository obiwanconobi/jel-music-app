import 'package:intl/intl.dart';
extension DateFormatter on DateTime{

  String formatDate(){
    var formatter = DateFormat('MM-dd-yyyy');
    return formatter.format(this);
  }
}

extension IntExtension on int{

  String intWithSuff() {

    if(this >= 11 && this <=13)return "${this}th";

    switch (this.toString().substring(this
        .toString()
        .length - 1)) {
      case "1":
        return "${this}st";
      case "2":
        return "${this}nd";
      case "3":
        return "${this}rd";
      default:
        return "${this}th";
    }
  }

  String intToStringDay(){
    switch(this){
      case 0:
        return "M";
      case 1:
        return "T";
      case 2:
        return "W";
      case 3:
        return "T";
      case 4:
        return "F";
      case 5:
        return "S";
      case 6:
        return "S";
      default:
        return "X";

    }
  }
}