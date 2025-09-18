import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/interpreter_sessions.controller.dart';
import '../../../domain/sessions/session.model.dart';

class InterpreterSessionsScreen extends GetView<InterpreterSessionsController> {
  const InterpreterSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => InterpreterSessionsController());
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Sessions'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          onChanged: (v) => controller.searchQuery.value = v,
          decoration: const InputDecoration(
            hintText: 'Search sessions',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final items = controller.filtered;

        if (items.isEmpty) {
          return const Center(child: Text('No sessions found'));
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _buildCard(items[i]),
        );
      }),
    );
  }

  Widget _buildCard(SessionModel s) {
    final active = controller.isSessionActive(s);
    final statusColor = controller.getStatusColor(s.status);
    final statusBg = controller.getStatusBg(s.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Session with Student',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _row('Class', s.className),
          const SizedBox(height: 4),
          _row('Date',
              '${s.startTime.year}-${s.startTime.month.toString().padLeft(2, '0')}-${s.startTime.day.toString().padLeft(2, '0')}'),
          const SizedBox(height: 4),
          _row(
              'Time', TimeOfDay.fromDateTime(s.startTime).format(Get.context!)),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Status:',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF374151))),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(6)),
              child: Text(
                s.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildActions(s, active),
        ]),
      ),
    );
  }

  Widget _buildActions(SessionModel s, bool active) {
    if (s.status == 'Cancelled') {
      return const SizedBox.shrink();
    }
    if (s.status == 'Pending') {
      return Row(children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.confirmSession(s),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => controller.cancelSession(s),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9B197D),
              side: const BorderSide(color: Color(0xFF9B197D)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ]);
    }
    // Confirmed
    return Row(children: [
      Expanded(
        child: ElevatedButton(
          onPressed: active ? () => controller.joinVideoCall(s) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                active ? const Color(0xFF9B197D) : Colors.grey.shade300,
            foregroundColor: active ? Colors.white : Colors.grey.shade600,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Join Video Call',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton(
          onPressed: () => controller.cancelSession(s),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF9B197D),
            side: const BorderSide(color: Color(0xFF9B197D)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    ]);
  }

  Widget _row(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 60,
              child: Text('$label:',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                      fontSize: 14))),
          Expanded(
              child: Text(value,
                  style:
                      const TextStyle(color: Color(0xFF6B7280), fontSize: 14))),
        ],
      );
}
