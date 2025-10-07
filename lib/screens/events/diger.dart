// // // import 'dart:ui';

// // // import 'package:flutter/material.dart';
// // // import 'package:home_page/bottom.dart';
// // // import 'package:home_page/utilts/models/events.dart';
// // // import 'package:url_launcher/url_launcher.dart';

// // // class EventDetailPage extends StatelessWidget {
// // //   final Events event;

// // //   const EventDetailPage({Key? key, required this.event}) : super(key: key);

// // //   String formatDate(String? dateString) {
// // //     if (dateString == null || dateString.isEmpty) return "Tarih Bilinmiyor";

// // //     try {
// // //       // Tarih verisini alıyoruz, örneğin: 2025-03-28T21:00:00.000Z
// // //       String cleanDate = dateString.split("T")[0]; // "2025-03-28"

// // //       // Tarih parçalarını ayırıyoruz
// // //       List<String> parts = cleanDate.split("-"); // ["2025", "03", "28"]

// // //       // İstediğimiz formatı oluşturuyoruz: "28.03.2025"
// // //       String formattedDate = "${parts[2]}.${parts[1]}.${parts[0]}";

// // //       return formattedDate; // "28.03.2025"
// // //     } catch (e) {
// // //       return "Geçersiz Tarih"; // Eğer format hatası olursa
// // //     }
// // //   }

// // //   void openInstagram(String username) async {
// // //     // Instagram uygulaması için URL
// // //     final Uri url = Uri.parse('instagram://user?username=$username');

// // //     // Web tarayıcı URL'si
// // //     final Uri webUrl = Uri.parse('https://www.instagram.com/$username/');

// // //     // Instagram uygulamasına yönlendirme
// // //     if (await canLaunchUrl(url)) {
// // //       await launchUrl(url); // Eğer uygulama varsa, uygulama ile açılır
// // //     } else if (await canLaunchUrl(webUrl)) {
// // //       await launchUrl(webUrl); // Uygulama yoksa, web tarayıcısında açılır
// // //     } else {
// // //       throw 'Instagram hesabı açılamadı';
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       bottomNavigationBar: bottomBar2(context, 2), // Alt gezinme çubuğu

