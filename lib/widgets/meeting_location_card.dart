import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../models/meeting.dart';

class MeetingLocationCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingLocationCard({
    super.key,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = meeting;

    final latlng.LatLng? location =
        (m.latitude != null && m.longitude != null)
            ? latlng.LatLng(m.latitude!, m.longitude!)
            : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (location != null)
              SizedBox(
                height: 250,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: location,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.flutter_application_1',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: location,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              const Text('No location available for this meeting'),
          ],
        ),
      ),
    );
  }
}
