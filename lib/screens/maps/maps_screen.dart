import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng currentLocation = LatLng(25.1193, 55.3773);
const LatLng destinationLocation = LatLng(25.0193, 55.3773);

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  final Map<String, Marker> _marker = {};
  final Set<Polyline> _polyline = {};
  List<LatLng> polylinecoord = [];
  late PolylinePoints polylinePoints;

  static const String _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  // late Directions info;
  @override
  void initState() {
    polylinePoints = PolylinePoints(apiKey: _googleMapsApiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: currentLocation,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          mapController = controller;
          addMarker('your current location', currentLocation);
          addMarker('destination', destinationLocation);
          setPolyLines();
        },
        markers: _marker.values.toSet(),
        polylines: _polyline,
      ),
    );
  }

  Future<Uint8List> getBytesFromAsset(String path) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: pixelRatio.round() * 30,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  addMarker(String markerId, LatLng location) async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/shop.png');
    var marker = Marker(
      markerId: MarkerId(markerId),
      position: location,
      infoWindow: InfoWindow(
        title: markerId.toString(),
        snippet: 'start your journey',
      ),
      icon: BitmapDescriptor.bytes(markerIcon),
    );

    _marker[markerId] = marker;
    setState(() {});
  }

  void setPolyLines() async {
    if (_googleMapsApiKey.isEmpty) {
      // Avoid hitting the network with an invalid key.
      return;
    }

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          currentLocation.latitude,
          currentLocation.longitude,
        ),
        destination: PointLatLng(
          destinationLocation.latitude,
          destinationLocation.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );
    if (result.status == 'OK') {
      for (var element in result.points) {
        polylinecoord.add(LatLng(element.latitude, element.longitude));
      }

      setState(() {
        _polyline.add(
          Polyline(
            polylineId: const PolylineId('polyLine'),
            width: 10,
            color: Colors.red,
            points: polylinecoord,
          ),
        );
      });
    }
  }
}
