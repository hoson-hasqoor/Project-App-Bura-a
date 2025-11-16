import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/Ticket_dates.dart';
import 'package:intl/intl.dart';

/// ---------------------------
/// ألوان التطبيق
/// ---------------------------
class AppColors {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color lightBlueBackground = Color(0xFFF5F9FF);
  static const Color darkText = Color(0xFF333333);
  static const Color veryLightGrey = Color(0xFFFAFAFA);
  static const Color redAccent = Color(0xFFEF5350);
  static const Color sectionBackground = Color(0xFF6FA8FF);
}

class AddTicketDates extends StatefulWidget {
  const AddTicketDates({super.key});

  @override
  State<AddTicketDates> createState() => _AddTicketDatesState();
}

class _AddTicketDatesState extends State<AddTicketDates> {
  // ---------------------------
  // المتغيرات
  // ---------------------------
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String frequency = 'مرة واحدة';
  List<String> frequencyOptions = ['مرة واحدة', 'يومي', 'أسبوعي', 'شهري'];

  List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  String? selectedDay;
  DateTime shownMonth = DateTime.now();
  int selectedHour = 8;
  int selectedMinute = 10;
  String selectedPeriod = 'AM';

  // ---------------------------
  // اختيار التاريخ والوقت
  // ---------------------------
  Future<void> _pickDateTime() async {
    DateTime? d = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (d != null) {
      TimeOfDay? t = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );

      if (t != null) {
        setState(() {
          selectedDate = d;
          selectedTime = t;
        });
      }
    }
  }

  String _formattedDateTime() {
    if (selectedDate == null || selectedTime == null) {
      return "اضغط لاختيار التاريخ والوقت";
    }

    final fDate = DateFormat("yyyy/MM/dd").format(selectedDate!);
    final fTime = selectedTime!.format(context);

    return "$fDate - $fTime";
  }

  // ---------------------------
  // واجهة المستخدم
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNewInputSection(),
            const SizedBox(height: 10), // قللت من المسافة
            _buildCalendarSection(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 70,
      title: const Text(
        "إضافة موعد جديد",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
          height: 0.85,
        ),
      ),
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            "assets/images/logo.png",
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const TicketDates()),
              (route) => false,
            );
          },
          icon: Image.asset('assets/images/back.png', width: 24, height: 24),
        ),
      ],
    );
  }

  // ---------------------------
  // قسم الاسم والتاريخ/الوقت العلوي
  // ---------------------------
  Widget _buildNewInputSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "اسم التذكرة",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 0.85,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: TextField(
              controller: nameController,
              textAlign: TextAlign.right,
              style: const TextStyle(height: 0.85),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "اكتب اسم التذكرة",
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "تاريخ ووقت التذكرة",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 0.85,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDateTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formattedDateTime(),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        height: 0.85,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // قسم التقويم + الوقت + التكرار + الملاحظات
  // ---------------------------
  Widget _buildCalendarSection() {
    int daysInMonth = DateTime(shownMonth.year, shownMonth.month + 1, 0).day;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        color: AppColors.sectionBackground,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _monthBox(DateFormat('MMMM').format(shownMonth)),
                const SizedBox(width: 10),
                _monthBox('${shownMonth.year}'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekdays
                  .map(
                    (d) => Text(
                      d,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 0.85,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                String dayNum = "${index + 1}";
                bool isSelected = selectedDay == dayNum;
                return GestureDetector(
                  onTap: () => setState(() => selectedDay = dayNum),
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(3), // قللت الهامش
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.sectionBackground
                            : Colors.white,
                        height: 0.85,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildTimeSelector(),
            const SizedBox(height: 20),
            const Text(
              "التكرار",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 0.85,
              ),
            ),
            const SizedBox(height: 15),
            _buildFrequency(),
            const SizedBox(height: 20),
            _buildNotes(),
            const SizedBox(height: 25),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // صناديق الشهر
  // ---------------------------
  Widget _monthBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
          height: 0.85,
        ),
      ),
    );
  }

  // ---------------------------
  // اختيار الوقت
  // ---------------------------
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "الوقت",
          style: TextStyle(color: Colors.white, fontSize: 18, height: 0.85),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _timeBox("${selectedHour} h", () {
              setState(() => selectedHour = (selectedHour % 12) + 1);
            }),
            const SizedBox(width: 8),
            _timeBox("${selectedMinute} m", () {
              setState(() => selectedMinute = (selectedMinute + 5) % 60);
            }),
            const SizedBox(width: 8),
            _timeBox(selectedPeriod, () {
              setState(
                () => selectedPeriod = (selectedPeriod == "AM") ? "PM" : "AM",
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _timeBox(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 0.85,
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // اختيار التكرار
  // ---------------------------
  Widget _buildFrequency() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // السطر الأول: مرة واحدة + يومي
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _freqOption("مرة واحدة"),
            const SizedBox(width: 40),
            _freqOption("يومي"),
          ],
        ),

        const SizedBox(height: 10),

        // السطر الثاني: أسبوعي + شهري
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _freqOption("أسبوعي"),
            const SizedBox(width: 40),
            _freqOption("شهري"),
          ],
        ),
      ],
    );
  }

  Widget _freqOption(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: text,
          groupValue: frequency,
          onChanged: (value) => setState(() => frequency = value!),
          fillColor: MaterialStateProperty.all(Colors.white),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 0.85,
          ),
        ),
      ],
    );
  }

  // ---------------------------
  // الملاحظات
  // ---------------------------
  Widget _buildNotes() {
    return TextField(
      controller: notesController,
      maxLines: 3,
      textAlign: TextAlign.right,
      style: const TextStyle(height: 0.85),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: "أضف أي ملاحظات عن الموعد...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---------------------------
  // الأزرار
  // ---------------------------
  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionBtn("إلغاء", true, () => Navigator.pop(context)),
        const SizedBox(width: 15),
        _buildActionBtn("حفظ", true, () {}),
      ],
    );
  }

  Widget _buildActionBtn(String label, bool primary, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 0.85,
        ),
      ),
    );
  }
}
