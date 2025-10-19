import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ------------------------------------------------------------
/// GENEL TASARIM BİLEŞENLERİ
/// ------------------------------------------------------------
import 'package:shared_preferences/shared_preferences.dart';

class CanvasPrefs {
  static const _key = 'is_prep';

  static Future<bool> load() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key) ?? false; // false = Bölüm, true = Hazırlık
  }

  static Future<void> save(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, v);
  }
}

Future<void> openLinkInApp(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  await launchUrl(
    uri,
    mode: LaunchMode.inAppWebView,
    webViewConfiguration: const WebViewConfiguration(),
  );
}

class HeroHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Widget> actions; // Hızlı işlemler
  final List<Color> gradient;
  const HeroHeader({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$emoji $title',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white.withOpacity(.95)),
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: actions
                  .map((w) => Padding(
                      padding: const EdgeInsets.only(right: 8), child: w))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // nullable yaptık

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap, // artık optional
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap, // null olursa chip pasif olur
      avatar: Icon(icon, size: 18),
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 1,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(.9),
    );
  }
}

class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color? color;
  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class Bullet extends StatelessWidget {
  final String text;
  const Bullet(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ]),
    );
  }
}

class TagWrap extends StatelessWidget {
  final List<String> tags;
  const TagWrap(this.tags, {super.key});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: -4,
      children: tags
          .map((t) => Chip(
                label: Text(t),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ))
          .toList(),
    );
  }
}

