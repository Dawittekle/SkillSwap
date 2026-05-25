import 'package:flutter/material.dart';

class HomeSummary {
  const HomeSummary({
    required this.studentName,
    required this.potentialSwapCount,
    required this.activeSwapCount,
    required this.completedSessionCount,
  });

  final String studentName;
  final int potentialSwapCount;
  final int activeSwapCount;
  final int completedSessionCount;
}

class UpcomingSession {
  const UpcomingSession({
    required this.id,
    required this.title,
    required this.partnerName,
    required this.skill,
    required this.dayLabel,
    required this.time,
    required this.location,
    required this.icon,
  });

  final String id;
  final String title;
  final String partnerName;
  final String skill;
  final String dayLabel;
  final String time;
  final String location;
  final IconData icon;
}

class RecentActivity {
  const RecentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
}

const mockHomeSummary = HomeSummary(
  studentName: 'Dawit',
  potentialSwapCount: 3,
  activeSwapCount: 2,
  completedSessionCount: 8,
);

const mockSkillCategories = [
  'Academic',
  'Tech',
  'Creative',
  'Language',
  'Music',
];

const mockUpcomingSession = UpcomingSession(
  id: 'session-guitar-abel',
  title: 'Guitar Lesson with Abel',
  partnerName: 'Abel Tesfaye',
  skill: 'Guitar Basics',
  dayLabel: 'Tomorrow',
  time: '4:00 PM',
  location: 'Online (Zoom)',
  icon: Icons.music_note,
);

const mockRecentActivities = [
  RecentActivity(
    id: 'activity-message-sarah',
    title: 'Sarah sent a message',
    subtitle: '2 hours ago',
    icon: Icons.chat_bubble_outline,
    tint: Color(0xFFE6F5F3),
  ),
  RecentActivity(
    id: 'activity-accepted-liam',
    title: 'Liam accepted your swap',
    subtitle: '5 hours ago',
    icon: Icons.handshake_outlined,
    tint: Color(0xFFFEF3C7),
  ),
  RecentActivity(
    id: 'activity-review-hana',
    title: 'Hana left a session review',
    subtitle: 'Yesterday',
    icon: Icons.star_border_rounded,
    tint: Color(0xFFEAF2FF),
  ),
];
