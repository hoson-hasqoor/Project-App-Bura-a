import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  // قائمة الأسئلة الشائعة (FAQ)
  static const List<Map<String, String>> faqItems = [
    {
      'question': 'ما هو تطبيق برء؟',
      'answer':
          'برء هو تطبيق صحي متكامل لإدارة السجلات الصحية للأفراد والعائلة، يشمل التحاليل، الأدوية، المطاعيم، الأمراض المزمنة، العمليات الجراحية، الحساسية، وتنبيهات المواعيد الطبية.',
    },
    {
      'question': 'كيف يمكنني إنشاء حساب جديد؟',
      'answer':
          'يمكنك التسجيل باستخدام البريد الإلكتروني أو رقم الهاتف، مع التحقق عبر رسالة لتأكيد الحساب.',
    },
    {
      'question': 'هل يمكن إضافة أفراد العائلة أو المرافقين؟',
      'answer':
          'نعم، يمكنك إضافة أفراد عائلتك أو مرافقين، إما بسجل صحي موجود مسبقًا أو بإنشاء سجل جديد لهم، مع إرسال طلب موافقة عند الحاجة.',
    },
    {
      'question': 'كيف أتحكم في صلاحيات المرافقين؟',
      'answer': 'يمكنك تحديد صلاحيات كل مرافق: عرض فقط، تعديل كامل.',
    },
    {
      'question': 'كيف أدخل البيانات الحيوية؟',
      'answer':
          'ضمن الصفحة الرئيسية، يمكنك إضافة الوزن والطول، ومستوى السكري وضغط الدم ونبضات القلب.',
    },
    {
      'question': 'كيف أدخل الأمراض المزمنة والعمليات الجراحية؟',
      'answer':
          'ضمن قسم “الأمراض المزمنة”، أضف اسم المرض وتاريخ التشخيص. أما العمليات الجراحية، أضف اسم العملية، التاريخ، والسبب.',
    },
    {
      'question': 'كيف أضيف التحاليل والفحوصات الطبية؟',
      'answer':
          'اختر “رفع ملف”، وأضف صورة أو PDF، واملأ اسم الفحص، التاريخ، وأي ملاحظات مهمة.',
    },
    {
      'question': 'كيف أضيف وصفات الأدوية؟',
      'answer':
          'ضمن قسم الأدوية، أضف اسم الدواء، نوعه (مزمن، مؤقت، أو مكمل غذائي)، الجرعة، عدد المرات، سبب الاستخدام، وتاريخ البداية.',
    },
    {
      'question': 'كيف أضيف الحساسية والمطاعيم؟',
      'answer':
          'ضمن قسم الحساسية، أضف نوع الحساسية (دواء، غذاء، مواد أخرى). أما المطاعيم، أضف اسم اللقاح وتاريخ التطعيم.',
    },
    {
      'question': 'هل يمكن تلقي تذكيرات بالمواعيد الطبية والأدوية؟',
      'answer':
          'نعم، برء يرسل إشعارات ذكية لجميع المواعيد الطبية والفحوصات وأوقات تناول الأدوية لضمان الالتزام بالخطة الصحية.',
    },
    {
      'question': 'كيف أنقل السجل الصحي من الحساب العائلي إلى حسابي الشخصي؟',
      'answer':
          'اختر خيار “نقل السجل”، وأدخل بريدك وبريد المسؤول، وسيتم إرسال طلب موافقة لنقل السجل بشكل آمن.',
    },
    {
      'question': 'ماذا أفعل إذا نسيت كلمة السر؟',
      'answer':
          'اضغط على “نسيت كلمة السر” واتبع خطوات استرجاعها عبر البريد الإلكتروني أو رقم الهاتف.',
    },
    {
      'question': 'هل يمكن مشاركة السجلات مع الأطباء أو المستشفيات؟',
      'answer':
          'حالياً، التطبيق يركز على إدارة البيانات داخل الأسرة، ويمكن مشاركة البيانات فقط حسب صلاحيات المرافقين.',
    },
    {
      'question': 'هل يمكن إضافة ملاحظات لكل فحص أو دواء؟',
      'answer':
          'نعم، عند إضافة أي فحص أو وصفة دواء، هناك خانة ملاحظات لتوضيح أي تفاصيل مهمة.',
    },
    {
      'question': 'كيف يمكن إزالة مرافق أو فصل الوصول؟',
      'answer':
          'من ادارة الصلاحيات، اختر “ فصل الوصول” وسيتم إشعار المستخدم حسب الصلاحيات.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFFF5F5F5);
    const Color primaryColor = HomeScreen.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 💡 تأكد من أن الـ AppBar يدعم RTL
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        leadingWidth: 70,
        title: const Text(
          'اسئلة شائعة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        // الشعار على اليمين في تصميم RTL
        leading: Padding(
          padding: const EdgeInsets.only(right: 16.0),
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
        // زر الرجوع على اليسار في تصميم RTL
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // 💡 لف المحتوى بـ Directionality لضمان تطبيق RTL بالكامل
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            children: faqItems.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 10.0,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
                color: cardColor,
                child: ExpansionTile(
                  // ❌ تم إزالة: controlAffinity: ListTileControlAffinity.leading
                  // هذا سيعيد الأيقونة إلى الوضع الافتراضي للـ RTL، وهو أن تكون على اليمين (Trailing)
                  iconColor: primaryColor,
                  collapsedIconColor: primaryColor,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  title: Text(
                    item['question']!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Text(
                        item['answer']!,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 15.0,
                          height: 1.5,
                          color: Color(0xFF616161),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
