import '../../../models/meeting.dart';
import '../../services/meeting_service.dart';

class MeetingController {
  List<Meeting> myMeetings = [];
  List<Meeting> allMeetings = [];

  bool loadingMy = false;
  bool loadingAll = false;

  String? errorMy;
  String? errorAll;

  // Load user meetings
  Future<void> loadMy(String userId) async {
    loadingMy = true;
    errorMy = null;

    try {
      myMeetings = await MeetingService.loadMyMeetings(userId);
    } catch (e) {
      errorMy = e.toString();
    }

    loadingMy = false;
  }

  // Load all meetings (admin only)
  Future<void> loadAll(String userId) async {
    loadingAll = true;
    errorAll = null;

    try {
      allMeetings = await MeetingService.loadAllMeetings(userId);
    } catch (e) {
      errorAll = e.toString();
    }

    loadingAll = false;
  }
}
