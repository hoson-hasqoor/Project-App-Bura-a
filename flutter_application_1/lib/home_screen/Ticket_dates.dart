import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/Add_Ticket_Dates.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';

// تعريف الألوان
class AppColors {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightBlueCard = Color(0xFFC5E0F4);
  static const Color midBlueCard = Color(0xFF81A2BC);
  static const Color lightOrangeCard = Color(0xFFFFE0B2);
  static const Color lightRedCard = Color(0xFFFF9480);
  static const Color veryLightBlue = Color(0xFFE3F2FD);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color redAccent = Color(0xFFEF5350);
}

// ----------------------------------------------------------------------
// TicketDates (شاشة التذكيرات والمواعيد)
// ----------------------------------------------------------------------

class TicketDates extends StatefulWidget {
  const TicketDates({super.key});

  @override
  State<TicketDates> createState() => _TicketDatesState();
}

class _TicketDatesState extends State<TicketDates> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _remindersList = [];
  String? _lastProfileId;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for profile changes and refetch data
    final currentProfileId = context.watch<ProfileProvider>().selectedProfileId;
    if (currentProfileId != _lastProfileId) {
      _lastProfileId = currentProfileId;
      _fetchReminders();
    }
  }

  Future<void> _fetchReminders() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Get selected profile from ProfileProvider
    final profileProvider = context.read<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;

    // Build dynamic reference
    DocumentReference baseRef;
    if (selectedProfileId == null) {
      // Main user
      baseRef = _firestore.collection('users').doc(user.uid);
    } else {
      // Dependent
      baseRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId);
    }

    try {
      final snapshot = await baseRef
          .collection('appointments')
          .orderBy('date', descending: false)
          .get();

      final List<Map<String, dynamic>> loadedReminders = [];

      final List<Color> cardColors = [
        AppColors.lightBlueCard,
        AppColors.midBlueCard,
        AppColors.lightOrangeCard,
        AppColors.lightRedCard,
      ];

      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        DateTime date = DateTime.now();
        if (data['date'] != null && data['date'] is Timestamp) {
          date = (data['date'] as Timestamp).toDate();
        }

        // Formatting
        String timeStr = DateFormat('h:mm a').format(date);
        // Basic translation for AM/PM
        timeStr = timeStr.replaceAll('AM', 'صباحًا').replaceAll('PM', 'مساءً');

        String dayName = DateFormat(
          'E',
        ).format(date).toUpperCase(); // e.g., MON
        int dayNumber = date.day;

        loadedReminders.add({
          'title': data['title'] ?? 'موعد',
          'time': timeStr,
          'dayName': dayName,
          'dayNumber': dayNumber,
          'color': cardColors[i % cardColors.length],
          'data': data,
        });
      }

      if (mounted) {
        setState(() {
          _remindersList = loadedReminders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching appointments: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ويدجت لعرض زر تبويب الحسابات
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

  // ويدجت لبلاطة التذكير الفردية
  Widget _buildReminderTile({
    required String title,
    required String time,
    required String dayName,
    required int dayNumber,
    required BuildContext context,
    required Color color,
  }) {
    final borderColor = color.withOpacity(0.6);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              // العنوان والوقت مع أيقونة الجرس
              Expanded(
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.notifications_active,
                        color: AppColors.primaryBlue,
                        size: 28,
                      ),
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // بطاقة اليوم والتاريخ
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      dayNumber.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت زر الإضافة
  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTicketDates()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: const Text(
          'إضافة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // شريط التنقل السفلي
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.veryLightBlue.withOpacity(0.5),
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
          // زر الإشعارات
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

          // زر الرئيسية (Home)
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
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_filled,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),

          // زر القائمة (Menu)
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
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
        title: Text(
          'التذكيرات والمواعيد',
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
        ],
      ),
      body: Column(
        children: [
          _buildAccountTabs(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _remindersList.isEmpty
                ? const Center(child: Text("لا توجد مواعيد مسجلة"))
                : ListView.builder(
                    itemCount: _remindersList.length,
                    itemBuilder: (context, index) {
                      final reminder = _remindersList[index];
                      return _buildReminderTile(
                        title: reminder['title']!,
                        time: reminder['time']!,
                        dayName: reminder['dayName']!,
                        dayNumber: reminder['dayNumber'],
                        color: reminder['color']!,
                        context: context,
                      );
                    },
                  ),
          ),
          _buildAddButton(context),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }
}
