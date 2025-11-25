import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/dal/services/chat.firestore.service.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class ChatController extends GetxController {
  // Dependencies
  late final ChatFirestoreService _chatService;

  // Text editing controller
  final TextEditingController messageController = TextEditingController();

  // Observable state
  final messages = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final isChatActive = true.obs;

  // Chat metadata
  final currentUserId = ''.obs;
  final currentUserName = ''.obs;
  final currentUserRole = ''.obs; // 'student' or 'interpreter'
  final otherPartyName = ''.obs;
  final otherPartyRole = ''.obs;

  late final String bookingId;
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSub;

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments passed during navigation
    final args = Get.arguments as Map<String, dynamic>?;
    
    if (args == null) {
      Get.log('ChatController: No arguments provided');
      Get.back();
      AppSnackbar.error(
        title: 'Error',
        message: 'Invalid chat session',
      );
      return;
    }

    // Extract booking data
    bookingId = args['bookingId'] as String;
    currentUserId.value = args['currentUserId'] as String;
    currentUserName.value = args['currentUserName'] as String;
    currentUserRole.value = args['currentUserRole'] as String; // 'student' or 'interpreter'
    otherPartyName.value = args['otherPartyName'] as String;
    otherPartyRole.value = args['otherPartyRole'] as String;

    Get.log('ChatController: Initializing chat for booking: $bookingId');
    Get.log('ChatController: Current user: ${currentUserName.value} (${currentUserRole.value})');
    Get.log('ChatController: Other party: ${otherPartyName.value} (${otherPartyRole.value})');

    // Initialize service
    _chatService = Get.find<ChatFirestoreService>();

    // Check if chat is still active
    _checkChatStatus();

    // Listen to messages
    _listenToMessages();

    // Mark messages as read
    _markMessagesAsRead();
  }

  /// Check if the chat window is still active (within 24 hours)
  Future<void> _checkChatStatus() async {
    try {
      final isActive = await _chatService.isChatActive(bookingId);
      isChatActive.value = isActive;
      
      if (!isActive) {
        Get.log('ChatController: Chat window has expired');
      }
    } catch (e) {
      Get.log('ChatController: Error checking chat status: $e');
    }
  }

  /// Listen to real-time message updates
  void _listenToMessages() {
    Get.log('ChatController: Starting to listen to messages');
    
    _messagesSub = _chatService.getMessagesStream(bookingId).listen(
      (messageList) {
        messages.value = messageList;
        isLoading.value = false;
        Get.log('ChatController: Received ${messageList.length} messages');
        
        // Mark new messages as read
        _markMessagesAsRead();
      },
      onError: (error) {
        Get.log('ChatController: Error listening to messages: $error');
        isLoading.value = false;
        AppSnackbar.error(
          title: 'Error',
          message: 'Failed to load messages',
        );
      },
    );
  }

  /// Mark messages from other party as read
  Future<void> _markMessagesAsRead() async {
    try {
      await _chatService.markMessagesAsRead(
        bookingId: bookingId,
        currentUserId: currentUserId.value,
      );
    } catch (e) {
      Get.log('ChatController: Error marking messages as read: $e');
    }
  }

  /// Send a new message
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    
    if (text.isEmpty) {
      return;
    }

    if (!isChatActive.value) {
      AppSnackbar.warning(
        title: 'Chat Expired',
        message: 'The chat window has expired (24 hours after session)',
      );
      return;
    }

    if (isSending.value) {
      return; // Prevent duplicate sends
    }

    try {
      isSending.value = true;
      
      Get.log('ChatController: Sending message: $text');
      
      await _chatService.sendMessage(
        bookingId: bookingId,
        senderId: currentUserId.value,
        senderName: currentUserName.value,
        senderRole: currentUserRole.value,
        messageText: text,
      );

      // Clear input field
      messageController.clear();
      
      Get.log('ChatController: Message sent successfully');
    } catch (e) {
      Get.log('ChatController: Error sending message: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to send message',
      );
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    _messagesSub?.cancel();
    super.onClose();
  }
}
