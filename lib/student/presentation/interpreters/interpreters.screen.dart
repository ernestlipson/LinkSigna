import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sign_language_app/infrastructure/theme/app_theme.dart';
import 'package:sign_language_app/domain/users/user.model.dart';
import 'package:sign_language_app/shared/components/app.button.dart';
import 'package:sign_language_app/shared/components/app.field.dart';
import 'controllers/interpreters.controller.dart';
import 'interpreter.viewmore.screen.dart';

class StudentBookInterpretersScreen extends StatelessWidget {
  const StudentBookInterpretersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterpretersController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Check if viewing details
        if (controller.isViewingDetails.value &&
            controller.selectedInterpreter.value != null) {
          return InterpreterViewMoreScreen(
            interpreter: controller.selectedInterpreter.value!,
            onBack: controller.goBackToList,
          );
        }

        // Otherwise show the main list view
        return _buildMainView(context, controller);
      }),
      // Filter Modal - only show when not viewing details
      bottomSheet: Obx(() => !controller.isViewingDetails.value &&
              controller.isFilterModalOpen.value
          ? _buildFilterModal(context, controller)
          : SizedBox.shrink()),
    );
  }

  Widget _buildMainView(
      BuildContext context, InterpretersController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search and Filter Section
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      controller.showFilterModal();
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_list, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text('Filter',
                              style: TextStyle(color: Colors.grey[600])),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Interpreter Cards List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.loadError.value != null) {
                return Center(child: Text(controller.loadError.value!));
              }
              final list = controller.filteredInterpreters;
              if (list.isEmpty) {
                return const Center(child: Text('No interpreters found'));
              }
              return ListView.builder(
                controller: controller.scrollController,
                itemCount: list.length + (controller.hasMoreData.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == list.length) {
                    // Loading indicator at the bottom
                    return Obx(() => controller.isLoadingMore.value
                        ? Container(
                            padding: EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox.shrink());
                  }
                  final interpreter = list[index];
                  return _buildInterpreterCard(interpreter, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInterpreterCard(
      User interpreter, InterpretersController controller) {
    // New model: isAvailable, languages, rating, experience, profileImage, name, email
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Text(
            (interpreter.isAvailable == true)
                ? 'Interpreter Available'
                : 'Not Available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ).paddingOnly(left: 12, right: 12),

          Divider(color: Colors.grey[300]),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: interpreter.avatarUrl != null &&
                        interpreter.avatarUrl!.isNotEmpty
                    ? NetworkImage(interpreter.avatarUrl!)
                    : null,
                backgroundColor: Colors.grey[200],
                child: interpreter.avatarUrl == null ||
                        interpreter.avatarUrl!.isEmpty
                    ? Icon(Icons.person, color: Colors.grey[400])
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          interpreter.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Pricing badge
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: interpreter.isFreeInterpreter
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            interpreter.isFreeInterpreter ? 'Free' : 'Paid',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: interpreter.isFreeInterpreter
                                  ? AppColors.freeColor
                                  : AppColors.paidColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      interpreter.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    if (interpreter.languages != null &&
                        interpreter.languages!.isNotEmpty)
                      Text(
                        'Languages: ${interpreter.languages!.join(", ")}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          (interpreter.rating ?? 0.0).toStringAsFixed(1),
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Experience: ${interpreter.years ?? 0} years',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    // Price display
                    if (!interpreter.isFreeInterpreter)
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Price: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextSpan(
                              text:
                                  'GH₵${interpreter.displayPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 18, vertical: 12),
          SizedBox(height: 4),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Builder(builder: (_) {
                  final booked = interpreter.isAvailable == false;
                  final isAvailable = interpreter.isAvailable == true;
                  final buttonText = booked
                      ? 'Booked'
                      : isAvailable
                          ? 'Book Interpreter'
                          : 'Unavailable';

                  return CustomButton(
                    text: buttonText,
                    onPressed: (booked || !isAvailable)
                        ? () {} // Disabled - does nothing
                        : () => controller.bookInterpreter(interpreter),
                    color: (booked || !isAvailable)
                        ? Colors.grey[400]
                        : AppColors.primary,
                  );
                }),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomOutlinedButton(
                  text: 'View More',
                  onPressed: () => controller.viewMore(interpreter),
                  borderColor: AppColors.primary,
                  textColor: AppColors.text,
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 18).paddingOnly(bottom: 20),
        ],
      ),
    );
  }

  Widget _buildFilterModal(
      BuildContext context, InterpretersController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Interpreters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => controller.closeFilterModal(),
                  icon: Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 20),

            CustomTextFormField(
              labelText: 'Subject',
              hintText: 'Enter subject',
              controller: controller.subjectController,
              onChanged: (value) => controller.selectedSubject.value = value,
            ),
            SizedBox(height: 16),

            Obx(() => CustomTextFormField(
                  labelText: 'Select Date',
                  hintText: 'Tap to choose date',
                  readOnly: true,
                  controller: TextEditingController(
                    text: controller.selectedDate.value == null
                        ? ''
                        : '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}',
                  ),
                  suffix: const Icon(Icons.calendar_today, size: 18),
                  onTap: () => controller.selectDate(context),
                )),
            SizedBox(height: 16),

            Obx(() => CustomTextFormField(
                  labelText: 'Select Time',
                  hintText: 'Tap to choose time',
                  readOnly: true,
                  controller: TextEditingController(
                    text: controller.selectedTime.value == null
                        ? ''
                        : controller.selectedTime.value!.format(context),
                  ),
                  suffix: const Icon(Icons.access_time, size: 18),
                  onTap: () => controller.selectTime(context),
                )),
            SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomOutlinedButton(
                    text: 'Clear All',
                    onPressed: () => controller.clearFilters(),
                    borderColor: Colors.grey[300],
                    textColor: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Apply Filters',
                    onPressed: () => controller.applyFilters(),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
