import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jel_music/controllers/artist_controller.dart';
import 'package:jel_music/helpers/conversions.dart';
import 'package:jel_music/widgets/shared_widgets.dart';
import 'package:jel_music/models/artist.dart';
import 'package:jel_music/widgets/album_page.dart';
import 'package:jel_music/widgets/newcontrols.dart';
import 'package:sizer/sizer.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({super.key});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  var controller = GetIt.instance<ArtistController>();
  double mainAxis = 250.h;
  final TextEditingController _searchController = TextEditingController();
  SharedWidgets sharedWidgets = SharedWidgets();
  Conversions conversions = Conversions();
  late Future<List<Artists>> artistsFuture;
  List<Artists> _filteredArtists = []; // List to hold filtered albums
  List<Artists> artistsList  = [];
  @override
  void initState() {
    super.initState();
    controller.favourite = false;
    artistsFuture = controller.onInit();
    _searchController.addListener(_filterArtists);
  }

  void _filterArtists() {
      String searchText = _searchController.text.toLowerCase();
      setState(() {
        if (searchText.isNotEmpty) {
          _filteredArtists = _filteredArtists
              .where((album) => album.name!.toLowerCase().contains(searchText))
              .toList();
        } else {
          _filteredArtists = List.from(artistsList); // Reset to original list if search text is empty
        }
      });


  }




  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Artists", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall!.color)),
      ), 
      body: Padding(
          padding: EdgeInsets.only(
            top: 0.h,
            left: 16.sp,
            bottom: 10.sp,
            right: 16.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: TextField(controller: _searchController, decoration: InputDecoration.collapsed(hintText: 'Search',hintStyle:  TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 18)), style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color, fontSize: 18)),
              ),
              Expanded(
                child:
                FutureBuilder<List<Artists>>(
                  future: artistsFuture,
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
                      
                      if(_searchController.text.isNotEmpty){
                      
                      }else{
                        _filteredArtists = snapshot.data!;
                      }
                      return ListView.builder(
                   // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, mainAxisExtent: 26.h),
                    itemCount: _filteredArtists.length,
                   // shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap:() => {
                         Navigator.push(context,
                              MaterialPageRoute(builder: (context) => AlbumPage(artistId: _filteredArtists[index].name!)),
                      )},     
                        child: SizedBox(
                          height: 15.h,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.sp),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 3.sp),
                                  child: SizedBox(
                                    height: 27.w,
                                    width: 27.w,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: _filteredArtists[index].picture ?? "",
                                        memCacheHeight: 150,
                                        memCacheWidth: 150,
                                        placeholder: (context, url) => sharedWidgets.artistImage404(_filteredArtists[index].name ?? "", context),
                                        errorWidget: (context, url, error) => sharedWidgets.artistImage404(_filteredArtists[index].name ?? "", context),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                              child: Text(
                                                _filteredArtists[index].name!,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: Theme.of(context).textTheme.bodySmall!.color,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Segoe UI",
                                                  
                                                ),
                                                overflow: TextOverflow.ellipsis, // Set overflow property
                                                maxLines: 2, 
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            ),
                        ),
                      );
                    },
                  );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomSheet: const Controls(),
      ),
    );
  }
}   

