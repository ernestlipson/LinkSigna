import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart';

/// WebRTC Signaling Service using Firestore
/// This eliminates the need for a separate signaling server
class WebRTCSignalingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  webrtc.RTCPeerConnection? _peerConnection;
  webrtc.MediaStream? _localStream;
  webrtc.MediaStream? _remoteStream;

  final localRenderer = webrtc.RTCVideoRenderer();
  final remoteRenderer = webrtc.RTCVideoRenderer();

  final isConnected = false.obs;
  final isMicOn = true.obs;
  final isCameraOn = true.obs;
  final isFrontCamera = true.obs;

  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _candidatesSubscription;

  // ICE servers configuration (using free STUN servers)
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ]
      }
    ]
  };

  // Media constraints
  final Map<String, dynamic> _mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
      'width': {'ideal': 1280},
      'height': {'ideal': 720},
    }
  };

  @override
  void onInit() {
    super.onInit();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  /// Initialize local media stream (camera + microphone)
  Future<void> initLocalStream() async {
    try {
      _localStream =
          await webrtc.navigator.mediaDevices.getUserMedia(_mediaConstraints);
      localRenderer.srcObject = _localStream;
      Get.log('Local stream initialized');
    } catch (e) {
      Get.log('Error initializing local stream: $e');
      rethrow;
    }
  }

  /// Create a peer connection
  Future<void> _createPeerConnection() async {
    try {
      _peerConnection = await webrtc.createPeerConnection(_configuration);

      // Add local tracks to peer connection
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      // Listen for remote stream
      _peerConnection?.onTrack = (webrtc.RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          remoteRenderer.srcObject = _remoteStream;
          Get.log('Remote stream received');
        }
      };

      // Listen for connection state changes
      _peerConnection?.onConnectionState = (state) {
        Get.log('Connection state: $state');
        isConnected.value = state ==
            webrtc.RTCPeerConnectionState.RTCPeerConnectionStateConnected;
      };

      Get.log('Peer connection created');
    } catch (e) {
      Get.log('Error creating peer connection: $e');
      rethrow;
    }
  }

  /// Create an offer (caller side)
  Future<void> createOffer(String channelId, String userId) async {
    try {
      await _createPeerConnection();

      final channelDoc = _firestore.collection('channels').doc(channelId);
      final candidatesCollection = channelDoc.collection('candidates');

      // Listen for ICE candidates
      _peerConnection?.onIceCandidate = (webrtc.RTCIceCandidate candidate) {
        if (candidate.candidate != null) {
          candidatesCollection.add({
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
            'userId': userId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      };

      // Create and set local description
      webrtc.RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Send offer to Firestore
      await channelDoc.set({
        'offer': {
          'sdp': offer.sdp,
          'type': offer.type,
        },
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.log('Offer created and sent to Firestore');

      // Listen for answer
      _answerSubscription = channelDoc.snapshots().listen((snapshot) async {
        final data = snapshot.data();
        if (data != null && data.containsKey('answer')) {
          final answer = data['answer'];
          final description = webrtc.RTCSessionDescription(
            answer['sdp'],
            answer['type'],
          );
          await _peerConnection?.setRemoteDescription(description);
          Get.log('Answer received and set');
        }
      });

      // Listen for remote ICE candidates
      _listenForRemoteCandidates(channelId, userId);
    } catch (e) {
      Get.log('Error creating offer: $e');
      rethrow;
    }
  }

  /// Create an answer (callee side)
  Future<void> createAnswer(String channelId, String userId) async {
    try {
      await _createPeerConnection();

      final channelDoc = _firestore.collection('channels').doc(channelId);
      final candidatesCollection = channelDoc.collection('candidates');

      // Listen for ICE candidates
      _peerConnection?.onIceCandidate = (webrtc.RTCIceCandidate candidate) {
        if (candidate.candidate != null) {
          candidatesCollection.add({
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
            'userId': userId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      };

      // Get offer from Firestore
      final snapshot = await channelDoc.get();
      final data = snapshot.data();

      if (data != null && data.containsKey('offer')) {
        final offer = data['offer'];
        final description = webrtc.RTCSessionDescription(
          offer['sdp'],
          offer['type'],
        );
        await _peerConnection?.setRemoteDescription(description);
        Get.log('Offer received and set');

        // Create and set answer
        webrtc.RTCSessionDescription answer =
            await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        // Send answer to Firestore
        await channelDoc.update({
          'answer': {
            'sdp': answer.sdp,
            'type': answer.type,
          },
          'answeredBy': userId,
          'answeredAt': FieldValue.serverTimestamp(),
        });

        Get.log('Answer created and sent to Firestore');

        // Listen for remote ICE candidates
        _listenForRemoteCandidates(channelId, userId);
      }
    } catch (e) {
      Get.log('Error creating answer: $e');
      rethrow;
    }
  }

  /// Listen for remote ICE candidates
  void _listenForRemoteCandidates(String channelId, String myUserId) {
    final candidatesCollection = _firestore
        .collection('channels')
        .doc(channelId)
        .collection('candidates');

    _candidatesSubscription =
        candidatesCollection.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null && data['userId'] != myUserId) {
            final candidate = webrtc.RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            );
            _peerConnection?.addCandidate(candidate);
            Get.log('Remote ICE candidate added');
          }
        }
      }
    });
  }

  /// Toggle microphone
  void toggleMic() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
      isMicOn.value = audioTrack.enabled;
    }
  }

  /// Toggle camera
  void toggleCamera() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
      isCameraOn.value = videoTrack.enabled;
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await webrtc.Helper.switchCamera(videoTrack);
      isFrontCamera.value = !isFrontCamera.value;
    }
  }

  /// End call and cleanup
  Future<void> endCall(String channelId) async {
    try {
      // Close peer connection
      await _peerConnection?.close();
      _peerConnection = null;

      // Stop local stream
      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream?.dispose();
      _localStream = null;

      // Clear remote stream
      _remoteStream?.dispose();
      _remoteStream = null;

      // Clear renderers
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;

      // Cancel subscriptions
      await _offerSubscription?.cancel();
      await _answerSubscription?.cancel();
      await _candidatesSubscription?.cancel();

      // Clean up Firestore data
      await _firestore.collection('channels').doc(channelId).delete();

      isConnected.value = false;
      isMicOn.value = true;
      isCameraOn.value = true;

      Get.log('Call ended and cleaned up');
    } catch (e) {
      Get.log('Error ending call: $e');
    }
  }

  @override
  void onClose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.dispose();
    _offerSubscription?.cancel();
    _answerSubscription?.cancel();
    _candidatesSubscription?.cancel();
    super.onClose();
  }
}
