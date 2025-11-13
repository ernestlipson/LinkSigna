import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../infrastructure/dal/services/interpreter.service.dart';
import '../../../../domain/users/user.model.dart';
import '../../../../infrastructure/dal/services/booking.firestore.service.dart';
import '../../../../infrastructure/dal/services/user.firestore.service.dart';
import '../../shared/controllers/student_user.controller.dart';
import 'package:sign_language_app/shared/components/app.snackbar.dart';
import 'package:sign_language_app/shared/components/payment_modal.component.dart';

class InterpretersController extends GetxController {
  final RxList<User> interpreters = <User>[].obs;
  final isLoading = false.obs;
  final loadError = RxnString();
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;

  // View state management
  final RxBool isViewingDetails = false.obs;
  final Rxn<User> selectedInterpreter = Rxn<User>();

  // Filter form controllers
  final searchController = TextEditingController();
  final subjectController = TextEditingController();
  final scrollController = ScrollController();
  final RxString searchQuery = ''.obs;

  // Filter state
  final RxBool isFilterModalOpen = false.obs;
  final RxString selectedSubject = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  late final InterpreterService _service;
  StreamSubscription<List<User>>? _sub;
  late final BookingFirestoreService _bookingService;
  final _bookingInProgress = false.obs;
  late final String _studentId;

  // Track booked interpreters
  final RxSet<String> bookedInterpreterIds = <String>{}.obs;

