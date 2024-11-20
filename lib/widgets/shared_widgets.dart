import 'package:flutter/material.dart';
import 'package:jel_music/helpers/conversions.dart';

class SharedWidgets{

  Conversions conversions = Conversions();

  artistImage404(String artistName, BuildContext context){
    return Container(
      color: conversions.returnColor(),
      child: Center(
        child: Text(conversions.returnName(artistName ?? ""), style: Theme.of(context).textTheme.displayLarge),
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