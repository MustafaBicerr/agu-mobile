import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_page/featuers/course/domain/entities/lessonEntity.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_bloc.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_event.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_state.dart';
import 'package:home_page/featuers/course/presentation/pages/lesson_add_page.dart';
import 'package:home_page/featuers/course/presentation/pages/lesson_detail_screen.dart';
import 'package:home_page/featuers/course/domain/usecases/sis_webview_login.dart';
import 'package:home_page/featuers/home/presentation/widgets/bottom.dart';
import 'package:home_page/methods.dart';

class Timetabledetail extends StatefulWidget {
  const Timetabledetail({super.key});

  @override
  State<Timetabledetail> createState() => _TimetabledetailState();
}

class _TimetabledetailState extends State<Timetabledetail> {
  final methods = Methods();

  final List<String> days = const [
    "Pazartesi",
    "Salı",
    "Çarşamba",
    "Perşembe",
    "Cuma",
    "Cumartesi",
    "Pazar"
  ];

  @override
  void initState() {
    super.initState();
    context.read<LessonBloc>().add(GetLessonsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 0),
      appBar: AppBar(
        title: const Text("Ders Programı",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == "delete") {
                _showDeleteDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: "delete", child: Text("Tüm Dersleri Sil"))
            ],
          ),
        ],
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LessonError) {
            return Center(
              child: Text(
                "Bir hata oluştu: ${state.message}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is LessonLoaded) {
            final lessons = state.lessons;

            if (lessons.isEmpty) {
              return const Center(
                child: Text(
                  "Henüz ders eklenmedi.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 39, 113, 148),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.builder(
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final dailyLessons = lessons
                      .where((lesson) => lesson.day == day)
                      .toList()
                    ..sort(_compareLessonsByHour);

                  return dailyLessons.isEmpty
                      ? const SizedBox.shrink()
                      : _buildDayCard(context, day, dailyLessons);
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  // === FAB ===
  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showFabMenu(context),
      backgroundColor: Colors.lightBlueAccent[400],
      child: const Icon(Icons.add),
    );
  }

  void _showFabMenu(BuildContext context) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromLTRB(
        overlay.size.width - 180, overlay.size.height - 250, 20, 0);

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.cloud_download, color: Colors.blue),
            title: const Text("SİS'ten Otomatik Çek"),
            subtitle: const Text("Bölüm öğrencileri için önerilir."),
            onTap: () {
              Navigator.pop(context);
              _showInfoDialog(context);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.edit_note, color: Colors.green),
            title: const Text("Manuel Ekle"),
            subtitle: const Text("Hazırlıktakiler için önerilir."),
            onTap: () {
              Navigator.pop(context);
              methods.navigateToPage(context, LessonAddPage());
            },
          ),
        ),
      ],
    );
  }

  // === Günlük Ders Kartı ===
  Widget _buildDayCard(
      BuildContext context, String day, List<LessonEntity> dailyLessons) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    day,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const Divider(),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyLessons.length,
                itemBuilder: (context, index) {
                  final lesson = dailyLessons[index];
                  return _buildLessonCard(context, lesson);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonEntity lesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          methods.navigateToPage(context, LessonDetailScreen(lesson: lesson));
        },
        child: Card(
          color: const Color.fromARGB(180, 0, 174, 254),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lesson.name!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _infoRow(Icons.person, lesson.teacher ?? "Öğretmen yok"),
                _infoRow(Icons.location_on, lesson.place ?? "Yer yok"),
                _infoRow(Icons.access_time,
                    "${lesson.hour1 ?? ''} ${lesson.hour2 ?? ''} ${lesson.hour3 ?? ''}"),
                _infoRow(
                    Icons.remove, "Devamsızlık = ${lesson.attendance ?? 0}"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // === Dersleri silme ===
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: const Text("Uyarı", style: TextStyle(color: Colors.red)),
        content: const Text("Tüm dersleri silmek istediğinize emin misiniz?",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hayır", style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LessonBloc>().add(DeleteAllLessonsEvent());
            },
            child: const Text("Evet", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // === SİS Bilgi Dialog ===
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title:
            const Text("Bilgilendirme", style: TextStyle(color: Colors.amber)),
        content: const Text(
          "SİS'e giriş yaptıktan sonra 'Genel İşlemler > Ders Programı' sekmesine gidip sağ üstteki kaydet ikonuna basın.",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              methods.navigateToPage(context, const SisWebViewFullscreen());
            },
            child:
                const Text("Sis'e Git", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  int _compareLessonsByHour(LessonEntity a, LessonEntity b) {
    String hourA = a.hour1 ?? "00:00";
    String hourB = b.hour1 ?? "00:00";
    return hourA.compareTo(hourB);
  }
}
