import 'dart:async';

import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dima/utils/utilsFunctionsMapPage.dart';

class LocationSelection extends StatefulWidget {
  final void Function(LatLng) onLocationSelected;
  final LatLng initialLocation;

  LocationSelection({
    required this.onLocationSelected,
    required this.initialLocation,
  });

  @override
  _LocationSelectionState createState() => _LocationSelectionState();
}

class _LocationSelectionState extends State<LocationSelection> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _selectedLocation;
  LatLngBounds? currentBounds; // This will hold the current map bounds
  double zoomVal = 20.0;

  @override
  Widget build(BuildContext context) {
    CameraPosition _initialCameraPosition =
        CameraPosition(target: widget.initialLocation, zoom: 12);
    CameraPosition _lastKnownCameraPosition =
        CameraPosition(target: widget.initialLocation, zoom: 12);

    return Scaffold(
      backgroundColor: Palette.offWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  color: Palette.offWhite,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      initialCameraPosition: _initialCameraPosition,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onCameraIdle: () {
                        _updateMapBounds();
                      },
                      onCameraMove: (CameraPosition position) {
                        _lastKnownCameraPosition = position;
                      },
                      onTap: (position) {
                        setState(() {
                          _selectedLocation = position;
                        });
                      },
                      compassEnabled:
                          false, // Disable the compass to remove the pointer
                      markers: _selectedLocation != null
                          ? {
                              Marker(
                                markerId: MarkerId('selected-location'),
                                position: _selectedLocation!,
                              )
                            }
                          : {},
                    ),
                    zoomminusfunction(
                        _lastKnownCameraPosition, zoomVal, _controller),
                    zoomplusfunction(
                        _lastKnownCameraPosition, zoomVal, _controller),
                    Positioned(
                      bottom: constraints.maxHeight*0.02,
                      left: constraints.maxHeight*0.01,
                      right: constraints.maxHeight*0.125,
                      child:
                      ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedLocation != null
                            ? Palette.red
                            : Palette.grey,
                        foregroundColor: Palette.offWhite,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24.sp, vertical: 16.sp),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (_selectedLocation != null) {
                          widget.onLocationSelected(_selectedLocation!);
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.check,
                        color: Palette.offWhite,
                      ),
                      label: Text(
                        'Conferma Posizione',
                        style: TextStyle(
                          color: Palette.offWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateMapBounds() async {
    final GoogleMapController controller = await _controller.future;
    LatLngBounds bounds =
        await controller.getVisibleRegion(); // This calls the built-in method.
    setState(() {
      currentBounds = bounds; // Updates your currentBounds with the new bounds.
    }); // Call this to filter articles based on the new bounds.
  }
}
