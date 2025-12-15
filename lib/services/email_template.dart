// lib/services/email_template.dart
import '../models/meeting.dart';

String buildMeetingSummaryEmail({
  required Meeting meeting,
  required String currentUserName,

  /// Optional overrides coming from the UI (text fields).
  /// If these are null, we fall back to the meeting’s own data
  /// (agreedActions / responsibilities / nextSteps).
  String? point1,
  String? point2,
  String? point3,
}) {
  final m = meeting;

  // 1) Greeting name
  final clientName =
      (m.client1Name.isNotEmpty ? m.client1Name : 'Client').trim();

  // 2) Signature name
  final signatureName = (() {
    if (currentUserName.isNotEmpty) return currentUserName;
    if (m.creatorName.isNotEmpty) return m.creatorName;
    if (m.creatorEmail.isNotEmpty) return m.creatorEmail;
    return '[Name]';
  })();

  // 3) Decide which text to use for each bullet:
  //    - Prefer the override from the UI (point1/2/3)
  //    - Otherwise use the value coming from the meeting model
  //      (which was loaded from n8n / Google Sheet)
  final rawP1 = point1 ?? m.agreedActions;
  final rawP2 = point2 ?? m.responsibilities;
  final rawP3 = point3 ?? m.nextSteps;

  String normalizePoint(String? raw, String fallback) {
    final s = (raw ?? '').trim();
    return s.isEmpty ? fallback : s;
  }

  final p1 = normalizePoint(rawP1, '[Brief point 1]');
  final p2 = normalizePoint(rawP2, '[Brief point 2]');
  final p3 = normalizePoint(rawP3, '[Brief point 3]');

  // 4) Build the email body
  final buffer = StringBuffer();

  buffer.writeln('Dear $clientName,');
  buffer.writeln();
  buffer.writeln(
      'Thank you for taking the time to meet with us today. We truly appreciate the opportunity to connect and discuss how we can work together to achieve your business goals.');
  buffer.writeln();
  buffer.writeln('As a quick recap, our discussion covered:');
  buffer.writeln();
  buffer.writeln('- $p1');
  buffer.writeln('- $p2');
  buffer.writeln('- $p3');
  buffer.writeln();

  // If AI minutes ("final") exist, include them below
  if (m.finalMinutes != null && m.finalMinutes!.trim().isNotEmpty) {
    buffer.writeln(
        'Below is an auto-generated summary of the meeting for your reference:');
    buffer.writeln();
    buffer.writeln(m.finalMinutes!.trim());
    buffer.writeln();
  }

  buffer.writeln(
      'Please feel free to reach out if you have any additional questions or inputs in the meantime.');
  buffer.writeln();
  buffer.writeln(
      'It was a pleasure speaking with you, and we look forward to continuing our collaboration.');
  buffer.writeln();
  buffer.writeln('Thanks,');
  buffer.writeln(signatureName);

  return buffer.toString();
}
