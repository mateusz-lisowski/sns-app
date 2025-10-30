import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/location_controller.dart';
import '../controllers/power_controller.dart';

class DevicePowerAndLocationScreen extends StatelessWidget {
  const DevicePowerAndLocationScreen({super.key});

  @override
  Widget build(context) {
    // Find the existing controllers.
    final LocationController lc = Get.find();
    final PowerController pc = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Power & Location"),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text("Location"),
                      trailing: Obx(
                        () => Switch(
                          value: lc.isLocationEnabled.value,
                          onChanged: (bool value) {
                            lc.toggleLocationServices();
                          },
                        ),
                      ),
                    ),
                    Obx(() {
                      if (lc.isLocationEnabled.value) {
                        if (lc.currentPosition.value != null) {
                          final position = lc.currentPosition.value!;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Latitude",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      position.latitude.toStringAsFixed(4),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Longitude",
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      position.longitude.toStringAsFixed(4),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.power),
                      title: Text("Power Consumption"),
                    ),
                    Obx(() => Text(
                          "${pc.averageCurrentFlow.value.toStringAsFixed(2)} µA",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.greenAccent,
                              ),
                        )),
                    const Text("Average Current Flow"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
