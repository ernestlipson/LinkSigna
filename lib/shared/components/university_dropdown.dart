import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../infrastructure/theme/app_theme.dart';

class UniversityDropdown extends StatelessWidget {
  final RxString selectedUniversity;
  final RxBool isUniversityValid;
  final List<String> universities;
  final Function(String) onUniversitySelected;
  final String placeholder;

  const UniversityDropdown({
    super.key,
    required this.selectedUniversity,
    required this.isUniversityValid,
    required this.universities,
    required this.onUniversitySelected,
    this.placeholder = 'Select your university',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'University ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              TextSpan(
                text: '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Obx(() => GestureDetector(
              onTap: () => _showUniversityBottomSheet(),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isUniversityValid.value
                        ? Colors.grey[300]!
                        : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedUniversity.value.isEmpty
                              ? placeholder
                              : selectedUniversity.value,
                          style: TextStyle(
                            color: selectedUniversity.value.isEmpty
                                ? Colors.grey[600]
                                : Colors.black,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  void _showUniversityBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select University',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ...universities.map((university) => Obx(
                  () => _buildUniversityListItem(university),
                )),
            SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildUniversityListItem(String university) {
    final isSelected = selectedUniversity.value == university;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFFFF0F5) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey[200]!,
          width: isSelected ? 1 : 0.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          university,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () {
          onUniversitySelected(university);
          Get.back();
        },
      ),
    );
  }
}
