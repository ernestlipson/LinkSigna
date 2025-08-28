import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
import 'package:flutter_zoom_videosdk/flutter_zoom_view.dart' as zoom_view;

import '../../infrastructure/theme/app_theme.dart';
import '../../../zoom_config.dart';
import '../../../utils/jwt.dart';

class StudentZoomScreen extends StatefulWidget {
  const StudentZoomScreen({super.key});

  @override
  State<StudentZoomScreen> createState() => _StudentZoomScreenState();
}

class _StudentZoomScreenState extends State<StudentZoomScreen> {
  final zoom = ZoomVideoSdk();
  final eventListener = ZoomVideoSdkEventListener();
  bool isInSession = false;
  List<StreamSubscription> subscriptions = [];
  List<ZoomVideoSdkUser> users = [];
  bool isMuted = true;
  bool isVideoOn = false;
  bool isLoading = false;

  // Controllers for input fields
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeZoom();
    _sessionNameController.text = sessionDetails['sessionName']!;
    _displayNameController.text =
        'Student_${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    _displayNameController.dispose();
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  Future<void> _initializeZoom() async {
    try {
      InitConfig initConfig = InitConfig(
        domain: "zoom.us",
        enableLog: true,
      );
      await zoom.initSdk(initConfig);
    } catch (e) {
      print('Failed to initialize Zoom SDK: $e');
    }
  }

  _handleSessionJoin(data) async {
    if (!mounted) return;
    final mySelf = ZoomVideoSdkUser.fromJson(jsonDecode(data['sessionUser']));
    final remoteUsers = await zoom.session.getRemoteUsers() ?? [];
    final isMutedState = await mySelf.audioStatus?.isMuted() ?? true;
    final isVideoOnState = await mySelf.videoStatus?.isOn() ?? false;
    setState(() {
      isInSession = true;
      isLoading = false;
      isMuted = isMutedState;
      isVideoOn = isVideoOnState;
      users = [mySelf, ...remoteUsers];
    });
  }

  _updateUserList(data) async {
    final mySelf = await zoom.session.getMySelf();
    if (mySelf == null) return;
    final remoteUserList = await zoom.session.getRemoteUsers() ?? [];
    remoteUserList.insert(0, mySelf);
    setState(() {
      users = remoteUserList;
    });
  }

  _handleVideoChange(data) async {
    if (!mounted) return;
    final mySelf = await zoom.session.getMySelf();
    final videoStatus = await mySelf?.videoStatus?.isOn() ?? false;
    setState(() {
      isVideoOn = videoStatus;
    });
  }

  _handleAudioChange(data) async {
    if (!mounted) return;
    final mySelf = await zoom.session.getMySelf();
    final audioStatus = await mySelf?.audioStatus?.isMuted() ?? true;
    setState(() {
      isMuted = audioStatus;
    });
  }

  _setupEventListeners() {
    subscriptions = [
      eventListener.addListener(EventType.onSessionJoin, _handleSessionJoin),
      eventListener.addListener(EventType.onSessionLeave, handleLeaveSession),
      eventListener.addListener(EventType.onUserJoin, _updateUserList),
      eventListener.addListener(EventType.onUserLeave, _updateUserList),
      eventListener.addListener(
          EventType.onUserVideoStatusChanged, _handleVideoChange),
      eventListener.addListener(
          EventType.onUserAudioStatusChanged, _handleAudioChange),
    ];
  }

  Future startSession() async {
    setState(() => isLoading = true);
    try {
      final token =
          generateJwt(_sessionNameController.text, sessionDetails['roleType']!);
      _setupEventListeners();
      await zoom.joinSession(JoinSessionConfig(
        sessionName: _sessionNameController.text,
        sessionPassword: '',
        token: token,
        userName: _displayNameController.text,
        audioOptions: {"connect": true, "mute": true},
        videoOptions: {"localVideoOn": true},
        sessionIdleTimeoutMins: int.parse(sessionDetails['sessionTimeout']!),
      ));
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to join session: $e');
    }
  }

  handleLeaveSession([data]) {
    setState(() {
      isInSession = false;
      isLoading = false;
      users = [];
    });
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
  }

  Future toggleAudio() async {
    final mySelf = await zoom.session.getMySelf();
    if (mySelf?.audioStatus == null) return;
    final isMuted = await mySelf!.audioStatus!.isMuted();
    isMuted
        ? await zoom.audioHelper.unMuteAudio(mySelf.userId)
        : await zoom.audioHelper.muteAudio(mySelf.userId);
  }

  Future toggleVideo() async {
    final mySelf = await zoom.session.getMySelf();
    if (mySelf?.videoStatus == null) return;
    final isOn = await mySelf!.videoStatus!.isOn();
    isOn
        ? await zoom.videoHelper.stopVideo()
        : await zoom.videoHelper.startVideo();
  }

  Future leaveSession() async {
    await zoom.leaveSession(false);
    handleLeaveSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Zoom Video',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (!isInSession)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Join Zoom Session',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _sessionNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Session Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        prefixIcon:
                            const Icon(Icons.video_call, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _displayNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : startSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Start Session',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Stack(
              children: [
                VideoGrid(users: users),
                ControlBar(
                  isMuted: isMuted,
                  isVideoOn: isVideoOn,
                  onLeaveSession: leaveSession,
                  onToggleAudio: toggleAudio,
                  onToggleVideo: toggleVideo,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class VideoGrid extends StatelessWidget {
  final List<ZoomVideoSdkUser> users;
  const VideoGrid({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: users.length <= 2 ? 1 : 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) => _VideoTile(user: users[index]),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final ZoomVideoSdkUser user;
  const _VideoTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SizedBox.expand(
        child: zoom_view.View(
          key: Key(user.userId),
          creationParams: {
            "userId": user.userId,
            "videoAspect": VideoAspect.FullFilled,
            "fullScreen": false,
          },
        ),
      ),
    );
  }
}

class ControlBar extends StatelessWidget {
  final bool isMuted;
  final bool isVideoOn;
  final double circleButtonSize = 50.0;
  final VoidCallback onLeaveSession;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleVideo;

  const ControlBar({
    super.key,
    required this.isMuted,
    required this.isVideoOn,
    required this.onLeaveSession,
    required this.onToggleAudio,
    required this.onToggleVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onToggleAudio,
              icon: Icon(
                isMuted ? Icons.mic_off : Icons.mic,
              ),
              iconSize: circleButtonSize,
              tooltip: isMuted ? "Unmute" : "Mute",
              color: Colors.white,
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: onToggleVideo,
              iconSize: circleButtonSize,
              icon: Icon(
                isVideoOn ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: onLeaveSession,
              iconSize: circleButtonSize,
              icon: const Icon(Icons.call_end, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
