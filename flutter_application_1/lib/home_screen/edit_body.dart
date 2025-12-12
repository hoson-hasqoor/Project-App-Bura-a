import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';

class EditBody extends StatefulWidget {
  const EditBody({super.key});

  @override
  State<EditBody> createState() => _EditBodyState();
}

class _EditBodyState extends State<EditBody> {
  final TextEditingController heightController = TextEditingController(
    text: "165",
  );
  final TextEditingController weightController = TextEditingController(
    text: "72",
  );
  final TextEditingController ageController = TextEditingController(text: "30");
  final TextEditingController bloodTypeController = TextEditingController(
    text: "A+",
  );
  final TextEditingController pressureController = TextEditingController(
    text: "120/80",
  );
  final TextEditingController heartController = TextEditingController(
    text: "80",
  );
  final TextEditingController sugarController = TextEditingController(
    text: "100",
  );

  String gender = "male";
  double bmi = 0;

  @override
  void initState() {
    super.initState();
    _calculateBMI();
  }

  void _calculateBMI() {
    double h = double.tryParse(heightController.text) ?? 0;
    double w = double.tryParse(weightController.text) ?? 0;

    if (h > 0 && w > 0) {
      double heightInMeters = h / 100;
      setState(() {
        bmi = w / (heightInMeters * heightInMeters);
      });
    }
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
          'تعديل البيانات الحيوية',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
            height: 0.90, // 🔥 تقليل المسافة بين الأسطر
          ),
        ),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _title("الجنس"),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _genderCard(Icons.male, "male", "ذكر"),
                  const SizedBox(width: 15),
                  _genderCard(Icons.female, "female", "أنثى"),
                ],
              ),

              const SizedBox(height: 25),
              _title("العمر"),
              _inputField(ageController, "أدخل العمر"),

              const SizedBox(height: 25),
              _title("فصيلة الدم"),
              _inputField(bloodTypeController, "مثال: A+"),

              const SizedBox(height: 25),
              _title("الطول (سم)"),
              _inputField(
                heightController,
                "مثال: 165",
                onChanged: (_) => _calculateBMI(),
              ),

              const SizedBox(height: 25),
              _title("الوزن (كجم)"),
              _inputField(
                weightController,
                "مثال: 72",
                onChanged: (_) => _calculateBMI(),
              ),

              const SizedBox(height: 20),
              _bmiCard(),

              const SizedBox(height: 25),
              _title("ضغط الدم"),
              _inputField(pressureController, "مثال: 120/80"),

              const SizedBox(height: 25),
              _title("معدل النبض"),
              _inputField(heartController, "مثال: 80"),

              const SizedBox(height: 25),
              _title("مستوى السكر"),
              _inputField(sugarController, "مثال: 100"),

              const SizedBox(height: 35),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم حفظ البيانات بنجاح")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeScreen.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "حفظ البيانات",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildNavBar(context),
    );
  }

  // ------------------ Widgets ------------------

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 0.85, // 🔥 تقليل المسافة
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String hint, {
    Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        style: const TextStyle(height: 0.85), // 🔥 هنا أهم تعديل
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  Widget _genderCard(IconData icon, String value, String label) {
    bool selected = gender == value;

    return GestureDetector(
      onTap: () {
        setState(() => gender = value);
      },
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected
              ? HomeScreen.primaryBlue.withOpacity(0.15)
              : Colors.white,
          border: Border.all(
            color: selected ? HomeScreen.primaryBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: selected ? HomeScreen.primaryBlue : Colors.grey,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? HomeScreen.primaryBlue : Colors.grey,
                height: 0.85, // 🔥 حتى هذا مصغر
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bmiCard() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
        ),
        child: Center(
          child: Text(
            "BMI: ${bmi.toStringAsFixed(1)}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: HomeScreen.primaryBlue,
              height: 0.90,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: HomeScreen.veryLightBlue.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              size: 30,
              color: Colors.grey,
            ),
          ),

          InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: HomeScreen.primaryBlue,
              child: const Icon(
                Icons.home_filled,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}
