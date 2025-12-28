import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_screen.dart';
import 'package:flutter_application_1/home_screen/Medical_test_record_display.dart';
import 'package:flutter_application_1/screens/medications_display_screen.dart';
import 'package:flutter_application_1/home_screen/Ticket_dates.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/health_data_screen.dart';
import 'home_screen.dart';
import '../screens/personal_data_screen.dart';
import '../screens/vital_data_screen.dart';
import '../screens/health_record_screen.dart';
import '../screens/dependents_management_screen.dart';
import '../screens/permissions_management_screen.dart';
import '../screens/settings_screen.dart';
import '../services/auth_service.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isLogout;
  final VoidCallback? onTap;

  const DrawerItem({
    super.key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = isLogout
        ? const Color(0xFF004AAD)
        : isSelected
        ? HomeScreen.primaryBlue
        : Colors.black87;

    final logoutBackgroundColor = isLogout && isSelected
        ? const Color(0xFF004AAD).withOpacity(0.1)
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected
              ? (isLogout
                    ? logoutBackgroundColor
                    : HomeScreen.veryLightBlue.withOpacity(0.5))
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        padding: const EdgeInsets.only(right: 20, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: itemColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: itemColor, size: 24),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'الصفحة الرئيسية',
      'icon': Icons.home_filled,
      'isLogout': false,
      'targetScreen': const HomeScreen(),
    },
    {
      'title': 'البيانات الشخصية',
      'icon': Icons.person_outline,
      'isLogout': false,
      'targetScreen': const PersonalDataScreen(),
    },
    {
      'title': 'البيانات الحيوية',
      'icon': Icons.monitor_heart_outlined,
      'isLogout': false,
      'targetScreen': const VitalDataScreen(),
    },
    {
      'title': 'البيانات الصحية',
      'icon': Icons.medical_information,
      'isLogout': false,
      'targetScreen': const HealthRecordScreen(),
    },
    {
      'title': 'السجل الصحي',
      'icon': Icons.medical_services_outlined,
      'isLogout': false,
      'targetScreen': const HealthDataScreen(),
    },
    {
      'title': 'عرض الأدوية ',
      'icon': Icons.poll_outlined,
      'isLogout': false,
      'targetScreen': const MedicationsDisplayScreen(),
    },
    {
      'title': 'عرض التحاليل الطبية',
      'icon': Icons.event_note_outlined,
      'isLogout': false,
      'targetScreen': const MedicalTestRecordDisplay(),
    },
    {
      'title': 'التذكيرات والمواعيد',
      'icon': Icons.calendar_today_outlined,
      'isLogout': false,
      'targetScreen': const TicketDates(),
    },
    {
      'title': 'إدارة المرافقين',
      'icon': Icons.people_outline,
      'isLogout': false,
      'targetScreen': const DependentsManagementScreen(),
    },
    {
      'title': 'إدارة الصلاحيات',
      'icon': Icons.admin_panel_settings_outlined,
      'isLogout': false,
      'targetScreen': const PermissionsManagementScreen(),
    },
    {
      'title': 'الإعدادات',
      'icon': Icons.settings_outlined,
      'isLogout': false,
      'targetScreen': const SettingsScreen(),
    },
    {
      'title': 'تسجيل الخروج',
      'icon': Icons.power_settings_new,
      'isLogout': true,
      'targetScreen': const LoginScreen(),
    },
  ];

  void _onItemTapped(int index) {
    Navigator.of(context).pop();

    final item = menuItems[index];
    final screen = item['targetScreen'];
    final isLogout = item['isLogout'] as bool;

    if (isLogout) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                // Sign out from Firebase Auth
                await FirebaseAuth.instance.signOut();
                // Clear saved login state
                await AuthService.clearLoginState();
                // Navigate to login screen
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Color(0xFF004AAD)),
              ),
            ),
          ],
        ),
      );
      return;
    }

    if (screen != null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => screen));
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final logoutItemIndex = menuItems.length - 1;
    final logoutItem = menuItems.last;
    final otherItems = menuItems.sublist(0, logoutItemIndex);

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.only(top: 40.0, right: 16.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 30,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        'assets/images/logo.png',
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: HomeScreen.veryLightBlue,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: HomeScreen.primaryBlue,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'شعار',
                              style: TextStyle(
                                fontSize: 14,
                                color: HomeScreen.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: otherItems.length,
              itemBuilder: (context, index) {
                final item = otherItems[index];
                return DrawerItem(
                  title: item['title'] as String,
                  icon: item['icon'] as IconData,
                  isSelected: index == _selectedIndex,
                  isLogout: false,
                  onTap: () => _onItemTapped(index),
                );
              },
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: DrawerItem(
              title: logoutItem['title'] as String,
              icon: logoutItem['icon'] as IconData,
              isSelected: logoutItemIndex == _selectedIndex,
              isLogout: true,
              onTap: () => _onItemTapped(logoutItemIndex),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
