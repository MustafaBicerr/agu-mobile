// import 'dart:collection';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:home_page/bottom.dart';
// import 'package:home_page/data/database_service.dart';
// import 'package:home_page/notifications.dart';
// import 'package:home_page/utilts/constants/constants.dart';
// import 'package:home_page/utilts/models/sisLessons.dart';
// import 'package:home_page/utilts/models/sisLessons_db_adapter.dart';
// import 'package:home_page/utilts/services/apiService.dart';
// import 'package:home_page/utilts/services/sis_lessons_local_service.dart';
// import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
// import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
// import 'package:multi_select_flutter/util/multi_select_item.dart';

// late List<sisLessons> _sisLessonsList = [];
// late List<dynamic> _lessonsNameList = [];
// List<String> secilenDersler = [];
// List<String> secilenDersKodlari = [];
// // aktif bölüm harici dersleri tutmak için:
// final Map<String, List<sisLessons>> _globalByCodeCache = {};
// bool _isPreloading = false; // küçük bir loading göstermek istersen

// String departmantName = "Bilgisayar Mühendisliği";

// const List<String> departmenstList = <String>[
//   "Bilgisayar Mühendisliği",
//   "Endüstri Mühendisliği",
//   "Elektrik-Elektronik Mühendisliği",
//   "Makine Mühendisliği",
//   "İnşaat Mühendisliği",
//   "Malzeme Bilimi ve NanoTeknoloji Mühendisliği",
//   "Biyomühendislik",
//   "Moleküler Biyoloji ve Genetik",
//   "Mimarlık",
//   "İşletme",
//   "Ekonomi",
//   "Psikoloji",
//   "Siyaset Bilimi ve Uluslararası İlişkiler",
// ];

// class sisAddLessonsPage extends StatefulWidget {
//   sisAddLessonsPage({
//     super.key,
//   });

//   @override
//   State<sisAddLessonsPage> createState() => _sisAddLessonsPageState();
// }

// class _sisAddLessonsPageState extends State<sisAddLessonsPage> {
//   sisLessonsAPI sisApi = sisLessonsAPI();

//   String? username;
//   bool isLoading = true;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _loadSisDataFromDB();
//   }

//   Future<void> _loadSisDataFromDB() async {
//     await DatabaseService.I.ensureReady(); // 🔴 mutlaka
//     final local = SisLessonsLocalService();
//     final data = await local.fetchAllLessonData(); // artık dolu gelmeli

//     // anahtar/tabloları gör
//     debugPrint('Local keys: ${data.keys.toList()}');

//     final key =
//         getLessonsFromDepartmentName(departmantName); // 'compdata' öneririm
//     // final key = "compData";
//     final lessons = data[key] ?? <sisLessons>[];

//     setState(() {
//       _sisLessonsList = lessons;
//       _lessonsNameList =
//           lessons.map((e) => e.ders_adi).whereType<String>().toSet().toList();
//       isLoading = false;
//     });
//     printColored("SQLite'den veriler yüklendi: $key (${lessons.length})", "32");
//   }

//   getLessonsFromDepartmentName(String departmantName) {
//     switch (departmantName) {
//       case "Bilgisayar Mühendisliği":
//         return "compData";
//       case "Endüstri Mühendisliği":
//         return "ieData";
//       case "Elektrik-Elektronik Mühendisliği":
//         return "eeeData"; // tablo adın neyse
//       case "Makine Mühendisliği":
//         return "meData";
//       case "İnşaat Mühendisliği":
//         return "ceData";
//       case "Malzeme Bilimi ve NanoTeknoloji Mühendisliği":
//         return "nanoData";
//       case "Biyomühendislik":
//         return "bioeData";
//       case "Moleküler Biyoloji ve Genetik":
//         return "mbgData";
//       case "Mimarlık":
//         return "arcData";
//       case "İşletme":
//         return "baData";
//       case "Ekonomi":
//         return "econData";
//       case "Siyaset Bilimi ve Uluslararası İlişkiler":
//         return "polData";
//       case "Psikoloji":
//         return "pscData";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           title: const Text("Ders Ekleme"),
//           centerTitle: true,
//         ),
//         bottomNavigationBar: bottomBar2(context, 2),
//         body: _sisLessonsList.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : Container(
//                 decoration: const BoxDecoration(
//                     gradient: LinearGradient(colors: [
//                   Color.fromARGB(255, 255, 255, 255),
//                   Color.fromARGB(255, 39, 113, 148),
//                   Color.fromARGB(255, 255, 255, 255),
//                 ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: DersSectionExpandablePicker(
//                           sisLessonsList: _sisLessonsList,
//                           allLessonNames:
//                               _lessonsNameList.toSet().toList().cast<String>()
//                                 ..sort(),
//                           secilenDersler: secilenDersler,
//                           secilenDersKodlari: secilenDersKodlari,

