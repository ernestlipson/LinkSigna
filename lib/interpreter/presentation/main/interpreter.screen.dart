import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/theme/app_theme.dart';

import 'controllers/interpreter.controller.dart';

class InterpreterScreen extends GetView<InterpreterController> {
  const InterpreterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: UserController is managed globally by student section

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
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
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: ListView.builder(
                itemCount: controller.interpreters.length,
                itemBuilder: (context, index) {
                  final interpreter = controller.interpreters[index];
                  return _buildInterpreterCard(interpreter);
                },
              ),
            ),
          ],
        ),
      ),
      // Filter Modal
      bottomSheet: Obx(() => controller.isFilterModalOpen.value
          ? _buildFilterModal(context)
          : SizedBox.shrink()),
    );
  }

  Widget _buildInterpreterCard(InterpreterData interpreter) {
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Interpreter Available',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        interpreter.isFree ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interpreter.isFree ? 'Free' : 'Paid',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: interpreter.isFree
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Interpreter Profile
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(interpreter.profileImage),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interpreter.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Experience: ${interpreter.experience} years in Sign Language interpretation',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (!interpreter.isFree) ...[
                        SizedBox(height: 4),
                        Text(
                          'Price: GHS ${interpreter.price}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.bookInterpreter(interpreter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Book interpreter',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.viewMore(interpreter),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'View More',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterModal(BuildContext context) {
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

            // Subject Filter
            Text(
              'Subject',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller.subjectController,
              decoration: InputDecoration(
                hintText: 'Enter subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryColor),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                controller.selectedSubject.value = value;
              },
            ),
            SizedBox(height: 16),

            // Date Filter
            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Obx(() => GestureDetector(
                  onTap: () => controller.selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.selectedDate.value != null
                                ? '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}'
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 16,
                              color: controller.selectedDate.value != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        Icon(Icons.calendar_today, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 16),

            // Time Filter
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Obx(() => GestureDetector(
                  onTap: () => controller.selectTime(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.selectedTime.value != null
                                ? controller.selectedTime.value!.format(context)
                                : 'Select time',
                            style: TextStyle(
                              fontSize: 16,
                              color: controller.selectedTime.value != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        Icon(Icons.access_time, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: 16),

            // // Experience Filter
            // Text(
            //   'Experience',
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.grey[700],
            //   ),
            // ),
            // SizedBox(height: 8),
            // Obx(() => DropdownButtonFormField<String>(
            //       value: controller.selectedExperience.value.isEmpty
            //           ? null
            //           : controller.selectedExperience.value,
            //       decoration: InputDecoration(
            //         hintText: 'Select experience level',
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8),
            //           borderSide: BorderSide(color: Colors.grey[300]!),
            //         ),
            //         enabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8),
            //           borderSide: BorderSide(color: Colors.grey[300]!),
            //         ),
            //         focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8),
            //           borderSide: BorderSide(color: primaryColor),
            //         ),
            //         contentPadding:
            //             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //       ),
            //       items: [
            //         DropdownMenuItem(value: '1-2', child: Text('1-2 years')),
            //         DropdownMenuItem(value: '3-5', child: Text('3-5 years')),
            //         DropdownMenuItem(value: '5+', child: Text('5+ years')),
            //       ],
            //       onChanged: (value) {
            //         controller.selectedExperience.value = value ?? '';
            //       },
            //     )),
            // SizedBox(height: 16),

            // // Price Filter
            // Text(
            //   'Price',
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.grey[700],
            //   ),
            // ),
            // SizedBox(height: 8),
            // Obx(() => DropdownButtonFormField<String>(
            //       value: controller.selectedPrice.value.isEmpty
            //           ? null
            //           : controller.selectedPrice.value,
            //       decoration: InputDecoration(
            //         hintText: 'Select price range',
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8),
            //           borderSide: BorderSide(color: Colors.grey[300]!),
            //         ),
            //         enabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8),
            //           borderSide: BorderSide(color: Colors.grey[300]!),
            //         ),
            //         focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8),
            //           borderSide: BorderSide(color: primaryColor),
            //         ),
            //         contentPadding:
            //             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //       ),
            //       items: [
            //         DropdownMenuItem(value: 'free', child: Text('Free')),
            //         DropdownMenuItem(value: 'paid', child: Text('Paid')),
            //         DropdownMenuItem(value: '0-25', child: Text('GHS 0-25')),
            //         DropdownMenuItem(value: '25-50', child: Text('GHS 25-50')),
            //         DropdownMenuItem(value: '50+', child: Text('GHS 50+')),
            //       ],
            //       onChanged: (value) {
            //         controller.selectedPrice.value = value ?? '';
            //       },
            //     )),
            // SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.clearFilters(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.applyFilters(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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

// Data model for interpreter
class InterpreterData {
  final String name;
  final String profileImage;
  final int experience;
  final bool isFree;
  final int? price;

  InterpreterData({
    required this.name,
    required this.profileImage,
    required this.experience,
    required this.isFree,
    this.price,
  });
}
