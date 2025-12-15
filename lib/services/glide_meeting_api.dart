import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GlideMeetingApi {
  static const String _baseUrl =
      'https://api.glideapp.io/api/function/mutateTables';

  // These are from your curl
  static const String _token = 'd34a3bd7-e55d-4fa1-8c99-26b1ef3cfa3e';
  static const String _appId = 'ONlIbD43DTMGjfi3C8X7';
  static const String _tableName = 'Sheet1';

  /// Delete a meeting row in Glide using the Row ID from Glide ("🔒 Row ID")
  static Future<void> deleteMeetingByRowId(String rowId) async {
    final payload = {
      "appID": _appId,
      "mutations": [
        {
          "kind": "delete-row",      // 🔹 must be exactly this
          "tableName": _tableName,   // 🔹 "Sheet1"
          "rowID": rowId,            // 🔹 note: rowID (capital D)
        }
      ]
    };

    if (kDebugMode) {
      debugPrint('🧨 Glide delete payload: ${jsonEncode(payload)}');
    }

    final resp = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(payload),
    );

    if (kDebugMode) {
      debugPrint(
        '🧨 Glide delete response: '
        'status=${resp.statusCode}, body=${resp.body}',
      );
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        'Glide delete failed (${resp.statusCode}): ${resp.body}',
      );
    }
  }
}
