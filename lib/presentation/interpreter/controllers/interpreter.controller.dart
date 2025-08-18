import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../interpreter.screen.dart';
import '../interpreter_profile.screen.dart';

class InterpreterController extends GetxController {
  final RxList<InterpreterData> interpreters = <InterpreterData>[].obs;

  // Filter form controllers
  final searchController = TextEditingController();

  // Filter state
  final RxBool isFilterModalOpen = false.obs;
  final RxString selectedExperience = ''.obs;
  final RxString selectedPrice = ''.obs;
  final RxString selectedAvailability = ''.obs;

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
        profileImage:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: true,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        profileImage:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: false,
        price: 50,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        profileImage:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: true,
      ),
      InterpreterData(
        name: 'Ama Buabeng',
        profileImage:
            'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: true,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        profileImage:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: true,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        profileImage:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: false,
        price: 50,
      ),
      InterpreterData(
        name: 'Arlene McCoy',
        profileImage:
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        experience: 4,
        isFree: false,
        price: 50,
      ),
      InterpreterData(
        name: 'Millicent Boateng',
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

  void clearFilters() {
    selectedExperience.value = '';
    selectedPrice.value = '';
    selectedAvailability.value = '';
    searchController.clear();
  }

  void bookInterpreter(InterpreterData interpreter) {
    Get.to(() => InterpreterProfileScreen(interpreter: interpreter));
  }

  void viewMore(InterpreterData interpreter) {
    Get.snackbar(
      'View More',
      'Viewing details for: ${interpreter.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to interpreter details screen
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
