// lib/screens/permissions_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import '../home_screen/home_screen.dart';

class PermissionsManagementScreen extends StatefulWidget {
  const PermissionsManagementScreen({super.key});

  @override
  State<PermissionsManagementScreen> createState() =>
      _PermissionsManagementScreenState();
}

class _PermissionsManagementScreenState
    extends State<PermissionsManagementScreen> {
  bool _isAccessGranted = true;
  bool _isReadOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
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
                  width: 45,
                  height: 45,
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
        title: const Text(
          'إدارة الصلاحيات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    const _PermissionRequestCard(
                      name: 'جاد محمد عادل ريان',
                      isRequest: true,
                    ),
                    const _PermissionRequestCard(
                      name: 'سميرة سعيد عادل ريان',
                      isRequest: true,
                    ),
                    const _PermissionRequestCard(
                      name: 'فرح احمد محمد',
                      isRequest: false,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            // ===== شريط الوصول والإجراءات السفلي
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAccessSwitch(),
                  const SizedBox(height: 16),
                  _buildPermissionToggle(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: _isAccessGranted,
            onChanged: (newValue) {
              setState(() {
                _isAccessGranted = newValue;
              });
            },
            activeThumbColor: HomeScreen.primaryBlue,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
          const Text(
            'هل توافق على منح الوصول',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: _isReadOnly,
                onChanged: (newValue) {
                  setState(() {
                    _isReadOnly = newValue;
                  });
                },
                activeThumbColor: HomeScreen.primaryBlue,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
              const Text(
                'القراءة فقط',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: !_isReadOnly,
                onChanged: (newValue) {
                  setState(() {
                    _isReadOnly = !newValue;
                  });
                },
                activeThumbColor: HomeScreen.primaryBlue,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
              const Text(
                'التعديل والقراءة',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // زر الإلغاء على اليسار
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: HomeScreen.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: HomeScreen.primaryBlue, width: 2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HomeScreen.primaryBlue,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // زر الحفظ على اليمين
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الحفظ بنجاح!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeScreen.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'حفظ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PermissionRequestCard extends StatelessWidget {
  final String name;
  final bool isRequest;

  const _PermissionRequestCard({required this.name, required this.isRequest});

  @override
  Widget build(BuildContext context) {
    final cardColor = isRequest ? Colors.white : Colors.grey.shade100;
    final borderColor = isRequest ? Colors.grey.shade300 : Colors.grey.shade300;
    final textColor = isRequest ? Colors.black87 : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isRequest
            ? [
                BoxShadow(
                  color: Colors.grey.shade200,
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              isRequest
                  ? '$name يرغب في الحصول على حق الوصول إلى السجل الطبي الخاص بك'
                  : 'تمت الموافقة من $name رحب على طلبك بالحصول على حق الوصول لسجلها الطبي',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.arrow_back_ios_new,
            color: HomeScreen.primaryBlue,
            size: isRequest ? 16 : 0,
          ),
        ],
      ),
    );
  }
}
