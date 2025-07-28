import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../infrastructure/services/video_call.service.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String sessionName;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.sessionName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late VideoCallService _videoCallService;
  List<int> _remoteUids = [];
  bool _localUserJoined = false;

  @override
  void initState() {
    super.initState();
    _videoCallService = Get.find<VideoCallService>();
    _joinChannel();
  }

  Future<void> _joinChannel() async {
    // Wait for engine to be ready
    while (!_videoCallService.isEngineInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await _videoCallService.joinChannel(widget.channelName);
  }

  @override
  void dispose() {
    _videoCallService.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video
            _buildRemoteVideo(),

            // Local video (picture-in-picture)
            _buildLocalVideo(),

            // Call controls
            _buildCallControls(),

            // Call info
            _buildCallInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    return Obx(() {
      final engine = _videoCallService.engineObservable.value;
      final remoteUid = _videoCallService.remoteUid;

      if (engine == null) {
        return Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Initializing video call...',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: engine,
            canvas: VideoCanvas(uid: remoteUid),
            connection: const RtcConnection(channelId: ''),
          ),
        );
      } else {
        return Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white54,
                ),
                SizedBox(height: 16),
                Text(
                  'Waiting for participant...',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  Widget _buildLocalVideo() {
    return Positioned(
      top: 60,
      right: 20,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Obx(() {
            final engine = _videoCallService.engineObservable.value;
            if (engine != null) {
              return AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              );
            } else {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildCallControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute button
            _buildControlButton(
              icon: Icons.mic_off,
              isActive: _videoCallService.isMuted.value,
              onPressed: () => _videoCallService.toggleMute(),
            ),

            // Camera switch button
            _buildControlButton(
              icon: Icons.switch_camera,
              onPressed: () => _videoCallService.switchCamera(),
            ),

            // End call button
            _buildControlButton(
              icon: Icons.call_end,
              backgroundColor: Colors.red,
              onPressed: () {
                _videoCallService.leaveChannel();
                Get.back();
              },
            ),

            // Video toggle button
            _buildControlButton(
              icon: Icons.videocam_off,
              isActive: !_videoCallService.isVideoEnabled.value,
              onPressed: () => _videoCallService.toggleVideo(),
            ),

            // Speaker button
            _buildControlButton(
              icon: Icons.volume_up,
              isActive: _videoCallService.isSpeakerOn.value,
              onPressed: () => _videoCallService.toggleSpeaker(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    Color? backgroundColor,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isActive ? Colors.white : Colors.white24),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: backgroundColor != null
              ? Colors.white
              : (isActive ? Colors.black : Colors.white),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCallInfo() {
    return Positioned(
      top: 60,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.sessionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
