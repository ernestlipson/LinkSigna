import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/shared/components/app.button.dart';
import 'package:sign_language_app/shared/components/app.field.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentModalComponent {
  static void showPaymentModal(BuildContext context,
      {String? interpreterName,
      required double amountGhs,
      required String customerEmail}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentModalContent(
          interpreterName: interpreterName,
          amountGhs: amountGhs,
          customerEmail: customerEmail),
    );
  }
}

class _PaymentModalContent extends StatefulWidget {
  final String? interpreterName;
  final double amountGhs;
  final String customerEmail;
  const _PaymentModalContent(
      {this.interpreterName,
      required this.amountGhs,
      required this.customerEmail});

  @override
  State<_PaymentModalContent> createState() => _PaymentModalContentState();
}

class _PaymentModalContentState extends State<_PaymentModalContent> {
  late TextEditingController _momoController;
  String _selectedProvider = 'MTN';
  bool _processing = false;

  bool get _isValidMomo => _momoController.text.trim().length >= 10;

  Future<void> _confirmPayment() async {
    if (!_isValidMomo || _processing) return;
    final secretKey = dotenv.env['PAYSTACK_SECRET_KEY'];
    if (secretKey == null || secretKey.isEmpty) {
      Get.snackbar('Error', 'Missing Paystack secret key',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
      return;
    }
    setState(() => _processing = true);
    final reference = PayWithPayStack().generateUuidV4();
    final amountMinor = (widget.amountGhs * 100).round();
    try {
      PayWithPayStack().now(
        context: context,
        secretKey: secretKey,
        customerEmail: widget.customerEmail,
        reference: reference,
        currency: 'GHS',
        amount: amountMinor.toDouble(),
        callbackUrl: 'https://callback.example',
        transactionCompleted: (data) {
          Navigator.of(context).pop();
          Get.snackbar('Payment Successful', 'Reference: $reference',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green[100],
              colorText: Colors.green[900]);
        },
        transactionNotCompleted: (reason) {
          setState(() => _processing = false);
          Get.snackbar('Payment Failed', reason,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red[100],
              colorText: Colors.red[900]);
        },
      );
    } catch (e) {
      setState(() => _processing = false);
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]);
    }
  }

  @override
  void initState() {
    super.initState();
    _momoController = TextEditingController();
  }

  @override
  void dispose() {
    _momoController.dispose();
    super.dispose();
  }

  void _chooseProvider() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (ctx) {
        final providers = ['MTN', 'Telecel', 'AirtelTigo'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...providers.map((p) {
                  final isSelected = p == _selectedProvider;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedProvider = p);
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
                                borderRadius: const BorderRadius.only(
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
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset > 0 ? 12 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Confirm Your Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.interpreterName != null
                      ? 'Please enter your mobile money (Momo) details to confirm your booking with ${widget.interpreterName}.'
                      : 'Please enter your mobile money (Momo) details to confirm your booking.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  labelText: 'Network Provider',
                  hintText: 'Tap to select provider',
                  readOnly: true,
                  controller: TextEditingController(text: _selectedProvider),
                  suffix: const Icon(Icons.keyboard_arrow_down, size: 18),
                  onTap: _chooseProvider,
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  labelText: 'Momo Number',
                  hintText: 'Enter your momo number',
                  controller: _momoController,
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: _isValidMomo ? 1 : 0.5,
                  child: IgnorePointer(
                    ignoring: !_isValidMomo || _processing,
                    child: CustomButton(
                      text: _processing ? 'Processing...' : 'Confirm Payment',
                      color: AppColors.primary,
                      onPressed: _confirmPayment,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
