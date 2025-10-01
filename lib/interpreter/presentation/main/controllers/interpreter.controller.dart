import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../shared/components/payment_modal.component.dart';
import '../interpreter.screen.dart';
import '../interpreter_profile.screen.dart';
import '../../components/payment_modal.component.dart';

class InterpreterController extends GetxController {
  final RxList<InterpreterData> interpreters = <InterpreterData>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    _loadInterpreters();
  }

  void _loadInterpreters() {
    // Mock data for interpreters
    interpreters.value = [
      InterpreterData(
        name: 'Arlene McCoy',
        email: 'arlene.mccoy@example.com',
        profileImage:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: true,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        email: 'arlene.mccoy@example.com',
        profileImage:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: false,
        price: 50,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        email: 'arlene.mccoy@example.com',
        profileImage:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: true,
      ),
      InterpreterData(
        name: 'Ama Buabeng',
        email: 'ama.buabeng@example.com',
        profileImage:
            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: true,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        email: 'arlene.mccoy@example.com',
        profileImage:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: true,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        email: 'arlene.mccoy@example.com',
        profileImage:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: false,
        price: 50,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        email: 'arlene.mccoy@example.com',
        profileImage:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: false,
        price: 50,
      ),
      InterpreterData(
        name: 'Millicent Boateng',
        email: 'millicent.boateng@example.com',
        profileImage:
            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: false,
        price: 50,
      ),
    ];
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

  void bookInterpreter(InterpreterData interpreter) {
    // Check if interpreter is free or paid
    if (interpreter.isFree) {
      // For free interpreters, directly book without payment
      Get.snackbar(
        'Success',
        'Free interpreter session booked successfully with ${interpreter.name}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } else {
      // For paid interpreters, show payment modal
      if (Get.context != null) {
        PaymentModalComponent.showPaymentModal(
          Get.context!,
          interpreterName: interpreter.name,
        );
      }
    }
  }

  void viewMore(InterpreterData interpreter) {
    Get.to(() => InterpreterProfileScreen(interpreter: interpreter));
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
    subjectController.dispose();
    super.onClose();
  }
}
