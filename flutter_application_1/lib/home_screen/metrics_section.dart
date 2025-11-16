import 'package:flutter/material.dart';

class MetricsSection extends StatelessWidget {
  const MetricsSection({super.key});

  Widget _buildMetricCard({
    required String imagePath, // صورة في حال توفرت
    required IconData fallbackIcon, // أيقونة احتياطية إذا الصورة لم تعمل
    required Color bgColor,
    required String title,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // صورة/أيقونة داخل دائرة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: ClipOval(
              child: SizedBox(
                width: 45,
                height: 45,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(fallbackIcon, size: 30, color: valueColor);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 8), // تم تقليل المسافة بين الصورة والنص
          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      unit,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 13,
                        color: valueColor.withOpacity(.7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // تمت إزالة السهم
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'أحدث المقاييس الحيوية',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          // ضغط الدم
          _buildMetricCard(
            imagePath: "assets/images/blood_pressure.png",
            fallbackIcon: Icons.monitor_heart,
            bgColor: const Color(0xffE0F2E9),
            title: 'ضغط الدم',
            value: '120/80',
            unit: 'mmHg',
            valueColor: Colors.green,
          ),
          const SizedBox(height: 15),

          // النبض
          _buildMetricCard(
            imagePath: "assets/images/heart_rate.png",
            fallbackIcon: Icons.favorite,
            bgColor: const Color(0xffffe6e6),
            title: 'معدل النبض',
            value: '105',
            unit: 'نبضة/د',
            valueColor: Colors.red,
          ),
          const SizedBox(height: 15),

          // السكر
          _buildMetricCard(
            imagePath: "assets/images/sugar.png",
            fallbackIcon: Icons.bloodtype,
            bgColor: const Color(0xfffff3d9),
            title: 'مستوى السكر',
            value: '130',
            unit: 'mg/dL',
            valueColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