//                           enableDepartmentPicker: true,
//                           departments: departmenstList, // senin sabit listen
//                           initialDepartmentName:
//                               departmantName, // mevcut seçili ad
//                           // Bölüm key’ine göre veriyi SQLite’tan çek (senin LocalService ile)
//                           fetchLessonsForDepartment: (deptKey) async {
//                             // Burada senin SisLessonsLocalService’i kullanarak tek departmanın verisini getiriyoruz
//                             final local = SisLessonsLocalService();
//                             final map = await local.fetchAllLessonData(
//                                 includeTables: [
//                                   deptKey.toLowerCase()
//                                 ]); // "compData" -> "compdata"
//                             final lessons = map[deptKey] ?? <sisLessons>[];
//                             final names = lessons
//                                 .map((e) => e.ders_adi)
//                                 .whereType<String>()
//                                 .toSet()
//                                 .toList();
//                             return (lessons: lessons, names: names);
//                           },
//                           // Bölüm adı -> key map’ini istersen override edebilirsin, yoksa varsayılan çalışır
//                           mapDepartmentToKey: (name) {
//                             switch (name) {
//                               case "Bilgisayar Mühendisliği":
//                                 return "compData";
//                               case "Endüstri Mühendisliği":
//                                 return "ieData";
//                               case "Elektrik-Elektronik Mühendisliği":
//                                 return "eeeData"; // tablo adın neyse
//                               case "Makine Mühendisliği":
//                                 return "meData";
//                               case "İnşaat Mühendisliği":
//                                 return "ceData";
//                               case "Malzeme Bilimi ve NanoTeknoloji Mühendisliği":
//                                 return "nanoData";
//                               case "Biyomühendislik":
//                                 return "bioeData";
//                               case "Moleküler Biyoloji ve Genetik":
//                                 return "mbgData";
//                               case "Mimarlık":
//                                 return "arcData";
//                               case "İşletme":
//                                 return "baData";
//                               case "Ekonomi":
//                                 return "econData";
//                               case "Siyaset Bilimi ve Uluslararası İlişkiler":
//                                 return "polData";
//                               case "Psikoloji":
//                                 return "pscData";
//                               default:
//                                 return "compData";
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ));
//   }
// }

// /// --- ANA WIDGET ---
// class DersSectionExpandablePicker extends StatefulWidget {
//   final List<sisLessons> sisLessonsList;
//   final List<String> allLessonNames; // duplicate gelebilir
//   final List<String> secilenDersler; // "Ders Adı - <KOD>"
//   final List<String> secilenDersKodlari; // <KOD> (parse YOK)

//   // Diyalog içinde bölüm seçimi göstermek için opsiyoneller:
//   final bool enableDepartmentPicker;
//   final List<String> departments; // görünen adlar
//   final String? initialDepartmentName; // default seçim
//   /// Bölüm adı -> tablo/key (örn: "Bilgisayar Mühendisliği" -> "compdata")
//   final String Function(String departmanName)? mapDepartmentToKey;

//   /// Seçilen tablo/key için dersi getir (SQLite servisinden)
//   /// döndürmesi gereken: lessons + uniq names
//   final Future<({List<sisLessons> lessons, List<String> names})> Function(
//       String deptKey)? fetchLessonsForDepartment;

//   const DersSectionExpandablePicker({
//     super.key,
//     required this.sisLessonsList,
//     required this.allLessonNames,
//     required this.secilenDersler,
//     required this.secilenDersKodlari,
//     this.enableDepartmentPicker = false,
//     this.departments = const [],
//     this.initialDepartmentName,
//     this.mapDepartmentToKey,
//     this.fetchLessonsForDepartment,
//   });

//   @override
//   State<DersSectionExpandablePicker> createState() =>
//       _DersSectionExpandablePickerState();
// }

