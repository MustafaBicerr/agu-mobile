import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_page/featuers/course/domain/entities/lessonEntity.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_bloc.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_event.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_state.dart';

class LessonAddPage extends StatefulWidget {
  const LessonAddPage({super.key});

  @override
  State<LessonAddPage> createState() => _LessonAddPageState();
}

class _LessonAddPageState extends State<LessonAddPage> {
  final nameController = TextEditingController();
  final classController = TextEditingController();
  final teacherController = TextEditingController();

  String? selectedDay;
  String? hour1;
  String? hour2;
  String? hour3;

  final List<String> days = [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ];

  final List<String> hours = [
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
    "19:00-19:45"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ders Ekle")),
      body: BlocConsumer<LessonBloc, LessonState>(
        listener: (context, state) {
          if (state is LessonActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is LessonError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(nameController, "Ders Adı", Icons.book),
                const SizedBox(height: 10),
                _buildTextField(classController, "Sınıf", Icons.place),
                const SizedBox(height: 10),
                _buildTextField(teacherController, "Öğretmen", Icons.person),
                const SizedBox(height: 20),
                _buildDropdown("Gün Seç", days, selectedDay, (value) {
                  setState(() => selectedDay = value);
                }),
                const SizedBox(height: 10),
                _buildDropdown("Birinci Ders Saati", hours, hour1,
                    (value) => setState(() => hour1 = value)),
                _buildDropdown("İkinci Ders Saati", hours, hour2,
                    (value) => setState(() => hour2 = value)),
                _buildDropdown("Üçüncü Ders Saati", hours, hour3,
                    (value) => setState(() => hour3 = value)),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _onSave(context),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Kaydet",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _onSave(BuildContext context) {
    if (nameController.text.isEmpty ||
        classController.text.isEmpty ||
        teacherController.text.isEmpty ||
        selectedDay == null ||
        hour1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm zorunlu alanları doldurun")),
      );
      return;
    }

    final lesson = LessonEntity(
      name: nameController.text,
      place: classController.text,
      day: selectedDay!,
      hour1: hour1,
      hour2: hour2,
      hour3: hour3,
      teacher: teacherController.text,
    );

    context.read<LessonBloc>().add(AddLessonEvent(lesson));
  }
}
