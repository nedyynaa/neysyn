import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        children: [
          const Text(
            'TODAY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            icon: Icons.science_outlined,
            title: "Daily Trivia: Did you know that the cornea is the only living tissue in the human body that has no blood vessels?",
            time: "2h ago",
            isUnread: true,
          ),
          _buildNotificationItem(
            icon: Icons.person_outline,
            title: "Jane clapped for your article 'Mythology in Endocrinology: The Adrenal Myth'",
            time: "5h ago",
            isUnread: false,
          ),
          const SizedBox(height: 24),
          const Text(
            'THIS WEEK',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            icon: Icons.person_add_outlined,
            title: "New follower: Dr. John registered as a clinical contributor from your region.",
            time: "3 days ago",
            isUnread: false,
          ),
          _buildNotificationItem(
            icon: Icons.favorite_border,
            title: "Your saved article 'The Heart Health Matrix' has received an updated study summary.",
            time: "5 days ago",
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[100],
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}