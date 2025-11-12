
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/tasks_controller.dart';

class ParallelLineScreen extends StatelessWidget {
  const ParallelLineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TasksController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parallel Line'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPointInput(
                pointNumber: 1,
                latController: controller.task1Lat1Controller,
                lonController: controller.task1Lon1Controller,
                onSetCurrentLocation:
                    controller.setTask1Point1FromCurrentLocation,
              ),
              const SizedBox(height: 16),
              _buildPointInput(
                pointNumber: 2,
                latController: controller.task1Lat2Controller,
                lonController: controller.task1Lon2Controller,
                onSetCurrentLocation:
                    controller.setTask1Point2FromCurrentLocation,
              ),
              const SizedBox(height: 16),
              _buildPointInput(
                pointNumber: 3,
                latController: controller.task1Lat3Controller,
                lonController: controller.task1Lon3Controller,
                onSetCurrentLocation:
                    controller.setTask1Point3FromCurrentLocation,
              ),
              const SizedBox(height: 24),
              const Text(
                'Direction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() => Compass(
                    direction: controller.parallelLineDirection.value,
                    lat1Controller: controller.task1Lat1Controller,
                    lon1Controller: controller.task1Lon1Controller,
                    lat2Controller: controller.task1Lat2Controller,
                    lon2Controller: controller.task1Lon2Controller,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointInput({
    required int pointNumber,
    required TextEditingController latController,
    required TextEditingController lonController,
    required VoidCallback onSetCurrentLocation,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Point $pointNumber',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: latController,
          decoration: const InputDecoration(
            labelText: 'Latitude',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: lonController,
          decoration: const InputDecoration(
            labelText: 'Longitude',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onSetCurrentLocation,
          child: const Text('Set Current Location'),
        ),
      ],
    );
  }
}

class Compass extends StatefulWidget {
  final String? direction;
  final TextEditingController lat1Controller;
  final TextEditingController lon1Controller;
  final TextEditingController lat2Controller;
  final TextEditingController lon2Controller;

  const Compass(
      {Key? key,
      this.direction,
      required this.lat1Controller,
      required this.lon1Controller,
      required this.lat2Controller,
      required this.lon2Controller})
      : super(key: key);

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = lat1 * pi / 180;
    final lat2Rad = lat2 * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    final bearingRad = atan2(y, x);
    return (bearingRad * 180 / pi + 360) % 360; // convert to degrees
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? deviceHeading = snapshot.data?.heading;

        if (deviceHeading == null) {
          return const Center(
            child: Icon(
              Icons.arrow_upward,
              size: 100,
              color: Colors.grey,
            ),
          );
        }

        final lat1 = double.tryParse(widget.lat1Controller.text);
        final lon1 = double.tryParse(widget.lon1Controller.text);
        final lat2 = double.tryParse(widget.lat2Controller.text);
        final lon2 = double.tryParse(widget.lon2Controller.text);

        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
          return const Center(
            child: Text('Please enter coordinates for Point 1 and Point 2.'),
          );
        }

        var targetBearing = _calculateBearing(lat1, lon1, lat2, lon2);

        if (widget.direction == 'Left') {
          targetBearing = _calculateBearing(lat2, lon2, lat1, lon1);
        }

        final relativeAngle = targetBearing - deviceHeading;

        return Transform.rotate(
          angle: (relativeAngle * pi) / 180,
          child: const Icon(
            Icons.arrow_upward,
            size: 100,
            color: Colors.green,
          ),
        );
      },
    );
  }
}
