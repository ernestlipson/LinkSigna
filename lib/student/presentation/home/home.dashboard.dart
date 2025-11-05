import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/controllers/user.controller.dart';
import '../interpreters/controllers/interpreters.controller.dart';
import '../interpreters/interpreter_profile.screen.dart';
import 'package:sign_language_app/shared/components/dashboard/dashboard_section.component.dart';
import 'package:sign_language_app/shared/components/dashboard/empty_state_box.component.dart';
import 'package:sign_language_app/shared/components/dashboard/session_card.component.dart';
import 'package:sign_language_app/infrastructure/dal/models/session.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final interpretersController = Get.put(InterpretersController());

    final upcomingSessions = [
      Session(
        id: 'up-1',
        studentName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionStatus.pending,
      ),
      Session(
        id: 'up-2',
        studentName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: DateTime(2025, 4, 15),
        time: '10:00 am',
        status: SessionStatus.confirmed,
      ),
    ];

    final historySessions = [
      Session(
        id: 'hist-1',
        studentName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: DateTime(2025, 3, 10),
        time: '09:00 am',
        status: SessionStatus.completed,
      ),
      Session(
        id: 'hist-2',
        studentName: 'Arlene McCoy',
        className: 'Communication Skills',
        date: DateTime(2025, 3, 02),
        time: '12:30 pm',
        status: SessionStatus.completed,
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome ${userController.displayName.value.isNotEmpty ? userController.displayName.value : "User"}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DashboardSection(
              title: 'Interpreters',
              onViewAll: () {},
              child: SizedBox(
                height: 140,
                child: Obx(() {
                  if (interpretersController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (interpretersController.loadError.value != null) {
                    return Center(
                      child: Text(interpretersController.loadError.value!),
                    );
                  }
                  final list = interpretersController.interpreters;
                  if (list.isEmpty) {
                    return const EmptyStateBox(message: 'No interpreters yet');
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length.clamp(0, 10),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final i = list[index];
                      return GestureDetector(
                        onTap: () => Get.to(
                            () => InterpreterProfileScreen(interpreter: i)),
                        child: Container(
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(i.profileImage),
                                backgroundColor: Colors.grey[200],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      i.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      i.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            DashboardSection(
              title: 'Upcoming Sessions',
              onViewAll: () {},
              child: SizedBox(
                height: 400,
                child: upcomingSessions.isEmpty
                    ? const EmptyStateBox(message: 'No upcoming sessions')
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: upcomingSessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final s = upcomingSessions[index];
                          final isPending = s.status == SessionStatus.pending;
                          return SessionCard(
                            session: s,
                            isUpcoming: true,
                            onJoin: isPending
                                ? null
                                : () => Get.snackbar('Video Call',
                                    'Joining video call with ${s.studentName}'),
                            onCancel: () => Get.snackbar('Cancel Session',
                                'Session with ${s.studentName} cancelled'),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 24),
            DashboardSection(
              title: 'History',
              onViewAll: () {},
              child: SizedBox(
                height: 320,
                child: historySessions.isEmpty
                    ? const EmptyStateBox(message: 'No past sessions')
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: historySessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final s = historySessions[index];
                          return SessionCard(
                            session: s,
                            isUpcoming: false,
                            onViewFeedback: () => Get.snackbar(
                              'Feedback',
                              'Viewing feedback for session with ${s.studentName}',
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
