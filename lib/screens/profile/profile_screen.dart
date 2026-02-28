import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salon_app/provider/user_provider.dart';
import 'package:salon_app/screens/profile/booking_history_screen.dart';
import 'package:salon_app/screens/profile/my_reviews_screen.dart';
import 'package:salon_app/screens/profile/settings_screen.dart';
import 'package:salon_app/utils/app_theme.dart';
import 'package:salon_app/widgets/horizontal_line.dart';

import '../../controller/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  // final User? user;
  const ProfileScreen({Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Widget _buildBookingsCard(BuildContext context, String userId) {
    final query = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        // Avoid composite-index requirement by sorting locally.
        .limit(200);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ProfileCard(
            title: 'My Bookings',
            subtitle: 'Failed to load booking history',
            trailing: const Icon(Icons.error_outline, color: Colors.redAccent),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookingHistoryScreen(userId: userId),
              ),
            ),
            child: const SizedBox.shrink(),
          );
        }

        if (!snapshot.hasData) {
          return _ProfileCard(
            title: 'My Bookings',
            subtitle: 'Loading…',
            trailing: const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookingHistoryScreen(userId: userId),
              ),
            ),
            child: const SizedBox.shrink(),
          );
        }

        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          DateTime? readDate(QueryDocumentSnapshot<Map<String, dynamic>> d) {
            final data = d.data();
            final rawDate = data['date'];
            if (rawDate is Timestamp) return rawDate.toDate();
            final createdAt = data['createdAt'];
            if (createdAt is Timestamp) return createdAt.toDate();
            return null;
          }

          final ad = readDate(a);
          final bd = readDate(b);
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });
        final count = docs.length;
        final preview = docs.take(3).toList();

        return _ProfileCard(
          title: 'My Bookings',
          subtitle: count == 0
              ? 'No bookings yet'
              : '$count booking${count == 1 ? '' : 's'}',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff721c80).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xff721c80).withOpacity(0.25),
              ),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Color(0xff721c80),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingHistoryScreen(userId: userId),
            ),
          ),
          child: Column(
            children: [
              if (count == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Book an appointment from Home to see it here.',
                    style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                  ),
                )
              else
                for (final d in preview)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _BookingPreviewRow(
                      workerName:
                          (d.data())['workerName']?.toString() ?? 'Specialist',
                      dateText: () {
                        final raw = (d.data())['date'];
                        if (raw is Timestamp) {
                          return _formatDate(raw.toDate());
                        }
                        return 'Date';
                      }(),
                      timeText: (d.data())['timeSlot']?.toString() ?? 'Time',
                      status: (d.data())['status']?.toString() ?? 'pending',
                      statusColor: _statusColor(
                        (d.data())['status']?.toString() ?? '',
                      ),
                    ),
                  ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: const Color(0xff721c80),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyReviewsCard(BuildContext context, String userId) {
    final query = FirebaseFirestore.instance
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        // Avoid composite-index requirement by sorting locally.
        .limit(200);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final onTap = () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MyReviewsScreen(userId: userId)),
        );

        if (snapshot.hasError) {
          return _ProfileCard(
            title: 'My Reviews',
            subtitle: 'Failed to load reviews',
            trailing: const Icon(Icons.error_outline, color: Colors.redAccent),
            onTap: onTap,
            child: const SizedBox.shrink(),
          );
        }

        if (!snapshot.hasData) {
          return _ProfileCard(
            title: 'My Reviews',
            subtitle: 'Loading…',
            trailing: const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            onTap: onTap,
            child: const SizedBox.shrink(),
          );
        }

        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          DateTime? readCreatedAt(
            QueryDocumentSnapshot<Map<String, dynamic>> d,
          ) {
            final ts = d.data()['createdAt'];
            if (ts is Timestamp) return ts.toDate();
            return null;
          }

          final ad = readCreatedAt(a);
          final bd = readCreatedAt(b);
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });
        final count = docs.length;
        final preview = docs.take(2).toList();

        return _ProfileCard(
          title: 'My Reviews',
          subtitle: count == 0
              ? 'No reviews yet'
              : '$count review${count == 1 ? '' : 's'}',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff721c80).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xff721c80).withOpacity(0.25),
              ),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Color(0xff721c80),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (count == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'After a visit, you can leave a review.',
                    style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                  ),
                )
              else
                for (final d in preview)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            (d.data())['workerName']?.toString() ??
                                'Specialist',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              () {
                                final r = (d.data())['rating'];
                                if (r is num) return r.toString();
                                if (r is String) return r;
                                return '-';
                              }(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: const Color(0xff721c80),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await Authentication.signOut(context: context);
    if (context.mounted) {
      Provider.of<UserProvider>(context, listen: false).setUser(null);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).getUser();
    final authUser = FirebaseAuth.instance.currentUser;

    //print(user);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My Profile",
                style: TextStyle(
                  color: Color(0xff721c80),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 12.0),
              const HorizontalLine(),
              const SizedBox(height: 20.0),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 35,
                    foregroundImage: (user?.photoURL == null)
                        ? null
                        : NetworkImage(user!.photoURL.toString()),
                    child: (user?.photoURL == null)
                        ? const Icon(Icons.person, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName?.toString() ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (authUser == null)
                Column(
                  children: [
                    const SectionCard(
                      header: 'Welcome to SalonEase',
                      desc: 'Sign in to manage your bookings and reviews.',
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              if (authUser == null)
                const SectionCard(
                  header: 'My bookings',
                  desc: 'Sign in to view your booking history.',
                )
              else
                _buildBookingsCard(context, authUser.uid),
              if (authUser == null)
                const SectionCard(
                  header: 'My reviews',
                  desc: 'Sign in to view your reviews.',
                )
              else
                _buildMyReviewsCard(context, authUser.uid),
              _ProfileCard(
                title: 'Settings',
                subtitle: 'Account & notifications',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: const SizedBox.shrink(),
              ),
              if (authUser != null)
                _ProfileCard(
                  title: 'Sign out',
                  subtitle: 'Log out of this account',
                  trailing: const Icon(Icons.logout),
                  onTap: () => _signOut(context),
                  child: const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String header;
  final String desc;
  const SectionCard({Key? key, required this.header, required this.desc})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            color: Color(0xff721c80),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(desc, style: TextStyle(color: Colors.grey.withOpacity(0.8))),
        const SizedBox(height: 12),
        const HorizontalLine(),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xff721c80),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                if (child is! SizedBox) ...[const SizedBox(height: 6), child],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingPreviewRow extends StatelessWidget {
  const _BookingPreviewRow({
    required this.workerName,
    required this.dateText,
    required this.timeText,
    required this.status,
    required this.statusColor,
  });

  final String workerName;
  final String dateText;
  final String timeText;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$dateText • $timeText',
                style: TextStyle(color: Colors.grey.withOpacity(0.85)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.35)),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
