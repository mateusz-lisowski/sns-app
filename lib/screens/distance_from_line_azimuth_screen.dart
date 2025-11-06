
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/tasks_controller.dart';

class DistanceFromLineAzimuthScreen extends StatelessWidget {
  const DistanceFromLineAzimuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TasksController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance from Line (Azimuth/Distance)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPointInput(
                pointNumber: 1,
                latController: controller.task3Lat1Controller,
                lonController: controller.task3Lon1Controller,
                onSetCurrentLocation:
                    controller.setTask3Point1FromCurrentLocation,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.task3AzimuthController,
                decoration: const InputDecoration(
                  labelText: 'Azimuth (degrees)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.task3DistanceController,
                decoration: const InputDecoration(
                  labelText: 'Distance (meters)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const Text(
                'Distance from Line (meters)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    controller.task3DistanceFromLine.value
                            ?.toStringAsFixed(2) ??
                        '--.-',
                    style: const TextStyle(fontSize: 24, color: Colors.green),
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
