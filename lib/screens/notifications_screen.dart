import 'package:flutter/material.dart';
import '../model/local_notification_services.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    // Load notifications if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.deepOrange,
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text('No Notifications Scheduled'),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(notification.title),
              subtitle: Text(notification.body),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Schedule a new notification
          DateTime scheduledTime = DateTime.now().add(const Duration(seconds: 10));
          LocalNotificationService.scheduleNotification(
            id: notifications.length + 1,
            scheduledTime: scheduledTime,
            title: 'Reminder',
            body: 'This is a test notification reminder.',
          );
          // Load notifications if needed
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Model class to represent a notification
class NotificationModel {
  final String title;
  final String body;

  NotificationModel({
    required this.title,
    required this.body,
  });
}
