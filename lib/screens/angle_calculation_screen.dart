
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/tasks_controller.dart';

class AngleCalculationScreen extends StatelessWidget {
  const AngleCalculationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TasksController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Angle Calculation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPointInput(
                pointNumber: 1,
                latController: controller.lat1Controller,
                lonController: controller.lon1Controller,
                onSetCurrentLocation: controller.setPoint1FromCurrentLocation,
              ),
              const SizedBox(height: 16),
              _buildPointInput(
                pointNumber: 2,
                latController: controller.lat2Controller,
                lonController: controller.lon2Controller,
                onSetCurrentLocation: controller.setPoint2FromCurrentLocation,
              ),
              const SizedBox(height: 24),
              const Text(
                'Current Angle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    controller.angle.value?.toStringAsFixed(2) ?? '--.-',
                    style: TextStyle(
                      fontSize: 24,
                      color: controller.isWithinThreshold.value
                          ? Colors.green
                          : Colors.white,
                    ),
                  )),
              const SizedBox(height: 16),
              const Text(
                'Current Azimuth',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    controller.azimuth.value?.toStringAsFixed(2) ?? '--.-',
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
