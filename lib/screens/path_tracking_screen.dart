import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/location_controller.dart';
import 'package:sns_app/widgets/path_painter.dart';

class PathTrackingScreen extends StatelessWidget {
  final LocationController locationController = Get.find();

  PathTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Path Tracking'),
      ),
      body: Column(
        children: [
          Obx(() => SwitchListTile(
            title: Text('Track Path'),
            value: locationController.isLocationEnabled.value,
            onChanged: (bool value) {
              locationController.toggleLocationServices();
            },
          )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => CustomPaint(
                    painter: PathPainter(path: locationController.path.toList()),
                    child: Container(),
                  )),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          locationController.addCurrentPositionToPath();
        },
        child: Icon(Icons.add_location),
      ),
    );
  }
}
