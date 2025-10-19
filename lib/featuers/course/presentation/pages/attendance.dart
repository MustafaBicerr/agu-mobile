import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_page/featuers/course/domain/entities/lessonEntity.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_bloc.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_event.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_state.dart';
import 'package:home_page/featuers/home/presentation/widgets/bottom.dart';

class DailyAttendanceScreen extends StatefulWidget {
  const DailyAttendanceScreen({super.key});

  @override
  State<DailyAttendanceScreen> createState() => _DailyAttendanceScreenState();
}

class _DailyAttendanceScreenState extends State<DailyAttendanceScreen> {
  late String currentDay;

  @override
  void initState() {
    super.initState();
    currentDay = _getDayName();
    context.read<LessonBloc>().add(GetDailyLessonsEvent(currentDay));
  }

  String _getDayName() {
    final days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar"
    ];
    return days[DateTime.now().weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 4),
      appBar: AppBar(
        title: Text(
          "Günlük Devamsızlık ($currentDay)",
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: BlocConsumer<LessonBloc, LessonState>(
        listener: (context, state) {
          if (state is LessonActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is LessonError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DailyLessonsLoaded) {
            if (state.lessons.isEmpty) {
              return Center(
                child: Text(
                  "Bugün (${state.day}) için ders bulunamadı.",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.lessons.length,
              itemBuilder: (context, index) {
                final lesson = state.lessons[index];
                return _buildLessonCard(context, lesson);
              },
            );
          } else {
            return const Center(child: Text("Veri yükleniyor..."));
          }
        },
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonEntity lesson) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.name!.toUpperCase(),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text("Sınıf: ${lesson.place ?? '-'}",
                style: const TextStyle(color: Colors.black54)),
            Text("Öğretmen: ${lesson.teacher ?? '-'}",
                style: const TextStyle(color: Colors.black54)),
            Text(
              "Saatler: ${lesson.hour1 ?? ''} / ${lesson.hour2 ?? ''} / ${lesson.hour3 ?? ''}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<LessonBloc>()
                        .add(MarkAttendanceEvent(lesson, true));
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Katıldım"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<LessonBloc>()
                        .add(MarkAttendanceEvent(lesson, false));
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text("Katılmadım"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
