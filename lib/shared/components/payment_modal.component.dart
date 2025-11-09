import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/shared/components/app.button.dart';
import 'package:sign_language_app/shared/components/app.field.dart';

class PaymentModalComponent {
  static void showPaymentModal(BuildContext context,
      {String? interpreterName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _buildPaymentModal(context, interpreterName: interpreterName),
    );
  }

  static Widget _buildPaymentModal(BuildContext context,
      {String? interpreterName}) {
    // Local state for form fields inside the bottom sheet
    String selectedProvider = 'MTN';
    final momoController = TextEditingController();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm Your Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                interpreterName != null
                    ? 'Please enter your mobile money (Momo) details to confirm your booking with $interpreterName.'
                    : 'Please enter your mobile money (Momo) details to confirm your booking.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),

              // Network Provider (Custom Field)
              CustomTextFormField(
                labelText: 'Network Provider',
                hintText: 'Tap to select provider',
                readOnly: true,
                controller: TextEditingController(text: selectedProvider),
                suffix: const Icon(Icons.keyboard_arrow_down, size: 18),
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (ctx) {
                      final providers = ['MTN', 'Telecel', 'AirtelTigo'];
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...providers.map((p) {
                                final isSelected = p == selectedProvider;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => selectedProvider = p);
                                    Navigator.pop(ctx);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.08)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        if (isSelected)
                                          Container(
                                            width: 14,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(28),
                                                bottomLeft: Radius.circular(28),
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: isSelected ? 18 : 14,
                                            ),
                                            child: Text(
                                              p,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 8),

              CustomTextFormField(
                labelText: 'Momo Number',
                hintText: 'Enter your momo number',
                controller: momoController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),

              CustomButton(
                text: 'Confirm Payment',
                color: AppColors.primary,
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.snackbar(
                    'Success',
                    'Payment confirmed successfully!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green[100],
                    colorText: Colors.green[900],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
