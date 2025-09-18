import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderName;
  final String avatarUrl;
  final bool isFromMe;
  final DateTime timestamp;
  final String timeLabel;
  final bool showDateSeparator;
  final String dateLabel;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    required this.avatarUrl,
    required this.isFromMe,
    required this.timestamp,
    required this.timeLabel,
    this.showDateSeparator = false,
    this.dateLabel = '',
  });
}

class InterpreterChatController extends GetxController {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxString studentName = 'Arlene McCoy'.obs;
  final RxString studentAvatar =
      'https://images.unsplash.com/photo-1494790108755-2616b612b47c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'
          .obs;
  final RxString interpreterAvatar =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'
          .obs;
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadChatHistory();

    // Get session data from arguments if available
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['studentName'] != null) {
        studentName.value = args['studentName'];
      }
      if (args['studentAvatar'] != null) {
        studentAvatar.value = args['studentAvatar'];
      }
    }
  }

  void loadChatHistory() {
    // Mock chat history matching the design from the image
    messages.value = [
      ChatMessage(
        id: '1',
        text: 'Hello, thank you for helping today!',
        senderName: studentName.value,
        avatarUrl: studentAvatar.value,
        isFromMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        timeLabel: 'Friday 2:20pm',
      ),
      ChatMessage(
        id: '2',
        text: 'Sure thing, I\'ll have a look today.',
        senderName: 'You',
        avatarUrl: interpreterAvatar.value,
        isFromMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        timeLabel: 'Friday 2:20pm',
      ),
      ChatMessage(
        id: '3',
        text: 'You\'re welcome! Let me know if you have any questions',
        senderName: studentName.value,
        avatarUrl: studentAvatar.value,
        isFromMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        timeLabel: 'Friday 2:20pm',
      ),
      ChatMessage(
        id: '4',
        text: 'What was the sign for "environment" again?',
        senderName: 'You',
        avatarUrl: interpreterAvatar.value,
        isFromMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        timeLabel: 'Friday 2:20pm',
      ),
      ChatMessage(
        id: '5',
        text: '',
        senderName: '',
        avatarUrl: '',
        isFromMe: false,
        timestamp: DateTime.now(),
        timeLabel: 'Today',
        showDateSeparator: true,
        dateLabel: 'Today',
      ),
    ];
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      senderName: 'You',
      avatarUrl: interpreterAvatar.value,
      isFromMe: true,
      timestamp: DateTime.now(),
      timeLabel: _formatTime(DateTime.now()),
    );

    messages.add(newMessage);
    messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate student response after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _simulateStudentResponse();
    });
  }

  void _simulateStudentResponse() {
    final responses = [
      'Thanks for the clarification!',
      'That makes sense now.',
      'I appreciate your help.',
      'Could you show me that sign again?',
      'Perfect, I understand now.',
    ];

    final randomResponse =
        responses[DateTime.now().millisecond % responses.length];

    final responseMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: randomResponse,
      senderName: studentName.value,
      avatarUrl: studentAvatar.value,
      isFromMe: false,
      timestamp: DateTime.now(),
      timeLabel: _formatTime(DateTime.now()),
    );

    messages.add(responseMessage);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'pm' : 'am';
      return '$hour:$minute$period';
    } else {
      // For other days, you might want to show the day
      return 'Friday 2:20pm'; // Keeping consistent with mock data
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