// // //       appBar: AppBar(
// // //         title: Text(
// // //           event.etkinlik_adi ?? "ETKİNLİK DETAYLARI",
// // //           style: const TextStyle(fontWeight: FontWeight.bold),
// // //         ),
// // //         backgroundColor: Colors.white,
// // //       ),
// // //       body: SingleChildScrollView(
// // //         child: Container(
// // //           height: MediaQuery.of(context).size.height,
// // //           decoration: const BoxDecoration(
// // //               gradient: LinearGradient(colors: [
// // //             Color.fromARGB(255, 255, 255, 255),
// // //             Color.fromARGB(255, 39, 113, 148),
// // //             Color.fromARGB(255, 255, 255, 255),
// // //           ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
// // //           child: Padding(
// // //             padding: const EdgeInsets.all(16.0),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Stack(
// // //                   alignment: Alignment(1.0, -0.1),
// // //                   children: [
// // //                     Transform.translate(
// // //                       offset: Offset(-65, 0),
// // //                       child: Container(
// // //                         // width: 250,
// // //                         decoration: BoxDecoration(
// // //                           borderRadius:
// // //                               BorderRadius.circular(12), // Kenar yuvarlama
// // //                           // color: Colors.amber
// // //                         ),
// // //                         padding: const EdgeInsets.all(
// // //                             8), // Padding ekleyerek metnin etrafına boşluk ekliyoruz
// // //                         child: Stack(
// // //                           alignment: Alignment(0.30, 0.001),
// // //                           children: [
// // //                             Image.asset(
// // //                               "assets/images/calendars/tabela6.png",
// // //                               alignment: Alignment.topLeft,
// // //                               height: 350,
// // //                               width: 350,
// // //                             ),
// // //                             Container(
// // //                               // color: Colors.blue,
// // //                               width: 150,
// // //                               height: 100,
// // //                               child: Text(
// // //                                 "${event.kulup}",
// // //                                 textAlign: TextAlign.left,
// // //                                 // overflow: TextOverflow.visible,
// // //                                 softWrap: true,
// // //                                 style: const TextStyle(
// // //                                     fontSize: 16,
// // //                                     fontWeight: FontWeight.w900,
// // //                                     color: Colors.white),
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     Stack(
// // //                       // alignment: Alignment.topCenter,
// // //                       alignment: Alignment(0.25, 0.5),
// // //                       children: [
// // //                         Image.asset(
// // //                           "assets/images/calendars/4.png",
// // //                           width: 100,
// // //                           height: 100,
// // //                         ),
// // //                         Text("Tarih\n${formatDate(event.etkinlik_tarihi)}",
// // //                             style: const TextStyle(
// // //                                 fontSize: 17, fontWeight: FontWeight.bold)),
// // //                       ],
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 const SizedBox(
// // //                   height: 15,
// // //                 ),
// // //                 Transform.translate(
// // //                   offset: const Offset(0, 10), // 10 piksel aşağı kaydır
// // //                   child: Container(
// // //                     decoration: const BoxDecoration(
// // //                         color: Colors.black,
// // //                         borderRadius: BorderRadius.only(
// // //                             topRight: Radius.circular(12),
// // //                             topLeft: Radius.circular(8),
// // //                             // bottomLeft: Radius.circular(12),
// // //                             bottomRight: Radius.circular(12)),
// // //                         border: Border(
// // //                             bottom: BorderSide(width: 6.0, color: Colors.white),
// // //                             right:
// // //                                 BorderSide(width: 3.0, color: Colors.white))),
// // //                     padding: const EdgeInsets.all(10),
// // //                     child: const Text(
// // //                       "Etkinlik Detayları: ",
// // //                       style: TextStyle(
// // //                         fontSize: 17,
// // //                         fontWeight: FontWeight.bold,
// // //                         color: Colors.white,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 Container(
// // //                   width: double.infinity,
// // //                   decoration: const BoxDecoration(
// // //                       color: Colors.white,
// // //                       borderRadius: BorderRadius.only(
// // //                           topRight: Radius.circular(12),
// // //                           bottomLeft: Radius.circular(12),
// // //                           bottomRight: Radius.circular(12)),
// // //                       border: Border(
// // //                           bottom: BorderSide(width: 6.0),
// // //                           right: BorderSide(width: 5.0))),
// // //                   padding: const EdgeInsets.all(8),
// // //                   child: Row(
// // //                     children: [
// // //                       // Expanded ekliyoruz
// // //                       Expanded(
// // //                         child: Text(
// // //                           "${event.etkinlik_aciklamasi}",
// // //                           style: const TextStyle(
// // //                               fontSize: 15, color: Colors.black),
// // //                           // overflow:
// // //                           //     TextOverflow.ellipsis, // Taşmayı engellemek için
// // //                           softWrap:
// // //                               true, // Uzun metinlerde satır kayması yapacak
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 const SizedBox(
// // //                   height: 25,
// // //                 ),
// // //                 ClipRRect(
// // //                   borderRadius: BorderRadius.circular(16),
// // //                   child: Image.network(
// // //                     event.uygulama_ici_resim ?? "",
// // //                     fit: BoxFit.fill,
// // //                     width: double.infinity,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 20),
// // //                 if (event.etkinlik_afisi != null &&
// // //                     event.etkinlik_afisi!.isNotEmpty)
// // //                   Container(
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.white,
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     padding: const EdgeInsets.all(8),
// // //                     child: Image.network(event.etkinlik_afisi!,
// // //                         fit: BoxFit.fill, width: double.infinity),
// // //                   ),
// // //                 const SizedBox(
// // //                   height: 25,
// // //                 ),
// // //                 Row(
// // //                   spacing: 120,
// // //                   children: [
// // //                     Column(
// // //                       children: [
// // //                         const Text("İletişim: ",
// // //                             style: TextStyle(
// // //                                 fontSize: 14, fontWeight: FontWeight.bold)),
// // //                         const SizedBox(
// // //                           height: 8,
// // //                         ),
// // //                         InkWell(
// // //                           onTap: () {
// // //                             openInstagram(event.sorumlu_iletisim ?? "");
// // //                           }, // Burada mail göndermek için bir işlem ekleyebilirsin
// // //                           child: Row(
// // //                             children: [
// // //                               const SizedBox(width: 10),
// // //                               Image.network(
// // //                                 "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/640px-Instagram_icon.png",
// // //                                 height: 25,
// // //                                 width: 25,
// // //                               ),
// // //                               const SizedBox(width: 15),
// // //                               Text(
// // //                                 event.sorumlu_iletisim ?? "",
// // //                                 style: const TextStyle(
// // //                                     fontSize: 14, color: Colors.black),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     ElevatedButton(
// // //                       style: ButtonStyle(
// // //                         backgroundColor:
// // //                             WidgetStateProperty.resolveWith<Color?>(
// // //                           (Set<WidgetState> states) {
// // //                             if (states.contains(WidgetState.pressed)) {
// // //                               return Colors.amber;
// // //                               // Theme.of(context)
// // //                               //     .colorScheme
// // //                               //     .primary
// // //                               //     .withOpacity(0.5);
// // //                             }
// // //                             return Colors
// // //                                 .blueAccent; // Use the component's default.
// // //                           },
// // //                         ),
// // //                       ),
// // //                       child: const Text('Hemen katıl',
// // //                           style: TextStyle.new(color: Colors.white)),
// // //                       onPressed: () {
// // //                         // ...
// // //                       },
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // //////////////////////////////////////////////////////////////////////

// // import 'package:flutter/material.dart';
// // import 'package:home_page/bottom.dart';
// // import 'package:url_launcher/url_launcher.dart';

// // // event modelindeki alan adlarını seninkilerle birebir kullandım:
// // // kulup, etkinlik_adi, etkinlik_tarihi, etkinlik_aciklamasi,
// // // uygulama_ici_resim (1. görsel), etkinlik_afisi (2. görsel?),
// // // sorumlu_iletisim, kulup_sayfasi, sorumlu_uye
// // class EventDetailPage extends StatefulWidget {
// //   const EventDetailPage({super.key, required this.event});
// //   final dynamic event; // kendi tipini koy (EventModel vs.)

// //   @override
// //   State<EventDetailPage> createState() => _EventDetailPageState();
// // }

// // class _EventDetailPageState extends State<EventDetailPage> {
// //   final PageController _pageController = PageController();
// //   int _pageIndex = 0;

// //   @override
// //   void dispose() {
// //     _pageController.dispose();
// //     super.dispose();
// //   }

// //   // Kullanıcıdaki formatDate fonksiyonunu kullanıyorsan burayı silebilirsin.
// //   // String _fmt(DateTime? d) {
// //   //   if (d == null) return "-";
// //   //   return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
// //   // }

// //   Future<void> _open(String url) async {
// //     final uri = Uri.tryParse(url);
// //     if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
// //   }

// //   Future<void> _openInstagramHandle(String handleOrUrl) async {
// //     final h = handleOrUrl.trim();
// //     if (h.isEmpty) return;
// //     final url = h.startsWith("http")
// //         ? h
// //         : "https://instagram.com/${h.startsWith("@") ? h.substring(1) : h}";
// //     await _open(url);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final event = widget.event;

// //     // Görseller: 1 veya 2 olabilir
// //     final List<String> images = [
// //       if ((event.uygulama_ici_resim ?? "").toString().isNotEmpty)
// //         event.uygulama_ici_resim!,
// //       if ((event.etkinlik_afisi ?? "").toString().isNotEmpty)
// //         event.etkinlik_afisi!,
// //     ];

// //     final theme = Theme.of(context);
// //     final color = theme.colorScheme;

// //     return Scaffold(
// //       extendBodyBehindAppBar: true,
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         foregroundColor: Colors.white,
// //         elevation: 0,
// //         title: Text(
// //           event.etkinlik_adi ?? "Etkinlik Detayları",
// //           maxLines: 1,
// //           overflow: TextOverflow.ellipsis,
// //         ),
// //       ),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
// //       floatingActionButton: SizedBox(
// //         width: MediaQuery.of(context).size.width - 32,
// //         child: ElevatedButton(
// //           style: ElevatedButton.styleFrom(
// //             padding: const EdgeInsets.symmetric(vertical: 14),
// //             shape:
// //                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           ),
// //           onPressed: () {
// //             // katılım aksiyonun
// //           },
// //           child: const Text("Hemen katıl", style: TextStyle(fontSize: 16)),
// //         ),
// //       ),
// //       body: CustomScrollView(
// //         slivers: [
// //           // HERO HEADER (tek veya çift görsel için slider)
// //           SliverAppBar(
// //             automaticallyImplyLeading: true,
// //             pinned: true,
// //             expandedHeight: 290,
// //             backgroundColor: Colors.black,
// //             flexibleSpace: FlexibleSpaceBar(
// //               collapseMode: CollapseMode.parallax,
// //               background: Stack(
// //                 fit: StackFit.expand,
// //                 children: [
// //                   PageView.builder(
// //                     controller: _pageController,
// //                     itemCount: images.isEmpty ? 1 : images.length,
// //                     onPageChanged: (i) => setState(() => _pageIndex = i),
// //                     itemBuilder: (_, i) {
// //                       final url = images.isEmpty ? null : images[i];
// //                       return url == null
// //                           ? Container(color: Colors.grey.shade300)
// //                           : Image.network(
// //                               url,
// //                               fit: BoxFit.cover,
// //                               errorBuilder: (_, __, ___) =>
// //                                   Container(color: Colors.grey.shade300),
// //                             );
// //                     },
// //                   ),
// //                   // gradient overlay
// //                   Container(
// //                     decoration: const BoxDecoration(
// //                       gradient: LinearGradient(
// //                         begin: Alignment.topCenter,
// //                         end: Alignment.bottomCenter,
// //                         colors: [
// //                           Colors.transparent,
// //                           Colors.black54,
// //                           Colors.black87
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   // üstte küçük etiketler
// //                   Positioned(
// //                     left: 16,
// //                     bottom: 72,
// //                     child: Wrap(
// //                       spacing: 8,
// //                       runSpacing: 8,
// //                       children: [
// //                         _Chip(
// //                             text: event.kulup ?? "Kulüp",
// //                             icon: Icons.groups_2_outlined),
// //                         _Chip(
// //                             text: event.etkinlik_tarihi,
// //                             icon: Icons.event_outlined),
// //                       ],
// //                     ),
// //                   ),
// //                   // sayfa göstergesi (2 görsel varsa)
// //                   if (images.length > 1)
// //                     Positioned(
// //                       bottom: 16,
// //                       left: 0,
// //                       right: 0,
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: List.generate(
// //                           images.length,
// //                           (i) => AnimatedContainer(
// //                             duration: const Duration(milliseconds: 250),
// //                             margin: const EdgeInsets.symmetric(horizontal: 4),
// //                             height: 6,
// //                             width: _pageIndex == i ? 20 : 8,
// //                             decoration: BoxDecoration(
// //                               color: _pageIndex == i
// //                                   ? Colors.white
// //                                   : Colors.white54,
// //                               borderRadius: BorderRadius.circular(4),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           // CONTENT
// //           SliverToBoxAdapter(
// //             child: Padding(
// //               padding: const EdgeInsets.fromLTRB(
// //                   16, 16, 16, 96), // altta FAB için boşluk
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Etkinlik Başlığı
// //                   Text(
// //                     event.etkinlik_adi ?? "",
// //                     style: theme.textTheme.headlineSmall
// //                         ?.copyWith(fontWeight: FontWeight.w800),
// //                   ),
// //                   const SizedBox(height: 12),

// //                   // Hızlı Bilgiler (kulüp adı, sorumlu kişi, kulüp sayfası)
// //                   Card(
// //                     elevation: 0,
// //                     color: theme.colorScheme.surface,
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(16)),
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(14),
// //                       child: Column(
// //                         children: [
// //                           _InfoRow(
// //                             icon: Icons.groups_3_outlined,
// //                             label: "Kulüp",
// //                             value: event.kulup ?? "-",
// //                           ),
// //                           const SizedBox(height: 10),
// //                           _InfoRow(
// //                             icon: Icons.person_outline,
// //                             label: "Sorumlu",
// //                             value: (event.sorumlu_uye ??
// //                                 event.sorumlu_iletisim ??
// //                                 "-"),
// //                           ),
// //                           const SizedBox(height: 10),
// //                           if ((event.kulup_sayfasi ?? "").toString().isNotEmpty)
// //                             InkWell(
// //                               onTap: () => _open(event.kulup_sayfasi!),
// //                               borderRadius: BorderRadius.circular(12),
// //                               child: Row(
// //                                 children: [
// //                                   const Icon(Icons.link_outlined),
// //                                   const SizedBox(width: 12),
// //                                   Expanded(
// //                                     child: Text(
// //                                       "Kulüp sayfası",
// //                                       style:
// //                                           theme.textTheme.bodyMedium?.copyWith(
// //                                         color: color.primary,
// //                                         fontWeight: FontWeight.w600,
// //                                         decoration: TextDecoration.underline,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   const Icon(Icons.open_in_new, size: 18),
// //                                 ],
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),

// //                   const SizedBox(height: 16),

// //                   // Detaylar
// //                   Text("Etkinlik Detayları",
// //                       style: theme.textTheme.titleMedium
// //                           ?.copyWith(fontWeight: FontWeight.w800)),
// //                   const SizedBox(height: 8),
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: theme.colorScheme.surface,
// //                       borderRadius: BorderRadius.circular(16),
// //                       border:
// //                           Border.all(color: theme.dividerColor.withOpacity(.2)),
// //                     ),
// //                     padding: const EdgeInsets.all(14),
// //                     child: Text(
// //                       event.etkinlik_aciklamasi ?? "-",
// //                       style: theme.textTheme.bodyMedium,
// //                     ),
// //                   ),

// //                   const SizedBox(height: 16),

// //                   // İletişim
// //                   Text("İletişim",
// //                       style: theme.textTheme.titleMedium
// //                           ?.copyWith(fontWeight: FontWeight.w800)),
// //                   const SizedBox(height: 8),
// //                   Card(
// //                     elevation: 0,
// //                     color: theme.colorScheme.surface,
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(16)),
// //                     child: ListTile(
// //                       leading: const Icon(Icons.alternate_email_outlined),
// //                       title: Text(event.sorumlu_iletisim ?? "-"),
// //                       subtitle: const Text("Instagram / iletişim bilgisi"),
// //                       trailing: const Icon(Icons.open_in_new),
// //                       onTap: () =>
// //                           _openInstagramHandle(event.sorumlu_iletisim ?? ""),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //       bottomNavigationBar: bottomBar2(context, 2), // mevcut yapını korudum
// //     );
// //   }
// // }

// // // —————————————— küçük yardımcı widget’lar ——————————————

// // class _Chip extends StatelessWidget {
// //   const _Chip({required this.text, required this.icon});
// //   final String text;
// //   final IconData icon;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(.14),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.white24),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 16, color: Colors.white),
// //           const SizedBox(width: 6),
// //           Text(text,
// //               style: const TextStyle(
// //                   color: Colors.white, fontWeight: FontWeight.w600)),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class _InfoRow extends StatelessWidget {
// //   const _InfoRow(
// //       {required this.icon, required this.label, required this.value});
// //   final IconData icon;
// //   final String label;
// //   final String value;

// //   @override
// //   Widget build(BuildContext context) {
// //     final t = Theme.of(context).textTheme;
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Icon(icon, size: 20),
// //         const SizedBox(width: 10),
// //         Expanded(
// //           child: RichText(
// //             text: TextSpan(
// //               style: t.bodyMedium,
// //               children: [
// //                 TextSpan(
// //                     text: "$label: ",
// //                     style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
// //                 TextSpan(text: value),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// //////////////////////////////////////

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.dart';
// import 'package:palette_generator/palette_generator.dart';

// class EventDetailPage extends StatefulWidget {
//   const EventDetailPage({super.key, required this.event});
//   final dynamic event; // kendi modelin

//   @override
//   State<EventDetailPage> createState() => _EventDetailPageState();
// }

// class _EventDetailPageState extends State<EventDetailPage> {
//   final PageController _pc = PageController();
//   int _index = 0;
//   Timer? _timer;

//   // renkler
//   Color _dominant = const Color(0xFF2C2C2C);
//   Color get _onDom =>
//       _dominant.computeLuminance() > 0.5 ? Colors.black : Colors.white;

//   List<String> get _images {
//     final e = widget.event;
//     return [
//       if ((e.uygulama_ici_resim ?? "").toString().isNotEmpty)
//         e.uygulama_ici_resim!,
//       if ((e.etkinlik_afisi ?? "").toString().isNotEmpty) e.etkinlik_afisi!,
//     ];
//   }

//   @override
//   void initState() {
//     super.initState();
//     _extractPalette();
//     _startAutoSlide();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pc.dispose();
//     super.dispose();
//   }

//   void _startAutoSlide() {
//     _timer?.cancel();
//     if (_images.length <= 1) return;
//     _timer = Timer.periodic(const Duration(seconds: 4), (_) {
//       if (!mounted) return;
//       final next = (_index + 1) % _images.length;
//       _pc.animateToPage(next,
//           duration: const Duration(milliseconds: 450), curve: Curves.easeOut);
//     });
//   }

//   Future<void> _extractPalette() async {
//     if (_images.isEmpty) return;
//     try {
//       final pg = await PaletteGenerator.fromImageProvider(
//         NetworkImage(_images.first),
//         maximumColorCount: 12,
//       );
//       final c = pg.dominantColor?.color ?? pg.vibrantColor?.color;
//       if (c != null) setState(() => _dominant = c);
//     } catch (_) {
//       // görsel alınamazsa varsayılan rengi kullan
//     }
//   }

//   // String _fmt(DateTime? d) =>
//   //     d == null ? "-" : DateFormat('dd.MM.yyyy').format(d.toLocal());

//   Future<void> _open(String url) async {
//     final u = Uri.tryParse(url);
//     if (u != null) await launchUrl(u, mode: LaunchMode.externalApplication);
//   }

//   Future<void> _openInstagramHandle(String h) async {
//     final handle = h.trim();
//     if (handle.isEmpty) return;
//     final url = handle.startsWith("http")
//         ? handle
//         : "https://instagram.com/${handle.startsWith("@") ? handle.substring(1) : handle}";
//     await _open(url);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final e = widget.event;
//     final images = _images;
//     final t = Theme.of(context);

//     return Scaffold(
//       // CTA en altta sabit
//       bottomNavigationBar: SafeArea(
//         minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//         child: SizedBox(
//           height: 52,
//           child: ElevatedButton(
//             onPressed: () {/* join action */},
//             style: ElevatedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16)),
//             ),
//             child: const Text("Hemen katıl"),
//           ),
//         ),
//       ),
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             pinned: true,
//             expandedHeight: 320,
//             backgroundColor: _dominant,
//             foregroundColor: _onDom,
//             title: Text(e.etkinlik_adi ?? "Etkinlik Detayları"),
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.parallax,
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // SLIDER (auto + swipe)
//                   PageView.builder(
//                     controller: _pc,
//                     itemCount: images.isEmpty ? 1 : images.length,
//                     onPageChanged: (i) => setState(() => _index = i),
//                     itemBuilder: (_, i) {
//                       if (images.isEmpty) {
//                         return Container(color: Colors.grey.shade300);
//                       }
//                       return Image.network(
//                         images[i],
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) =>
//                             Container(color: Colors.grey.shade300),
//                       );
//                     },
//                   ),
//                   // gradient: dominant renkten saydamlığa
//                   DecoratedBox(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           _dominant.withOpacity(.10),
//                           _dominant.withOpacity(.45),
//                           _dominant.withOpacity(.85),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // üst etiketler
//                   Positioned(
//                     left: 16,
//                     bottom: 76,
//                     right: 16,
//                     child: Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         _Tag(
//                             text: e.kulup ?? "Kulüp",
//                             icon: Icons.groups_2_outlined,
//                             fg: _onDom,
//                             bg: _onDom.withOpacity(.18)),
//                         _Tag(
//                             text: e.etkinlik_tarihi,
//                             icon: Icons.event_outlined,
//                             fg: _onDom,
//                             bg: _onDom.withOpacity(.18)),
//                       ],
//                     ),
//                   ),
//                   // DOTS (tıklanabilir)
//                   if (images.length > 1)
//                     Positioned(
//                       bottom: 16,
//                       left: 0,
//                       right: 0,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(images.length, (i) {
//                           final active = i == _index;
//                           return GestureDetector(
//                             onTap: () => _pc.animateToPage(i,
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeOut),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 250),
//                               margin: const EdgeInsets.symmetric(horizontal: 5),
//                               height: 7,
//                               width: active ? 22 : 8,
//                               decoration: BoxDecoration(
//                                 color: _onDom.withOpacity(active ? .95 : .55),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           // CONTENT
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(e.etkinlik_adi ?? "",
//                       style: t.textTheme.headlineSmall
//                           ?.copyWith(fontWeight: FontWeight.w800)),
//                   const SizedBox(height: 12),
//                   _Card(
//                     child: Column(
//                       children: [
//                         _InfoRow(
//                             icon: Icons.groups_3_outlined,
//                             label: "Kulüp",
//                             value: e.kulup ?? "-"),
//                         const SizedBox(height: 10),
//                         _InfoRow(
//                             icon: Icons.person_outline,
//                             label: "Sorumlu",
//                             value:
//                                 (e.sorumlu_uye ?? e.sorumlu_iletisim ?? "-")),
//                         const SizedBox(height: 10),
//                         if ((e.kulup_sayfasi ?? "").toString().isNotEmpty)
//                           InkWell(
//                             onTap: () => _open(e.kulup_sayfasi!),
//                             borderRadius: BorderRadius.circular(10),
//                             child: Row(
//                               children: const [
//                                 Icon(Icons.link_outlined),
//                                 SizedBox(width: 10),
//                                 Text("Kulüp sayfası"),
//                                 Spacer(),
//                                 Icon(Icons.open_in_new, size: 18),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text("Etkinlik Detayları",
//                       style: t.textTheme.titleMedium
//                           ?.copyWith(fontWeight: FontWeight.w800)),
//                   const SizedBox(height: 8),
//                   _Card(
//                     child: Text(e.etkinlik_aciklamasi ?? "-",
//                         style: t.textTheme.bodyMedium),
//                   ),
//                   const SizedBox(height: 16),
//                   Text("İletişim",
//                       style: t.textTheme.titleMedium
//                           ?.copyWith(fontWeight: FontWeight.w800)),
//                   const SizedBox(height: 8),
//                   _Card(
//                     child: ListTile(
//                       leading: const Icon(Icons.alternate_email_outlined),
//                       title: Text(e.sorumlu_iletisim ?? "-"),
//                       subtitle: const Text("Instagram / iletişim"),
//                       trailing: const Icon(Icons.open_in_new),
//                       onTap: () =>
//                           _openInstagramHandle(e.sorumlu_iletisim ?? ""),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBarTheme: const BottomNavigationBarThemeData(), // senin bottomBar2’nin üstüne gelmez
//     );
//   }
// }

// // ——— helper widgets ———

// class _Tag extends StatelessWidget {
//   const _Tag(
//       {required this.text,
//       required this.icon,
//       required this.fg,
//       required this.bg});
//   final String text;
//   final IconData icon;
//   final Color fg, bg;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//       decoration:
//           BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 16, color: fg),
//         const SizedBox(width: 6),
//         Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
//       ]),
//     );
//   }
// }

// class _Card extends StatelessWidget {
//   const _Card({required this.child});
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         border:
//             Border.all(color: Theme.of(context).dividerColor.withOpacity(.12)),
//       ),
//       child: child,
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   const _InfoRow(
//       {required this.icon, required this.label, required this.value});
//   final IconData icon;
//   final String label, value;

//   @override
//   Widget build(BuildContext context) {
//     final s = Theme.of(context).textTheme.bodyMedium;
//     return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Icon(icon, size: 20),
//       const SizedBox(width: 10),
//       Expanded(
//         child: RichText(
//           text: TextSpan(
//             style: s,
//             children: [
//               TextSpan(
//                   text: "$label: ",
//                   style: s?.copyWith(fontWeight: FontWeight.w700)),
//               TextSpan(text: value),
//             ],
//           ),
//         ),
//       ),
//     ]);
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_page/bottom.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:palette_generator/palette_generator.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.event});
  final dynamic event; // kendi modelin

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final PageController _pc = PageController();
  int _index = 0;
  Timer? _timer;

  Color _dominant = const Color(0xFF2C2C2C);

  List<String> get _images {
    final e = widget.event;
    return [
      if ((e.etkinlik_afisi ?? '').toString().isNotEmpty) e.etkinlik_afisi!,
    ];
  }

  @override
  void initState() {
    super.initState();
    _extractPalette();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  // ----- slider -----
  void _startAutoSlide() {
    _timer?.cancel();
    if (_images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_index + 1) % _images.length;
      _pc.animateToPage(next,
          duration: const Duration(milliseconds: 450), curve: Curves.easeOut);
    });
  }

  // ----- palette -----
  Future<void> _extractPalette() async {
    if (_images.isEmpty) return;
    try {
      final pg = await PaletteGenerator.fromImageProvider(
        NetworkImage(_images.first),
        maximumColorCount: 12,
      );
      final c = pg.dominantColor?.color ??
          pg.vibrantColor?.color ??
          pg.lightVibrantColor?.color ??
          pg.darkVibrantColor?.color;
      if (c != null && mounted) setState(() => _dominant = c);
    } catch (_) {}
  }

  // ----- helpers -----
  Future<void> _open(String url) async {
    final u = Uri.tryParse(url);
    if (u != null) await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  Future<void> _openInstagramHandle(String h) async {
    final handle = h.trim();
    if (handle.isEmpty) return;
    final url = handle.startsWith("http")
        ? handle
        : "https://instagram.com/${handle.startsWith("@") ? handle.substring(1) : handle}";
    await _open(url);
  }

  Color _mixToSurface(Color base, double alpha) {
    // dominant rengin çok düşük opaklıkta yüzeye karışımı
    return Color.alphaBlend(
        base.withOpacity(alpha), Theme.of(context).colorScheme.surface);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final images = _images;
    final t = Theme.of(context);
    final surface = Theme.of(context).colorScheme.surface;

    // yüzey ve tonlar
// final surface      = Theme.of(context).colorScheme.surface;
    final wrapBg = Color.alphaBlend(_dominant.withOpacity(.06), surface);
    final pillBg = Color.alphaBlend(_dominant.withOpacity(.10), Colors.white);
    final pillBorder = Colors.white.withOpacity(.70);
    final sectionBg =
        Color.alphaBlend(_dominant.withOpacity(.08), Colors.white);

    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 2),
      body: CustomScrollView(
        slivers: [
          // ===== HEADER (yalnızca görseller + overlay, auto & swipe & dots) =====
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            // title: Text(e.etkinlik_adi ?? "Etkinlik Detayları",
            //     maxLines: 1, overflow: TextOverflow.ellipsis),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pc,
                    itemCount: images.isEmpty ? 1 : images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      if (images.isEmpty)
                        return Container(color: Colors.grey.shade300);
                      return Image.network(
                        images[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey.shade300),
                      );
                    },
                  ),
                  // Hafif alt gölge (okunurluk için, gradient hissi vermeden)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 110,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                            Colors.black87
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Dots (tıklanabilir)
                  if (images.length > 1)
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) {
                          final active = i == _index;
                          return GestureDetector(
                            onTap: () => _pc.animateToPage(i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: 7,
                              width: active ? 22 : 8,
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withOpacity(active ? .95 : .6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ===== CONTENT (modern arka plan + glass cards) =====
          SliverToBoxAdapter(
            child: Container(
              // arka plan: modern, yumuşak (wrap ile uyumlu)
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 39, 113, 148),
                    Color.fromARGB(255, 255, 255, 255),
                    // Color.alphaBlend(_dominant.withOpacity(.08), surface),
                    // Color.alphaBlend(_dominant.withOpacity(.03), surface),
                    // surface,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      e.etkinlik_adi ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),

                    // —— INFO WRAP (Kulüp / Sorumlu / Tarih / Kulüp sayfası) ——
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      decoration: BoxDecoration(
                        color: wrapBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _PillCard(
                            bg: pillBg,
                            border: pillBorder,
                            icon: Icons.groups_3_outlined,
                            title: "Kulüp",
                            value: e.kulup ?? "-",
                          ),
                          _PillCard(
                            bg: pillBg,
                            border: pillBorder,
                            icon: Icons.person_outline,
                            title: "Sorumlu",
                            value: (e.sorumlu_uye ?? e.sorumlu_iletisim ?? "-"),
                          ),
                          _PillCard(
                            bg: pillBg,
                            border: pillBorder,
                            icon: Icons.event_outlined,
                            title: "Tarih",
                            value: e.etkinlik_tarihi != null
                                ? DateFormat('yyyy-MM-dd').format(
                                    DateTime.parse(e.etkinlik_tarihi!)
                                        .toLocal())
                                : "-",
                          ),
                          if ((e.kulup_sayfasi ?? "").toString().isNotEmpty)
                            _LinkPillCard(
                              bg: pillBg,
                              border: pillBorder,
                              icon: Icons.link_outlined,
                              title: "Bağlantı",
                              onTap: () => _open(e.kulup_sayfasi!),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // —— Etkinlik Detayları ——
                    Text("Etkinlik Detayları",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    _ToneCard(
                      bg: sectionBg,
                      child: Text(
                        e.etkinlik_aciklamasi ?? "-",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // —— İletişim ——
                    Text("İletişim",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    _ToneCard(
                      bg: sectionBg,
                      child: ListTile(
                        leading: const Icon(Icons.alternate_email_outlined,
                            color: Colors.black87),
                        title: Text(e.sorumlu_iletisim ?? "-",
                            style: const TextStyle(color: Colors.black87)),
                        subtitle: const Text("Instagram / iletişim",
                            style: TextStyle(color: Colors.black54)),
                        trailing: const Icon(Icons.open_in_new,
                            color: Colors.black54),
                        onTap: () =>
                            _openInstagramHandle(e.sorumlu_iletisim ?? ""),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // —— CTA (sayfanın en altında) ——
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 52,
                    //   child: ElevatedButton(
                    //     onPressed: () {/* join action */},
                    //     style: ElevatedButton.styleFrom(
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(16)),
                    //     ),
                    //     child: const Text("Hemen katıl"),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- helpers ----------

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 20, color: Colors.black87),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87),
            children: [
              TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: value),
            ],
          ),
        ),
      ),
    ]);
  }
}

class _ToneCard extends StatelessWidget {
  const _ToneCard({required this.child, required this.bg});
  final Widget child;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PillCard extends StatelessWidget {
  const _PillCard({
    required this.bg,
    required this.border,
    required this.icon,
    required this.title,
    required this.value,
  });

  final Color bg, border;
  final IconData icon;
  final String title, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                      text: "$title: ",
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkPillCard extends StatelessWidget {
  const _LinkPillCard({
    required this.bg,
    required this.border,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Color bg, border;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.link_outlined, size: 18, color: Colors.black87),
          SizedBox(width: 8),
          Text("Bağlantı",
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w600)),
          SizedBox(width: 6),
          Icon(Icons.open_in_new, size: 16, color: Colors.black54),
        ]),
      ),
    );
  }
}
