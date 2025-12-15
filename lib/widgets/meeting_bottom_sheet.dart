import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/meeting.dart';
import 'bottom_sheet_wigets/meeting_location_section.dart';
import 'bottom_sheet_wigets/meeting_clients_section.dart';

class MeetingBottomSheet extends StatefulWidget {
  final String creatorId;
  final String creatorName;
  final String creatorEmail;
  final VoidCallback onSaved;

  const MeetingBottomSheet({
    super.key,
    required this.creatorId,
    required this.creatorName,
    required this.creatorEmail,
    required this.onSaved,
  });

  @override
  State<MeetingBottomSheet> createState() => _MeetingBottomSheetState();
}

class _MeetingBottomSheetState extends State<MeetingBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  bool _useCurrentLocation = false;
  bool _isSaving = false;

  // 🔹 Glide mutateTables endpoint + config
  static const String _glideMutateUrl =
      'https://api.glideapp.io/api/function/mutateTables';
  static const String _glideAppId = 'ONlIbD43DTMGjfi3C8X7';
  static const String _glideTableName = 'Sheet1';

  // ⚠️ Ideally keep this in a secure backend, not in the app.
  static const String _glideApiToken =
      'd34a3bd7-e55d-4fa1-8c99-26b1ef3cfa3e';

  final _headingController = TextEditingController();
  final _client1NameController = TextEditingController();
  final _client1EmailController = TextEditingController();
  final _client2NameController = TextEditingController();
  final _client2EmailController = TextEditingController();
  final _client3NameController = TextEditingController();
  final _client3EmailController = TextEditingController();

  @override
  void dispose() {
    _headingController.dispose();
    _client1NameController.dispose();
    _client1EmailController.dispose();
    _client2NameController.dispose();
    _client2EmailController.dispose();
    _client3NameController.dispose();
    _client3EmailController.dispose();
    super.dispose();
  }

  // ───────────────── LOCATION ─────────────────

  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable GPS.'),
        ),
      );
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied. Cannot get location.'),
          ),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission permanently denied. '
            'Please enable it in system settings.',
          ),
        ),
      );
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ───────────────── SAVE ─────────────────

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (!_useCurrentLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable "Use current location" to proceed.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    double? lat;
    double? lng;

    try {
      final position = await _getCurrentPosition();
      if (position == null) {
        setState(() {
          _isSaving = false;
        });
        return;
      }
      lat = position.latitude;
      lng = position.longitude;
      debugPrint('[_save] Got position: lat=$lat, lng=$lng');
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      return;
    }

    // 👇 This is the meeting START time, and will go into "Meeting Start Time"
    final now = DateTime.now();
    debugPrint('[_save] now (DateTime.now) = $now');

    final meeting = Meeting(
      heading: _headingController.text.trim(),
      useCurrentLocation: _useCurrentLocation,
      client1Name: _client1NameController.text.trim(),
      client1Email: _client1EmailController.text.trim(),
      client2Name: _client2NameController.text.trim().isEmpty
          ? null
          : _client2NameController.text.trim(),
      client2Email: _client2EmailController.text.trim().isEmpty
          ? null
          : _client2EmailController.text.trim(),
      client3Name: _client3NameController.text.trim().isEmpty
          ? null
          : _client3NameController.text.trim(),
      client3Email: _client3EmailController.text.trim().isEmpty
          ? null
          : _client3EmailController.text.trim(),
      createdAt: now, // used as "Meeting Start Time"
      creatorId: widget.creatorId,
      creatorName: widget.creatorName,
      creatorEmail: widget.creatorEmail,
      latitude: lat,
      longitude: lng,
    );

    final columnValues = meeting.toJsonForCreate();

    // Build Glide mutateTables body
    final body = {
      'appID': _glideAppId,
      'mutations': [
        {
          'kind': 'add-row-to-table',
          'tableName': _glideTableName,
          'columnValues': columnValues,
        },
      ],
    };

    final prettyBody = const JsonEncoder.withIndent('  ').convert(body);
    debugPrint('=== GLIDE MUTATE TABLES REQUEST BODY ===');
    debugPrint(prettyBody);

    try {
      final response = await http.post(
        Uri.parse(_glideMutateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_glideApiToken',
        },
        body: jsonEncode(body),
      );

      debugPrint('=== GLIDE MUTATE TABLES RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save meeting (status ${response.statusCode})',
            ),
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Refresh parent + close sheet
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending to Glide: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          bottomPadding + 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Meeting',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Log a client visit with location & contacts.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey[400],
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.grey[400],
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Location section
                MeetingLocationSection(
                  useCurrentLocation: _useCurrentLocation,
                  isSaving: _isSaving,
                  onChanged: (val) {
                    setState(() => _useCurrentLocation = val);
                  },
                ),

                const SizedBox(height: 18),

                // Heading + clients section
                MeetingClientsSection(
                  headingController: _headingController,
                  client1NameController: _client1NameController,
                  client1EmailController: _client1EmailController,
                  client2NameController: _client2NameController,
                  client2EmailController: _client2EmailController,
                  client3NameController: _client3NameController,
                  client3EmailController: _client3EmailController,
                  isSaving: _isSaving,
                  onDynamicFieldsChanged: () => setState(() {}),
                ),

                const SizedBox(height: 12),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'Save meeting',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