/// ------------------------------------------------------------
/// 1) ŞEHRİ TANI – KAYSERİ
/// ------------------------------------------------------------
class CityKayseriPage extends StatelessWidget {
  const CityKayseriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🏙️',
            title: 'Kayseri – Şehri Tanı',
            subtitle:
                'Erciyes eteklerinde sanayi & öğrenci şehri. Talas–Merkez hattı, uygun yaşam ve zengin mutfak.',
            gradient: const [Color(0xFF277194), Color(0xFF36B2A5)],
            actions: [
              QuickActionChip(
                icon: Icons.credit_card,
                label: 'Ulaşım Kartı',
                onTap: () => openLinkInApp('https://kart38.com/islem-merkezi'),
              ),
              QuickActionChip(
                icon: Icons.tram,
                label: 'Tramvay Saatleri',
                onTap: () => openLinkInApp(
                    'https://www.kayseriulasim.com/hatlar/tramvay'),
              ),
              QuickActionChip(
                icon: Icons.medical_services_outlined,
                label: 'AGÜ Konum',
                onTap: () =>
                    openLinkInApp('https://maps.app.goo.gl/gUWhJn5hsmamtRpMA'),
              ),
            ],
          ),
          const SectionCard(
            icon: Icons.info_outline,
            title: 'Genel Bakış',
            children: const [
              Bullet(
                  'Kayseri, Anadolu’nun ortasında, İç Anadolu’nun önemli şehirlerinden biridir.'),
              Bullet(
                  'Erciyes Dağı şehrin simgesidir; kışın kayak, yazın doğa yürüyüşleri için popülerdir.'),
              Bullet('Öğrenci dostu fiyatlar; ulaşım kolay.'),
              TagWrap(['Rakım 1000m+', 'Kuru iklim', 'Erciyes']),
            ],
          ),
          const SectionCard(
            icon: Icons.restaurant_outlined,
            title: 'Tarih ve Kültür',
            children: const [
              Bullet(
                  'Kültepe (Kaniş Karum): Anadolu’nun en eski yazılı tabletleri burada bulundu.'),
              Bullet(
                  'Hunat Hatun Külliyesi, Gevher Nesibe Şifahanesi ve Kayseri Kalesi mutlaka görülmeli.'),
              Bullet(
                  'Meşhur Kapalı Çarşı ve tarihi hanlar, şehri tanımak için iyi başlangıç noktalarıdır.'),
            ],
          ),
          const SectionCard(
            icon: Icons.place_outlined,
            title: 'Gezilecek Noktalar',
            children: const [
              Bullet('Cumhuriyet Meydanı, Saat Kulesi, Kayseri Kalesi'),
              Bullet('Hunat Hatun Külliyesi, Gevher Nesibe Şifahanesi'),
              Bullet('Talas eski sokakları, Ağırnas (Mimar Sinan)'),
              Bullet('Erciyes Kayak Merkezi, Sultan Sazlığı'),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 2) ÜNİVERSİTEYE GENEL BAKIŞ
/// ------------------------------------------------------------
class UniversityOverviewPage extends StatelessWidget {
  const UniversityOverviewPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🏫',
            title: 'Üniversiteye Genel Bakış',
            subtitle:
                'Kampüs haritası, kütüphane, öğrenci işleri ve en çok kullanılan bağlantılar.',
            gradient: const [Color(0xFF5C6BC0), Color(0xFF26A69A)],
            actions: [
              QuickActionChip(
                  icon: Icons.map_outlined,
                  label: 'Kampüs Haritası',
                  onTap: () => openLinkInApp(
                      'https://www.arkitera.com/gorus/fabrikadan-universite-kampusune-agu-sumer-kampusu/')),
              QuickActionChip(
                  icon: Icons.local_library_outlined,
                  label: 'Kütüphane',
                  onTap: () => openLinkInApp(
                      'https://katalog.agu.edu.tr/yordam/?p=0&dil=0')),
              QuickActionChip(
                  icon: Icons.business_center_outlined,
                  label: 'Öğrenci İşleri',
                  onTap: () => openLinkInApp('https://oidb-tr.agu.edu.tr/')),
            ],
          ),
          SectionCard(
            icon: Icons.link_outlined,
            title: 'Sık Kullanılanlar',
            children: [
              const Bullet(
                  'Akademik Takvim • SIS • LMS (Canvas) • E-posta (Zimbra)'),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('SIS'),
                    onPressed: () => openLinkInApp(
                        'https://sis.agu.edu.tr/oibs/std/login.aspx'),
                  ),
                  // ValueListenableBuilder<bool>(
                  //   valueListenable: isPrepNotifier,
                  //   builder: (_, isPrep, __) => ActionChip(
                  //     label: Text(canvasLabel(isPrep)),
                  //     onPressed: () => openLinkInApp(canvasUrl(isPrep)),
                  //   ),
                  // ),
                  ActionChip(
                      label: const Text('Canvas/Hazırlık'),
                      onPressed: () => openLinkInApp(
                          'https://canvasfl.agu.edu.tr/login/canvas')),
                  ActionChip(
                      label: const Text('Canvas/Bölüm'),
                      onPressed: () => openLinkInApp(
                          'https://canvas.agu.edu.tr/login/canvas')),
                  ActionChip(
                    label: const Text('E-posta'),
                    onPressed: () => openLinkInApp('https://posta.agu.edu.tr/'),
                  ),
                ],
              ),
            ],
          ),
          const SectionCard(
            icon: Icons.school_outlined,
            title: 'Eğitim ve Kampüs Olanakları',
            children: [
              Bullet(
                  'Nitelikli eğitim: Mühendislik, Yaşam ve Doğa Bilimleri, Mimarlık, İktisadi ve Sosyal Bilimler fakülteleri,'),
              Bullet('Zengin kütüphane ve 7/24 açık çalışma salonları,'),
              Bullet('Modern laboratuvarlar ve araştırma merkezleri,'),
              Bullet('Spor kompleksi, yemekhane ve sosyal yaşam alanları,'),
              Bullet('Öğrenci kulüpleri, etkinlikler ve kültürel aktiviteler.'),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 3) YEMEK & KAFELER
/// ------------------------------------------------------------
class FoodCafesPage extends StatelessWidget {
  const FoodCafesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🍽',
            title: 'Yemek & Kafeler',
            subtitle:
                'Yemekhane saatleri, kampüs çevresi ve bütçe dostu öneriler.',
            gradient: const [Color(0xFFEF6C00), Color(0xFFAB47BC)],
            actions: [
              QuickActionChip(
                icon: Icons.restaurant_menu,
                label: 'Günlük Menü',
                onTap: () {},
              ),
              QuickActionChip(
                icon: Icons.local_cafe_outlined,
                label: 'Yakın Kafeler',
                onTap: () {},
              ),
            ],
          ),

          // ——— Bölümler ———
          const SectionCard(
            icon: Icons.schedule_outlined,
            title: 'Yemekhane Saatleri',
            children: [
              Bullet('Öğle servisi: 11:00 – 14:00'),
              Bullet(
                  'Yoğun saatlerde erken git; menüyü uygulamadan kontrol et.'),
              Bullet(
                  "Yemekhaneler, Fabrika Binası ve Ambar Binasında yer almaktadır."),
              TagWrap(['Günlük Menü', 'Aylık Menü']),
            ],
          ),

          const SectionCard(
            icon: Icons.local_cafe,
            title: 'Kampüs & Çevresi',
            children: [
              Bullet('Starbucks--> Çelik Bina A Blok karşısı'),
              Bullet('Elif Cafe--> Çelik Bina B Blok 2. kat'),
              Bullet('Vivoli Cafe--> Çelik Bina C Blok'),
              Bullet(
                  'Mobil Kafe(Karavan)--> Fabrika Binası-Erkilet Giriş arası'),
              Bullet('Fabrika Binası Kantin'),
              Bullet('The House Cafe Müze'),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 4) ULAŞIM REHBERİ
/// ------------------------------------------------------------
class TransportPage extends StatelessWidget {
  const TransportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🚌',
            title: 'Ulaşım Rehberi',
            subtitle:
                'Kayseray + otobüs hatları, güzergâh sorgu, yoğun saat ipuçları ve güvenli dönüş önerileri.',
            gradient: const [Color(0xFF00897B), Color(0xFF1976D2)],
            actions: [
              QuickActionChip(
                icon: Icons.map_outlined,
                label: 'Güzergâh Sorgu',
                onTap: () => openLinkInApp(
                    'https://www.kayseriulasim.com/hat-sorgulama'),
              ),
              QuickActionChip(
                icon: Icons.bus_alert,
                label: 'Otobüs Hatları',
                onTap: () => openLinkInApp(
                    'https://www.kayseriulasim.com/hatlar/otobus'),
              ),
              QuickActionChip(
                icon: Icons.tram,
                label: 'Tramvay Hatları',
                onTap: () => openLinkInApp(
                    'https://www.kayseriulasim.com/hatlar/tramvay'),
              ),
              QuickActionChip(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Kart38 Bakiye',
                onTap: () => openLinkInApp('https://kart38.com/uye-giris'),
              ),
            ],
          ),
          const SectionCard(
            icon: Icons.directions_bus_filled,
            title: 'Otobüs',
            children: [
              Bullet('Çok sayıda hattın Talas–Merkez bağlantısı var.'),
              Bullet('Yoğun saatlerde alternatif durakları tercih et.'),
              Bullet('Hat ve saatleri web sitesinden anlık kontrol et.'),
            ],
          ),
          const SectionCard(
            icon: Icons.directions_railway_filled,
            title: 'Tramvay',
            children: [
              Bullet(
                  'Talas ↔ Merkez hattı özellikle sınav/iş çıkışında kalabalık.'),
              Bullet('Durak yoğunluğuna göre otobüs alternatiflerini bil.'),
              Bullet(
                  'Tramvay saatlerini uygulama veya web sitesinden takip et.'),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 5) KAYIT & EVRAK İŞLERİ
/// ------------------------------------------------------------
class RegistrationDocsPage extends StatelessWidget {
  const RegistrationDocsPage({super.key});
  Widget _step(String title, String desc, {bool done = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? Colors.green : null),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(desc),
          const SizedBox(height: 10),
        ])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🧾',
            title: 'Kayıt & Evrak İşleri',
            subtitle:
                'SIS, danışman onayı ve e-Devlet belgeleri için kısa yol.',
            gradient: const [Color(0xFF7B1FA2), Color(0xFF512DA8)],
            actions: [
              QuickActionChip(
                  icon: Icons.assignment_outlined,
                  label: 'Öğrenci Belgesi',
                  onTap: () => openLinkInApp(
                      'https://sis.agu.edu.tr/oibs/std/login.aspx')),
              QuickActionChip(
                  icon: Icons.note_alt_outlined,
                  label: 'Transkript',
                  onTap: () => openLinkInApp(
                      'https://sis.agu.edu.tr/oibs/std/login.aspx')),
            ],
          ),
          SectionCard(
            icon: Icons.format_list_numbered,
            title: 'Adım Adım',
            children: [
              _step('Kayıt Belgeleri',
                  'Kimlik, fotoğraf, yerleştirme belgesi, varsa muafiyet.'),
              _step('SIS Hesabı',
                  'Bilgilerini güncelle; danışmanını ve bölümünü kontrol et.'),
              _step('Ders Kayıt', 'Danışman onayı olmadan kayıt tamamlanmaz.',
                  done: false),
              _step('Ücret/Harç', 'Varsa ödeme planını kontrol et.',
                  done: false),
            ],
          ),
          const SectionCard(
            icon: Icons.info_outline,
            title: 'İpuçları',
            children: [
              Bullet(
                  'Belgeleri PDF olarak sakla; e-Devlet şifrelerini güvenli tut.'),
              Bullet(
                  'Kayıt günlerinde yoğunluk olur, işlemleri erken tamamla.'),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 6) AKADEMİK HAYATTA KALMA
/// ------------------------------------------------------------

class AcademicSurvivalPage extends StatelessWidget {
  const AcademicSurvivalPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🎓',
            title: 'Akademik Hayatta Kalma',
            subtitle:
                'Ders seçimi, not sistemi, kütüphane ve sınav haftası taktikleri.',
            gradient: const [Color(0xFF3949AB), Color(0xFF00ACC1)],
            actions: [
              QuickActionChip(
                  icon: Icons.school_outlined,
                  label: 'SIS',
                  onTap: () => openLinkInApp('https://sis.agu.edu.tr/')),
              QuickActionChip(
                  icon: Icons.laptop_mac,
                  label: 'Canvas/Hazırlık',
                  onTap: () => openLinkInApp(
                      'https://canvasfl.agu.edu.tr/login/canvas')),
              QuickActionChip(
                  icon: Icons.laptop_mac,
                  label: 'Canvas/Bölüm',
                  onTap: () =>
                      openLinkInApp('https://canvas.agu.edu.tr/login/canvas')),
              QuickActionChip(
                  icon: Icons.local_library_outlined,
                  label: 'Kütüphane',
                  onTap: () => openLinkInApp(
                      'https://katalog.agu.edu.tr/yordam/?p=0&dil=0')),
            ],
          ),
          const SectionCard(
            icon: Icons.rule_folder_outlined,
            title: 'Not Sistemi & Devamsızlık',
            children: [
              Bullet('Ders planındaki % ağırlıkları ve barajları öğren.'),
              Bullet('Devamsızlık limitlerini kaçırma; derslere düzenli git.'),
            ],
          ),
          const SectionCard(
            icon: Icons.tips_and_updates_outlined,
            title: 'Çalışma Taktikleri',
            children: [
              Bullet('Kütüphanede sessiz alan + grup çalışma odaları.'),
              Bullet('Haftalık plan: ders sonrası 20–30 dk tekrar.'),
              Bullet(
                  'Sınav haftası: eski sorular, özet defter, küçük molalar.'),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 7) SOSYAL YAŞAM
/// ------------------------------------------------------------
class SocialLifePage extends StatelessWidget {
  const SocialLifePage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🧑‍🤝‍🧑',
            title: 'Sosyal Yaşam',
            subtitle: 'Kulüpler, etkinlikler ve spor alanları ile sosyalleş.',
            gradient: const [Color(0xFF8E24AA), Color(0xFFE53935)],
            actions: [
              QuickActionChip(
                  icon: Icons.groups_2_outlined,
                  label: 'Kulüpler',
                  onTap: () =>
                      openLinkInApp('https://od-tr.agu.edu.tr/kulupler')),
              QuickActionChip(
                  icon: Icons.sports_soccer_outlined,
                  label: 'Spor',
                  onTap: () => openLinkInApp(
                      'https://booked.agu.edu.tr/Web/view-calendar.php')),
            ],
          ),
          const SectionCard(
            icon: Icons.celebration_outlined,
            title: 'Nereden Başlamalı?',
            children: [
              Bullet('Tanıtım haftasında kulüp stantlarını gez.'),
              Bullet(
                  'Deneme toplantılarına katıl, ilgi alanına uygun 1–2 kulüp seç.'),
              Bullet('Gönüllülük programlarını takip et.'),
            ],
          ),
          const SectionCard(
            icon: Icons.coffee_outlined,
            title: 'Buluşma & Çalışma Mekânları',
            children: [
              Bullet('Kampüs içi sessiz/yarı sessiz alanlar.'),
              Bullet('Talas ve merkezde uygun fiyatlı kafeler.'),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 8) YURT & BARINMA
/// ------------------------------------------------------------
class HousingPage extends StatelessWidget {
  const HousingPage({super.key});
  Widget _check(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          const Icon(Icons.check, size: 18),
          const SizedBox(width: 6),
          Expanded(child: Text(t))
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🏠',
            title: 'Yurt ve Barınma',
            subtitle:
                'Yurt ipuçları, ev kiralama checklist ve taşınma tüyoları.',
            gradient: const [Color(0xFF00796B), Color(0xFF43A047)],
            actions: [
              QuickActionChip(
                  icon: Icons.home_work_outlined,
                  label: 'Yurt Başvurusu',
                  onTap: () => openLinkInApp(
                      'https://www.turkiye.gov.tr/gsb-yurt-basvurusu')),
              // QuickActionChip(
              //     icon: Icons.key_outlined,
              //     label: 'Ev Kiralama',
              //     onTap: () => openLinkInApp('Kampüs haritası — link ekleyin')),
            ],
          ),
          const SectionCard(
            icon: Icons.domain_outlined,
            title: 'Yurt İpuçları',
            children: const [
              Bullet('Sessiz saatler ve ortak alan kurallarını öğren.'),
              Bullet(
                  'Dolap kilidi, priz çoklayıcı ve kulaklık kurtarıcı olur.'),
            ],
          ),
          SectionCard(
            icon: Icons.checklist_outlined,
            title: 'Ev Kiralama Checklist',
            children: [
              _check('Isınma türü (doğalgaz/merkezi) ve fatura durumu'),
              _check('Tramvaya yürüme mesafesi, market/eczane yakınlığı'),
              _check('Depozito & sözleşme; dairede nem/ısı yalıtımı'),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 9) ACİL DURUMLAR & İLETİŞİM (son sayfa, sağ ok YOK)
/// ------------------------------------------------------------

/// ------------------------------------------------------------
/// PAGEVIEW: REHBER (orta sağda >, orta solda <; son sayfada > gizli)
/// ------------------------------------------------------------
class GuidePage extends StatefulWidget {
  const GuidePage({super.key});
  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _isAnimating = false;

  late final List<Widget> _pages = [
    const CityKayseriPage(key: PageStorageKey('city_kayseri')),
    const UniversityOverviewPage(key: PageStorageKey('univ_overview')),
    const FoodCafesPage(key: PageStorageKey('food_cafes')),
    const TransportPage(key: PageStorageKey('transport')),
    const RegistrationDocsPage(key: PageStorageKey('reg_docs')),
    const AcademicSurvivalPage(key: PageStorageKey('academic_survival')),
    const SocialLifePage(key: PageStorageKey('social_life')),
    const HousingPage(key: PageStorageKey('housing')),
    //const EmergencyContactsPage(key: PageStorageKey('emergency')),
  ];

  @override
  void dispose() {
    _controller.dispose(); // 💡 kritik: controller'ı serbest bırak
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_isAnimating) return;
    final isLast = _index >= _pages.length - 1;
    if (isLast) return;
    _isAnimating = true;
    await _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    _isAnimating = false;
  }

  Future<void> _goPrev() async {
    if (_isAnimating) return;
    final isFirst = _index <= 0;
    if (isFirst) return;
    _isAnimating = true;
    await _controller.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isFirst = _index == 0;
    final bool isLast = _index == _pages.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Rehber'), centerTitle: true),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _pages[i],
          ),

          // ← önceki
          if (!isFirst)
            Positioned(
              left: 8,
              top: size.height * 0.45,
              child: Semantics(
                label: 'Önceki sayfa',
                button: true,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: const Text('<', style: TextStyle(fontSize: 28)),
                    onPressed: _goPrev,
                  ),
                ),
              ),
            ),

          // → sonraki (son sayfa hariç)
          if (!isLast)
            Positioned(
              right: 8,
              top: size.height * 0.45,
              child: Semantics(
                label: 'Sonraki sayfa',
                button: true,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: const Text('>', style: TextStyle(fontSize: 28)),
                    onPressed: _goNext,
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Text('Kaydırınız',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
