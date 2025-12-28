import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import '../home_screen/home_screen.dart';

class PermissionsManagementScreen extends StatefulWidget {
  const PermissionsManagementScreen({super.key});

  @override
  State<PermissionsManagementScreen> createState() =>
      _PermissionsManagementScreenState();
}

class _PermissionsManagementScreenState
    extends State<PermissionsManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _requestsList = [];
  String? _selectedRequestId;
  String? _lastProfileId;

  // Granular Permissions State
  bool _currentAccessGranted = false;
  final Map<String, Map<String, bool>> _permissions = {
    'vital_signs': {'can_read': false, 'can_write': false},
    'medications': {'can_read': false, 'can_write': false},
    'medical_tests': {'can_read': false, 'can_write': false},
    'chronic_diseases': {'can_read': false, 'can_write': false},
    'allergies': {'can_read': false, 'can_write': false},
    'appointments': {'can_read': false, 'can_write': false},
    'surgeries': {'can_read': false, 'can_write': false},
    'hospital_stays': {'can_read': false, 'can_write': false},
    'vaccines': {'can_read': false, 'can_write': false},
    'family_history': {'can_read': false, 'can_write': false},
  };

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentProfileId = context.watch<ProfileProvider>().selectedProfileId;
    if (currentProfileId != _lastProfileId) {
      _lastProfileId = currentProfileId;
      _fetchPermissions();
    }
  }

  Future<void> _fetchPermissions() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;

    DocumentReference baseRef;
    if (selectedProfileId == null) {
      baseRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    } else {
      baseRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId);
    }

    try {
      final snapshot = await baseRef
          .collection('permissions')
          .orderBy('created_at', descending: true)
          .get();

      final List<Map<String, dynamic>> data = [];
      for (var doc in snapshot.docs) {
        var map = doc.data();
        map['id'] = doc.id;
        data.add(map);
      }

      if (mounted) {
        setState(() {
          _requestsList = data;
          _isLoading = false;
          if (_requestsList.isEmpty) {
            _selectedRequestId = null;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching permissions: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_selectedRequestId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profileProvider = context.read<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;

    DocumentReference baseRef;
    if (selectedProfileId == null) {
      baseRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    } else {
      baseRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId);
    }

    try {
      // 1. Update the permission request locally (Recipient's side)
      await baseRef.collection('permissions').doc(_selectedRequestId).update({
        'is_access_granted': _currentAccessGranted,
        'permissions': _permissions,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // 2. Reverse Linking: Update Requester's "shared_profiles"
      // Get request details specifically for the requester ID
      final requestDoc = await baseRef
          .collection('permissions')
          .doc(_selectedRequestId)
          .get();
      
      if (requestDoc.exists) {
        final data = requestDoc.data()!;
        final requesterId = data['requester_id'];
        
        if (requesterId != null) {
          final requesterRef = FirebaseFirestore.instance
              .collection('users')
              .doc(requesterId)
              .collection('shared_profiles')
              .doc(user.uid); // Use recipient's UID as doc ID

           if (_currentAccessGranted) {
             // Fetch current user's name to share
             final userDoc = await FirebaseFirestore.instance
                 .collection('users')
                 .doc(user.uid)
                 .get();
             final myName = userDoc.data()?['name'] ?? 'مستخدم';

             await requesterRef.set({
               'target_user_id': user.uid,
               'target_user_name': myName,
               'target_user_email': user.email ?? '',
               'access_granted': true,
               'shared_at': FieldValue.serverTimestamp(),
               // Store granular permissions copy for quick access check
               'permissions': _permissions,
             }, SetOptions(merge: true));
           } else {
             // If access revoked, remove or mark as disabled
             await requesterRef.delete();
           }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ الصلاحيات بنجاح',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
        ),
      );

      _fetchPermissions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطأ اثناء الحفظ: $e',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
  }

  Future<void> _simulateIncomingRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profileProvider = context.read<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;

    DocumentReference baseRef;
    if (selectedProfileId == null) {
      baseRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    } else {
      baseRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId);
    }

    // Default permissions structure
    Map<String, Map<String, bool>> defaultPermissions = {
      'vital_signs': {'can_read': false, 'can_write': false},
      'medications': {'can_read': false, 'can_write': false},
      'medical_tests': {'can_read': false, 'can_write': false},
      'chronic_diseases': {'can_read': false, 'can_write': false},
      'allergies': {'can_read': false, 'can_write': false},
      'appointments': {'can_read': false, 'can_write': false},
      'surgeries': {'can_read': false, 'can_write': false},
      'hospital_stays': {'can_read': false, 'can_write': false},
      'vaccines': {'can_read': false, 'can_write': false},
      'family_history': {'can_read': false, 'can_write': false},
    };

    await baseRef.collection('permissions').add({
      'requester_name': 'طبيب تجريبي ${DateTime.now().second}',
      'is_access_granted': false,
      'permissions': defaultPermissions,
      'created_at': FieldValue.serverTimestamp(),
    });

    _fetchPermissions();
  }

  void _onSelectRequest(Map<String, dynamic> request) {
    setState(() {
      _selectedRequestId = request['id'];
      _currentAccessGranted = request['is_access_granted'] ?? false;

      // Reset all permissions first
      _permissions.forEach((key, value) {
        _permissions[key] = {'can_read': false, 'can_write': false};
      });

      // Load granular permissions from Firestore
      if (request['permissions'] != null) {
        try {
          Map<String, dynamic> loadedPermissions = 
              Map<String, dynamic>.from(request['permissions']);
          
          loadedPermissions.forEach((key, value) {
            if (_permissions.containsKey(key) && value is Map) {
              _permissions[key] = {
                'can_read': value['can_read'] ?? false,
                'can_write': value['can_write'] ?? false,
              };
            }
          });
          
          debugPrint('Loaded permissions: $_permissions');
        } catch (e) {
          debugPrint('Error loading permissions: $e');
        }
      }
    });
  }

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
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
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
            // Profile tabs
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SharedProfileTabs(showTitle: false),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _requestsList.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "لا توجد طلبات صلاحيات حالياً\n\nعندما يطلب شخص ما الوصول إلى سجلك الطبي،\nستظهر الطلبات هنا",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _requestsList.length,
                      itemBuilder: (context, index) {
                        final req = _requestsList[index];
                        final isSelected = req['id'] == _selectedRequestId;
                        return GestureDetector(
                          onTap: () => _onSelectRequest(req),
                          child: _PermissionRequestCard(
                            name: req['requester_name'] ?? 'مستخدم',
                            email: req['requester_email'] ?? '',
                            timestamp: req['created_at'],
                            isAccessGranted: req['is_access_granted'] ?? false,
                            isSelected: isSelected,
                          ),
                        );
                      },
                    ),
            ),

            // Permission Controls
            if (_selectedRequestId != null)
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
                    Text(
                      "تعديل صلاحيات: ${_getRequestName(_selectedRequestId!)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: HomeScreen.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildAccessSwitch(),
                    const SizedBox(height: 16),
                    const Text(
                      'الصلاحيات التفصيلية:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: _buildGranularPermissions(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.grey.shade50,
                width: double.infinity,
                child: const Text(
                  "اختر مستخدماً من القائمة لتعديل صلاحياته",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getRequestName(String id) {
    final req = _requestsList.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {},
    );
    return req['requester_name'] ?? 'مستخدم';
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
            value: _currentAccessGranted,
            onChanged: (newValue) {
              setState(() {
                _currentAccessGranted = newValue;
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

  Widget _buildGranularPermissions() {
    final permissionLabels = {
      'vital_signs': 'العلامات الحيوية',
      'medications': 'الأدوية',
      'medical_tests': 'التحاليل والفحوصات',
      'chronic_diseases': 'الأمراض المزمنة',
      'allergies': 'الحساسية',
      'appointments': 'المواعيد',
      'surgeries': 'العمليات الجراحية',
      'hospital_stays': 'الدخول للمستشفى',
      'vaccines': 'المطاعيم',
      'family_history': 'التاريخ العائلي',
    };

    return Column(
      children: permissionLabels.entries.map((entry) {
        return _buildPermissionRow(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildPermissionRow(String permissionKey, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPermissionCheckbox(
                'القراءة',
                _permissions[permissionKey]!['can_read']!,
                (value) {
                  setState(() {
                    _permissions[permissionKey]!['can_read'] = value;
                  });
                },
              ),
              _buildPermissionCheckbox(
                'الكتابة',
                _permissions[permissionKey]!['can_write']!,
                (value) {
                  setState(() {
                    _permissions[permissionKey]!['can_write'] = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCheckbox(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (newValue) => onChanged(newValue ?? false),
          activeColor: HomeScreen.primaryBlue,
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() => _selectedRequestId = null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: HomeScreen.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                    color: HomeScreen.primaryBlue,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'إلغاء التحديد',
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeScreen.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'حفظ التغييرات',
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
  final String email;
  final dynamic timestamp;
  final bool isAccessGranted;
  final bool isSelected;

  const _PermissionRequestCard({
    required this.name,
    required this.email,
    required this.timestamp,
    required this.isAccessGranted,
    required this.isSelected,
  });

  String _formatTimestamp() {
    if (timestamp == null) return 'غير محدد';
    
    try {
      final DateTime dt = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'منذ ${difference.inMinutes} دقيقة';
        }
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} يوم';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (e) {
      return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isSelected ? HomeScreen.veryLightBlue : Colors.white;
    final borderColor = isSelected
        ? HomeScreen.primaryBlue
        : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isAccessGranted
                      ? "تم منح الوصول ✓"
                      : "بانتظار الموافقة",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isAccessGranted ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            isAccessGranted ? Icons.check_circle : Icons.pending_outlined,
            color: isAccessGranted ? Colors.green : Colors.orange,
            size: 28,
          ),
        ],
      ),
    );
  }
}
