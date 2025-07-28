import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/agora_config.dart';

class VideoCallService extends GetxService {
  static const String appId = AgoraConfig.appId;
  static const String token = AgoraConfig.token;

  RtcEngine? _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isInitialized = false;

  // Observable variables for UI updates
  final isJoined = false.obs;
  final isMuted = false.obs;
  final isVideoEnabled = true.obs;
  final isSpeakerOn = true.obs;
  final isEngineReady = false.obs;
  final engineObservable = Rx<RtcEngine?>(null);

  @override
  void onInit() {
    super.onInit();
    _initAgora();
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  Future<void> _initAgora() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await [Permission.microphone, Permission.camera].request();

      // Create RTC Engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Set the observable engine
      engineObservable.value = _engine;

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("Local user joined");
            _localUserJoined = true;
            isJoined.value = true;
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("Remote user joined");
            _remoteUid = remoteUid;
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            debugPrint("Remote user left");
            _remoteUid = null;
          },
        ),
      );

      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.enableVideo();
      await _engine!.startPreview();
      await _engine!
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);

      _isInitialized = true;
      isEngineReady.value = true;
    } catch (e) {
      debugPrint("Failed to initialize Agora: $e");
      _isInitialized = false;
      isEngineReady.value = false;
    }
  }

  Future<void> joinChannel(String channelName, {int uid = 0}) async {
    if (!_isInitialized) {
      await _initAgora();
    }

    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
    _localUserJoined = false;
    _remoteUid = null;
    isJoined.value = false;
  }

  Future<void> toggleMute() async {
    await _engine?.muteLocalAudioStream(!isMuted.value);
    isMuted.value = !isMuted.value;
  }

  Future<void> toggleVideo() async {
    await _engine?.enableLocalVideo(!isVideoEnabled.value);
    isVideoEnabled.value = !isVideoEnabled.value;
  }

  Future<void> toggleSpeaker() async {
    await _engine?.setEnableSpeakerphone(!isSpeakerOn.value);
    isSpeakerOn.value = !isSpeakerOn.value;
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  void _dispose() {
    _engine?.leaveChannel();
    _engine?.release();
  }

  // Getter for remote user ID
  int? get remoteUid => _remoteUid;

  // Getter for local user joined status
  bool get localUserJoined => _localUserJoined;

  // Getter for engine (needed for video views)
  RtcEngine? get engine => engineObservable.value;

  // Getter to check if engine is ready
  bool get isEngineInitialized =>
      _isInitialized && engineObservable.value != null;
}
