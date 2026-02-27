import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key, required this.userId});

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

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        // Avoid composite-index requirement by sorting locally.
        .limit(200);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
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
                  'Failed to load reviews.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final docs = (snapshot.data?.docs ?? const []).toList();
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

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No reviews yet.',
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
              final comment = data['comment']?.toString() ?? '';
              final ratingRaw = data['rating'];

              double? rating;
              if (ratingRaw is num) rating = ratingRaw.toDouble();
              if (ratingRaw is String) rating = double.tryParse(ratingRaw);

              DateTime? createdAt;
              final ts = data['createdAt'];
              if (ts is Timestamp) createdAt = ts.toDate();

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
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
                          if (rating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(
                                      rating == rating.roundToDouble() ? 0 : 1,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(createdAt),
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.85),
                          ),
                        ),
                      ],
                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          comment,
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.95),
                          ),
                        ),
                      ],
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
