import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/webrtc_signaling.service.dart';

class VideoCallController extends GetxController {
  final WebRTCSignalingService _signalingService =
      Get.find<WebRTCSignalingService>();

  final String channelId;
  final bool isInitiator; // true if creating offer, false if answering

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  late final String _userId;

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
    await _signalingService.endCall(channelId);
    Get.back(); // Return to previous screen
  }

  // Expose signaling service observables
  bool get isConnected => _signalingService.isConnected.value;
  bool get isMicOn => _signalingService.isMicOn.value;
  bool get isCameraOn => _signalingService.isCameraOn.value;
  bool get isFrontCamera => _signalingService.isFrontCamera.value;

  @override
  void onClose() {
    _signalingService.endCall(channelId);
    super.onClose();
  }
}
