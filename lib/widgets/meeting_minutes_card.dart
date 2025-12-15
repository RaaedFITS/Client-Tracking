import 'package:flutter/material.dart';
import '../../models/meeting.dart';

class MeetingMinutesCard extends StatelessWidget {
  final Meeting meeting;

  final bool isRecording;
  final String? recordingPath;
  final VoidCallback onToggleRecording;

  final VoidCallback onSendEmail;

  /// Controllers for the 3 points (live in MeetingDetailPage)
  final TextEditingController point1Controller;
  final TextEditingController point2Controller;
  final TextEditingController point3Controller;

  /// Called when user taps "Update points"
  final Future<void> Function()? onUpdatePoints;

  const MeetingMinutesCard({
    super.key,
    required this.meeting,
    required this.isRecording,
    required this.recordingPath,
    required this.onToggleRecording,
    required this.onSendEmail,
    required this.point1Controller,
    required this.point2Controller,
    required this.point3Controller,
    this.onUpdatePoints,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              'Meeting Minutes',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // AI-generated minutes
            if (meeting.finalMinutes != null &&
                meeting.finalMinutes!.trim().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: SelectableText(
                  meeting.finalMinutes!,
                  style: textTheme.bodyMedium,
                ),
              )
            else
              Text(
                'No AI minutes available yet.\n'
                'Record audio to generate minutes, or wait for AI processing.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),

            // Key points section (on page, not in popup)
            Text(
              'Key Discussion Points',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: point1Controller,
              decoration: const InputDecoration(
                labelText: 'Agreed Actions',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: point2Controller,
              decoration: const InputDecoration(
                labelText: 'Responsibilities',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: point3Controller,
              decoration: const InputDecoration(
                labelText: 'Next Steps',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                // ✅ slimmer, nicer button
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 13),
                ),
                onPressed:
                    onUpdatePoints == null ? null : () => onUpdatePoints!(),
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Update points'),
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),

            // Recording + send email row
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: isRecording ? Colors.red : Colors.blue,
                  ),
                  onPressed: onToggleRecording,
                  tooltip: isRecording ? 'Stop recording' : 'Start recording',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recordingPath != null
                        ? 'Saved at: $recordingPath'
                        : 'Tap the mic to record and upload for AI minutes.',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  onPressed: onSendEmail,
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text('Email'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
