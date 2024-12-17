import 'dart:async';
import 'package:dima/model/community.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../managers/controllers/community_controller.dart';
import '../managers/provider/article_provider.dart';
import '../model/article.dart';
import '../model/globals.dart';
import '../utils/utilsFunctionsMapPage.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final CommunityController communityController = CommunityController();
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> articlesMarkers = {};
  final Set<Marker> communitiesMarkers = {};
  LatLngBounds? currentBounds; // This will hold the current map bounds
  List<Article> articles = [];
  List<Community> communities = [];
  List<Article> visibleArticles = [];
  List<Community> visibleCommunities = [];
  double zoomVal = 20.0;
  CameraPosition _lastKnownPosition =
      const CameraPosition(target: LatLng(45.4642, 9.1900), zoom: 12);
  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(45.4642, 9.1900), zoom: 12);
  String selectedCategory = "Tutto"; // Default category
  String _selectedPanel = "Articoli"; // Default panel

  final List<String> categories = [
    'Tutto',
    'Attualità',
    'Sport',
    'Intrattenimento',
    'Salute',
    'Economia',
    'Tecnologia'
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition().then((_) {
      _loadAllMarkers(); // Ensure markers are loaded after position is determined.
    }).catchError((error) {
      _loadAllMarkers(); // Still load markers even if location fetching fails
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Mappa',
            style: TextStyle(
              color: Palette.red,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Palette.offWhite,
        foregroundColor: Palette.black,
        actions: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(selectedCategory,
                  style: const TextStyle(color: Palette.black)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: _onCategorySelected,
                itemBuilder: (BuildContext context) {
                  return categories.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(children: [
            Container(
              color: Palette.offWhite,
              height:
                  constraints.maxHeight * 0.55, // Adjusted for the button row
              child: Stack(
                children: <Widget>[
                  _buildGoogleMap(context),
                  zoomminusfunction(_lastKnownPosition, zoomVal, _controller),
                  zoomplusfunction(_lastKnownPosition, zoomVal, _controller),
                ],
              ),
            ),
            Container(
              color: Palette.offWhite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPanel = "Articoli";
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        margin: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 5.sp),
                        decoration: _selectedPanel == "Articoli"
                            ? BoxDecoration(
                                color: Palette.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              )
                            : const BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              color: _selectedPanel == "Articoli"
                                  ? Palette.red
                                  : Palette.grey,
                            ),
                            SizedBox(width: 8.sp),
                            Text(
                              "Articoli",
                              style: TextStyle(
                                color: _selectedPanel == "Articoli"
                                    ? Palette.red
                                    : Palette.grey,
                                fontSize: 16.sp,
                                fontWeight: _selectedPanel == "Articoli"
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPanel = "Community";
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        margin: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 5.sp),
                        decoration: _selectedPanel == "Community"
                            ? BoxDecoration(
                                color: Palette.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              )
                            : const BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.groups,
                              color: _selectedPanel == "Community"
                                  ? Palette.red
                                  : Palette.grey,
                            ),
                            SizedBox(width: 8.sp),
                            Text(
                              "Community",
                              style: TextStyle(
                                color: _selectedPanel == "Community"
                                    ? Palette.red
                                    : Palette.grey,
                                fontSize: 16.sp,
                                fontWeight: _selectedPanel == "Community"
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _selectedPanel == "Articoli"
                ? Expanded(
                    child: showArticlesCard(_controller, visibleArticles,
                        constraints.maxHeight * 0.4, constraints.maxWidth * 1),
                  )
                : SizedBox.shrink(), // Hide if "Communities" is selected
            _selectedPanel == "Community"
                ? Expanded(
                    child: showCommunityCard(_controller, visibleCommunities,
                        constraints.maxHeight * 0.4, constraints.maxWidth * 1),
                  )
                : SizedBox.shrink(), // Hide if "Community" is selected
          ]);
        },
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        myLocationEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition, // Milan coordinates
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onCameraIdle: () {
          _updateMapBounds(); // Call your method to update bounds here
        },
        onCameraMove: (CameraPosition position) {
          _lastKnownPosition = position;
        },
        markers:
            _selectedPanel == "Articoli" ? articlesMarkers : communitiesMarkers,
        compassEnabled: false, // Disable the compass to remove the pointer
      ),
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('I servizi di localizzazione sono disabilitati');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('I permessi di localizzazione sono stati negati');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'I permessi di localizzazione sono stati permanentemente negati, non possiamo accedere alla posizione');
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.0,
      );
    });

    final GoogleMapController mapController = await _controller.future;
    mapController
        .animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
  }

  bool _isWithinBounds(LatLng point, LatLngBounds bounds) {
    bool withinLat = (point.latitude <= bounds.northeast.latitude) &&
        (point.latitude >= bounds.southwest.latitude);
    bool withinLng = (point.longitude <= bounds.northeast.longitude) &&
        (point.longitude >= bounds.southwest.longitude);
    return withinLat && withinLng;
  }

  bool _isArticleInSelectedCategory(Article article, String selectedCategory) {
    if (article.category == selectedCategory.toLowerCase() ||
        selectedCategory == "Tutto") {
      return true;
    } else {
      return false;
    }
  }

  bool _isCommunityInSelectedCategory(
      Community community, String selectedCategory) {
    if (community.categories.contains(selectedCategory) ||
        selectedCategory == "Tutto") {
      return true;
    } else {
      return false;
    }
  }

  void _updateVisibleArticles() {
    if (currentBounds == null) return;
    List<Article> filteredArticles = articles.where((article) {
      // Adjust this line to use the new method
      return _isWithinBounds(article.coordinates, currentBounds!) &&
          _isArticleInSelectedCategory(article, selectedCategory);
    }).toList();

    setState(() {
      visibleArticles = filteredArticles;
    });
  }

  void _updateVisibleCommunities() {
    if (currentBounds == null) return;
    List<Community> filteredCommunities = communities.where((community) {
      var coords = community.coordinates.split(',');
      LatLng coordinates = LatLng(double.parse(coords[0]), double.parse(coords[1]));
      // Adjust this line to use the new method
      return _isWithinBounds(coordinates, currentBounds!) &&
          _isCommunityInSelectedCategory(community, selectedCategory);
    }).toList();

    setState(() {
      visibleCommunities = filteredCommunities;
    });
  }

  Future<void> _updateMapBounds() async {
    final GoogleMapController controller = await _controller.future;
    LatLngBounds bounds =
        await controller.getVisibleRegion(); // This calls the built-in method.
    setState(() {
      currentBounds = bounds; // Updates your currentBounds with the new bounds.
    });
    _updateVisibleArticles();
    _updateVisibleCommunities(); // Call this to filter articles based on the new bounds.
  }

  Future<void> _loadAllMarkers() async {
    List<List<Article>> groupedArticles = await ArticleRepository().retrieveAllArticles();
    articles = groupedArticles.expand((group) => group).toList();
    Set<Marker> articleMarkers = articles.asMap().entries.map((entry) {
      int idx = entry.key;
      Article article = entry.value;
      return Marker(
        markerId: MarkerId('article_$idx'),
        position: article.coordinates,
        onTap: () => showCustomDialogWithArticleInfo(article, context),
        // Hide the default InfoWindow by not setting it or by providing an empty title
        infoWindow: const InfoWindow(title: ''),
      );
    }).toSet();

    Set<Marker> communityMarkers = {};

    if (Globals.instance.userUid != null) {
      // Fetch communities asynchronously
      communities = await communityController.fetchCommunities();

      // Map communities to markers
      communityMarkers = communities.asMap().entries.map((entry) {
        int idx = entry.key;
        Community community = entry.value;
        var coords = community.coordinates.split(',');
        LatLng coordinates = LatLng(double.parse(coords[0]), double.parse(coords[1]));
        return Marker(
          markerId: MarkerId('community_$idx'),
          position: coordinates,
          onTap: () => showCustomDialogWithCommunityInfo(community, context),
          // Hide the default InfoWindow by not setting it or by providing an empty title
          infoWindow: const InfoWindow(title: ''),
        );
      }).toSet();
    }

// Update the state with the new markers
    setState(() {
      articlesMarkers.addAll(articleMarkers);
      communitiesMarkers.addAll(communityMarkers);
    });
  }

  void _onCategorySelected(String value) {
    setState(() {
      selectedCategory = value;
      _filterMarkersAndArticles();
      _filterMarkersAndCommunity();
    });
  }

  void _filterMarkersAndArticles() {
    // Filter articles based on the selected category.
    List<Article> filteredArticles = articles
        .where((article) =>
            _isArticleInSelectedCategory(article, selectedCategory))
        .toList();
    // Create a new set of markers for the filtered articles.
    Set<Marker> filteredArticleMarkers =
        filteredArticles.asMap().entries.map((entry) {
      int idx = entry.key;
      Article article = entry.value;
      return Marker(
        markerId: MarkerId('article_$idx'),
        position: article.coordinates,
        onTap: () => showCustomDialogWithArticleInfo(article, context),
        // Hide the default InfoWindow by not setting it or by providing an empty title
        //infoWindow: InfoWindow(title: ''),
      );
    }).toSet();

    setState(() {
      articlesMarkers.clear();
      articlesMarkers.addAll(filteredArticleMarkers);
      visibleArticles = filteredArticles;
      _updateMapBounds();
    });
  }

  void _filterMarkersAndCommunity() {
    // Filter articles based on the selected category.
    List<Community> filteredCommunities = communities
        .where((article) =>
            _isCommunityInSelectedCategory(article, selectedCategory))
        .toList();
    // Create a new set of markers for the filtered articles.
    Set<Marker> filteredCommunityMarkers =
        filteredCommunities.asMap().entries.map((entry) {
      int idx = entry.key;
      Community community = entry.value;
      var coords = community.coordinates.split(',');
      LatLng coordinates = LatLng(double.parse(coords[0]), double.parse(coords[1]));
      return Marker(
        markerId: MarkerId('article_$idx'),
        position: coordinates,
        onTap: () => showCustomDialogWithCommunityInfo(community, context),
        // Hide the default InfoWindow by not setting it or by providing an empty title
        //infoWindow: InfoWindow(title: ''),
      );
    }).toSet();

    setState(() {
      communitiesMarkers.clear();
      communitiesMarkers.addAll(filteredCommunityMarkers);
      visibleCommunities = filteredCommunities;
      _updateMapBounds();
    });
  }
}
