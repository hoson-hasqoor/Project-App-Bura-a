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
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double radius = deviceWidth * 0.30; // ديناميكية التباعد حسب الشاشة
    final double centerCircle = deviceWidth * 0.33;

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

    final List<Offset> iconCenters = services.asMap().entries.map((entry) {
      final int index = entry.key;
      final double angle =
          (2 * math.pi / services.length) * index - math.pi / 2;
      final double centerX = stackSize / 2;
      final double centerY = stackSize / 2;
      return Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
    }).toList();

    return Center(
      child: SizedBox(
        width: stackSize,
        height: stackSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(stackSize, stackSize),
              painter: FullConnectedLinesPainter(iconCenters: iconCenters),
            ),

            // الدائرة المركزية
            Container(
              width: centerCircle,
              height: centerCircle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [HomeScreen.primaryBlue, HomeScreen.lightBlue],
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
                    SizedBox(height: 10),
                    Text(
                      'نرعاك لتبقى بخير',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // الأيقونات
            ...services.asMap().entries.map((entry) {
              final int index = entry.key;
              final double angle =
                  (2 * math.pi / services.length) * index - math.pi / 2;
              final double centerX = stackSize / 2;
              final double centerY = stackSize / 2;

              return Positioned(
                left: centerX + radius * math.cos(angle) - 35,
                top: centerY + radius * math.sin(angle) - 35,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => entry.value['screen'],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: HomeScreen.primaryBlue,
                        child: Icon(
                          entry.value['icon'],
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    Text(
                      entry.value['label'],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class FullConnectedLinesPainter extends CustomPainter {
  final List<Offset> iconCenters;
  FullConnectedLinesPainter({required this.iconCenters});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    List<int> order = [4, 0, 1, 2, 3, 4];
    for (int i = 0; i < order.length - 1; i++) {
      canvas.drawLine(iconCenters[order[i]], iconCenters[order[i + 1]], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
