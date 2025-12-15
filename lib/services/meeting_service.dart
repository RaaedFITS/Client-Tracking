import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/meeting.dart';

class MeetingService {
  static const String myMeetingsUrl =
      'https://fitsit.app.n8n.cloud/webhook/49d2486e-0210-472d-b989-3e8dde90df20';

  static const String allMeetingsUrl =
      'https://fitsit.app.n8n.cloud/webhook/04783f02-367b-4ee4-815c-351f7ee7fb4a';

  static const String meetingDetailUrl =
      'https://fitsit.app.n8n.cloud/webhook/b98ab00e-d952-4820-a3a1-ded0eb6a7a1c';

  // Clean helper
   // Clean helper: works with BOTH full sheet rows and slim n8n rows
  static bool isRowEmpty(Map<String, dynamic> row) {
    const fields = [
      // Old sheet-style keys
      'Client Email',
      'Client Name',
      'Creators Email',
      'Creator',
      'Description',

      // New slim API keys (from n8n Function)
      'clientEmail',
      'clientName',
      'creatorEmail',
      'heading',
    ];

    // If *all* of these are null/empty → treat as empty row
    return fields.every(
      (k) => row[k] == null || row[k].toString().trim().isEmpty,
    );
  }


  // Fetch user meetings
  static Future<List<Meeting>> loadMyMeetings(String userId) async {
    final response = await http.post(
      Uri.parse(myMeetingsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userID': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);
    final rows =
        (data is List) ? data : (data is Map) ? [data] : [];

    return rows
        .whereType<Map<String, dynamic>>()
        .where((row) => !isRowEmpty(row))
        .map(Meeting.fromSheetJson)
        .toList();
  }

  // Fetch ALL meetings (admin only)
  static Future<List<Meeting>> loadAllMeetings(String userId) async {
    final response = await http.post(
      Uri.parse(allMeetingsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userID': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);
    final rows =
        (data is List) ? data : (data is Map) ? [data] : [];

    return rows
        .whereType<Map<String, dynamic>>()
        .where((row) => !isRowEmpty(row))
        .map(Meeting.fromSheetJson)
        .toList();
  }
    static Future<Meeting> loadMeetingByRowId(String rowId) async {
    final response = await http.post(
      Uri.parse(meetingDetailUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rowId': rowId}),
    );

    if (response.statusCode != 200) {
      throw Exception("Server error: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);

    if (data is List && data.isNotEmpty && data.first is Map) {
      return Meeting.fromSheetJson(
          Map<String, dynamic>.from(data.first as Map));
    } else if (data is Map<String, dynamic>) {
      return Meeting.fromSheetJson(data);
    } else {
      throw Exception('Unexpected detail response format');
    }
  }
}
