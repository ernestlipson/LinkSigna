import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/controllers/student_user.controller.dart';
import '../sessions/controllers/sessions.controller.dart';
import 'controllers/home.controller.dart';
import 'package:sign_language_app/shared/components/dashboard/dashboard_section.component.dart';
import 'package:sign_language_app/shared/components/dashboard/empty_state_box.component.dart';
import 'package:sign_language_app/shared/components/session_card_detailed.component.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final studentUserController = Get.find<StudentUserController>();
    final sessionsController = Get.put(SessionsController());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final user = studentUserController.current.value;
              final userName = user?.fullName.isNotEmpty == true
                  ? user!.fullName
                  : user?.displayName ?? "User";

              return Text(
                'Welcome $userName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
            const SizedBox(height: 24),
            DashboardSection(
              title: 'Upcoming Sessions',
              onViewAll: () {
                final homeController = Get.find<HomeController>();
                homeController.changeTab(2); // Navigate to sessions page
              },
              child: SizedBox(
                height: 400,
                child: Obx(() {
                  final upcomingSessions = sessionsController.bookings
                      .where((booking) {
                        final status = booking['status'] as String? ?? '';
                        return status != 'completed' && status != 'cancelled';
                      })
                      .take(3)
                      .toList();

                  if (upcomingSessions.isEmpty) {
                    return const EmptyStateBox(message: 'No upcoming sessions');
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: upcomingSessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = upcomingSessions[index];
                      final isActive =
                          sessionsController.isSessionActive(booking);
                      final status = booking['status'] as String? ?? 'pending';
                      final statusColor =
                          sessionsController.getStatusColor(status);
                      final statusBgColor =
                          sessionsController.getStatusBackgroundColor(status);

                      return SessionCardDetailed(
                        booking: booking,
                        isActive: isActive,
                        status: status,
                        statusColor: statusColor,
                        statusBgColor: statusBgColor,
                        onJoinVideoCall: () =>
                            sessionsController.joinVideoCall(booking),
                        onCancelSession: () =>
                            sessionsController.cancelSession(booking),
                        isHistory: false,
                      );
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            DashboardSection(
              title: 'History',
              onViewAll: () {
                final homeController = Get.find<HomeController>();
                homeController.changeTab(3);
              },
              child: SizedBox(
                height: 320,
                child: Obx(() {
                  final historySessions = sessionsController.bookings
                      .where((booking) {
                        final status = booking['status'] as String? ?? '';
                        return status == 'completed';
                      })
                      .take(3)
                      .toList();

                  if (historySessions.isEmpty) {
                    return const EmptyStateBox(message: 'No past sessions');
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: historySessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = historySessions[index];
                      final status =
                          booking['status'] as String? ?? 'completed';
                      final statusColor =
                          sessionsController.getStatusColor(status);
                      final statusBgColor =
                          sessionsController.getStatusBackgroundColor(status);

                      return SessionCardDetailed(
                        booking: booking,
                        isActive: false,
                        status: status,
                        statusColor: statusColor,
                        statusBgColor: statusBgColor,
                        onViewFeedback: () {
                          // TODO: Navigate to feedback screen
                          Get.snackbar(
                            'Feedback',
                            'Viewing feedback for session with ${booking['interpreterName']}',
                          );
                        },
                        isHistory: true,
                      );
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
