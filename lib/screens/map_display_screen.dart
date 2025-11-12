
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:sns_app/controllers/tasks_controller.dart';

class MapDisplayScreen extends StatefulWidget {
  const MapDisplayScreen({super.key});

  @override
  State<MapDisplayScreen> createState() => _MapDisplayScreenState();
}

class _MapDisplayScreenState extends State<MapDisplayScreen> {
  final TasksController controller = Get.find();
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Listen for changes to the track points
    controller.task5TrackPoints.listen((points) {
      if (points.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(
            points.map((p) => LatLng(p.lat!, p.lon!)).toList());
        mapController.fitCamera(CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPX Map Matching'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: controller.loadGpxFile,
                  child: const Text('Load GPX File'),
                ),
                ElevatedButton(
                  onPressed: controller.matchGpxToRoads,
                  child: const Text('Match to Roads'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              LatLng initialCenter;
              if (controller.task5TrackPoints.isNotEmpty) {
                initialCenter = LatLng(controller.task5TrackPoints.first.lat!,
                    controller.task5TrackPoints.first.lon!);
              } else if (controller.currentPosition.value != null) {
                initialCenter = LatLng(controller.currentPosition.value!.latitude,
                    controller.currentPosition.value!.longitude);
              } else {
                initialCenter =
                    const LatLng(51.509865, -0.118092); // Fallback to London
              }

              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: controller.task5TrackPoints
                            .map((p) => LatLng(p.lat!, p.lon!))
                            .toList(),
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                      Polyline(
                        points: controller.task5MatchedTrackPoints
                            .map((p) => LatLng(p.lat!, p.lon!))
                            .toList(),
                        strokeWidth: 4.0,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
