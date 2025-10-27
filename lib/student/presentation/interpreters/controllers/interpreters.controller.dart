import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../interpreter_profile.screen.dart';
import '../../../infrastructure/dal/services/interpreter.service.dart';
import '../../../../infrastructure/dal/models/interpreter.model.dart';
import '../../../../infrastructure/dal/services/session.firestore.service.dart';
import '../../shared/controllers/student_user.controller.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';

class InterpretersController extends GetxController {
  final RxList<InterpreterData> interpreters = <InterpreterData>[].obs;
  final isLoading = false.obs;
  final loadError = RxnString();

  // Filter form controllers
  final searchController = TextEditingController();
  final subjectController = TextEditingController();

  // Filter state
  final RxBool isFilterModalOpen = false.obs;
  final RxString selectedExperience = ''.obs;
  final RxString selectedPrice = ''.obs;
  final RxString selectedAvailability = ''.obs;

  // New filter options
  final RxString selectedSubject = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  late final InterpreterService _service;
  StreamSubscription<List<Interpreter>>? _sub;
  late final SessionFirestoreService _sessionService;
  final _bookingInProgress = false.obs;
  late final String _studentId;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<InterpreterService>();
    _sessionService = Get.find<SessionFirestoreService>();
    _studentId = _resolveStudentId();
    _listen();
  }

  String _resolveStudentId() {
    // Get student ID from StudentUserController if available
    if (Get.isRegistered<StudentUserController>()) {
      final studentController = Get.find<StudentUserController>();
      final currentStudent = studentController.current.value;
      if (currentStudent != null && currentStudent.uid.isNotEmpty) {
        return currentStudent.uid; // This is the Firestore document ID
      }
    }

    // Fallback: generate a UUID if no proper student ID found
    Get.log('Warning: No proper student ID found, using fallback');
    return 'student_fallback_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _listen() {
    isLoading.value = true;
    loadError.value = null;
    _sub = _service.streamAllInterpreters().listen((list) {
      interpreters.assignAll(list.map(_mapToData).toList());
      isLoading.value = false;
    }, onError: (e) {
      loadError.value = 'Failed to load interpreters';
      isLoading.value = false;
      Get.log('Interpreter stream error: $e');
    });
  }

  InterpreterData _mapToData(Interpreter i) {
    final fullName = _fullName(i.firstName, i.lastName);
    return InterpreterData(
      id: i.id,
      interpreterId: i.interpreterId,
      name: fullName,
      email: i.email,
      profileImage: i.profilePictureUrl.isNotEmpty
          ? i.profilePictureUrl
          : 'https://via.placeholder.com/150?text=Interpreter',
      experience: 2, // You can infer from joinedDate or add logic if needed
      isAvailable: i.isAvailable,
      languages: i.languages,
      rating: i.rating,
      specializations: i.specializations,
      updatedAt: i.updatedAt,
    );
  }

  String _fullName(String first, String last) {
    if (first.isEmpty && last.isEmpty) return 'Unknown Interpreter';
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  List<InterpreterData> get filteredInterpreters {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return interpreters;
    return interpreters
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.email.toLowerCase().contains(q) ||
            (i.languages.join(',').toLowerCase().contains(q)) ||
            (i.specializations.join(',').toLowerCase().contains(q)))
        .toList();
  }

  void showFilterModal() {
    isFilterModalOpen.value = true;
  }

  void closeFilterModal() {
    isFilterModalOpen.value = false;
  }

  void applyFilters() {
    AppSnackbar.success(
      title: 'Filters Applied',
      message: 'Filters have been applied successfully!',
    );
    closeFilterModal();
  }

  // Date picker method
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // Time picker method
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  void clearFilters() {
    selectedExperience.value = '';
    selectedPrice.value = '';
    selectedAvailability.value = '';
    selectedSubject.value = '';
    selectedDate.value = null;
    selectedTime.value = null;
    searchController.clear();
    subjectController.clear();
  }

  Future<void> bookInterpreter(InterpreterData interpreter) async {
    if (_bookingInProgress.value) return; // prevent double tap

    if (!interpreter.isAvailable) {
      AppSnackbar.warning(
        title: 'Unavailable',
        message: 'This interpreter is currently unavailable.',
      );
      return;
    }

    _bookingInProgress.value = true;
    try {
      final startTime = _deriveStartTime();
      final className = _deriveClassName();
      await _sessionService.createSession(
        studentId: _studentId,
        interpreterId: interpreter.id,
        className: className,
        startTime: startTime,
      );

      // Optionally, set interpreter as unavailable after booking
      await _service.setBookingStatus(
          interpreterId: interpreter.id, isBooked: true);

      AppSnackbar.success(
        title: 'Session Created',
        message:
            'Session booked with ${interpreter.name}. Waiting for interpreter confirmation.',
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Booking Failed',
        message: 'Could not create session: $e',
      );
      Get.log('Error booking interpreter: $e');
    } finally {
      _bookingInProgress.value = false;
    }
  }

  DateTime _deriveStartTime() {
    // If user selected date/time filters, use them; else schedule 30 mins ahead
    final base = DateTime.now().add(const Duration(minutes: 30));
    final date = selectedDate.value;
    final time = selectedTime.value;
    if (date == null || time == null) return base;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _deriveClassName() {
    if (selectedSubject.value.isNotEmpty) return selectedSubject.value;
    return 'Communication Skills';
  }

  void viewMore(InterpreterData interpreter) {
    Get.to(() => InterpreterProfileScreen(interpreter: interpreter));
  }

  @override
  void onClose() {
    _sub?.cancel();
    searchController.dispose();
    subjectController.dispose();
    super.onClose();
  }
}

class InterpreterData {
  final String id;
  final String interpreterId;
  final String name;
  final String email;
  final String profileImage;
  final int experience;
  final bool isAvailable;
  final List<dynamic> languages;
  final double rating;
  final List<dynamic> specializations;
  final DateTime? updatedAt;

  InterpreterData({
    required this.id,
    required this.interpreterId,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.experience,
    this.isAvailable = false,
    required this.languages,
    required this.rating,
    required this.specializations,
    required this.updatedAt,
  });
}
