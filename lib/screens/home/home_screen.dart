import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salon_app/components/searchbar.dart' as app_widgets;
import 'package:salon_app/screens/booking/booking_screen.dart';
import 'package:salon_app/screens/profile/profile_screen.dart';
import '../../components/carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userLocation = "Hapugala, Galle";
  String searchQuery = "";

  String? selectedServiceId;
  String? selectedServiceName;
  String? selectedWorkerId;

  _SpecialistSort specialistSort = _SpecialistSort.best;

  bool _isSeeding = false;

  Future<void> _refreshData() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  void _toggleServiceSelection({required String id, required String name}) {
    setState(() {
      if (selectedServiceId == id) {
        selectedServiceId = null;
        selectedServiceName = null;
      } else {
        selectedServiceId = id;
        selectedServiceName = name;
      }
      // If the currently selected worker no longer matches the filter, clear it.
      selectedWorkerId = null;
    });
  }

  void _clearFilters() {
    setState(() {
      searchQuery = '';
      selectedServiceId = null;
      selectedServiceName = null;
      selectedWorkerId = null;
      specialistSort = _SpecialistSort.best;
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _seedSampleData() async {
    if (_isSeeding) return;
    setState(() => _isSeeding = true);

    try {
      final firestore = FirebaseFirestore.instance;

      String _key(String? value) => (value ?? '').trim().toLowerCase();

      final desiredServices = <Map<String, dynamic>>[
        {
          'name': 'Hair Cut',
          'price': 250,
          'duration': 30,
          'description': 'Professional haircut tailored to your style.',
          'img':
              'https://images.unsplash.com/photo-1517832606294-7e0c60c7a8a4?auto=format&fit=crop&w=400&q=60',
        },
        {
          'name': 'Hair Color',
          'price': 900,
          'duration': 90,
          'description': 'Premium color using salon-grade products.',
          'img':
              'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=400&q=60',
        },
        {
          'name': 'Make Up',
          'price': 1200,
          'duration': 60,
          'description': 'Party / bridal makeup with a flawless finish.',
          'img':
              'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=400&q=60',
        },
        {
          'name': 'Nails',
          'price': 700,
          'duration': 45,
          'description': 'Manicure + nail shaping + polish.',
          'img':
              'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=400&q=60',
        },
        {
          'name': 'Skin Care',
          'price': 800,
          'duration': 50,
          'description': 'Facial + cleanse to refresh your skin.',
          'img':
              'https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?auto=format&fit=crop&w=400&q=60',
        },
        // Added services
        {
          'name': 'Beard Trim',
          'price': 200,
          'duration': 20,
          'description': 'Beard shaping + trim for a clean look.',
          'img':
              'https://images.unsplash.com/photo-1519724247339-6e0d0b8c1e9f?auto=format&fit=crop&w=400&q=60',
        },
        {
          'name': 'Keratin Treatment',
          'price': 2500,
          'duration': 120,
          'description': 'Smooth, frizz-free hair with keratin care.',
          'img':
              'https://images.unsplash.com/photo-1527799820374-44f2f0c7b5cf?auto=format&fit=crop&w=400&q=60',
        },
        {
          'name': 'Head Massage',
          'price': 500,
          'duration': 30,
          'description': 'Relaxing head + shoulder massage.',
          'img':
              'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=400&q=60',
        },
      ];

      final desiredWorkers = <Map<String, dynamic>>[
        {
          'name': 'Holland',
          'specialty': 'Hair Stylist',
          'img':
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=60',
          'serviceNames': ['Hair Cut', 'Keratin Treatment'],
          'totalBookings': 120,
        },
        {
          'name': 'Reyes',
          'specialty': 'Makeup Artist',
          'img':
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=60',
          'serviceNames': ['Make Up', 'Skin Care'],
          'totalBookings': 98,
        },
        {
          'name': 'Davis',
          'specialty': 'Skin Specialist',
          'img':
              'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=400&q=60',
          'serviceNames': ['Skin Care', 'Head Massage'],
          'totalBookings': 76,
        },
        // Added specialists
        {
          'name': 'Singh',
          'specialty': 'Nail Artist',
          'img':
              'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=60',
          'serviceNames': ['Nails', 'Skin Care'],
          'totalBookings': 64,
        },
        {
          'name': 'Patel',
          'specialty': 'Color Specialist',
          'img':
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=60',
          'serviceNames': ['Hair Color', 'Keratin Treatment'],
          'totalBookings': 89,
        },
        {
          'name': 'Fernando',
          'specialty': 'Barber & Grooming',
          'img':
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=60',
          'serviceNames': ['Beard Trim', 'Hair Cut'],
          'totalBookings': 71,
        },
      ];

      final batch = firestore.batch();
      int servicesAdded = 0;
      int specialistsAdded = 0;

      final existingServices = await firestore
          .collection('services')
          .limit(200)
          .get();
      final serviceNameToId = <String, String>{
        for (final d in existingServices.docs)
          _key((d.data())['name']?.toString()): d.id,
      }..removeWhere((k, v) => k.isEmpty);

      for (final s in desiredServices) {
        final nameKey = _key(s['name']?.toString());
        if (nameKey.isEmpty) continue;
        if (serviceNameToId.containsKey(nameKey)) continue;
        final ref = firestore.collection('services').doc();
        serviceNameToId[nameKey] = ref.id;
        batch.set(ref, {
          ...s,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        servicesAdded++;
      }

      final existingWorkers = await firestore
          .collection('workers')
          .limit(200)
          .get();
      final existingWorkerNames = <String>{
        for (final d in existingWorkers.docs)
          _key((d.data())['name']?.toString()),
      }..removeWhere((e) => e.isEmpty);

      for (final w in desiredWorkers) {
        final nameKey = _key(w['name']?.toString());
        if (nameKey.isEmpty) continue;
        if (existingWorkerNames.contains(nameKey)) continue;

        final serviceNames =
            (w['serviceNames'] as List?)
                ?.map((e) => _key(e.toString()))
                .where((e) => e.isNotEmpty)
                .toList() ??
            <String>[];
        final serviceIds = <String>[];
        for (final sn in serviceNames) {
          final id = serviceNameToId[sn];
          if (id != null) serviceIds.add(id);
        }

        final ref = firestore.collection('workers').doc();
        batch.set(ref, {
          'name': w['name'],
          'specialty': w['specialty'],
          'img': w['img'],
          'serviceIds': serviceIds,
          'totalBookings': w['totalBookings'] ?? 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        specialistsAdded++;
      }

      await batch.commit();
      _showSnack(
        'Demo data added (services: $servicesAdded, specialists: $specialistsAdded).',
      );
    } catch (e) {
      _showSnack('Failed to add sample data: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xff721c80),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Column(
                    children: [
                      _buildSectionHeader(
                        title: 'Best Services',
                        onViewAll: _showAllServicesSheet,
                      ),
                      _buildActiveFiltersRow(),
                      _buildServicesSection(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      _buildSectionHeader(
                        title: "Best Specialists",
                        onViewAll: _showAllSpecialistsSheet,
                      ),
                      const SizedBox(height: 18),
                      _buildSpecialistsSection(),
                    ],
                  ),
                ),
                _buildDivider(),
                _buildFooterActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff721c80), Color.fromARGB(255, 196, 103, 169)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 38, left: 18, right: 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showLocationPicker,
                          child: Text(
                            userLocation,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(
                          CupertinoIcons.person_alt_circle_fill,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'More',
                        icon: _isSeeding
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'seed') _seedSampleData();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'seed',
                            enabled: !_isSeeding,
                            child: Text(
                              _isSeeding
                                  ? 'Adding demo data…'
                                  : 'Add demo data',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  app_widgets.SearchBar(
                    onChanged: _onSearchChanged,
                    onSortTap: _showSortSheet,
                    onFilterTap: _showFilterSheet,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(top: 150, left: 0, right: 0, child: Carousel()),
      ],
    );
  }

  Widget _buildActiveFiltersRow() {
    if ((selectedServiceId == null || selectedServiceName == null) &&
        searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 6),
      child: Row(
        children: [
          if (selectedServiceId != null && selectedServiceName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xff721c80).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xff721c80).withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedServiceName!,
                    style: const TextStyle(
                      color: Color(0xff721c80),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() {
                      selectedServiceId = null;
                      selectedServiceName = null;
                      selectedWorkerId = null;
                    }),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xff721c80),
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          if (searchQuery.isNotEmpty)
            Text(
              'Searching…',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff721c80),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          if (onViewAll != null) ...[
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                "View all",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.double_arrow_rounded,
              color: Colors.grey,
              size: 18,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('services').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(
            message: 'Failed to load services',
            onRetry: () => setState(() {}),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildServicesLoadingSkeleton();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.category_outlined,
            message: 'No services available',
            actionLabel: _isSeeding ? 'Adding…' : 'Add sample data',
            onAction: _isSeeding ? null : _seedSampleData,
          );
        }

        final servicesAll = snapshot.data!.docs.where((doc) {
          if (searchQuery.isEmpty) return true;
          final name =
              (doc.data() as Map<String, dynamic>)['name']
                  ?.toString()
                  .toLowerCase() ??
              '';
          return name.contains(searchQuery);
        }).toList();

        if (servicesAll.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off,
            message: 'No services match your search',
          );
        }

        // Keep the home row compact.
        final services = servicesAll.take(8).toList();

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = services[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name']?.toString() ?? 'Service';

              return CategoryCard(
                e: doc,
                isSelected: selectedServiceId == doc.id,
                onTap: () => _toggleServiceSelection(id: doc.id, name: name),
                onLongPress: _showAllServicesSheet,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSpecialistsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('workers').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(
            message: 'Failed to load specialists',
            onRetry: () => setState(() {}),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSpecialistsLoadingSkeleton();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_outline,
            message: 'No specialists available',
            actionLabel: _isSeeding ? 'Adding…' : 'Add sample data',
            onAction: _isSeeding ? null : _seedSampleData,
          );
        }

        final workersFiltered = snapshot.data!.docs.where((doc) {
          if (searchQuery.isEmpty) return true;
          final name =
              (doc.data() as Map<String, dynamic>)['name']
                  ?.toString()
                  .toLowerCase() ??
              '';
          return name.contains(searchQuery);
        }).toList();

        final serviceId = selectedServiceId;
        final serviceName = selectedServiceName?.toLowerCase();

        final workers = workersFiltered.where((doc) {
          if (serviceId == null &&
              (serviceName == null || serviceName.isEmpty)) {
            return true;
          }
          final data = doc.data() as Map<String, dynamic>;
          final specialty = data['specialty']?.toString().toLowerCase() ?? '';
          final serviceIds = data['serviceIds'];
          final hasServiceId = serviceIds is Iterable
              ? serviceId != null &&
                    serviceIds.map((e) => e.toString()).contains(serviceId)
              : false;
          final matchesSpecialty =
              serviceName != null &&
              serviceName.isNotEmpty &&
              specialty.contains(serviceName);
          return hasServiceId || matchesSpecialty;
        }).toList();

        if (workers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off,
            message: 'No specialists match your search',
          );
        }

        // Sort for "best" on home.
        workers.sort((a, b) {
          final aMap = a.data() as Map<String, dynamic>;
          final bMap = b.data() as Map<String, dynamic>;
          if (specialistSort == _SpecialistSort.name) {
            final an = (aMap['name']?.toString() ?? '').toLowerCase();
            final bn = (bMap['name']?.toString() ?? '').toLowerCase();
            return an.compareTo(bn);
          }
          num aBookings = 0;
          num bBookings = 0;
          final av = aMap['totalBookings'];
          final bv = bMap['totalBookings'];
          if (av is num) aBookings = av;
          if (bv is num) bBookings = bv;
          return bBookings.compareTo(aBookings);
        });

        final topWorkers = workers.take(10).toList();

        return SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 18, right: 18),
            scrollDirection: Axis.horizontal,
            itemCount: topWorkers.length,
            itemBuilder: (BuildContext context, int index) {
              final workerDoc = topWorkers[index];
              final workerId = workerDoc.id;
              final data = workerDoc.data() as Map<String, dynamic>;
              final workerName = data['name']?.toString();
              final workerImg = data['img']?.toString();
              final specialty = data['specialty']?.toString();

              return _buildSpecialistCard(
                workerId: workerId,
                workerName: workerName,
                workerImg: workerImg,
                specialty: specialty,
                isSelected: selectedWorkerId == workerId,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSpecialistCard({
    required String workerId,
    String? workerName,
    String? workerImg,
    String? specialty,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: () {
        setState(() => selectedWorkerId = workerId);
        _showSpecialistPreview(
          workerId: workerId,
          workerName: workerName,
          workerImg: workerImg,
          specialty: specialty,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(right: 12.0),
        height: 160,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: isSelected ? 2.5 : 0,
            color: isSelected ? const Color(0xff721c80) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: workerImg != null
                  ? Image.network(
                      workerImg,
                      height: 160,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildImagePlaceholder();
                      },
                    )
                  : _buildImagePlaceholder(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      workerName ?? 'Specialist',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (specialty != null)
                      Text(
                        specialty,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xff721c80),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSpecialistPreview({
    required String workerId,
    String? workerName,
    String? workerImg,
    String? specialty,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: workerImg == null
                        ? null
                        : NetworkImage(workerImg),
                    backgroundColor: Colors.grey[200],
                    child: workerImg == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workerName ?? 'Specialist',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2d2a2a),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty ?? 'Specialist',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(this.context).push(
                      MaterialPageRoute(
                        builder: (_) => BookingScreen.fromWorker(
                          workerId,
                          workerName,
                          workerImg,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff721c80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.category_outlined),
                title: Text(
                  selectedServiceName == null
                      ? 'Service: All'
                      : 'Service: $selectedServiceName',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showAllServicesSheet();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear all filters'),
                onTap: () {
                  Navigator.pop(context);
                  _clearFilters();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort specialists by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star_outline),
                title: const Text('Best (most booked)'),
                trailing: specialistSort == _SpecialistSort.best
                    ? const Icon(Icons.check, color: Color(0xff721c80))
                    : null,
                onTap: () {
                  setState(() => specialistSort = _SpecialistSort.best);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Name'),
                trailing: specialistSort == _SpecialistSort.name
                    ? const Icon(Icons.check, color: Color(0xff721c80))
                    : null,
                onTap: () {
                  setState(() => specialistSort = _SpecialistSort.name);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllServicesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'All Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedServiceId = null;
                            selectedServiceName = null;
                            selectedWorkerId = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('services')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff721c80),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Failed to load services'),
                          );
                        }
                        final docs = snapshot.data?.docs ?? const [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No services'));
                        }
                        docs.sort((a, b) {
                          final an =
                              ((a.data() as Map<String, dynamic>)['name']
                                          ?.toString() ??
                                      '')
                                  .toLowerCase();
                          final bn =
                              ((b.data() as Map<String, dynamic>)['name']
                                          ?.toString() ??
                                      '')
                                  .toLowerCase();
                          return an.compareTo(bn);
                        });

                        return GridView.builder(
                          controller: controller,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name']?.toString() ?? 'Service';
                            final img = data['img']?.toString();
                            final selected = selectedServiceId == doc.id;

                            return GestureDetector(
                              onTap: () {
                                _toggleServiceSelection(id: doc.id, name: name);
                                Navigator.pop(context);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    height: 56,
                                    width: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(56),
                                      border: Border.all(
                                        width: selected ? 3 : 1,
                                        color: selected
                                            ? const Color(0xff721c80)
                                            : Colors.grey[300]!,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            selected ? 0.12 : 0.06,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(56),
                                      child: img == null
                                          ? const Icon(
                                              Icons.category,
                                              color: Colors.deepPurple,
                                            )
                                          : Image.network(
                                              img,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.category,
                                                    color: Colors.deepPurple,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: selected
                                          ? const Color(0xff721c80)
                                          : Colors.grey[700],
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAllSpecialistsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Specialists',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('workers')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff721c80),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Failed to load specialists'),
                          );
                        }
                        final docs = snapshot.data?.docs ?? const [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No specialists'));
                        }

                        final serviceId = selectedServiceId;
                        final serviceName = selectedServiceName?.toLowerCase();
                        final filtered = docs.where((doc) {
                          if (serviceId == null &&
                              (serviceName == null || serviceName.isEmpty)) {
                            return true;
                          }
                          final data = doc.data() as Map<String, dynamic>;
                          final specialty =
                              data['specialty']?.toString().toLowerCase() ?? '';
                          final serviceIds = data['serviceIds'];
                          final hasServiceId = serviceIds is Iterable
                              ? serviceId != null &&
                                    serviceIds
                                        .map((e) => e.toString())
                                        .contains(serviceId)
                              : false;
                          final matchesSpecialty =
                              serviceName != null &&
                              serviceName.isNotEmpty &&
                              specialty.contains(serviceName);
                          return hasServiceId || matchesSpecialty;
                        }).toList();

                        filtered.sort((a, b) {
                          final aMap = a.data() as Map<String, dynamic>;
                          final bMap = b.data() as Map<String, dynamic>;
                          if (specialistSort == _SpecialistSort.name) {
                            final an = (aMap['name']?.toString() ?? '')
                                .toLowerCase();
                            final bn = (bMap['name']?.toString() ?? '')
                                .toLowerCase();
                            return an.compareTo(bn);
                          }
                          num aBookings = 0;
                          num bBookings = 0;
                          final av = aMap['totalBookings'];
                          final bv = bMap['totalBookings'];
                          if (av is num) aBookings = av;
                          if (bv is num) bBookings = bv;
                          return bBookings.compareTo(aBookings);
                        });

                        return ListView.separated(
                          controller: controller,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final doc = filtered[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['name']?.toString();
                            final img = data['img']?.toString();
                            final specialty = data['specialty']?.toString();

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundImage: img == null
                                    ? null
                                    : NetworkImage(img),
                                backgroundColor: Colors.grey[200],
                                child: img == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                name ?? 'Specialist',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff2d2a2a),
                                ),
                              ),
                              subtitle: Text(specialty ?? ''),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() => selectedWorkerId = doc.id);
                                _showSpecialistPreview(
                                  workerId: doc.id,
                                  workerName: name,
                                  workerImg: img,
                                  specialty: specialty,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: 120,
      color: Colors.grey[200],
      child: const Icon(Icons.person_outline, size: 50, color: Colors.grey),
    );
  }

  Widget _buildServicesLoadingSkeleton() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (_, __) => _buildServiceSkeleton(),
      ),
    );
  }

  Widget _buildServiceSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 8),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          Container(
            height: 12,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistsLoadingSkeleton() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 18, right: 18),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(right: 12.0),
          height: 160,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 40),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff721c80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[400], size: 40),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey[600])),
            if (actionLabel != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(actionLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff721c80),
                    side: BorderSide(
                      color: const Color(0xff721c80).withOpacity(0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      height: 1,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 220, 218, 218),
            width: 0.9,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 18, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.language,
            label: 'Website',
            onTap: () {
              // Open website
            },
          ),
          _buildActionButton(
            icon: Icons.discount,
            label: 'Offers',
            onTap: () {
              // Navigate to offers
            },
          ),
          _buildActionButton(
            icon: Icons.phone_in_talk_sharp,
            label: 'Call',
            onTap: () {
              // Make phone call
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xff721c80)),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Hapugala, Galle'),
              onTap: () {
                setState(() => userLocation = 'Hapugala, Galle');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Colombo'),
              onTap: () {
                setState(() => userLocation = 'Colombo');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Kandy'),
              onTap: () {
                setState(() => userLocation = 'Kandy');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalText extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const HorizontalText({Key? key, required this.title, this.onViewAll})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff721c80),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onViewAll,
            child: const Text("View all", style: TextStyle(color: Colors.grey)),
          ),
          const Icon(Icons.double_arrow_rounded, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}

enum _SpecialistSort { best, name }

class CategoryCard extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> e;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const CategoryCard({
    Key? key,
    required this.e,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = e.data() as Map<String, dynamic>;
    final name = data['name']?.toString() ?? 'Service';
    final img = data['img']?.toString();

    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 18),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  width: isSelected ? 3 : 1,
                  color: isSelected
                      ? const Color(0xff721c80)
                      : Colors.grey.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.12 : 0.08),
                    blurRadius: 10.0,
                    spreadRadius: 0.2,
                    offset: const Offset(3.0, 3.0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: img != null
                    ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.category,
                          color: Colors.deepPurple,
                        ),
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xff721c80),
                            ),
                          );
                        },
                      )
                    : const Icon(Icons.category, color: Colors.deepPurple),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xff721c80)
                      : Colors.deepPurple,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