// class _DersSectionExpandablePickerState
//     extends State<DersSectionExpandablePicker> {
//   // --- Local kopya (aktif bölüm verisi) ---
//   late List<sisLessons> _lessons;
//   late List<String> _lessonNames;

//   // code -> tüm slotlar (sadece aktif bölümden)
//   Map<String, List<sisLessons>> _byCode = {};
//   // ders_adi -> (code -> code)  (section yerine direkt KOD gösteriyoruz)
//   Map<String, Map<String, String>> _codesByLessonName = {};

//   // --- Bölüm bağımsız seçilenler (GLOBAL) ---
//   final Set<String> _selectedCodes = <String>{}; // <KOD>
//   final Set<String> _selectedLabels = <String>{}; // "Ders Adı - <KOD>"

//   // --- Bölüm dışı kodların slotları için GLOBAL CACHE ---
//   final Map<String, List<sisLessons>> _globalByCodeCache = {};
//   bool _isPreloading = false;
//   final Set<String> _preloadingCodes =
//       <String>{}; // YENİ: aynı kod için eşzamanlı preload’u engelle

//   // UI yardımcıları
//   final _hScroll = ScrollController();
//   String _search = '';
//   String? _currentDepartmentName; // diyalog içi dropdown seçimi

//   @override
//   void initState() {
//     super.initState();

//     _lessons = List<sisLessons>.from(widget.sisLessonsList);
//     _lessonNames = widget.allLessonNames.toSet().toList()..sort();

//     // Parent'tan gelenleri içeri al (varsa)
//     _selectedCodes.addAll(widget.secilenDersKodlari);
//     _selectedLabels.addAll(widget.secilenDersler);

//     _currentDepartmentName = widget.initialDepartmentName;
//     _buildIndexes();

//     // Uygulama ilk açıldığında, aktif tabloda olmayan seçili kodlar için preload
//     for (final c in _selectedCodes) {
//       if ((_byCode[c]?.isEmpty ?? true) && !_globalByCodeCache.containsKey(c)) {
//         _preloadCodeFromDb(c);
//       }
//     }
//   }

//   @override
//   void didUpdateWidget(covariant DersSectionExpandablePicker oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!identical(oldWidget.sisLessonsList, widget.sisLessonsList) ||
//         !identical(oldWidget.allLessonNames, widget.allLessonNames)) {
//       _lessons = List<sisLessons>.from(widget.sisLessonsList);
//       _lessonNames = widget.allLessonNames.toSet().toList()..sort();
//       _buildIndexes();
//     }
//   }

//   // Aktif bölüm için indexler (PARSE YOK)
//   void _buildIndexes() {
//     _byCode = {};
//     _codesByLessonName = {};
//     for (final e in _lessons) {
//       final code = e.ders_kodu ?? '';
//       if (code.isEmpty) continue;

//       // 1) code -> slots
//       (_byCode[code] ??= <sisLessons>[]).add(e);

//       // 2) ders_adi -> code
//       final name = e.ders_adi ?? '';
//       if (name.isEmpty) continue;
//       final map = _codesByLessonName[name] ??= <String, String>{};
//       map.putIfAbsent(code, () => code);
//     }
//   }

//   // Label -> KOD (parse etmeden, ayırıcıyı index ile bul)
//   String? _labelToCode(String label) {
//     final idx = label.indexOf(' - ');
//     if (idx == -1) return null;
//     return label.substring(idx + 3);
//   }

//   Future<void> _preloadCodeFromDb(String code) async {
//     // Zaten varsa veya şu an yükleniyorsa tekrar başlatma
//     if (_globalByCodeCache.containsKey(code) || _preloadingCodes.contains(code))
//       return;

//     _preloadingCodes.add(code);
//     setState(() => _isPreloading = true);

//     try {
//       final db = await DatabaseService.I.db;
//       final tables = await db.rawQuery(
//           "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
//       final names = tables.map((e) => e['name'] as String).toList();

//       // Tüm tablolardan çek
//       final List<Map<String, Object?>> rows = [];
//       for (final t in names) {
//         final r =
//             await db.rawQuery("SELECT * FROM $t WHERE ders_kodu = ?", [code]);
//         rows.addAll(r);
//       }

