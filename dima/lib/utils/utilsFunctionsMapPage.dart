import 'dart:async';
import 'package:dima/utils/login_prompt.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/articleCard/articleDialogCard.dart';
import 'package:dima/widgets/communityCard/communityDialogCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/article.dart';
import '../model/community.dart';
import '../model/globals.dart';
import '../widgets/articleCard/articleMapCard.dart';
import '../widgets/communityCard/communityMapCard.dart';

Widget zoomminusfunction(CameraPosition _lastKnownPosition, double zoomVal,
    Completer<GoogleMapController> _controller) {
  return Align(
    alignment: Alignment.topLeft,
    child: IconButton(
      icon: Icon(FontAwesomeIcons.magnifyingGlassMinus, color: Palette.red, size: 20.sp,),
      onPressed: () {
        _minus(_lastKnownPosition, zoomVal, _controller);
      },
    ),
  );
}

Widget zoomplusfunction(CameraPosition _lastKnownPosition, double zoomVal,
    Completer<GoogleMapController> _controller) {
  return Align(
    alignment: Alignment.topRight,
    child: IconButton(
      icon: Icon(FontAwesomeIcons.magnifyingGlassPlus, color: Palette.red, size: 20.sp),
      onPressed: () {
        _plus(_lastKnownPosition, zoomVal, _controller);
      },
    ),
  );
}

Future<void> _minus(CameraPosition _lastKnownPosition, double zoomVal,
    Completer<GoogleMapController> _controller) async {
  final GoogleMapController controller = await _controller.future;
  double newZoom = _lastKnownPosition.zoom - 1; // Decrease zoom level
  controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    target: _lastKnownPosition.target,
    zoom: newZoom,
  )));
}

Future<void> _plus(CameraPosition _lastKnownPosition, double zoomVal,
    Completer<GoogleMapController> _controller) async {
  final GoogleMapController controller = await _controller.future;
  double newZoom = _lastKnownPosition.zoom + 1; // Increase zoom level
  controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    target: _lastKnownPosition.target,
    zoom: newZoom,
  )));
}

Widget showArticlesCard(Completer<GoogleMapController> _controller,
    List<Article> visibleArticles, double height, double width) {
  return Align(
    alignment: Alignment.bottomLeft,
    child: Container(
      color: Palette.offWhite,
      width: width,
      child: visibleArticles.isEmpty
          ? Center(
              child: Text("Nessun articolo in questa parte della mappa",
                  style: TextStyle(fontSize: 16.sp, color: Colors.black)))
          : Swiper(
              itemCount: visibleArticles.length,
              itemBuilder: (context, index) {
                Article article = visibleArticles[index];
                return SizedBox(
                    width: width * 0.4,
                    child: ArticleCardMap(
                      article: article,
                      onLocationTap: (lat, long) =>
                          _gotoLocation(lat, long, _controller),
                      width: width,
                      height: height,
                    ));
              },
              itemWidth: width * 0.6,
              itemHeight: height,
              viewportFraction: 0.5,
              scale: 0.7,
              loop: false,
            ),
    ),
  );
}

Widget showCommunityCard(Completer<GoogleMapController> _controller,
    List<Community> visibleCommunties, double height, double width) {
  return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        color: Palette.offWhite,
        width: width,
        child: Globals.instance.userUid != null
            ? (visibleCommunties.isEmpty
                ? Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "Nessuna community in questa parte della mappa",
                      style: TextStyle(fontSize: 16.sp, color: Colors.black),
                    ),
                  )
                : Swiper(
                    itemCount: visibleCommunties.length,
                    itemBuilder: (context, index) {
                      Community community = visibleCommunties[index];
                      return SizedBox(
                        width: width * 0.4,
                        child: CommunityMapCard(
                          onLocationTap: (lat, long) =>
                              _gotoLocation(lat, long, _controller),
                          community: community,
                          height: MediaQuery.of(context).size.height * 0.5,
                        ),
                      );
                    },
                    itemWidth: width * 0.6,
                    itemHeight: height,
                    viewportFraction: 0.5,
                    scale: 0.7,
                    loop: false,
                  ))
            : Center(child: loginPrompt(height: height, width: width)),
      ));
}

void _gotoLocation(
    double lat, double long, Completer<GoogleMapController> _controller) {
  _controller.future.then((GoogleMapController mapController) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  });
}

void showCustomDialogWithArticleInfo(Article article, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor:
            Colors.transparent, // Makes the dialog itself transparent
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height * 0.8, // Maximum height
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ArticleCardDialog(
                    article: article,
                    height: MediaQuery.of(context).size.height *
                        0.7, // Fixed syntax
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20.sp,
              top: 3.sp,
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Palette.black, // Icon color
                  size: 30.sp, // Icon size
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showCustomDialogWithCommunityInfo(
    Community community, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor:
            Colors.transparent, // Makes the dialog itself transparent

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height * 0.8, // Maximum height
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommunityDialogCard(
                    community: community,
                    height: MediaQuery.of(context).size.height * 0.5,
                    // Fixed syntax
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20.sp,
              top: 30.sp,
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Palette.black, // Icon color
                  size: 30.sp, // Icon size
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
