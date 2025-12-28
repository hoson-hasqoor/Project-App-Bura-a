import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color lightBlueCard = Color(0xFFC5E0F4);
  static const Color midBlueCard = Color(0xFF81A2BC);
  static const Color lightOrangeCard = Color(0xFFFFE0B2);
  static const Color lightRedCard = Color(0xFFFF9480);
  static const Color veryLightBlue = Color(0xFFE3F2FD);
  static const Color lightGrey = Color(0xFFF5F5F5);
}

class MedicalTestRecordDisplay extends StatelessWidget {
  const MedicalTestRecordDisplay({super.key});

  final List<Map<String, dynamic>> _testsList = const [
    {'name': 'الدهون', 'date': '2022/09/09'},
    {'name': 'فيتامين د', 'date': '2022/09/09'},
    {'name': 'CBC', 'date': '2022/09/09'},
  ];

  //-------------------------  بطاقة التحليل -------------------------
  Widget _buildGridItem(String name, String date) {
    return Column(
      children: [
        Container(
          height: 90,
          width: 80,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description_outlined, size: 50),
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  //-------------------------  Bottom Navigation -------------------------
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 35),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F6FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ← مكان الإشعارات سابقاً — الآن القائمة
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu, size: 32, color: Colors.grey),
            ),
          ),

          // زر الصفحة الرئيسية
          const Icon(Icons.home, size: 32, color: Color(0xFF004AAD)),

          // ← مكان القائمة سابقاً — الآن الإشعارات
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
        ],
      ),
    );
  }

  //-------------------------  واجهة الصفحة -------------------------
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        endDrawer: const AppDrawer(),

        //-------------------------------- AppBar --------------------------------
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,

          title: const Text(
            'التحاليل الطبية',
            style: TextStyle(
              color: Color(0xFF004AAD),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          // back.png ← استبدال السهم
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('assets/images/back.png', width: 23),
          ),

          // الكاميرا يمين
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 3),
              child: Icon(
                Icons.camera_alt,
                color: Colors.grey,
                size: 32, // ← تم التكبير
              ),
            ),
          ],
        ),

        //-------------------------------- Body --------------------------------
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
                left: 20,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // أيقونة الفلتر

                  // النص في المنتصف
                  const Text(
                    "ابحث عن التحليل الذي تريده",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  // السهم يمين (مطابق للصورة)
                  const Icon(
                    Icons.filter_alt_outlined,
                    color: Color(0xFF004AAD),
                    size: 26,
                  ),
                ],
              ),
            ),

            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                children: _testsList
                    .map((t) => _buildGridItem(t['name'], t['date']))
                    .toList(),
              ),
            ),
          ],
        ),

        //------------------------------ Bottom Nav ------------------------------
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }
}
