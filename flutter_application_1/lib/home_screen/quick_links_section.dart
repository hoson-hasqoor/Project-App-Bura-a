// TODO Implement this library.
// lib/home_screen/quick_links_section.dart

import 'package:flutter/material.dart';
import 'home_screen.dart'; // لاستيراد الألوان

class QuickLinksSection extends StatelessWidget {
  const QuickLinksSection({super.key});

  Widget _buildTab({required String text, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? HomeScreen.lightBlue : HomeScreen.lightGrey,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isSelected ? HomeScreen.lightBlue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: HomeScreen.lightBlue.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (الكود الخاص بالقسم كما هو في الأصل)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 24, bottom: 12),
          child: Text(
            'حسابات إضافية وسجلات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildTab(text: 'حسابك الشخصي', isSelected: true),
              _buildTab(text: 'ملف العائلة'),
              _buildTab(text: 'التقارير الطبية'),
              _buildTab(text: 'المستشفيات'),
              _buildTab(text: 'الصحة العامة'),
            ],
          ),
        ),
      ],
    );
  }
}
