import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sns_app/controllers/location_controller.dart';
import 'package:sns_app/widgets/satellite_radar.dart';

class SatelliteRadarScreen extends StatelessWidget {
  const SatelliteRadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController lc = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satellite Radar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (lc.isLocationEnabled.value) {
                  return const Center(
                    child: SatelliteRadar(),
                  );
                } else {
                  return const Center(
                    child: Text('Enable location to see the satellite radar.'),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
