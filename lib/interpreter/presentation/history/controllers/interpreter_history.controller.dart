import 'package:get/get.dart';
import '../../../../domain/sessions/session_history.model.dart';

class InterpreterHistoryController extends GetxController {
  final RxList<SessionHistoryModel> historyList = <SessionHistoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSessionHistory();
  }

  Future<void> loadSessionHistory() async {
    isLoading.value = true;
    try {
      // TODO: Replace with actual Firebase call
      // For now, using mock data that matches the UI
      await Future.delayed(const Duration(milliseconds: 500));

      historyList.value = _getMockHistoryData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load session history');
    } finally {
      isLoading.value = false;
    }
  }

  List<SessionHistoryModel> get filteredHistory {
    if (searchQuery.value.isEmpty) {
      return historyList;
    }
    return historyList.where((session) {
      return session.studentName
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          session.className
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  void viewFeedback(SessionHistoryModel session) {
    if (session.hasFeedback && session.feedbackText != null) {
    } else {
      Get.snackbar('Info', 'No feedback available for this session');
    }
  }

  // Mock data that matches the UI design
  List<SessionHistoryModel> _getMockHistoryData() {
    return [
      SessionHistoryModel(
        id: '1',
        studentId: 'student1',
        studentName: 'Micheal Chen',
        interpreterId: 'current_interpreter',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionHistoryStatus.completed,
        rating: 4,
        hasFeedback: true,
        feedbackText: 'Great interpretation session. Very clear communication.',
      ),
      SessionHistoryModel(
        id: '2',
        studentId: 'student1',
        studentName: 'Micheal Chen',
        interpreterId: 'current_interpreter',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionHistoryStatus.completed,
        rating: 4,
        hasFeedback: true,
        feedbackText: 'Excellent work! Very professional and helpful.',
      ),
      SessionHistoryModel(
        id: '3',
        studentId: 'student1',
        studentName: 'Micheal Chen',
        interpreterId: 'current_interpreter',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionHistoryStatus.cancelled,
        rating: 0,
        hasFeedback: false,
      ),
      SessionHistoryModel(
        id: '4',
        studentId: 'student1',
        studentName: 'Micheal Chen',
        interpreterId: 'current_interpreter',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionHistoryStatus.cancelled,
        rating: 0,
        hasFeedback: false,
      ),
      SessionHistoryModel(
        id: '5',
        studentId: 'student1',
        studentName: 'Micheal Chen',
        interpreterId: 'current_interpreter',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionHistoryStatus.completed,
        rating: 4,
        hasFeedback: true,
        feedbackText: 'Another excellent session with great communication.',
      ),
      SessionHistoryModel(
        id: '6',
        studentId: 'student1',
        studentName: 'Micheal Chen',
        interpreterId: 'current_interpreter',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionHistoryStatus.completed,
        rating: 4,
        hasFeedback: true,
        feedbackText: 'Professional and clear interpretation throughout.',
      ),
    ];
  }
}
