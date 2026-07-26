import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

/// A Pathao/InDrive-style live view of employees currently on a task.
///
/// Used two ways:
///  - Admin Profile -> sees every active task in the system.
///  - A General User's own "Live Monitoring" -> sees only the tasks THEY
///    personally assigned to colleagues (assignedByFilter set to their name).
///
/// NOTE: there's no real GPS/location backend wired up yet — this shows a
/// stylized map background with pins for each employee currently "In
/// Progress" on a task, refreshed live from the shared TaskService. Wiring
/// this to real device location would need location permissions on the
/// employee's phone plus a server to relay coordinates.
class LiveMonitoringScreen extends StatefulWidget {
  final String? assignedByFilter;
  final String title;

  const LiveMonitoringScreen({
    super.key,
    this.assignedByFilter,
    this.title = "Live Monitoring",
  });

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  Task? selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        var active = TaskService.instance.tasks
            .where(
              (t) =>
                  t.status == TaskStatus.accepted ||
                  t.status == TaskStatus.busy,
            )
            .toList();

        if (widget.assignedByFilter != null) {
          active = active
              .where((t) => t.assignedBy == widget.assignedByFilter)
              .toList();
        }

        final current = (selected != null && active.contains(selected))
            ? selected
            : (active.isNotEmpty ? active.first : null);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(widget.title),
          ),
          body: Column(
            children: [
              // Stylized "map" area
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFDCEFE0),
                  child: Stack(
                    children: [
                      CustomPaint(size: Size.infinite, painter: _RoadPainter()),
                      if (active.isEmpty)
                        Center(
                          child: Text(
                            "No one is currently active on a task",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      else
                        ...List.generate(active.length, (i) {
                          final t = active[i];
                          final isSelected = t == current;
                          // pseudo-scatter pins based on index, so each has a stable spot
                          final left = 40.0 + (i * 67) % 240;
                          final top = 30.0 + (i * 53) % 180;
                          return Positioned(
                            left: left,
                            top: top,
                            child: GestureDetector(
                              onTap: () => setState(() => selected = t),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: isSelected
                                        ? AppColors.nepalRed
                                        : AppColors.primary,
                                    size: isSelected ? 40 : 32,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              // Bottom info card for the selected / current employee
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: current == null
                      ? Center(
                          child: Text(
                            "Live tracking will appear here once a task is in progress",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(.15),
                                  child: Text(current.employee.name[0]),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        current.employee.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        current.workType,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    current.status,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.room,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Room: ${current.employee.room}",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Last updated ${current.updatedAt.hour}:${current.updatedAt.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "● Live",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (active.length > 1) ...[
                              const SizedBox(height: 14),
                              Text(
                                "Tap a pin above to switch between ${active.length} active employees",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Simple road-like lines to suggest a map without needing real map tiles.
class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8;
    canvas.drawLine(
      Offset(0, size.height * .3),
      Offset(size.width, size.height * .35),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .2, 0),
      Offset(size.width * .35, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * .7),
      Offset(size.width, size.height * .65),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
