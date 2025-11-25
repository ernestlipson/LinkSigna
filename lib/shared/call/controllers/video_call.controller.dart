import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/webrtc_signaling.service.dart';
import '../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../components/rating_bottom_sheet.component.dart';
import '../../../student/presentation/shared/controllers/student_user.controller.dart';

class VideoCallController extends GetxController {
  final WebRTCSignalingService _signalingService =
      Get.find<WebRTCSignalingService>();

  final String channelId;
  final bool isInitiator; // true if creating offer, false if answering

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  late final String _userId;
  Worker? _callEndedWorker;

  VideoCallController({
    required this.channelId,
    required this.isInitiator,
  });

  @override
  void onInit() {
    super.onInit();
    _userId = FirebaseAuth.instance.currentUser?.uid ??
        'anonymous_${DateTime.now().millisecondsSinceEpoch}';
    _initializeCall();
    _listenForUnexpectedDisconnection();
  }

  /// Listen for unexpected call disconnections
  void _listenForUnexpectedDisconnection() {
    _callEndedWorker = ever(_signalingService.callEnded, (bool ended) {
      if (ended) {
        Get.log('Detected unexpected call end');
        Get.snackbar(
          'Call Ended',
          'The call was disconnected',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        // Auto-cleanup and mark booking as completed (no rating sheet for unexpected disconnections)
        _handleCallEnd();
        Get.back(); // Navigate back to previous screen
      }
    });
  }

  Future<void> _initializeCall() async {
    try {
      isLoading.value = true;

      // Initialize local stream (camera + microphone)
      await _signalingService.initLocalStream();

      // Create offer or answer based on role
      if (isInitiator) {
        await _signalingService.createOffer(channelId, _userId);
      } else {
        await _signalingService.createAnswer(channelId, _userId);
      }

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to initialize call: $e';
      isLoading.value = false;
      Get.log('Error initializing call: $e');
    }
  }

  void toggleMic() {
    _signalingService.toggleMic();
  }

  void toggleCamera() {
    _signalingService.toggleCamera();
  }

  Future<void> switchCamera() async {
    await _signalingService.switchCamera();
  }

  Future<void> endCall() async {
    await _handleCallEnd();

    // Store booking info before navigation
    final shouldShowRating = _shouldShowRating();
    String? bookingId;
    if (shouldShowRating && channelId.startsWith('booking_')) {
      bookingId = channelId.replaceFirst('booking_', '');
    }

    Get.back(); // Return to previous screen

    // Show rating after navigation completes
    if (shouldShowRating && bookingId != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _getBookingDetailsAndShowRating(bookingId!);
      });
    }
  }

  /// Handle call end logic (cleanup and mark booking complete)
  Future<void> _handleCallEnd() async {
    await _signalingService.endCall(channelId);

    // Mark booking as completed if channelId follows pattern 'booking_<id>'
    if (channelId.startsWith('booking_')) {
      final bookingId = channelId.replaceFirst('booking_', '');
      try {
        final bookingService = Get.find<BookingFirestoreService>();
        await bookingService.completeBooking(bookingId);
        Get.log('Booking $bookingId marked as completed');
      } catch (e) {
        Get.log('Error completing booking: $e');
      }
    }
  }

  /// Check if should show rating (student only)
  bool _shouldShowRating() {
    // Check if user is actually a student (has valid student profile)
    if (Get.isRegistered<StudentUserController>()) {
      final studentController = Get.find<StudentUserController>();
      final hasStudentProfile = studentController.current.value != null;
      Get.log('Rating check - hasStudentProfile: $hasStudentProfile');

      if (!hasStudentProfile) {
        Get.log(
            'Not showing rating - no student profile (user is interpreter)');
        return false;
      }
    } else {
      Get.log('Not showing rating - StudentUserController not registered');
      return false;
    }

    if (!channelId.startsWith('booking_')) {
      Get.log('Not showing rating - not a booking-based call');
      return false; // Not a booking-based call
    }

    Get.log('Showing rating - confirmed student in booking call');
    return true;
  }

  /// Fetch booking details and show rating sheet
  Future<void> _getBookingDetailsAndShowRating(String bookingId) async {
    try {
      final bookingService = Get.find<BookingFirestoreService>();

      // Fetch booking document
      final bookingDoc = await bookingService.getBookingById(bookingId);

      if (bookingDoc == null) {
        Get.log('Booking not found: $bookingId');
        return;
      }

      final interpreterId = bookingDoc['interpreterId'] as String?;
      final interpreterName = bookingDoc['interpreterName'] as String?;

      if (interpreterId == null || interpreterName == null) {
        Get.log('Missing interpreter info in booking');
        return;
      }

      // Show rating sheet
      RatingBottomSheet.show(
        bookingId: bookingId,
        interpreterId: interpreterId,
        interpreterName: interpreterName,
      );
    } catch (e) {
      Get.log('Error showing rating sheet: $e');
    }
  }

  // Expose signaling service observables
  bool get isConnected => _signalingService.isConnected.value;
  bool get isMicOn => _signalingService.isMicOn.value;
  bool get isCameraOn => _signalingService.isCameraOn.value;
  bool get isFrontCamera => _signalingService.isFrontCamera.value;

  @override
  void onClose() {
    _callEndedWorker?.dispose();
    _signalingService.endCall(channelId);
    super.onClose();
  }
}
