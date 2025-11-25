import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/shared/components/dashboard/dashboard_section.component.dart';
import 'package:sign_language_app/shared/components/dashboard/empty_state_box.component.dart';
import 'package:sign_language_app/shared/components/session_card_detailed.component.dart';

import '../sessions/controllers/sessions.controller.dart';
import 'controllers/home.controller.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final sessionsController = Get.put(SessionsController());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  'Welcome ${homeController.userFirstName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                )),
            Text(
              'Here\'s what\'s happening with your interpreter sessions today.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            DashboardSection(
              title: 'Upcoming Sessions',
              onViewAll: () {
                homeController.changeTab(2);
              },
              child: SizedBox(
                height: 300,
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
                homeController.changeTab(3);
              },
              child: SizedBox(
                height: 300,
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
