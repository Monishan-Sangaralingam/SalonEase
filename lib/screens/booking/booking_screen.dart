import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salon_app/components/date_piceker.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    this.workerId,
    this.workerName,
    this.workerImg,
  });

  const BookingScreen.fromWorker(
    this.workerId,
    this.workerName,
    this.workerImg, {
    super.key,
  });

  final String? workerId;
  final String? workerName;
  final String? workerImg;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  final Set<String> selectedServiceIds = <String>{};
  bool isSubmitting = false;
  Map<String, dynamic> selectedServices = {};

  static const List<String> timeSlots = <String>[
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _submitBooking({required int totalPrice}) async {
    final workerId = widget.workerId;

    // Validation
    if (workerId == null || workerId.isEmpty) {
      _showSnackBar('Please select a specialist first.', isError: true);
      return;
    }
    if (selectedTime == null) {
      _showSnackBar('Please select a time slot.', isError: true);
      return;
    }
    if (selectedServiceIds.isEmpty) {
      _showSnackBar('Please select at least one service.', isError: true);
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showBookingConfirmation(totalPrice);
    if (!confirmed) return;

    setState(() => isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Please login to book an appointment.', isError: true);
        return;
      }

      final dateKey = _dateKey(selectedDate);

      // Use Firestore transaction for atomic booking
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Check if slot is still available
        final bookingQuery = await FirebaseFirestore.instance
            .collection('bookings')
            .where('workerId', isEqualTo: workerId)
            .where('dateKey', isEqualTo: dateKey)
            .where('timeSlot', isEqualTo: selectedTime)
            .limit(1)
            .get();

        if (bookingQuery.docs.isNotEmpty) {
          throw Exception(
            'This time slot has just been booked by someone else.',
          );
        }

        // Create the booking
        final bookingRef = FirebaseFirestore.instance
            .collection('bookings')
            .doc();
        transaction.set(bookingRef, {
          'workerId': workerId,
          'workerName': widget.workerName,
          'workerImg': widget.workerImg,
          'userId': user.uid,
          'userEmail': user.email,
          'dateKey': dateKey,
          'date': Timestamp.fromDate(
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
          ),
          'timeSlot': selectedTime,
          'serviceIds': selectedServiceIds.toList(),
          'services': selectedServices,
          'totalPrice': totalPrice,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Optional: Update worker's booking count
        final workerRef = FirebaseFirestore.instance
            .collection('workers')
            .doc(workerId);
        transaction.update(workerRef, {
          'totalBookings': FieldValue.increment(1),
        });
      });

      if (!mounted) return;

      _showSnackBar('Appointment booked successfully! ✓', isError: false);

      // Optional: Send notification
      // await _sendBookingNotification();

      // Navigate back after short delay
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    } catch (e) {
      _showSnackBar('Booking failed. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<bool> _showBookingConfirmation(int totalPrice) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Confirm Booking',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfirmRow('Specialist', widget.workerName ?? 'N/A'),
                _buildConfirmRow('Date', _formatDate(selectedDate)),
                _buildConfirmRow('Time', selectedTime ?? 'N/A'),
                _buildConfirmRow(
                  'Services',
                  '${selectedServiceIds.length} selected',
                ),
                const Divider(height: 24),
                _buildConfirmRow('Total', '₹$totalPrice', isBold: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, size: 20, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please arrive 10 minutes early',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff721c80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildConfirmRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
              color: isBold ? const Color(0xff721c80) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (service['img'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service['img'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  service['name'] ?? 'Service',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${service['price']}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xff721c80),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (service['description'] != null) ...[
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service['description'],
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ],
                if (service['duration'] != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 8),
                      Text('Duration: ${service['duration']} minutes'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff721c80), Color.fromARGB(255, 196, 103, 169)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff721c80),
                    Color.fromARGB(255, 196, 103, 169),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 18,
                  right: 18,
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Book Your Appointment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomDatePicker(
                      initialDate: selectedDate,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                          selectedTime = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.workerName != null || widget.workerImg != null)
                    _buildWorkerCard()
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No specialist selected',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Go to the Home screen and tap on a specialist to book with them.',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "Available Slots",
                    style: TextStyle(
                      color: Color.fromARGB(255, 45, 42, 42),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildTimeSlots(),
                  const SizedBox(height: 24),
                  const Text(
                    "Select Services",
                    style: TextStyle(
                      color: Color.fromARGB(255, 45, 42, 42),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildServicesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: (widget.workerImg == null)
                ? null
                : NetworkImage(widget.workerImg!),
            backgroundColor: Colors.grey[200],
            child: widget.workerImg == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.workerName ?? 'Specialist',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2d2a2a),
                  ),
                ),
                const SizedBox(height: 4),
                // Dynamic rating from Firestore
                widget.workerId != null
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reviews')
                            .where('workerId', isEqualTo: widget.workerId)
                            .limit(200)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Row(
                              children: const [
                                Icon(
                                  Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'No reviews yet',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          }
                          final docs = snapshot.data!.docs;
                          double total = 0;
                          int count = 0;
                          for (final doc in docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final r = data['rating'];
                            if (r is num) {
                              total += r.toDouble();
                              count++;
                            }
                          }
                          final avg = count > 0 ? (total / count) : 0.0;
                          return Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${avg.toStringAsFixed(1)} ($count review${count == 1 ? '' : 's'})',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : Row(
                        children: const [
                          Icon(
                            Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'No reviews yet',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          if (widget.workerId == null)
            const Icon(Icons.error_outline, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    final workerId = widget.workerId;

    return StreamBuilder<QuerySnapshot>(
      stream: (workerId == null)
          ? null
          : FirebaseFirestore.instance
                .collection('bookings')
                .where('workerId', isEqualTo: workerId)
                .where('dateKey', isEqualTo: _dateKey(selectedDate))
                .snapshots(),
      builder: (context, snapshot) {
        final booked = <String>{};
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final map = doc.data() as Map<String, dynamic>;
            final t = map['timeSlot']?.toString();
            if (t != null && t.isNotEmpty) booked.add(t);
          }
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final slot in timeSlots)
              ChoiceChip(
                label: Text(slot),
                selected: selectedTime == slot,
                onSelected: (workerId == null || booked.contains(slot))
                    ? null
                    : (selected) {
                        setState(() {
                          selectedTime = selected ? slot : null;
                        });
                      },
                selectedColor: const Color(0xff721c80),
                labelStyle: TextStyle(
                  color: (selectedTime == slot)
                      ? Colors.white
                      : booked.contains(slot)
                      ? Colors.grey
                      : const Color(0xff2d2a2a),
                  fontWeight: selectedTime == slot
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                disabledColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: selectedTime == slot
                        ? const Color(0xff721c80)
                        : Colors.grey[300]!,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildServicesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('services').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load services',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No services available.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // Calculate total price
        int totalPrice = 0;
        selectedServices.clear();

        for (final doc in docs) {
          if (!selectedServiceIds.contains(doc.id)) continue;
          final data = doc.data() as Map<String, dynamic>;
          selectedServices[doc.id] = data;

          final price = data['price'];
          if (price is int) totalPrice += price;
          if (price is num) totalPrice += price.toInt();
          if (price is String) {
            totalPrice += int.tryParse(price) ?? 0;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString() ?? '';
                  final img = data['img']?.toString() ?? '';
                  final priceText = data['price']?.toString() ?? '';
                  final selected = selectedServiceIds.contains(doc.id);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          selectedServiceIds.remove(doc.id);
                        } else {
                          selectedServiceIds.add(doc.id);
                        }
                      });
                    },
                    onLongPress: () => _showServiceDetails(data),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12.0),
                      height: 130,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: selected ? 3 : 1,
                          color: selected
                              ? const Color(0xff721c80)
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xff721c80,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                                child: Image.network(
                                  img,
                                  height: 70,
                                  width: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 70,
                                    width: 110,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.spa),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Color(0xff721c80),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹$priceText',
                                        style: const TextStyle(
                                          color: Color(0xff721c80),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (selected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xff721c80),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services: ${selectedServiceIds.length}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: ₹$totalPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff721c80),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () => _submitBooking(totalPrice: totalPrice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff721c80),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Book Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
