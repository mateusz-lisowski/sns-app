
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/tasks_controller.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TasksController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (previous task cards)
              _buildTaskCard(
                taskNumber: 0,
                title: 'Angle Calculation',
                content: Column(
                  children: [
                    const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              _buildTaskCard(
                taskNumber: 1,
                title: 'Parallel Line',
                content: Column(
                  children: [
                    const SizedBox(height: 8),
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
                    Obx(() => Text(
                          controller.parallelLineDirection.value ?? '--',
                          style: const TextStyle(fontSize: 24, color: Colors.green),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTaskCard(
                taskNumber: 2,
                title: 'Points on a Line',
                content: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildPointInput(
                      pointNumber: 1,
                      latController: controller.task2Lat1Controller,
                      lonController: controller.task2Lon1Controller,
                      onSetCurrentLocation:
                          controller.setTask2Point1FromCurrentLocation,
                    ),
                    const SizedBox(height: 16),
                    _buildPointInput(
                      pointNumber: 2,
                      latController: controller.task2Lat2Controller,
                      lonController: controller.task2Lon2Controller,
                      onSetCurrentLocation:
                          controller.setTask2Point2FromCurrentLocation,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Distance from Line (meters)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          controller.distanceFromLine.value?.toStringAsFixed(2) ??
                              '--.-',
                          style: const TextStyle(fontSize: 24, color: Colors.green),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTaskCard(
                taskNumber: 3,
                title: 'Distance from Line (Azimuth/Distance)',
                content: Column(
                  children: [
                    const SizedBox(height: 8),
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
                const SizedBox(height: 16),
              _buildTaskCard(
                taskNumber: 4,
                title: 'Track Following & Distance',
                content: Column(
                  children: [
                    const SizedBox(height: 8),
                    Obx(() => ElevatedButton(
                          onPressed: controller.toggleTask4Tracking,
                          child: Text(controller.task4IsTracking.value
                              ? 'Stop Tracking'
                              : 'Start Current Route'),
                        )),
                    const SizedBox(height: 24),
                    const Text(
                      'Current Route Distance (meters)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          controller.task4CurrentDistance.value.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 24, color: Colors.green),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTaskCard(
                taskNumber: 5,
                title: 'Map Matching',
                content: Column(
                  children: [
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: controller.loadGpxFile,
                      child: const Text('Load GPX File'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Nearest Point on Track',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final nearestPoint = controller.task5NearestPoint.value;
                      if (nearestPoint == null) {
                        return const Text('--', style: TextStyle(fontSize: 16));
                      }
                      return Text(
                        'Lat: ${nearestPoint.lat?.toStringAsFixed(6)}, Lon: ${nearestPoint.lon?.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      );
                    }),
                    const SizedBox(height: 16),
                    const Text(
                      'Distance to Nearest Point (meters)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          controller.task5DistanceToNearestPoint.value
                              .toStringAsFixed(2),
                          style: const TextStyle(fontSize: 24, color: Colors.green),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required int taskNumber,
    required String title,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task $taskNumber: $title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            content,
          ],
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
