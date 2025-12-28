import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/app_drawer.dart';
import '../home_screen/notifications_screen.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF004AAD); // Main Blue
  static const Color lightBlueCard = Color(0xFFC5E0F4); // Light Blue for cards
  static const Color midBlueCard = Color(0xFF81A2BC); // Mid/Dark Blue
  static const Color lightOrangeCard = Color(0xFFFFE0B2); // Light Orange
  static const Color lightRedCard = Color(0xFFFF9480); // Light Red
  static const Color veryLightBlue = Color(0xFFE3F2FD);
  static const Color lightGrey = Color(0xFFF5F5F5); // Extra background color
}

class MedicationsDisplayScreen extends StatefulWidget {
  const MedicationsDisplayScreen({super.key});

  @override
  State<MedicationsDisplayScreen> createState() =>
      _MedicationsDisplayScreenState();
}

class _MedicationsDisplayScreenState extends State<MedicationsDisplayScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _medicationsList = [];
  String? _lastProfileId;

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for profile changes and refetch data
    final currentProfileId = context.watch<ProfileProvider>().selectedProfileId;
    if (currentProfileId != _lastProfileId) {
      _lastProfileId = currentProfileId;
      _fetchMedications();
    }
  }

  Future<void> _fetchMedications() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Get selected profile from ProfileProvider
    final profileProvider = context.read<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;

    // CHECK READ PERMISSION
    if (!profileProvider.hasPermission('medications', 'read')) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    // Use getFirestorePath to support shared profiles
    final collectionPath = profileProvider.getFirestorePath(user.uid, 'medicines');

    try {
      final snapshot = await _firestore
          .collection(collectionPath)
          .orderBy('created_at', descending: true)
          .get();

      final List<Map<String, dynamic>> loadedMeds = [];

      // We'll cycle through colors for variety since we don't have categories defined for colors yet
      final List<Color> cardColors = [
        AppColors.lightBlueCard,
        AppColors.midBlueCard,
        AppColors.lightOrangeCard,
        AppColors.lightRedCard,
      ];

      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        loadedMeds.add({
          'name': data['medicine_name'] ?? 'دواء',
          'purpose': data['purpose'] ?? 'غير محدد',
          'dosage': data['dosage'] ?? '',
          'frequency': data['frequency'] ?? '',
          'color': cardColors[i % cardColors.length], // Cycle colors
          'data': data, // Keep raw data for details
        });
      }

      if (mounted) {
        setState(() {
          _medicationsList = loadedMeds;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching medications: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الأدوية: $e')));
      }
    }
  }

  Widget _buildTabButton(String title, {bool isSelected = false}) {
    final Color primaryColor = AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.lightBlueCard.withOpacity(0.5)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Profile tabs - using SharedProfileTabs widget
  Widget _buildAccountTabs() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: SharedProfileTabs(showTitle: false),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final Color primaryColor = AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن الأدوية التي تريدها',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.search, color: primaryColor),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),
            border: InputBorder.none,
            isDense: true,
          ),
          // Fix for TextDirection
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildMedicationTile({
    required String name,
    required String purpose,
    String? dosage,
    String? frequency,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Logic to show medication details could be added here
          _showMedicationDetails(context, name, purpose, dosage, frequency);
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Icon on the left
              Icon(Icons.medication, color: color, size: 28),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Name
                    Text(
                      name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Purpose
                    Text(
                      purpose,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (dosage != null && dosage.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'الجرعة: $dosage',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMedicationDetails(
    BuildContext context,
    String name,
    String purpose,
    String? dosage,
    String? frequency,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
                textAlign: TextAlign.right,
              ),
              const Divider(),
              const SizedBox(height: 10),
              _buildDetailItem('الغرض:', purpose),
              if (dosage != null && dosage.isNotEmpty)
                _buildDetailItem('الجرعة:', dosage),
              if (frequency != null && frequency.isNotEmpty)
                _buildDetailItem('التكرار:', frequency),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final Color primaryColor = AppColors.primaryBlue;
    final Color veryLightBlue = AppColors.veryLightBlue;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: veryLightBlue.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              size: 30,
              color: Colors.grey,
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_filled,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          // 3. Menu Button
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,

        // Center Title
        title: Text(
          'سجل الأدوية',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: HomeScreen.veryLightBlue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HomeScreen.primaryBlue, width: 1),
                  ),
                  child: const Text(
                    'Logo',
                    style: TextStyle(
                      fontSize: 10,
                      color: HomeScreen.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Actions: Back Button
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Account Tabs
                  _buildAccountTabs(),

                  // 2. Search Bar
                  _buildSearchBar(context),

                  // 3. Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.rtl, // RTL
                      children: [
                        const Text(
                          'الأدوية المسجلة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'عرض الكل',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _medicationsList.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "لا توجد أدوية مسجلة",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: _medicationsList
                              .map(
                                (medication) => _buildMedicationTile(
                                  name: medication['name']!,
                                  purpose: medication['purpose']!,
                                  dosage: medication['dosage'],
                                  frequency: medication['frequency'],
                                  color: medication['color']!,
                                  context: context,
                                ),
                              )
                              .toList(),
                        ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}
