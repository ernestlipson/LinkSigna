import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class GoogleCalendarService extends GetxService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );

  GoogleSignInAccount? _currentUser;

  @override
  void onInit() {
    super.onInit();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      if (account != null) {
        _initializeCalendarApi();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _initializeCalendarApi() async {
    if (_currentUser == null) return;

    try {
      Get.log('Calendar API initialization - using simplified version for now');
    } catch (e) {
      Get.log('Error initializing Calendar API: $e');
    }
  }

  Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        _currentUser = account;
        await _initializeCalendarApi();
        return true;
      }
      return false;
    } catch (e) {
      Get.log('Error signing in: $e');
      Get.snackbar(
        'Sign In Error',
        'Failed to sign in with Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }
  }

  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;

  Future<Map<String, String>?> createMeetingEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required Duration duration,
    required List<String> attendeeEmails,
  }) async {
    if (!isSignedIn) {
      final signedIn = await signIn();
      if (!signedIn) return null;
    }

    try {
      final mockMeetId = DateTime.now().millisecondsSinceEpoch.toString();
      final mockMeetLink = 'https://meet.google.com/$mockMeetId';

      Get.snackbar(
        'Meeting Created',
        'Google Meet session created successfully! (Demo version)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 3),
      );

      return {
        'eventId': mockMeetId,
        'meetLink': mockMeetLink,
        'eventLink':
            'https://calendar.google.com/calendar/event?eid=$mockMeetId',
      };
    } catch (e) {
      Get.log('Error creating calendar event: $e');
      Get.snackbar(
        'Meeting Creation Failed',
        'Failed to create Google Meet session: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return null;
    }
  }

  Future<void> openMeetLink(String meetLink) async {
    try {
      final uri = Uri.parse(meetLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch Google Meet');
      }
    } catch (e) {
      Get.log('Error opening meet link: $e');
      Get.snackbar(
        'Error',
        'Failed to open Google Meet: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy at hh:mm a').format(dateTime);
  }

  Future<bool> deleteEvent(String eventId) async {
    if (!isSignedIn) return false;

    try {
      // TODO: Implement actual Calendar API deletion
      Get.log('Mock: Deleting calendar event $eventId');
      return true;
    } catch (e) {
      Get.log('Error deleting calendar event: $e');
      return false;
    }
  }
}
