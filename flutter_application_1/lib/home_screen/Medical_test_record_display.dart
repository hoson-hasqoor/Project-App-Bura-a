import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // لفتح روابط الـ PDF
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import '../home_screen/app_drawer.dart';
import '../home_screen/notifications_screen.dart';

class MedicalTestRecordDisplay extends StatefulWidget {
  const MedicalTestRecordDisplay({super.key});

  @override
  State<MedicalTestRecordDisplay> createState() =>
      _MedicalTestRecordDisplayState();
}

class _MedicalTestRecordDisplayState extends State<MedicalTestRecordDisplay> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _testsList = [];
  List<Map<String, dynamic>> _filteredTestsList = [];
  String? _lastProfileId;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _selectedDate;

  // يحاول تحويل نص المدخل إلى تاريخ بمختلف التنسيقات الشائعة
  DateTime? _parseDateFromString(String input) {
    final s = input.trim();
    if (s.isEmpty) return null;
    // جرب صيغة ISO أولاً
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    // استبدال فواصل شائعة
    final normalized = s.replaceAll('-', '/').replaceAll('.', '/');
    final parts = normalized.split('/');
    if (parts.length != 3) return null;
    final p0 = int.tryParse(parts[0]);
    final p1 = int.tryParse(parts[1]);
    final p2 = int.tryParse(parts[2]);
    if (p0 == null || p1 == null || p2 == null) return null;

    // توقعات: yyyy/MM/dd أو dd/MM/yyyy أو dd/MM/yy
    if (p0 > 31) {
      try {
        return DateTime(p0, p1, p2);
      } catch (_) {}
    }
    if (p2 > 31) {
      try {
        return DateTime(p2, p0, p1);
      } catch (_) {}
    }
    if (p2 >= 0 && p2 < 100) {
      final year = (p2 >= 50) ? 1900 + p2 : 2000 + p2;
      try {
        return DateTime(year, p0, p1);
      } catch (_) {}
    }
    return null;
  }

  // فتح رابط PDF خارجي
  Future<void> _openPdf(String? url) async {
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      // عرض مربع حوار يوضح أن الرابط غير موجود ويعرض بعض بيانات السجل للمساعدة في التصحيح
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('لا يوجد ملف مرفق'),
            content: const Text(
              'هذا السجل لا يحتوي على رابط ملف. هل تريد عرض بيانات السجل للتدقيق؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إغلاق'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // اطبع رسالة في الكونصول لمساعدة المطور
                  debugPrint('Open PDF failed: empty url for record.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الرابط غير موجود في هذا السجل'),
                    ),
                  );
                },
                child: const Text('تفاصيل'),
              ),
            ],
          );
        },
      );
      return;
    }
    final raw = url.trim();
    Uri? uri;
    try {
      uri = Uri.tryParse(raw);
      if (uri == null || uri.scheme.isEmpty) {
        // حاول إضافة https:// إذا لم توجد بروتوكول
        uri = Uri.tryParse('https://$raw');
      }
    } catch (_) {
      uri = null;
    }

    if (uri == null) {
      // جرب تحويل مسارات أو روابط Firebase Storage إلى رابط تحميل
      try {
        if (raw.startsWith('gs://')) {
          final download = await FirebaseStorage.instance
              .refFromURL(raw)
              .getDownloadURL();
          uri = Uri.tryParse(download);
        } else if (!raw.startsWith('http')) {
          // raw قد يكون مساراً داخل الـ bucket مثل 'users/uid/lab_xray/file.jpg'
          try {
            final download = await FirebaseStorage.instance
                .ref(raw)
                .getDownloadURL();
            uri = Uri.tryParse(download);
          } catch (_) {
            // لا شيء
          }
        }
      } catch (_) {}

      if (uri == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('رابط غير صالح: $raw')));
        return;
      }
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // انسخ الرابط للحافظة لتسهيل المحاولة اليدوية
        await Clipboard.setData(ClipboardData(text: uri.toString()));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح الرابط. تم نسخ الرابط للحافظة: ${uri.toString()}',
            ),
          ),
        );
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: uri.toString()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في فتح الملف: $e\nتم نسخ الرابط للحافظة')),
      );
    }
  }

  // تعامل مع الضغط على سجل الاختبار: إن وُجد رابط افتحه، وإلا اعرض تفاصيل السجل للمساعدة
  void _handleOpenTest(Map<String, dynamic> test) {
    final url = (test['pdfUrl'] ?? '').toString();
    if (url.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('لا يوجد ملف مرفق'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حقول السجل:'),
                  const SizedBox(height: 8),
                  ...test.entries.map((e) {
                    final key = e.key.toString();
                    final val = e.value?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '$key: $val',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إغلاق'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  debugPrint('Record details: ${test.toString()}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم طباعة تفاصيل السجل في الكونصول'),
                    ),
                  );
                },
                child: const Text('طباعة في الكونصول'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await _exportTestRecordAsPdf(test);
                },
                child: const Text('حفظ كـ PDF'),
              ),
            ],
          );
        },
      );
    } else {
      _openPdf(url);
    }
  }

  Future<void> _exportTestRecordAsPdf(Map<String, dynamic> test) async {
    try {
      final doc = pw.Document();

      final name = (test['name'] ?? '') as String;
      final date = (test['date'] ?? '') as String;
      final dataMap = test['data'] as Map<String, dynamic>? ?? {};

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'سجل التحليل',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text('الاسم: $name', style: pw.TextStyle(fontSize: 14)),
                  pw.Text(
                    'التاريخ: $date',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'تفاصيل:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  ...dataMap.entries.map(
                    (e) => pw.Text(
                      '${e.key}: ${e.value ?? ''}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'test_${name.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل إنشاء PDF: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchTestRecords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentProfileId = context.watch<ProfileProvider>().selectedProfileId;
    if (currentProfileId != _lastProfileId) {
      _lastProfileId = currentProfileId;
      _fetchTestRecords();
    }
  }

  Future<void> _fetchTestRecords() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user == null) return;

    final profileProvider = context.read<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;

    DocumentReference baseRef;
    if (selectedProfileId == null) {
      baseRef = _firestore.collection('users').doc(user.uid);
    } else {
      baseRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId);
    }

    try {
      final snapshot = await baseRef
          .collection('lab_xray')
          .orderBy('created_at', descending: true)
          .get();
      final List<Map<String, dynamic>> loadedTests = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        List<dynamic> labs = data['lab_names'] ?? [];
        String name = labs.isNotEmpty ? labs.join('، ') : 'تحليل طبي';

        DateTime? rawDate;
        String dateStr = 'غير محدد';
        if (data['date'] != null && data['date'] is Timestamp) {
          rawDate = (data['date'] as Timestamp).toDate();
          dateStr =
              "${rawDate.year} / ${rawDate.month.toString().padLeft(2, '0')} / ${rawDate.day.toString().padLeft(2, '0')}";
        }
        loadedTests.add({
          'name': name,
          'date': dateStr,
          'rawDate': rawDate,
          'pdfUrl':
              data['pdf_url'] ??
              data['file_url'] ??
              data['image_url'] ??
              data['url'] ??
              '',
          'data': data,
        });
      }

      if (mounted) {
        setState(() {
          _testsList = loadedTests;
          _filteredTestsList = loadedTests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredTestsList = _testsList.where((test) {
        final nameMatches =
            test['name']?.toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ??
            true;

        bool dateMatches = true;
        if (_selectedDate != null && test['rawDate'] != null) {
          DateTime tDate = test['rawDate'];
          dateMatches =
              tDate.year == _selectedDate!.year &&
              tDate.month == _selectedDate!.month &&
              tDate.day == _selectedDate!.day;
        }

        return nameMatches && dateMatches;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _searchController.text = "${picked.year}/${picked.month}/${picked.day}";
      });
      _applyFilter();
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          controller: _searchController,
          textAlign: TextAlign.right,
          onChanged: (v) {
            // إذا المستخدم أدخل تاريخ بأي صيغة معروفة، نستخدمه كفلتر تاريخ
            final parsed = _parseDateFromString(v);
            if (parsed != null) {
              _selectedDate = parsed;
              _searchQuery = '';
            } else {
              if (v.isEmpty) {
                _selectedDate = null;
              }
              _searchQuery = v;
            }
            _applyFilter();
          },
          decoration: InputDecoration(
            hintText: "ابحث عن التاريخ أو الاسم",
            prefixIcon: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.blue),
              onPressed: () => _selectDate(context),
            ),
            suffixIcon: const Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestsGrid() {
    if (_filteredTestsList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text("لا توجد تحاليل مسجلة"),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _filteredTestsList.length,
        itemBuilder: (context, index) {
          final test = _filteredTestsList[index];
          return InkWell(
            onTap: () => _handleOpenTest(test),
            child: Column(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  test['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  test['date'],
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: HomeScreen.veryLightBlue.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. القائمة (يمين)
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
          // 2. الرئيسية (وسط)
          InkWell(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            ),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: HomeScreen.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_filled,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),

          // 3. الإشعارات (يسار)
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _buildPdfBytes() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return [
              pw.Center(
                child: pw.Text(
                  'سجل التحاليل الطبية',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              ..._filteredTestsList.asMap().entries.map((entry) {
                final i = entry.key;
                final t = entry.value;
                final name = (t['name'] ?? '').toString();
                final date = (t['date'] ?? '').toString();

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${i + 1}. $name',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'التاريخ: $date',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ];
          },
        ),
      );

      return await doc.save();
    } catch (e) {
      debugPrint('PDF ERROR: $e');
      return null;
    }
  }

  Future<void> _exportVisibleTestsAsPdf() async {
    final bytes = await _buildPdfBytes();
    if (bytes == null) return;
    await Printing.sharePdf(bytes: bytes, filename: 'medical_tests.pdf');
  }

  Future<void> _printVisibleTests() async {
    final bytes = await _buildPdfBytes();
    if (bytes == null) return;
    try {
      await Printing.layoutPdf(onLayout: (format) => bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الطباعة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'التحاليل الطبية',
          style: TextStyle(
            color: Color(0xFF004AAD),
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
            icon: Image.asset('assets/images/back.png', width: 23),
          ),
          const SizedBox(width: 10),
        ],
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 28),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    child: SharedProfileTabs(showTitle: false),
                  ),
                  _buildSearchBar(),
                  if (_selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ActionChip(
                        label: const Text("مسح فلاتر التاريخ"),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                            _searchController.clear();
                            _searchQuery = '';
                          });
                          _applyFilter();
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontSize: 14,
                            color: HomeScreen.primaryBlue,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'سجل التحاليل الطبية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTestsGrid(),
                ],
              ),
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (ctx) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const Text('حفظ/مشاركة PDF'),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _exportVisibleTestsAsPdf();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.print),
                        title: const Text('طباعة مباشرة'),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _printVisibleTests();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: HomeScreen.primaryBlue,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('تصدير PDF'),
      ),
    );
  }
}
