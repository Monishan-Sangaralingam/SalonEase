import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key, required this.userId});

  final String userId;

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

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        // Avoid composite-index requirement by sorting locally.
        .limit(200);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        backgroundColor: const Color(0xff721c80),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load booking history.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final docs = (snapshot.data?.docs ?? const []).toList();
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

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No bookings yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final workerName = data['workerName']?.toString() ?? 'Specialist';
              final timeSlot = data['timeSlot']?.toString() ?? '';
              final status = data['status']?.toString() ?? 'pending';
              final totalPrice = data['totalPrice'];

              DateTime? date;
              final rawDate = data['date'];
              if (rawDate is Timestamp) {
                date = rawDate.toDate();
              }

              String servicesText = '';
              final services = data['services'];
              if (services is Map) {
                final names = <String>[];
                for (final v in services.values) {
                  if (v is Map && v['name'] != null) {
                    names.add(v['name'].toString());
                  }
                }
                if (names.isNotEmpty) {
                  servicesText = names.join(', ');
                }
              }
              if (servicesText.isEmpty) {
                final serviceIds = data['serviceIds'];
                if (serviceIds is Iterable) {
                  servicesText = '${serviceIds.length} service(s)';
                }
              }

              final subtitleLines = <String>[];
              if (date != null) subtitleLines.add(_formatDate(date));
              if (timeSlot.isNotEmpty) subtitleLines.add(timeSlot);
              if (servicesText.isNotEmpty) subtitleLines.add(servicesText);

              final priceText = () {
                if (totalPrice is num) return '₹${totalPrice.toInt()}';
                if (totalPrice is String) return '₹$totalPrice';
                return '';
              }();

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    workerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      status,
                                    ).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _statusColor(
                                        status,
                                      ).withOpacity(0.35),
                                    ),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitleLines.join(' • '),
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.9),
                              ),
                            ),
                            if (priceText.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Total: $priceText',
                                style: const TextStyle(
                                  color: Color(0xff721c80),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
