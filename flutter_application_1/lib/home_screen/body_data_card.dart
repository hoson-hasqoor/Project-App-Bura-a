import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'edit_body.dart';

class BodyDataCard extends StatelessWidget {
  const BodyDataCard({super.key});

  Widget _buildBodyData({
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Text(unit, style: const TextStyle(fontSize: 11, color: Colors.black45)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 50, color: Colors.grey.shade300);
  }

  Widget _bmiIndicator() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 140,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              width: 90,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _indicatorLabel("منخفض", Colors.blue.shade300),
            const SizedBox(width: 8),
            _indicatorLabel("متوسط", Colors.amber.shade500),
            const SizedBox(width: 8),
            _indicatorLabel("مرتفع", Colors.red.shade400),
          ],
        ),
      ],
    );
  }

  Widget _indicatorLabel(String text, Color color) {
    return Column(
      children: [
        CircleAvatar(radius: 8, backgroundColor: color),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(fontSize: 9)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14), // ← تقليل
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14), // ← تقليل مهم
        decoration: BoxDecoration(
          color: HomeScreen.veryLightBlue.withOpacity(.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.blue,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditBody()),
                  );
                },
              ),
            ),

            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      "assets/images/body.png",
                      width: 130, // ← أكبر ليملأ المساحة
                      height: 130,
                      fit: BoxFit.contain,
                    ),

                    _divider(),

                    _buildBodyData(
                      title: 'الطول',
                      value: '165',
                      unit: 'سم',
                      color: HomeScreen.primaryBlue,
                    ),

                    _divider(),

                    _buildBodyData(
                      title: 'الوزن',
                      value: '72',
                      unit: 'كجم',
                      color: HomeScreen.primaryBlue,
                    ),

                    _divider(),

                    _buildBodyData(
                      title: 'BMI',
                      value: '26.5',
                      unit: 'زيادة وزن',
                      color: Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 14), // ← تقليل كبير

                _bmiIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
