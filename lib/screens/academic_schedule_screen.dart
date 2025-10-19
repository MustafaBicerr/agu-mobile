import 'package:flutter/material.dart';
import 'package:home_page/models/academic.dart';
import 'package:home_page/services/apiService.dart';
import 'package:intl/intl.dart';

class AcademicCalendarScreen extends StatefulWidget {
  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  final AcademicApi academicApi = AcademicApi();
  late Future<List<Academic>> academicData;

  @override
  void initState() {
    super.initState();
    academicData = academicApi.fetchAcademicData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Akademik Takvim",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 226, 225, 225),
      ),
      body: FutureBuilder<List<Academic>>(
        future: academicData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Bir hata oluştu: ${snapshot.error}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final List<Academic> allData = snapshot.data!;
            final List<Map<String, String>> periods = allData
                .where((data) => data.category == "Dönem") // sadece "Dönem"
                .map((e) => {
                      "event": e.event!,
                      "startDate": e.startDate!,
                      "endDate": e.endDate!,
                      "term": e.term!, // term ekle
                    })
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: periods.length,
              itemBuilder: (context, index) {
                final period = periods[index];
                final backgroundColors = [
                  const Color.fromARGB(255, 99, 180, 215),
                  const Color.fromARGB(255, 162, 224, 91),
                  const Color.fromARGB(255, 235, 208, 120),
                  Colors.pink[50]
                ];
                return Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 125),
                  child: Card(
                    color: backgroundColors[index % backgroundColors.length],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      iconColor: Colors.blueAccent,
                      collapsedIconColor: Colors.blueAccent,
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          period["event"]!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: [_buildSubCategoryList(period, allData)],
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildSubCategoryList(Map period, List<Academic> allData) {
    final periodStart = DateTime.parse(period["startDate"]!);
    final periodEnd = DateTime.parse(period["endDate"]!);
    final term = period["term"];

    final List<String> subCategories = allData
        .where((item) =>
            item.startDate != null &&
            item.endDate != null &&
            item.term == term && // sadece aynı term
            !(item.category == "Dönem")) // Dönem kategorisini exclude et
        .where((item) {
          final itemStart = DateTime.parse(item.startDate!);
          final itemEnd = DateTime.parse(item.endDate!);
          return itemStart.isBefore(periodEnd.add(const Duration(days: 1))) &&
              itemEnd.isAfter(periodStart.subtract(const Duration(days: 1)));
        })
        .map((e) => e.category!)
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subCategories.map((subCategory) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                subCategory,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (context) {
                    return _buildDetailsList(subCategory, period, allData);
                  },
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailsList(
      String category, Map period, List<Academic> allData) {
    final term = period["term"];
    final List<Academic> filteredData = allData.where((item) {
      return item.category == category &&
          item.term == term && // sadece aynı term
          item.startDate != null &&
          item.endDate != null;
    }).toList();

    if (filteredData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          "Bu kategoriye ait veri bulunamadı.",
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SizedBox(
      height: 400, // modalde overflow olmasın diye
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          final detail = filteredData[index];
          String formattedStartDate = DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(detail.startDate!).toLocal());
          String formattedEndDate = DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(detail.endDate!).toLocal());

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(
                Icons.event,
                color: Colors.blueAccent,
              ),
              title: Text(
                detail.event!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("📅 $formattedStartDate - $formattedEndDate"),
            ),
          );
        },
      ),
    );
  }
}
