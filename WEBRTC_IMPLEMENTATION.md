# WebRTC Video Calling Implementation

## Overview

This implementation provides **peer-to-peer (P2P) video calling** using WebRTC and Firestore for signaling. **No backend server required!**

## Architecture

### Key Components

1. **WebRTC Signaling Service** (`lib/shared/call/services/webrtc_signaling.service.dart`)
   - Manages WebRTC peer connections
   - Uses Firestore for signaling (SDP offer/answer exchange)
   - Handles ICE candidate exchange
   - Controls local/remote media streams

2. **Video Call Screen** (`lib/shared/call/webrtc_call.screen.dart`)
   - UI for video calls with local and remote video
   - Control buttons: mute, camera toggle, switch camera, end call
   - Connection status indicator
   - Loading and error states

3. **Video Call Controller** (`lib/shared/call/controllers/video_call.controller.dart`)
   - Manages call initialization
   - Handles offer/answer creation based on role (initiator or answerer)
   - Exposes controls to UI

### How It Works (No Backend!)

#### Signaling with Firestore

Instead of a traditional signaling server, we use **Firestore** to exchange connection metadata:

```
channels/{channelId}
├── offer (SDP)
├── answer (SDP)
└── candidates (ICE candidates subcollection)
    ├── candidate1
    ├── candidate2
    └── ...
```

#### Call Flow

1. **Student Books Interpreter** → Status: `pending`
2. **Interpreter Confirms** → Status: `confirmed`
3. **Student Joins Call** (creates offer):
   - Generates channel ID: `booking_{bookingId}`
   - Initializes local media (camera + microphone)
   - Creates RTCPeerConnection
   - Creates SDP offer and writes to `channels/{channelId}`
   - Listens for SDP answer from Firestore
   - Exchanges ICE candidates via Firestore subcollection

4. **Interpreter Joins Call** (creates answer):
   - Uses same channel ID
   - Initializes local media
   - Creates RTCPeerConnection
   - Reads SDP offer from `channels/{channelId}`
   - Creates SDP answer and writes to Firestore
   - Exchanges ICE candidates via Firestore subcollection

5. **P2P Connection Established**:
   - WebRTC establishes direct peer-to-peer connection
   - Video/audio streams directly between devices
   - Firestore only used for initial signaling

## Configuration

### Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter_webrtc: ^0.12.6  # WebRTC support for Flutter
  cloud_firestore: ^6.0.1  # Firestore for signaling
  firebase_auth: ^6.0.0    # User authentication
```

### Android Permissions (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
```

### iOS Permissions (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Camera permission is required for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone permission is required for video calls</string>
```

### Firestore Security Rules

```javascript
// WebRTC signaling channels
match /channels/{channelId} {
  allow create, read, update, delete: if request.auth != null;
  
  match /candidates/{candidateId} {
    allow create, read, delete: if request.auth != null;
  }
}
```

## Usage

### In Sessions Controllers

**Student (Initiator)**:

```dart
void joinVideoCall(Map<String, dynamic> booking) {
  final channelId = 'booking_${booking['id']}';
  Get.to(() => WebRTCCallScreen(channelId: channelId, isInitiator: true));
}
```

**Interpreter (Answerer)**:

```dart
void joinVideoCall(Map<String, dynamic> booking) {
  final channelId = 'booking_${booking['id']}';
  Get.to(() => WebRTCCallScreen(channelId: channelId, isInitiator: false));
}
```

## Features

### Video Controls

- **Mute/Unmute Microphone**: Toggle audio stream
- **Enable/Disable Camera**: Toggle video stream
- **Switch Camera**: Toggle between front/back camera
- **End Call**: Cleanup and return to previous screen

### Connection States

- **Connecting**: Initializing media and establishing connection
- **Connected**: P2P connection established
- **Error**: Display error message with retry option

### UI Features

- Full-screen remote video
- Picture-in-picture local video (top-right)
- Connection status indicator (top-left)
- Control buttons at bottom
- Visual feedback for mic/camera state

## Technical Details

### ICE Servers

Using free Google STUN servers for NAT traversal:

```dart
{
  'iceServers': [
    {
      'urls': [
        'stun:stun1.l.google.com:19302',
        'stun:stun2.l.google.com:19302',
      ]
    }
  ]
}
```

### Media Constraints

```dart
{
  'audio': true,
  'video': {
    'facingMode': 'user',  // Front camera by default
    'width': {'ideal': 1280},
    'height': {'ideal': 720},
  }
}
```

## Advantages Over Agora

### No Backend Required

- ✅ No signaling server needed (uses Firestore)
- ✅ No token generation server required
- ✅ No server costs for signaling

### Free & Open Source

- ✅ WebRTC is free and open source
- ✅ No monthly subscription fees
- ✅ Only Firestore usage costs (minimal for signaling)

### Direct P2P Connection

- ✅ Lower latency (direct peer connection)
- ✅ Better privacy (direct communication)
- ✅ Scales naturally (no central server bottleneck)

## Limitations & Considerations

### Network Requirements

- Both peers must have internet connectivity
- NAT traversal may fail in restrictive networks (consider TURN server)

### Firestore Costs

- Signaling uses Firestore read/write operations
- Typical call: ~10-20 reads/writes for signaling
- ICE candidates: ~5-10 documents per peer

### Production Recommendations

1. **Add TURN Server** (for restrictive networks):

```dart
{
  'iceServers': [
    {
      'urls': 'turn:your-turn-server.com',
      'username': 'user',
      'credential': 'password',
    }
  ]
}
```

2. **Implement Call Quality Monitoring**:
   - Track connection state changes
   - Monitor ICE connection state
   - Log failed connection attempts

3. **Add Call Notifications**:
   - Notify interpreter when student initiates call
   - Use Firebase Cloud Messaging (FCM)

4. **Cleanup Strategy**:
   - Auto-cleanup old channels (Cloud Function)
   - Delete channel on call end
   - Handle abandoned channels

## Troubleshooting

### Camera/Microphone Permissions

```dart
// Request permissions before joining call
await Permission.camera.request();
await Permission.microphone.request();
```

### Connection Fails

1. Check Firestore security rules
2. Verify both peers are authenticated
3. Check network connectivity
4. Try with TURN server for NAT traversal

### No Video/Audio

1. Verify permissions granted
2. Check media constraints
3. Ensure tracks added to peer connection
4. Check browser/device compatibility

## Testing

### Local Testing

1. Run app on two devices (or emulator + device)
2. Student books interpreter and confirms
3. Both join call from sessions screen
4. Verify video/audio working
5. Test all controls (mute, camera, switch)

### Production Testing

1. Test across different networks (WiFi, cellular)
2. Test with restrictive firewalls
3. Test call quality over time
4. Test reconnection scenarios
5. Test cleanup on unexpected disconnect

## Future Enhancements

1. **Screen Sharing**: Add screen capture capability
2. **Call Recording**: Record calls for training/quality
3. **Chat Messages**: Add text chat during call
4. **Call History**: Store call duration and quality metrics
5. **Multi-party Calls**: Support group video calls
6. **Background Mode**: Continue call when app backgrounded

## Resources

- [WebRTC Documentation](https://webrtc.org/)
- [Flutter WebRTC Plugin](https://pub.dev/packages/flutter_webrtc)
- [Firestore Signaling Guide](https://firebase.google.com/docs/firestore/solutions/webrtc)
- [ICE/STUN/TURN Explained](https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/)
