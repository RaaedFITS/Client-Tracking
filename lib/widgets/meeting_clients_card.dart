import 'package:flutter/material.dart';
import '../models/meeting.dart';

class MeetingClientsCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingClientsCard({
    super.key,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = meeting;

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
              'Clients',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Primary client
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.client1Name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (m.client1Email.isNotEmpty)
                        Text(
                          m.client1Email,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Optional 2nd client
            if (m.client2Name != null || m.client2Email != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (m.client2Name != null &&
                            m.client2Name!.isNotEmpty)
                          Text(
                            m.client2Name!,
                            style: textTheme.bodyLarge,
                          ),
                        if (m.client2Email != null &&
                            m.client2Email!.isNotEmpty)
                          Text(
                            m.client2Email!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Optional 3rd client
            if (m.client3Name != null || m.client3Email != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (m.client3Name != null &&
                            m.client3Name!.isNotEmpty)
                          Text(
                            m.client3Name!,
                            style: textTheme.bodyLarge,
                          ),
                        if (m.client3Email != null &&
                            m.client3Email!.isNotEmpty)
                          Text(
                            m.client3Email!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
