import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/meeting.dart';

class MeetingHeaderCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingHeaderCard({
    super.key,
    required this.meeting,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Not available';
    final local = dt.toLocal();
    return DateFormat('EEE, dd MMM yyyy • hh:mm a').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final m = meeting;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final createdAtText = _formatDate(m.createdAt);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + optional status chip ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    m.heading.isNotEmpty ? m.heading : 'Untitled meeting',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (m.status != null && m.status!.trim().isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.4),
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      m.status!,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.blue[200],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Date row ────────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    createdAtText,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Creator row ────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    m.creatorName.isNotEmpty
                        ? '${m.creatorName} • ${m.creatorEmail}'
                        : m.creatorEmail,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),

            // ── Description, if present ────────────────────────────────
            if (m.description != null && m.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Description',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m.description!.trim(),
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[200],
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
