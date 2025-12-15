import 'package:flutter/material.dart';

class MeetingLocationSection extends StatelessWidget {
  final bool useCurrentLocation;
  final bool isSaving;
  final ValueChanged<bool> onChanged;

  const MeetingLocationSection({
    super.key,
    required this.useCurrentLocation,
    required this.isSaving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showWarning = !useCurrentLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  useCurrentLocation ? Icons.my_location : Icons.location_off,
                  size: 18,
                  color: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use current location',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      'Required to tag the visit on the map.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: useCurrentLocation,
                activeColor: const Color(0xFF38BDF8),
                onChanged: isSaving ? null : onChanged,
              ),
            ],
          ),
        ),
        if (showWarning) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Turn this on to capture the meeting’s GPS location.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red[200],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
