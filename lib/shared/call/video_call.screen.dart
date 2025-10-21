import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../config/agora_config.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelId;
  final bool showDebugInfo;

  const VideoCallScreen(
      {super.key, required this.channelId, this.showDebugInfo = false});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final RtcEngine _engine;
  bool _isJoined = false;
  bool _isMicEnabled = true;
  bool _isVideoEnabled = true;
  int? _remoteUid;
  DateTime? _joinedAt;

  @override
  void initState() {
    super.initState();
    _initializeAndJoin();
  }

  Future<void> _initializeAndJoin() async {
    await _ensurePermissions();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: AgoraConfig.appId));

    await _engine.enableVideo();

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _isJoined = true;
          _joinedAt = DateTime.now();
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        setState(() {
          if (_remoteUid == remoteUid) _remoteUid = null;
        });
      },
      onError: (ErrorCodeType code, String message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agora error: ${code.name}')), // keep generic
        );
      },
    ));

    await _engine.joinChannel(
      token: AgoraConfig.tempToken,
      channelId: widget.channelId,
      uid: AgoraConfig.uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> _ensurePermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  void _toggleMic() async {
    setState(() => _isMicEnabled = !_isMicEnabled);
    await _engine.muteLocalAudioStream(!_isMicEnabled);
  }

  void _toggleVideo() async {
    setState(() => _isVideoEnabled = !_isVideoEnabled);
    await _engine.muteLocalVideoStream(!_isVideoEnabled);
  }

  void _switchCamera() async {
    await _engine.switchCamera();
  }

  Duration get callDuration =>
      _joinedAt == null ? Duration.zero : DateTime.now().difference(_joinedAt!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildRemoteView()),
            Positioned(
              right: 12,
              top: 12,
              width: 120,
              height: 180,
              child: _buildLocalPreview(),
            ),
            if (widget.showDebugInfo)
              Positioned(
                left: 12,
                top: 12,
                child: _buildDebugPanel(),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: _buildToolbar(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteView() {
    if (_remoteUid == null) {
      return const Center(
        child: Text(
          'Waiting for remote user...',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        connection: RtcConnection(channelId: widget.channelId),
        canvas: VideoCanvas(uid: _remoteUid),
      ),
    );
  }

  Widget _buildLocalPreview() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _isJoined
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _roundButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 16),
        _roundButton(
          icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
          onPressed: _toggleMic,
        ),
        const SizedBox(width: 16),
        _roundButton(
          icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
          onPressed: _toggleVideo,
        ),
        const SizedBox(width: 16),
        _roundButton(
          icon: Icons.cameraswitch,
          onPressed: _switchCamera,
        ),
      ],
    );
  }

  Widget _roundButton({
    required IconData icon,
    Color color = const Color(0xFF9B197D),
    required VoidCallback onPressed,
  }) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      fillColor: color,
      constraints: const BoxConstraints.tightFor(width: 56, height: 56),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white70, fontSize: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Channel: ${widget.channelId}'),
            Text('Joined: $_isJoined'),
            Text('Remote UID: ${_remoteUid ?? '-'}'),
            Text(
                'Mic: ${_isMicEnabled ? 'on' : 'off'} Video: ${_isVideoEnabled ? 'on' : 'off'}'),
            if (_joinedAt != null) Text('Duration: ${callDuration.inSeconds}s'),
          ],
        ),
      ),
    );
  }
}