//       // --- TEKİLLEŞTİRME ---
//       // Aynı slot birden fazla tablo/satırda varsa tekrarını ele.
//       final seen = <String>{};
//       final list = <sisLessons>[];
//       for (final m in rows) {
//         final s = SisLessonsDb.fromDb(m);
//         final key = '${s.gun}|${s.saat}|${s.derslik}|${s.ogretim_elemani}';
//         if (seen.add(key)) {
//           list.add(s);
//         }
//       }

//       setState(() {
//         _globalByCodeCache[code] = list;
//       });
//     } finally {
//       _preloadingCodes.remove(code);
//       setState(() => _isPreloading = false);
//     }
//   }

//   // --- Firestore KAYDET (mevcut akışın) ---
//   Future<void> _saveClassToFirestore(List<String> lessonCodes) async {
//     final email = FirebaseAuth.instance.currentUser?.email ?? "";
//     final year = DateTime.now().year.toString();

//     String term;
//     final m = DateTime.now().month;
//     if (m == 9 || m == 10 || m == 11 || m == 12 || m == 1) {
//       term = "GÜZ";
//     } else if (m == 2 || m == 3 || m == 4 || m == 5) {
//       term = "BAHAR";
//     } else {
//       term = "YAZ";
//     }

//     const dateAndHour = "14.08.2025/perşembe/16.00-16.45";
//     const isAttend = false;

//     final userDoc = await FirebaseFirestore.instance
//         .collection("users")
//         .where("email", isEqualTo: email)
//         .get();

//     if (userDoc.docs.isNotEmpty) {
//       final username = userDoc.docs.first.id;
//       for (final code in lessonCodes) {
//         await FirebaseFirestore.instance
//             .collection("users")
//             .doc(username)
//             .collection("classes")
//             .doc(year)
//             .set({
//           term: {
//             code: {
//               "attendance_list": {dateAndHour: isAttend},
//               "total_absence": 0,
//               "absence_from_user": 0,
//             },
//           }
//         }, SetOptions(merge: true));
//       }
//     }
//     showSuccessDialog(context);
//     // local + parent sync temizliği:
//     setState(() {
//       _selectedCodes.clear();
//       _selectedLabels.clear();
//       widget.secilenDersKodlari.clear();
//       widget.secilenDersler.clear();
//     });
//   }

//   void showSuccessDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.check_circle_rounded,
//                   color: Colors.green, size: 60),
//               const SizedBox(height: 15),
//               const Text('Kaydedildi',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               const Text('Dersleriniz başarıyla kaydedildi.',
//                   textAlign: TextAlign.center),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
//                 ),
//                 onPressed: () => Navigator.pop(context),
//                 child:
//                     const Text('Tamam', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- Dialog (üstte bölüm dropdown + arama + liste) ---
//   void _openDialog() {
//     List<String> names = _lessonNames;
//     bool loading = false;

//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             Future<void> _onDeptChanged(String deptName) async {
//               if (widget.fetchLessonsForDepartment == null) return;
//               setStateDialog(() => loading = true);

//               String key;
//               if (widget.mapDepartmentToKey != null) {
//                 key = widget.mapDepartmentToKey!(deptName);
//               } else {
//                 // fallback örnek
//                 key = deptName.contains("Endüstri") ? "iedata" : "compdata";
//               }

//               final fetched = await widget.fetchLessonsForDepartment!(key);
//               setState(() {
//                 _lessons = fetched.lessons;
//                 _lessonNames = fetched.names.toSet().toList()..sort();
//                 _buildIndexes();
//                 // aktif tabloda olmayan seçili kodlar için preload tetikle
//                 for (final c in _selectedCodes) {
//                   if ((_byCode[c]?.isEmpty ?? true) &&
//                       !_globalByCodeCache.containsKey(c)) {
//                     _preloadCodeFromDb(c);
//                   }
//                 }
//               });
//               setStateDialog(() {
//                 names = _lessonNames;
//                 _search = '';
//                 loading = false;
//               });
//             }

//             void _filter(String q) {
//               setStateDialog(() {
//                 _search = q.toLowerCase();
//                 names = _lessonNames
//                     .where((n) => n.toLowerCase().contains(_search))
//                     .toList();
//               });
//             }

