import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/Medical_test_record_display.dart';
import 'package:flutter_application_1/home_screen/Profile_Screen.dart';
import 'package:flutter_application_1/screens/health_data_screen.dart';
import 'package:flutter_application_1/home_screen/Ticket_dates.dart';
import 'package:flutter_application_1/screens/dependents_management_screen.dart';

import 'dart:math' as math;
import 'home_screen.dart';

class RadialMenuSection extends StatelessWidget {
  const RadialMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double radius = 140;
    final List<Map<String, dynamic>> services = [
      {
        'label': 'بياناتي',
        'icon': Icons.person_outline,
        'screen': ProfileScreen(),
      },
      {
        'label': 'مواعيد',
        'icon': Icons.calendar_today_outlined,
        'screen': TicketDates(),
      },
      {
        'label': 'السجل الصحي',
        'icon': Icons.history_edu_outlined,
        'screen': HealthDataScreen(),
      },
      {
        'label': 'المرافقين',
        'icon': Icons.family_restroom_outlined,
        'screen': DependentsManagementScreen(),
      },
      {
        'label': 'تحاليل',
        'icon': Icons.medical_information_outlined,
        'screen': MedicalTestRecordDisplay(),
      },
    ];

    final double stackSize = radius * 2 + 120;

    // حساب مواقع الأيقونات
    final List<Offset> iconCenters = services.asMap().entries.map((entry) {
      final int index = entry.key;
      final double angle =
          (2 * math.pi / services.length) * index - math.pi / 2;
      final double centerX = stackSize / 2;
      final double centerY = stackSize / 2;
      final double dx = radius * math.cos(angle);
      final double dy = radius * math.sin(angle);
      return Offset(centerX + dx, centerY + dy);
    }).toList();

    return Center(
      child: SizedBox(
        width: stackSize,
        height: stackSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // CustomPaint لرسم الخط المتصل بين جميع الأيقونات
            CustomPaint(
              size: Size(stackSize, stackSize),
              painter: FullConnectedLinesPainter(iconCenters: iconCenters),
            ),
            // الدائرة المركزية
            // الدائرة المركزية
            // الدائرة المركزية
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [HomeScreen.primaryBlue, HomeScreen.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: HomeScreen.primaryBlue.withOpacity(0.3),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'بٌرء',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 0.8,
                      ),
                    ),
                    SizedBox(height: 10), // ← هذه المسافة الجديدة بين النصوص
                    Text(
                      'نرعاك لتبقى بخير',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        height: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // الأيقونات حول الدائرة
            ...services.asMap().entries.map((entry) {
              final int index = entry.key;
              final service = entry.value;
              final double angle =
                  (2 * math.pi / services.length) * index - math.pi / 2;
              final double centerX = stackSize / 2;
              final double centerY = stackSize / 2;
              final double dx = radius * math.cos(angle);
              final double dy = radius * math.sin(angle);

              return Positioned(
                left: centerX + dx - 40,
                top: centerY + dy - 40,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => service['screen']),
                        );
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: HomeScreen.primaryBlue,
                        child: Icon(
                          service['icon'],
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    Text(
                      service['label'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// CustomPainter لرسم الخط المتصل بالكامل
class FullConnectedLinesPainter extends CustomPainter {
  final List<Offset> iconCenters;
  FullConnectedLinesPainter({required this.iconCenters});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (iconCenters.length < 2) return;

    // ترتيب الخط: تحاليل → بياناتي → مواعيد → السجل الصحي → المرافقين → تحاليل
    List<int> order = [4, 0, 1, 2, 3, 4];

    for (int i = 0; i < order.length - 1; i++) {
      canvas.drawLine(iconCenters[order[i]], iconCenters[order[i + 1]], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
