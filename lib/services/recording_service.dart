// lib/services/recording_service.dart
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as rec;

class RecordingService {
  RecordingService._internal();
  static final RecordingService instance = RecordingService._internal();

  rec.AudioRecorder? _audioRecorder; // 👈 nullable, created lazily

  bool _isRecording = false;
  String? _currentPath;

  bool get isRecording => _isRecording;
  String? get currentPath => _currentPath;

  /// 🔗 Your n8n webhook for recordings (PRODUCTION URL)
  static const String _uploadWebhookUrl =
      'https://fitsit.app.n8n.cloud/webhook/f96e3717-2a4f-4a7a-ae7d-5040bfa7d95d';

  // -------------------- INTERNAL --------------------

  Future<rec.AudioRecorder> _ensureRecorder() async {
    // If already created, reuse
    if (_audioRecorder != null) {
      return _audioRecorder!;
    }

    // Create a new instance
    _audioRecorder = rec.AudioRecorder();
    return _audioRecorder!;
  }

  // -------------------- RECORDING (M4A / AAC) --------------------

  Future<String> startRecording() async {
    final recorder = await _ensureRecorder();

    final hasPerm = await recorder.hasPermission();
    if (!hasPerm) {
      throw Exception('Microphone permission denied');
    }

    final dir = await getTemporaryDirectory();
    final filePath = p.join(
      dir.path,
      // 👇 local file path (M4A so it lines up with GCS / Glide)
      'meeting_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );

    // Record as AAC LC in an M4A (audio-only MP4) container
    final config = rec.RecordConfig(
      encoder: rec.AudioEncoder.aacLc, // 👈 AAC LC
      sampleRate: 44100,
      numChannels: 1,
      // bitrate: you can set this if you want, e.g. 64000
    );

    await recorder.start(config, path: filePath);

    _isRecording = true;
    _currentPath = filePath;

    print('🎙 START recording (M4A/AAC) → $filePath');

    return filePath;
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return _currentPath;
    }

    if (_audioRecorder == null) {
      // Recorder was somehow disposed; just return what we last had
      _isRecording = false;
      return _currentPath;
    }

    final path = await _audioRecorder!.stop();
    _isRecording = false;

    if (path != null) {
      _currentPath = path;
    }

    print('⏹ STOP recording → $_currentPath');

    return _currentPath;
  }

  /// You almost never need to call this from a screen.
  /// Only call this once when the app is truly shutting down.
  Future<void> dispose() async {
    if (_audioRecorder != null) {
      await _audioRecorder!.dispose();
      _audioRecorder = null; // 👈 so _ensureRecorder() can recreate later
    }
  }

  // -------------------- UPLOAD TO N8N --------------------

  /// Upload the recorded file to n8n.
  ///
  /// n8n will receive:
  ///   fields: userId, rowId
  ///   file:   "file" (binary)
  Future<void> uploadRecordingToN8n({
    required String filePath,
    required String userId,
    required String rowId,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Recording file not found at $filePath');
    }

    print('=== UPLOAD RECORDING REQUEST ===');
    print('URL: $_uploadWebhookUrl');
    print('File: $filePath');
    print('userId: $userId | rowId: $rowId');

    final uri = Uri.parse(_uploadWebhookUrl);
    final request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = userId
      ..fields['rowId'] = rowId
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          // 👇 match what we set in the GCS node
          contentType: MediaType('audio', 'x-m4a'),
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print('=== UPLOAD RECORDING RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Body: $body');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Upload failed: ${response.statusCode} | body: $body',
      );
    }
  }

}
