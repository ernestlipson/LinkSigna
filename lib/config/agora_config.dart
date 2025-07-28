class AgoraConfig {
  // Replace these with your actual Agora credentials
  static const String appId = '3d2c83d6b7814932b38e75f7a69489bc';
  static const String token = 'YOUR_AGORA_TOKEN';

  // For testing purposes, you can use a temporary token
  // In production, you should generate tokens on your server
  static const String tempToken = 'YOUR_TEMP_TOKEN';

  // Channel configuration
  static const int uid = 0; // 0 means Agora will assign a random UID

  // Video configuration
  static const int videoEncoderConfiguration =
      0; // 0 = 640x360, 1 = 480x360, 2 = 360x360

  // Audio configuration
  static const int audioProfile =
      0; // 0 = Default, 1 = Standard, 2 = Music Standard, 3 = Music Standard Stereo
  static const int audioScenario =
      0; // 0 = Default, 1 = Chatroom Entertainment, 2 = Education, 3 = Game Streaming, 4 = Showroom, 5 = Chatroom Gaming
}
