import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/infrastructure/dal/services/booking.firestore.service.dart';

class RatingBottomSheet extends StatefulWidget {
  final String bookingId;
  final String interpreterId;
  final String interpreterName;
  final VoidCallback? onComplete;

  const RatingBottomSheet({
    super.key,
    required this.bookingId,
    required this.interpreterId,
    required this.interpreterName,
    this.onComplete,
  });

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();

  /// Show the rating bottom sheet
  static void show({
    required String bookingId,
    required String interpreterId,
    required String interpreterName,
    VoidCallback? onComplete,
  }) {
    Get.bottomSheet(
      RatingBottomSheet(
        bookingId: bookingId,
        interpreterId: interpreterId,
        interpreterName: interpreterName,
        onComplete: onComplete,
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: false,
    );
  }
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Rate Your Session',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'How was your experience with ${widget.interpreterName}?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = starNumber;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    starNumber <= _selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    size: 48,
                    color: starNumber <= _selectedRating
                        ? Colors.amber
                        : Colors.grey[400],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              // Skip Button
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          Get.back();
                          widget.onComplete?.call();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Submit Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedRating == 0
                      ? null
                      : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final bookingService = Get.find<BookingFirestoreService>();

      // Submit rating to booking
      await bookingService.updateBookingRating(
        widget.bookingId,
        _selectedRating,
      );

      // Update interpreter's average rating
      await bookingService.updateInterpreterRating(
        widget.interpreterId,
        _selectedRating,
      );

      // Close the bottom sheet first
      Get.back();

      // Show success message after closing
      await Future.delayed(const Duration(milliseconds: 300));
      Get.snackbar(
        'Thank You!',
        'Your rating has been submitted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 2),
      );

      widget.onComplete?.call();
    } catch (e) {
      Get.log('Error submitting rating: $e');

      // Reset submitting state on error
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      Get.snackbar(
        'Error',
        'Failed to submit rating. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }
}
