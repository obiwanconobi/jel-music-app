import 'package:flutter/material.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:sizer/sizer.dart';

class SharedWidgets{

  Conversions conversions = Conversions();

  artistImage404(String artistName, BuildContext context, TextStyle style, double height){
    return SizedBox(
      height: height,
      width:height,
      child: Container(
        height: 27.w,
        width: 27.w,
        color: conversions.returnColor(),
        child: Center(
          child: Text(conversions.returnName(artistName ?? ""), style: style),
        ),
      ),
    );
  }


  albumImage404(String artistName, String albumName, BuildContext context){
    return Container(
      color: conversions.returnColor(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(albumName, style: Theme.of(context).textTheme.bodyMedium),
            Text(artistName, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

}