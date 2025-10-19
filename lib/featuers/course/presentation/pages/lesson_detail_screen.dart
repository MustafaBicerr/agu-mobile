import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_page/featuers/course/domain/entities/lessonEntity.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_bloc.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_event.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_state.dart';
import 'package:home_page/featuers/course/presentation/pages/TimeTableDetail.dart';
import 'package:home_page/featuers/home/presentation/widgets/bottom.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonEntity lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final txtName = TextEditingController();
  final txtClass = TextEditingController();
  final txtTeacher = TextEditingController();

  String? selectedDay;
  String? selectedHour1;
  String? selectedHour2;
  String? selectedHour3;
  int? attendance;

  @override
  void initState() {
    super.initState();
    final lesson = widget.lesson;
    txtName.text = lesson.name ?? '';
    txtClass.text = lesson.place ?? '';
    txtTeacher.text = lesson.teacher ?? '';
    selectedDay = lesson.day;
    selectedHour1 = lesson.hour1;
    selectedHour2 = lesson.hour2;
    selectedHour3 = lesson.hour3;
    attendance = lesson.attendance ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 0),
      appBar: AppBar(
        title: const Text("Ders Detayı"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<LessonBloc, LessonState>(
        listener: (context, state) {
          if (state is LessonActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Timetabledetail()),
            );
          } else if (state is LessonError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCard("Ders Adı", _buildTextField(txtName, "Ders adı")),
              _buildCard("Sınıf", _buildTextField(txtClass, "Sınıf")),
              _buildCard("Öğretmen", _buildTextField(txtTeacher, "Öğretmen")),
              _buildCard("Gün", _buildDayDropdown()),
              _buildCard("Ders Saatleri", _buildHoursDropdowns()),
              _buildCard("Devamsızlık", _buildAttendanceDropdown()),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    text: "Dersi Güncelle",
                    color: Colors.blue,
                    onPressed: () => _showConfirmDialog(context, false),
                  ),
                  _buildActionButton(
                    text: "Devamsızlığı Güncelle",
                    color: Colors.green,
                    onPressed: () => _showConfirmDialog(context, true),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDayDropdown() {
    final days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar"
    ];
    return DropdownButtonFormField<String>(
      value: selectedDay,
      items:
          days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (v) => setState(() => selectedDay = v),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHoursDropdowns() {
    final hours = [
      "08:00-08:45",
      "09:00-09:45",
      "10:00-10:45",
      "11:00-11:45",
      "12:00-12:45",
      "13:00-13:45",
      "14:00-14:45",
      "15:00-15:45",
      "16:00-16:45",
      "17:00-17:45",
      "18:00-18:45",
    ];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedHour1,
          items: hours
              .map((h) => DropdownMenuItem(value: h, child: Text(h)))
              .toList(),
          onChanged: (v) => setState(() => selectedHour1 = v),
          decoration: const InputDecoration(labelText: "1. Saat"),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedHour2,
          items: hours
              .map((h) => DropdownMenuItem(value: h, child: Text(h)))
              .toList(),
          onChanged: (v) => setState(() => selectedHour2 = v),
          decoration: const InputDecoration(labelText: "2. Saat"),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedHour3,
          items: hours
              .map((h) => DropdownMenuItem(value: h, child: Text(h)))
              .toList(),
          onChanged: (v) => setState(() => selectedHour3 = v),
          decoration: const InputDecoration(labelText: "3. Saat"),
        ),
      ],
    );
  }

  Widget _buildAttendanceDropdown() {
    final values = List.generate(21, (i) => i);
    return DropdownButtonFormField<int>(
      value: attendance,
      items: values
          .map((v) => DropdownMenuItem(value: v, child: Text(v.toString())))
          .toList(),
      onChanged: (v) => setState(() => attendance = v),
    );
  }

  Widget _buildActionButton(
      {required String text,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  void _showConfirmDialog(BuildContext context, bool isAttendanceUpdate) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Onay",
          style:
              TextStyle(color: isAttendanceUpdate ? Colors.green : Colors.blue),
        ),
        content: Text(
          isAttendanceUpdate
              ? "Devamsızlığı güncellemek istediğinize emin misiniz?"
              : "Dersi güncellemek istediğinize emin misiniz?",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final updatedLesson = widget.lesson
                  .copyWith(
                    attendance: attendance,
                    isProcessed: widget.lesson.isProcessed,
                  )
                  .copyWith(
                    isProcessed: 0,
                  );
              final newEntity = LessonEntity(
                id: widget.lesson.id,
                name: txtName.text,
                place: txtClass.text,
                day: selectedDay ?? widget.lesson.day!,
                hour1: selectedHour1,
                hour2: selectedHour2,
                hour3: selectedHour3,
                teacher: txtTeacher.text,
                attendance: attendance ?? widget.lesson.attendance,
              );

              context.read<LessonBloc>().add(
                    isAttendanceUpdate
                        ? UpdateAttendanceEvent(newEntity)
                        : UpdateLessonEvent(newEntity),
                  );
            },
            child:
                const Text("Güncelle", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Uyarı", style: TextStyle(color: Colors.red)),
        content: const Text("Bu dersi silmek istediğinize emin misiniz?",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<LessonBloc>()
                  .add(DeleteLessonEvent(widget.lesson.id!));
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
