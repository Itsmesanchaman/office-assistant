import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import 'activity_feed_screen.dart';
import 'notification_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationHomeScreen extends StatefulWidget {
  const NotificationHomeScreen({super.key});

  @override
  State<NotificationHomeScreen> createState() => _NotificationHomeScreenState();
}

class _NotificationHomeScreenState extends State<NotificationHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Opening this screen counts as the admin reviewing task updates.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TaskService.instance.markAllSeenByAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child:  TabBar(
              indicatorColor: Colors.blue,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'assigned_task'.tr()),
                Tab(text: 'activity_feed'.tr()),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [NotificationScreen(), ActivityFeedScreen()],
            ),
          ),
        ],
      ),
    );
  }
}
