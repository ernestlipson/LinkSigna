import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart';
import 'controllers/video_call.controller.dart';
import 'services/webrtc_signaling.service.dart';

class WebRTCCallScreen extends StatelessWidget {
  final String channelId;
  final bool isInitiator;

  const WebRTCCallScreen({
    super.key,
    required this.channelId,
    this.isInitiator = true, // Default to initiator
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(
      VideoCallController(
        channelId: channelId,
        isInitiator: isInitiator,
      ),
      tag: channelId,
    );

    final signalingService = Get.find<WebRTCSignalingService>();

    return WillPopScope(
      onWillPop: () async {
        await controller.endCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingState();
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _buildErrorState(controller.errorMessage.value);
            }

            return Stack(
              children: [
                // Remote video (full screen)
                Positioned.fill(
                  child: webrtc.RTCVideoView(
                    signalingService.remoteRenderer,
                    objectFit:
                        webrtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: false,
                  ),
                ),

                // Local video (small overlay)
                Positioned(
                  top: 40,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: webrtc.RTCVideoView(
                        signalingService.localRenderer,
                        objectFit: webrtc
                            .RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        mirror: signalingService.isFrontCamera.value,
                      ),
                    ),
                  ),
                ),

                // Connection status indicator
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: signalingService.isConnected.value
                          ? Colors.green.withOpacity(0.8)
                          : Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          signalingService.isConnected.value
                              ? 'Connected'
                              : 'Connecting...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Controls at bottom
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildControls(controller, signalingService),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Connecting to call...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'Call Failed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B197D),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(
      VideoCallController controller, WebRTCSignalingService service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Toggle microphone
          _buildControlButton(
            icon: service.isMicOn.value ? Icons.mic : Icons.mic_off,
            onPressed: controller.toggleMic,
            backgroundColor: service.isMicOn.value
                ? Colors.white.withOpacity(0.2)
                : Colors.red.withOpacity(0.8),
          ),

          // Switch camera
          _buildControlButton(
            icon: Icons.cameraswitch,
            onPressed: controller.switchCamera,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),

          // End call
          _buildControlButton(
            icon: Icons.call_end,
            onPressed: controller.endCall,
            backgroundColor: Colors.red,
            size: 64,
            iconSize: 32,
          ),

          // Toggle camera
          _buildControlButton(
            icon:
                service.isCameraOn.value ? Icons.videocam : Icons.videocam_off,
            onPressed: controller.toggleCamera,
            backgroundColor: service.isCameraOn.value
                ? Colors.white.withOpacity(0.2)
                : Colors.red.withOpacity(0.8),
          ),

          // Toggle speaker (placeholder for future implementation)
          _buildControlButton(
            icon: Icons.volume_up,
            onPressed: () {
              // Future: toggle speaker
            },
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double size = 56,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
