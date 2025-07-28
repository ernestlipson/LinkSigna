# Video Call Implementation with Agora SDK

This guide explains how to set up and use the video calling functionality in your Flutter app using Agora RTC Engine.

## Prerequisites

1. **Agora Account**: Sign up at [Agora Console](https://console.agora.io/)
2. **Flutter SDK**: Ensure you have Flutter installed
3. **Android/iOS Development Environment**: Set up for mobile development

## Setup Instructions

### 1. Get Agora Credentials

1. Go to [Agora Console](https://console.agora.io/)
2. Create a new project or use an existing one
3. Get your **App ID** from the project settings
4. Generate a **Token** (for testing) or set up token server (for production)

### 2. Update Configuration

Edit `lib/config/agora_config.dart`:

```dart
class AgoraConfig {
  // Replace with your actual Agora credentials
  static const String appId = 'YOUR_ACTUAL_APP_ID';
  static const String token = 'YOUR_ACTUAL_TOKEN';
  
  // For testing, you can use a temporary token
  // In production, generate tokens on your server
  static const String tempToken = 'YOUR_TEMP_TOKEN';
}
```

### 3. Android Permissions

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### 4. iOS Permissions

Add these permissions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera permission is required for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone permission is required for video calls</string>
```

## Usage

### Starting a Video Call

1. Navigate to the Sessions screen
2. Find an active session
3. Tap "Join Video Call"
4. The app will request camera and microphone permissions
5. You'll be taken to the video call screen

### Video Call Features

- **Local Video**: Picture-in-picture view of your camera
- **Remote Video**: Full-screen view of the other participant
- **Mute/Unmute**: Toggle microphone
- **Camera Switch**: Switch between front and back cameras
- **Video Toggle**: Enable/disable video
- **Speaker Toggle**: Switch between speaker and earpiece
- **End Call**: Leave the video call

### Controls

- **Mute Button**: Toggle microphone on/off
- **Camera Switch**: Switch between front and back cameras
- **End Call**: Red button to leave the call
- **Video Toggle**: Enable/disable video stream
- **Speaker Toggle**: Switch audio output

## Architecture

### Files Structure

```
lib/
├── config/
│   └── agora_config.dart          # Agora configuration
├── infrastructure/
│   └── services/
│       └── video_call.service.dart # Video call service
└── presentation/
    ├── sessions/
    │   ├── controllers/
    │   │   └── sessions.controller.dart # Updated with video call integration
    │   └── sessions.screen.dart
    └── video_call/
        └── video_call.screen.dart  # Video call UI
```

### Key Components

1. **VideoCallService**: Manages Agora RTC Engine
2. **VideoCallScreen**: UI for video calling
3. **SessionsController**: Updated to handle video call navigation
4. **AgoraConfig**: Configuration settings

## Testing

### Local Testing

1. Run the app on two devices
2. Join the same channel name
3. Test video and audio functionality

### Production Considerations

1. **Token Security**: Generate tokens on your server
2. **Channel Management**: Implement proper channel naming
3. **Error Handling**: Add comprehensive error handling
4. **Network Handling**: Handle poor network conditions
5. **Background/Foreground**: Handle app state changes

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure camera and microphone permissions are granted
2. **No Video**: Check camera permissions and device camera
3. **No Audio**: Check microphone permissions and device audio
4. **Connection Issues**: Verify internet connection and Agora credentials

### Debug Steps

1. Check Agora Console for connection logs
2. Verify App ID and Token are correct
3. Test with Agora's sample app first
4. Check device permissions in settings

## Security Notes

- Never commit real Agora credentials to version control
- Use environment variables for production
- Implement proper token generation on your server
- Consider implementing user authentication for video calls

## Next Steps

1. Implement user authentication for video calls
2. Add call history and recording features
3. Implement screen sharing functionality
4. Add chat functionality during calls
5. Implement call quality monitoring 