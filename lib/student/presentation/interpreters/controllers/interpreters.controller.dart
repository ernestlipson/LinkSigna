import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../interpreter_profile.screen.dart';
import '../../../infrastructure/dal/services/interpreter.service.dart';
import '../../../infrastructure/dal/daos/models/Interpreter.model.dart';
import '../../../../infrastructure/dal/services/session.firestore.service.dart';

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
    // TODO: integrate actual auth; placeholder for now
    return 'student_test_id';
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
      name: fullName,
      email: i.email,
      profileImage: i.profileAvatar.isNotEmpty
          ? i.profileAvatar
          : 'https://via.placeholder.com/150?text=Interpreter',
      experience: _inferExperience(i.description),
      isFree: i.price <= 0,
      price: i.price > 0 ? i.price.toInt() : null,
      description: i.description,
      isBooked: i.isBooked,
    );
  }

  int _inferExperience(String description) {
    final d = description.toLowerCase();
    if (d.contains('senior')) return 7;
    if (d.contains('intermediate')) return 4;
    return 2; // default
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
            (i.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void showFilterModal() {
    isFilterModalOpen.value = true;
  }

  void closeFilterModal() {
    isFilterModalOpen.value = false;
  }

  void applyFilters() {
    // TODO: Implement filter logic
    Get.snackbar(
      'Filters Applied',
      'Filters have been applied successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
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
    if (interpreter.isBooked == true) {
      Get.snackbar(
        'Already Booked',
        'This interpreter is already booked.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
      );
      return;
    }
    _bookingInProgress.value = true;
    try {
      // For now we treat both free & paid similarly (paid path can add payment confirmation before calling)
      final startTime = _deriveStartTime();
      final className = _deriveClassName();
      final sessionDocId = await _sessionService.createSession(
        studentId: _studentId,
        interpreterId: interpreter.id,
        className: className,
        startTime: startTime,
      );

      // Mark interpreter as booked
      await _service.setBookingStatus(
          interpreterId: interpreter.id, isBooked: true);

      Get.snackbar(
        'Session Created',
        'Session booked with ${interpreter.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
      Get.log('Session created: $sessionDocId');
    } catch (e) {
      Get.snackbar(
        'Booking Failed',
        'Could not create session: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
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
  final String name;
  final String email;
  final String profileImage;
  final int experience;
  final bool isFree;
  final int? price;
  final String? description;
  final bool? isBooked;

  InterpreterData({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.experience,
    required this.isFree,
    this.price,
    this.description,
    this.isBooked,
  });
}