  // Pagination state
  DocumentSnapshot? _lastDocument;
  int _currentLimit = InterpreterService.pageSize;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<InterpreterService>();
    _bookingService = Get.find<BookingFirestoreService>();
    _initializeStudentId();
    _setupScrollListener();
    _listen();
  }

  Future<void> _initializeStudentId() async {
    _studentId = await _resolveStudentId();
    Get.log('InterpretersController: Resolved student ID: $_studentId');
    _loadBookedInterpreters();
  }

  Future<String> _resolveStudentId() async {
    // First: Try to get from SharedPreferences (most reliable)
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedId = prefs.getString('student_user_doc_id');
      if (cachedId != null && cachedId.isNotEmpty) {
        Get.log(
            'InterpretersController: Using cached student ID from SharedPreferences: $cachedId');
        return cachedId;
      }
    } catch (e) {
      Get.log('Error reading from SharedPreferences: $e');
    }

    // Second: Get student ID from StudentUserController if available
    if (Get.isRegistered<StudentUserController>()) {
      final studentController = Get.find<StudentUserController>();
      final currentStudent = studentController.current.value;
      if (currentStudent != null && currentStudent.uid.isNotEmpty) {
        Get.log(
            'InterpretersController: Using student ID from controller: ${currentStudent.uid}');
        return currentStudent.uid;
      }
    }

    // Third: Try to find by Firebase Auth UID
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      try {
        final userService = Get.find<UserFirestoreService>();
        final user = await userService.findByAuthUid(authUser.uid);
        if (user != null && user.isStudent) {
          Get.log(
              'InterpretersController: Found student by authUid: ${user.uid}');
          // Cache it for next time
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('student_user_doc_id', user.uid);
          return user.uid;
        }
      } catch (e) {
        Get.log('Error finding user by authUid: $e');
      }
    }

    // Fallback: generate a UUID if no proper student ID found
    Get.log('Warning: No proper student ID found, using fallback');
    return 'student_fallback_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _loadBookedInterpreters() {
    // Load active bookings for this student
    _bookingService.bookingsForStudent(_studentId).listen((bookings) {
      final activeBookings = bookings
          .where((b) => b['status'] == 'pending' || b['status'] == 'confirmed')
          .toList();

      bookedInterpreterIds.clear();
      for (var booking in activeBookings) {
        bookedInterpreterIds.add(booking['interpreterId'] as String);
      }
    });
  }

  bool isInterpreterBooked(String interpreterId) {
    return bookedInterpreterIds.contains(interpreterId);
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore.value &&
          hasMoreData.value) {
        _loadMore();
      }
    });
  }

  void _listen() {
    isLoading.value = true;
    loadError.value = null;
    _currentLimit = InterpreterService.pageSize;

    _sub = _service.streamAllInterpreters(limit: _currentLimit).listen((list) {
      interpreters.assignAll(list);
      isLoading.value = false;

      // Update pagination state
      if (list.length < _currentLimit) {
        hasMoreData.value = false;
      }

      // Store last document for pagination
      if (list.isNotEmpty) {
        final lastInterpreter = list.last;
        _updateLastDocument(lastInterpreter.uid);
      }
    }, onError: (e) {
      loadError.value = 'Failed to load interpreters';
      isLoading.value = false;
      Get.log('Interpreter stream error: $e');
    });
  }

  Future<void> _updateLastDocument(String documentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(documentId)
          .get();
      if (doc.exists) {
        _lastDocument = doc;
      }
    } catch (e) {
      Get.log('Error updating last document: $e');
    }
  }

  Future<void> _loadMore() async {
    if (_lastDocument == null || !hasMoreData.value) return;

    isLoadingMore.value = true;
    try {
      final moreInterpreters = await _service.getAllInterpreters(
        lastDocument: _lastDocument,
        limit: InterpreterService.pageSize,
      );

      if (moreInterpreters.isEmpty ||
          moreInterpreters.length < InterpreterService.pageSize) {
        hasMoreData.value = false;
      }

      if (moreInterpreters.isNotEmpty) {
        interpreters.addAll(moreInterpreters);
        _currentLimit += moreInterpreters.length;

        // Update last document
        await _updateLastDocument(moreInterpreters.last.uid);
      }
    } catch (e) {
      Get.log('Error loading more interpreters: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to load more interpreters',
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  List<User> get filteredInterpreters {
    List<User> result = interpreters.toList();

    // Apply search filter using reactive searchQuery
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((i) =>
              i.fullName.toLowerCase().contains(q) ||
              (i.email?.toLowerCase().contains(q) ?? false) ||
              (i.languages?.join(',').toLowerCase().contains(q) ?? false) ||
              (i.specializations?.join(',').toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Apply subject/specialization filter
    if (selectedSubject.value.isNotEmpty) {
      final subject = selectedSubject.value.toLowerCase();
      result = result
          .where((i) =>
              (i.specializations
                      ?.any((s) => s.toLowerCase().contains(subject)) ??
                  false) ||
              i.fullName.toLowerCase().contains(subject))
          .toList();
    }

    // Apply availability filter based on date/time
    // If date and time are selected, check if interpreter is available
    if (selectedDate.value != null && selectedTime.value != null) {
      // For now, filter by availability status
      // In a real app, you'd check against interpreter's schedule
      result = result.where((i) => i.isAvailable == true).toList();
    }

    return result;
  }

  void showFilterModal() {
    isFilterModalOpen.value = true;
  }

  void closeFilterModal() {
    isFilterModalOpen.value = false;
  }

  void applyFilters() {
    // Show feedback to user
    final filterCount = _getActiveFilterCount();
    if (filterCount > 0) {
      AppSnackbar.success(
        title: 'Filters Applied',
        message: '$filterCount filter(s) applied successfully!',
      );
    }

    closeFilterModal();
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (selectedSubject.value.isNotEmpty) count++;
    if (selectedDate.value != null) count++;
    if (selectedTime.value != null) count++;
    return count;
  }

  // Date picker method
  Future<void> selectDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime tempDate = selectedDate.value ?? now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: tempDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }

  // Time picker method
  Future<void> selectTime(BuildContext context) async {
    TimeOfDay initialTime = selectedTime.value ?? TimeOfDay.now();

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      selectedTime.value = pickedTime;
    }
  }

  void clearFilters() {
    selectedSubject.value = '';
    selectedDate.value = null;
    selectedTime.value = null;
    searchController.clear();
    searchQuery.value = ''; // Clear reactive search query
    subjectController.clear();

    AppSnackbar.success(
      title: 'Filters Cleared',
      message: 'All filters have been cleared',
    );
  }

  Future<void> bookInterpreter(User interpreter) async {
    if (_bookingInProgress.value) return; // prevent double tap

    if (interpreter.isAvailable != true) {
      AppSnackbar.warning(
        title: 'Unavailable',
        message: 'This interpreter is currently unavailable.',
      );
      return;
    }

    // Check if already booked
    if (isInterpreterBooked(interpreter.uid)) {
      AppSnackbar.info(
        title: 'Already Booked',
        message: 'You already have an active booking with this interpreter.',
      );
      return;
    }

    // If interpreter is paid, show payment modal instead of directly booking
    if (!interpreter.isFreeInterpreter) {
      final studentEmail = _getStudentEmail();
      if (Get.context != null) {
        PaymentModalComponent.showPaymentModal(
          Get.context!,
          interpreterName: interpreter.fullName,
          amountGhs: interpreter.displayPrice,
          customerEmail: studentEmail,
        );
      }
      return;
    }

    // For free interpreters, proceed with direct booking
    _bookingInProgress.value = true;
    try {
      // Use current date and time
      final bookingDateTime = DateTime.now();

      // Get student name and email
      String studentName = 'Unknown Student';
      String studentEmail = '';
      if (Get.isRegistered<StudentUserController>()) {
        final studentController = Get.find<StudentUserController>();
        final student = studentController.current.value;
        studentName = student?.displayName ?? 'Unknown Student';
        studentEmail = student?.email ?? '';
      }

      // Create booking in bookings collection
      await _bookingService.createBooking(
        studentId: _studentId,
        interpreterId: interpreter.uid,
        dateTime: bookingDateTime,
        status: 'pending',
        studentName: studentName,
        studentEmail: studentEmail,
        interpreterName: interpreter.fullName,
        interpreterEmail: interpreter.email,
      );

      // Mark interpreter as booked locally
      bookedInterpreterIds.add(interpreter.uid);

      AppSnackbar.success(
        title: 'Booking Created',
        message:
            'Successfully booked ${interpreter.fullName} for ${_formatDateTime(bookingDateTime)}. Waiting for confirmation.',
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Booking Failed',
        message: 'Could not create booking: $e',
      );
      Get.log('Error booking interpreter: $e');
    } finally {
      _bookingInProgress.value = false;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (bookingDate == today) {
      dateStr = 'today';
    } else if (bookingDate == today.add(const Duration(days: 1))) {
      dateStr = 'tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr at $hour:$minute $period';
  }

  String _getStudentEmail() {
    // Try to get student email from StudentUserController
    if (Get.isRegistered<StudentUserController>()) {
      final studentController = Get.find<StudentUserController>();
      final currentStudent = studentController.current.value;
      if (currentStudent != null && currentStudent.email != null) {
        return currentStudent.email!;
      }
    }
    return 'student@example.com'; // Fallback
  }

  void viewMore(User interpreter) {
    selectedInterpreter.value = interpreter;
    isViewingDetails.value = true;
  }

  void goBackToList() {
    isViewingDetails.value = false;
    selectedInterpreter.value = null;
  }

  @override
  void onClose() {
    _sub?.cancel();
    searchController.dispose();
    subjectController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