//             return Dialog(
//               insetPadding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 height: 560,
//                 width: 480,
//                 child: Column(
//                   children: [
//                     if (widget.enableDepartmentPicker &&
//                         widget.departments.isNotEmpty)
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: FractionallySizedBox(
//                             widthFactor: 0.9,
//                             child: DropdownButton2<String>(
//                               isExpanded: true,
//                               hint: const Text("Bölüm seç"),
//                               value: _currentDepartmentName,
//                               items: [
//                                 for (int i = 0;
//                                     i < widget.departments.length;
//                                     i++) ...[
//                                   DropdownMenuItem(
//                                     value: widget.departments[i],
//                                     child: Container(
//                                         width: double.infinity,
//                                         decoration: const BoxDecoration(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(10)),
//                                             border: Border(
//                                               bottom: BorderSide(
//                                                   color: Colors.blue,
//                                                   width: 4.0),
//                                               right: BorderSide(
//                                                   color: Colors.blue,
//                                                   width: 2.0),
//                                               // left: BorderSide(
//                                               //     color: Colors.black,
//                                               //     width: 2.0)
//                                               // top: BorderSide(
//                                               //     color: Colors.black,
//                                               //     width: 1.0)
//                                             )),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(6.0),
//                                           child: Text(widget.departments[i]),
//                                         )),
//                                   ),
//                                 ]
//                               ],
//                               onChanged: (val) {
//                                 setState(() => _currentDepartmentName = val);
//                                 _onDeptChanged(val!);
//                               },
//                               menuItemStyleData:
//                                   const MenuItemStyleData(height: 60),
//                               buttonStyleData: const ButtonStyleData(
//                                 padding: EdgeInsets.symmetric(horizontal: 8),
//                                 height: 50,
//                                 decoration: BoxDecoration(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(12)),
//                                   border: Border.fromBorderSide(
//                                       BorderSide(color: Colors.grey)),
//                                 ),
//                               ),
//                               barrierColor: Colors.black54,
//                               // barrierLabel: ">",
//                               underline: const Text(""),

//                               dropdownStyleData: DropdownStyleData(
//                                 // offset: Offset(0, -30),
//                                 elevation: 6,
//                                 // padding: EdgeInsets.all(10),
//                                 maxHeight:
//                                     MediaQuery.of(context).size.height * 0.45,
//                                 width: MediaQuery.of(context).size.width * 0.85,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             )

//                             // DropdownButtonFormField<String>(

//                             //   menuMaxHeight: 400,
//                             //   // alignment: Alignment(0.5, 0.5),
//                             //   borderRadius: BorderRadius.all(Radius.circular(20)),
//                             //   // padding: EdgeInsets.all(12),
//                             //   // isDense: true,

//                             //   isExpanded: true,
//                             //   // menuMaxWidth: MediaQuery.of(context).size.width * 0.9,
//                             //   value: _currentDepartmentName ??
//                             //       widget.departments.first,
//                             //   items: widget.departments
//                             //       .map((d) => DropdownMenuItem(
//                             //           value: d,
//                             //           child: Text(d,
//                             //               overflow: TextOverflow.ellipsis)))
//                             //       .toList(),
//                             //   selectedItemBuilder: (ctx) => widget.departments
//                             //       .map((d) => Align(
//                             //             alignment: Alignment.centerLeft,
//                             //             child: Text(d,
//                             //                 overflow: TextOverflow.ellipsis),
//                             //           ))
//                             //       .toList(),
//                             //   onChanged: (val) {
//                             //     if (val == null) return;
//                             //     _currentDepartmentName = val;
//                             //     _onDeptChanged(val);
//                             //   },
//                             //   decoration: const InputDecoration(
//                             //     labelText: "Bölüm seç",
//                             //     prefixIcon: Icon(Icons.school),
//                             //     border: OutlineInputBorder(),
//                             //   ),
//                             // ),
//                             ),
//                       ),
//                     if (widget.enableDepartmentPicker &&
//                         widget.departments.isNotEmpty)
//                       const SizedBox(height: 10),
//                     TextField(
//                       decoration: InputDecoration(
//                         hintText: "Ders ara...",
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       onChanged: _filter,
//                     ),
//                     const SizedBox(height: 10),
//                     if (loading)
//                       const Expanded(
//                           child: Center(child: CircularProgressIndicator()))
//                     else
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: names.length,
//                           itemBuilder: (context, i) {
//                             final dersAdi = names[i];
//                             final codesMap = _codesByLessonName[dersAdi] ??
//                                 const <String, String>{};
//                             final codes = codesMap.keys.toList()..sort();

//                             return ExpansionTile(
//                               title: Text(dersAdi),
//                               children: codes.map((codeKey) {
//                                 final code = codesMap[codeKey]!;
//                                 final isSelected =
//                                     _selectedCodes.contains(code);

//                                 return CheckboxListTile(
//                                   subtitle: Text(code),
//                                   value: isSelected,
//                                   activeColor: Colors.blueAccent,
//                                   onChanged: (val) {
//                                     setState(() {
//                                       final label = "$dersAdi - $code";
//                                       if (val == true) {
//                                         _selectedLabels.add(label);
//                                         _selectedCodes.add(code);
//                                         if ((_byCode[code]?.isEmpty ?? true) &&
//                                             !_globalByCodeCache
//                                                 .containsKey(code)) {
//                                           _preloadCodeFromDb(code);
//                                         }
//                                       } else {
//                                         _selectedLabels.remove(label);
//                                         _selectedCodes.remove(code);
//                                       }
//                                       // parent ile sync (istersen)
//                                       widget.secilenDersler
//                                         ..clear()
//                                         ..addAll(_selectedLabels);
//                                       widget.secilenDersKodlari
//                                         ..clear()
//                                         ..addAll(_selectedCodes);
//                                     });
//                                     setStateDialog(() {});
//                                   },
//                                 );
//                               }).toList(),
//                             );
//                           },
//                         ),
//                       ),
//                     const SizedBox(height: 8),
//                     ElevatedButton.icon(
//                       onPressed: () => Navigator.of(context).pop(),
//                       icon: const Icon(
//                         Icons.check,
//                         color: Colors.blue,
//                       ),
//                       label: const Text("Tamam",
//                           style: TextStyle(color: Colors.blue)),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // --- Detaylar: yatay scroll, her kolonda max 2 kart ---
//   Widget _buildSelectedDetailsList() {
//     final codes = _selectedCodes.toList();

//     List<sisLessons>? _slotsFor(String code) {
//       final a = _byCode[code];
//       if (a != null && a.isNotEmpty) return a;
//       final g = _globalByCodeCache[code];
//       if (g != null && g.isNotEmpty) return g;
//       return null;
//     }

//     final selectedByCode =
//         <({String code, String name, List<sisLessons> slots})>[];
//     for (final code in codes) {
//       final slots = _slotsFor(code);
//       if (slots != null) {
//         selectedByCode.add((
//           code: code,
//           name: slots.first.ders_adi ?? '-',
//           slots: slots,
//         ));
//       } else {
//         // henüz yüklenmediyse arkada tetikle
//         _preloadCodeFromDb(code);
//       }
//     }

//     List<List<({String code, String name, List<sisLessons> slots})>> chunk2(
//         List<({String code, String name, List<sisLessons> slots})> items) {
//       final out =
//           <List<({String code, String name, List<sisLessons> slots})>>[];
//       for (var i = 0; i < items.length; i += 2) {
//         out.add(items.sublist(i, i + 2 > items.length ? items.length : i + 2));
//       }
//       return out;
//     }

//     const cardWidth = 350.0;
//     const cardHeight = 250.0;
//     const vGap = 10.0;
//     final totalHeight = cardHeight * 2 + vGap + 12;

//     final columns = chunk2(selectedByCode);

//     if (columns.isEmpty && _isPreloading) {
//       return const SizedBox(
//         height: 60,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return SizedBox(
//       height: totalHeight,
//       child: Scrollbar(
//         controller: _hScroll,
//         thumbVisibility: true,
//         child: SingleChildScrollView(
//           controller: _hScroll,
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: List.generate(columns.length, (idx) {
//               final col = columns[idx];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 6),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: cardWidth,
//                       height: cardHeight,
//                       child: LessonCard(
//                         dersKodu: col[0].code,
//                         dersAdi: col[0].name,
//                         slots: col[0].slots,
//                       ),
//                     ),
//                     const SizedBox(height: vGap),
//                     if (col.length > 1)
//                       SizedBox(
//                         width: cardWidth,
//                         height: cardHeight,
//                         child: LessonCard(
//                           dersKodu: col[1].code,
//                           dersAdi: col[1].name,
//                           slots: col[1].slots,
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final labels = _selectedLabels.toList();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         TextButton(
//           onPressed: _openDialog,
//           child: Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(Radius.circular(25)),
//               border: Border(
//                 bottom: BorderSide(width: 6.0, color: Colors.black),
//                 right: BorderSide(width: 4.0, color: Colors.black),
//                 top: BorderSide(width: 1.0, color: Colors.black),
//               ),
//             ),
//             child: const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text("DERS EKLEMEK İÇİN TIKLAYIN",
//                   style: TextStyle(fontSize: 23, color: Colors.black)),
//             ),
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Chip container + Kaydet
//         Stack(
//           alignment: const Alignment(0.0, 1.5),
//           children: [
//             Container(
//               width: double.infinity,
//               height: 180,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: labels.isEmpty ? null : Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Wrap(
//                   spacing: 2,
//                   runSpacing: 6,
//                   direction: Axis.vertical,
//                   children: labels.map((label) {
//                     final code = _labelToCode(label);
//                     return Chip(
//                       label: Text(label,
//                           style: const TextStyle(color: Colors.white)),
//                       backgroundColor: Colors.blue,
//                       deleteIcon: const Icon(Icons.close, color: Colors.white),
//                       onDeleted: () {
//                         setState(() {
//                           _selectedLabels.remove(label);
//                           if (code != null) _selectedCodes.remove(code);

//                           // parent ile sync (istersen)
//                           widget.secilenDersler
//                             ..clear()
//                             ..addAll(_selectedLabels);
//                           widget.secilenDersKodlari
//                             ..clear()
//                             ..addAll(_selectedCodes);
//                         });
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             if (_selectedCodes.isNotEmpty)
//               TextButton(
//                 onPressed: () => _saveClassToFirestore(_selectedCodes.toList()),
//                 child: Container(
//                   width: 100,
//                   decoration: const BoxDecoration(
//                     color: Color.fromARGB(255, 14, 224, 21),
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Text("Kaydet",
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 17)),
//                         SizedBox(width: 10),
//                         Icon(Icons.save_outlined, color: Colors.white),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),

//         const SizedBox(height: 25),

//         // Detay kartları
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: labels.isEmpty ? null : Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12),
//             border:
//                 labels.isEmpty ? null : Border.all(color: Colors.grey.shade300),
//           ),
//           child: _buildSelectedDetailsList(),
//         ),
//       ],
//     );
//   }
// }

// /// Tek bir ders için kart
// class LessonCard extends StatelessWidget {
//   final String dersKodu;
//   final String dersAdi;
//   final List<sisLessons> slots; // aynı ders_kodu altındaki tüm kayıtlar

//   const LessonCard({
//     super.key,
//     required this.dersKodu,
//     required this.dersAdi,
//     required this.slots,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final toplamSaat = slots.length;

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Başlık
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Flexible(
//                     child: Text(
//                       '$dersAdi ($dersKodu)',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   Chip(
//                     label: Text('$toplamSaat saat/hafta'),
//                     backgroundColor: Colors.blue.shade50,
//                     avatar: const Icon(Icons.access_time,
//                         size: 18, color: Colors.blue),
//                     labelStyle: const TextStyle(color: Colors.blue),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               // Öğretim Elemanı
//               Row(
//                 children: [
//                   const Icon(Icons.person, size: 18, color: Colors.grey),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(slots.first.ogretim_elemani ?? "-",
//                         style: const TextStyle(fontSize: 14)),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),

//               // Gün/Saat/Derslik listesi
//               ...slots.map((s) => Padding(
//                     padding: const EdgeInsets.only(bottom: 4),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.calendar_today,
//                             size: 16, color: Colors.grey),
//                         const SizedBox(width: 4),
//                         Text(s.gun ?? "-",
//                             style: const TextStyle(fontSize: 14)),
//                         const SizedBox(width: 12),
//                         const Icon(Icons.access_time,
//                             size: 16, color: Colors.grey),
//                         const SizedBox(width: 4),
//                         Text(s.saat ?? "-",
//                             style: const TextStyle(fontSize: 14)),
//                         const SizedBox(width: 12),
//                         const Icon(Icons.room, size: 16, color: Colors.grey),
//                         const SizedBox(width: 4),
//                         Expanded(
//                             child: Text(s.derslik ?? "-",
//                                 style: const TextStyle(fontSize: 14))),
//                       ],
//                     ),
//                   )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
