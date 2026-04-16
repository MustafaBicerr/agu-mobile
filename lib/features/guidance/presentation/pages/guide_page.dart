import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agu_mobile/features/platform_access/presentation/services/login_service.dart';
import 'package:agu_mobile/features/menu/presentation/pages/menu_page.dart';

/// ------------------------------------------------------------
/// SHARED PREFERENCES
/// ------------------------------------------------------------
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

/// Otomatik giriş yaparak platforma yönlendirir.
/// Eğer kaydedilmiş bilgi yoksa kullanıcıyı Şifreler sayfasına yönlendirir.
Future<void> _openWithAutoLogin(
  BuildContext context, {
  required String title,
  required String url,
  required String mailPrefKey,
  required String passwordPrefKey,
  required String mailFieldName,
  required String passwordFieldName,
  required String loginButtonFieldXPath,
  required String keyword,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final savedMail = prefs.getString(mailPrefKey) ?? '';
  final savedPassword = prefs.getString(passwordPrefKey) ?? '';

  if (!context.mounted) return;

  if (savedMail.isNotEmpty && savedPassword.isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginService(
          title: title,
          url: url,
          mail: savedMail,
          password: savedPassword,
          mailFieldName: mailFieldName,
          passwordFieldName: passwordFieldName,
          loginButtonFieldXPath: loginButtonFieldXPath,
          keyword: keyword,
        ),
      ),
    );
  } else {
    // Bilgi kayıtlı değil — kullanıcıya bildir ve yönlendir
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Giriş Bilgisi Bulunamadı'),
        content: const Text(
          'Otomatik giriş yapabilmek için önce '
          '"Menü → Şifreler ve Giriş" sayfasından '
          'bilgilerinizi kaydetmeniz gerekiyor.\n\n'
          'Şimdi o sayfaya gitmek ister misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Kayıt yok, düz tarayıcıda aç
              openLinkInApp(url);
            },
            child: const Text('Manuel Giriş'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PasswordScreen()),
              );
            },
            child: const Text('Bilgi Kaydet'),
          ),
        ],
      ),
    );
  }
}

/// SIS otomatik giriş kısayolu
void _openSIS(BuildContext context) {
  _openWithAutoLogin(
    context,
    title: 'SIS AGU',
    url: 'https://sis.agu.edu.tr/oibs/std/login.aspx',
    mailPrefKey: 'sisMail',
    passwordPrefKey: 'sisPassword',
    mailFieldName: 'txtParamT01',
    passwordFieldName: 'txtParamT02',
    loginButtonFieldXPath: "//*[@id='btnLoginn']",
    keyword: 'index',
  );
}

/// Canvas Bölüm otomatik giriş kısayolu
void _openCanvasBolum(BuildContext context) {
  _openWithAutoLogin(
    context,
    title: 'Canvas AGU',
    url: 'https://canvas.agu.edu.tr/login/canvas',
    mailPrefKey: 'canvasMail',
    passwordPrefKey: 'canvasPassword',
    mailFieldName: 'pseudonym_session[unique_id]',
    passwordFieldName: 'pseudonym_session[password]',
    loginButtonFieldXPath: "//*[@id='login_form']/button",
    keyword: 'success',
  );
}

/// Canvas Hazırlık otomatik giriş kısayolu
void _openCanvasHazirlik(BuildContext context) {
  _openWithAutoLogin(
    context,
    title: 'Canvas PREP',
    url: 'https://canvasfl.agu.edu.tr/login/canvas',
    mailPrefKey: 'prepCanvasMail',
    passwordPrefKey: 'prepCanvasPassword',
    mailFieldName: 'pseudonym_session[unique_id]',
    passwordFieldName: 'pseudonym_session[password]',
    loginButtonFieldXPath: "//*[@id='login_form']/button",
    keyword: 'success',
  );
}

/// ------------------------------------------------------------
/// GENEL TASARIM BİLEŞENLERİ (Yenilenmiş)
/// ------------------------------------------------------------

/// Glassmorphism efektli, animasyonlu gradient Hero Header
class HeroHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final List<Color> gradient;
  final IconData? backgroundIcon;

  const HeroHeader({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.gradient,
    this.backgroundIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Arka plan dekoratif ikon
          if (backgroundIcon != null)
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                backgroundIcon,
                size: 110,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          // Dekoratif daireler
          Positioned(
            left: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // İçerik
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                        height: 1.4,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Quick action chips
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
          ),
        ],
      ),
    );
  }
}

/// Glassmorphism efektli quick action chip
class QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Geliştirilmiş SectionCard – renkli ikon arka planı + gölge
class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Color? color;
  final Color? iconColor;
  final Color? iconBgColor;

  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.color,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveIconBg =
        iconBgColor ?? theme.colorScheme.primary.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: effectiveIconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Gelişmiş Bullet – emoji veya ikon desteği
class Bullet extends StatelessWidget {
  final String text;
  final String? leadEmoji;
  final IconData? leadIcon;
  final Color? leadColor;

  const Bullet(
    this.text, {
    super.key,
    this.leadEmoji,
    this.leadIcon,
    this.leadColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadEmoji != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 1),
              child: Text(leadEmoji!, style: const TextStyle(fontSize: 14)),
            )
          else if (leadIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: Icon(leadIcon, size: 16, color: leadColor),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 6),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.85),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renkli etiketler
class TagWrap extends StatelessWidget {
  final List<String> tags;
  final Color? tagColor;
  const TagWrap(this.tags, {super.key, this.tagColor});

  @override
  Widget build(BuildContext context) {
    final color = tagColor ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: tags
            .map((t) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// Link kartı – tıklanabilir dış bağlantı
/// [onTapOverride] verilmişse URL yerine bu callback çalışır.
class LinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String url;
  final Color? color;
  final void Function(BuildContext context)? onTapOverride;

  const LinkCard({
    super.key,
    required this.icon,
    required this.label,
    required this.url,
    this.subtitle,
    this.color,
    this.onTapOverride,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTapOverride != null
              ? onTapOverride!(context)
              : openLinkInApp(url),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: chipColor.withOpacity(0.06),
              border: Border.all(
                color: chipColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: chipColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: chipColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.55),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: chipColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Info banner – önemli bilgi kutusu
class InfoBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;

  const InfoBanner({
    super.key,
    required this.text,
    this.icon = Icons.lightbulb_outline_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bannerColor = color ?? const Color(0xFFFFA726);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: bannerColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Numaralı adım widget'ı
class NumberedStep extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final Color? color;
  final bool isLast;

  const NumberedStep({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final stepColor = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Numara ve çizgi
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [stepColor, stepColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: stepColor.withOpacity(0.2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Konum / yer kartı
class PlaceCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String? location;

  const PlaceCard({
    super.key,
    required this.emoji,
    required this.name,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                if (location != null)
                  Text(
                    location!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.55),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
                'Erciyes eteklerinde tarih, kültür ve sanayi bir arada. Öğrenci dostu fiyatlar, zengin mutfak ve ulaşım kolaylığı seni bekliyor.',
            gradient: const [Color(0xFF277194), Color(0xFF36B2A5)],
            backgroundIcon: Icons.location_city_rounded,
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
                icon: Icons.place_outlined,
                label: 'AGÜ Konum',
                onTap: () =>
                    openLinkInApp('https://maps.app.goo.gl/gUWhJn5hsmamtRpMA'),
              ),
            ],
          ),

          // Genel Bakış
          SectionCard(
            icon: Icons.info_outline_rounded,
            title: 'Genel Bakış',
            iconColor: const Color(0xFF277194),
            iconBgColor: const Color(0xFF277194).withOpacity(0.1),
            children: const [
              Bullet(
                'Kayseri, Anadolu\'nun merkezinde, İç Anadolu\'nun en dinamik şehirlerinden biridir.',
                leadEmoji: '📍',
              ),
              Bullet(
                'Erciyes Dağı (3.917 m) şehrin simgesidir — kışın kayak, yazın trekking için idealdir.',
                leadEmoji: '⛷️',
              ),
              Bullet(
                'Öğrenci dostu uygun fiyatlar, gelişmiş toplu taşıma ağı ve güvenli yaşam ortamı.',
                leadEmoji: '🎓',
              ),
              Bullet(
                'Kuru karasal iklim: Yazlar sıcak, kışlar soğuk ve karlı geçer. Katmanlı giyinin!',
                leadEmoji: '🌡️',
              ),
              TagWrap(
                ['Rakım 1000m+', 'Kuru iklim', 'Erciyes', 'Sanayi şehri'],
                tagColor: Color(0xFF277194),
              ),
            ],
          ),

          // Tarih ve Kültür
          SectionCard(
            icon: Icons.museum_outlined,
            title: 'Tarih ve Kültür',
            iconColor: const Color(0xFF8D6E63),
            iconBgColor: const Color(0xFF8D6E63).withOpacity(0.1),
            children: const [
              Bullet(
                'Kültepe (Kaniş Karum): Anadolu\'nun bilinen en eski yazılı tabletleri burada keşfedildi.',
                leadEmoji: '🏛️',
              ),
              Bullet(
                'Gevher Nesibe Şifahanesi — dünyanın ilk tıp eğitimi merkezlerinden biri.',
                leadEmoji: '🏥',
              ),
              Bullet(
                'Hunat Hatun Külliyesi, Kayseri Kalesi ve Döner Kümbet tarihi dokunun öne çıkan yapıları.',
                leadEmoji: '🕌',
              ),
              Bullet(
                'Kapalı Çarşı ve tarihi hanlar — özellikle pastırma, sucuk ve mücevher alışverişi ünlü.',
                leadEmoji: '🛍️',
              ),
            ],
          ),

          // Gezilecek Noktalar
          SectionCard(
            icon: Icons.explore_outlined,
            title: 'Gezilecek Noktalar',
            iconColor: const Color(0xFF2E7D32),
            iconBgColor: const Color(0xFF2E7D32).withOpacity(0.1),
            children: const [
              PlaceCard(
                  emoji: '🏔️',
                  name: 'Erciyes Kayak Merkezi',
                  location: 'Kampüse ~25 km'),
              PlaceCard(
                  emoji: '🏰',
                  name: 'Kayseri Kalesi & Cumhuriyet Meydanı',
                  location: 'Şehir merkezi'),
              PlaceCard(
                  emoji: '🕌',
                  name: 'Hunat Hatun Külliyesi',
                  location: 'Kale yanı'),
              PlaceCard(
                  emoji: '🏠',
                  name: 'Ağırnas – Mimar Sinan\'ın doğduğu köy',
                  location: 'Merkeze ~45 dk'),
              PlaceCard(
                  emoji: '🦩',
                  name: 'Sultan Sazlığı Kuş Cenneti',
                  location: 'Develi ilçesi'),
              PlaceCard(
                  emoji: '🧱',
                  name: 'Talas Eski Sokakları',
                  location: 'Tramvay ile erişilebilir'),
            ],
          ),

          // Yöresel Lezzetler
          const SectionCard(
            icon: Icons.restaurant_outlined,
            title: 'Yöresel Lezzetler',
            iconColor: Color(0xFFD84315),
            iconBgColor: Color(0x1AD84315),
            children: [
              Bullet('Kayseri mantısı — mutlaka deneyin, çok farklı!',
                  leadEmoji: '🥟'),
              Bullet(
                  'Pastırma & sucuk — Kayseri dışında böylesini bulamazsınız.',
                  leadEmoji: '🥩'),
              Bullet('Yağlama, höşmerim, nevzine ve katmer tatlıları.',
                  leadEmoji: '🍮'),
              Bullet('Cıvıklı (çırpılmış ayran) ve Talas çöreği.',
                  leadEmoji: '🥤'),
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
                'AGÜ Sümer Kampüsü — modern laboratuvarlar, zengin kütüphane, öğrenci işleri ve dijital platformlar.',
            gradient: const [Color(0xFF5C6BC0), Color(0xFF26A69A)],
            backgroundIcon: Icons.school_rounded,
            actions: [
              QuickActionChip(
                icon: Icons.map_outlined,
                label: 'Kampüs Haritası',
                onTap: () => openLinkInApp(
                    'https://www.arkitera.com/gorus/fabrikadan-universite-kampusune-agu-sumer-kampusu/'),
              ),
              QuickActionChip(
                icon: Icons.local_library_outlined,
                label: 'Kütüphane',
                onTap: () => openLinkInApp(
                    'https://katalog.agu.edu.tr/yordam/?p=0&dil=0'),
              ),
              QuickActionChip(
                icon: Icons.business_center_outlined,
                label: 'Öğrenci İşleri',
                onTap: () => openLinkInApp('https://oidb-tr.agu.edu.tr/'),
              ),
            ],
          ),

          // Sık Kullanılan Platformlar
          SectionCard(
            icon: Icons.dashboard_outlined,
            title: 'Dijital Platformlar',
            iconColor: const Color(0xFF5C6BC0),
            iconBgColor: const Color(0xFF5C6BC0).withOpacity(0.1),
            children: [
              LinkCard(
                icon: Icons.school_outlined,
                label: 'SIS – Öğrenci Bilgi Sistemi',
                subtitle: 'Ders kayıt, not görüntüleme, transkript',
                url: 'https://sis.agu.edu.tr/oibs/std/login.aspx',
                color: const Color(0xFF5C6BC0),
                onTapOverride: _openSIS,
              ),
              LinkCard(
                icon: Icons.laptop_mac_outlined,
                label: 'Canvas – Hazırlık',
                subtitle: 'İngilizce hazırlık dersleri için LMS',
                url: 'https://canvasfl.agu.edu.tr/login/canvas',
                color: const Color(0xFF26A69A),
                onTapOverride: _openCanvasHazirlik,
              ),
              LinkCard(
                icon: Icons.laptop_chromebook_outlined,
                label: 'Canvas – Bölüm',
                subtitle: 'Lisans/yüksek lisans dersleri için LMS',
                url: 'https://canvas.agu.edu.tr/login/canvas',
                color: const Color(0xFF42A5F5),
                onTapOverride: _openCanvasBolum,
              ),
              const LinkCard(
                icon: Icons.email_outlined,
                label: 'Zimbra E-posta',
                subtitle: '@agu.edu.tr kurumsal posta',
                url: 'https://posta.agu.edu.tr/',
                color: Color(0xFFEF5350),
              ),
            ],
          ),

          // Kampüs Olanakları
          const SectionCard(
            icon: Icons.apartment_outlined,
            title: 'Kampüs Olanakları',
            iconColor: Color(0xFF26A69A),
            iconBgColor: Color(0x1A26A69A),
            children: [
              Bullet(
                '4 fakülte: Mühendislik, Yaşam & Doğa Bilimleri, Mimarlık, İktisadi & Sosyal Bilimler.',
                leadEmoji: '🏢',
              ),
              Bullet(
                'Modern kütüphane, 7/24 açık çalışma salonları ve sessiz bireysel çalışma odaları.',
                leadEmoji: '📚',
              ),
              Bullet(
                'Araştırma laboratuvarları: nano-teknoloji, yapay zeka, malzeme bilimi ve daha fazlası.',
                leadEmoji: '🔬',
              ),
              Bullet(
                'Spor kompleksi: fitness salonu, basketbol/voleybol sahaları, tenis kortu.',
                leadEmoji: '🏋️',
              ),
              Bullet(
                'Açık ve kapalı sosyal alanlar, amfiteatr, sergi mekanları.',
                leadEmoji: '🎭',
              ),
            ],
          ),

          // Bilgi kutusu
          const InfoBanner(
            text:
                'Kampüs, tarihi Sümerbank Bez Fabrikası alanında kurulmuştur. Endüstriyel mimarinin modern eğitimle buluştuğu eşsiz bir ortam sunar.',
            icon: Icons.auto_awesome_rounded,
            color: Color(0xFF5C6BC0),
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
            emoji: '🍽️',
            title: 'Yemek & Kafeler',
            subtitle:
                'Yemekhane menüleri, kampüs içi kafeler ve çevredeki bütçe dostu mekanlar.',
            gradient: const [Color(0xFFEF6C00), Color(0xFFE65100)],
            backgroundIcon: Icons.restaurant_rounded,
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

          // Yemekhane
          const SectionCard(
            icon: Icons.schedule_outlined,
            title: 'Yemekhane Bilgileri',
            iconColor: Color(0xFFEF6C00),
            iconBgColor: Color(0x1AEF6C00),
            children: [
              Bullet('Öğle servisi: 11:00 – 14:00',
                  leadIcon: Icons.access_time_rounded,
                  leadColor: Color(0xFFEF6C00)),
              Bullet(
                  'Yoğun saatlerde erken git — 11:30-12:00 arası en rahat zaman dilimi.',
                  leadIcon: Icons.tips_and_updates_outlined,
                  leadColor: Color(0xFFFFA726)),
              Bullet('İki yemekhane mevcut: Fabrika Binası ve Ambar Binası.',
                  leadIcon: Icons.location_on_outlined,
                  leadColor: Color(0xFF66BB6A)),
              Bullet(
                  'Günlük ve aylık menü bilgilerini uygulamadan takip edebilirsin.',
                  leadIcon: Icons.phone_android_outlined,
                  leadColor: Color(0xFF42A5F5)),
              TagWrap(['Günlük Menü', 'Aylık Menü', 'Diyet Seçenekleri'],
                  tagColor: Color(0xFFEF6C00)),
            ],
          ),

          // Kampüs Kafeleri
          SectionCard(
            icon: Icons.local_cafe_rounded,
            title: 'Kampüs İçi Kafeler',
            iconColor: const Color(0xFF6D4C41),
            iconBgColor: const Color(0xFF6D4C41).withOpacity(0.1),
            children: const [
              PlaceCard(
                  emoji: '☕',
                  name: 'Starbucks',
                  location: 'Çelik Bina A Blok karşısı'),
              PlaceCard(
                  emoji: '🍰',
                  name: 'Elif Cafe',
                  location: 'Çelik Bina B Blok, 2. kat'),
              PlaceCard(
                  emoji: '🧁',
                  name: 'Vivoli Cafe',
                  location: 'Çelik Bina C Blok'),
              PlaceCard(
                  emoji: '🚐',
                  name: 'Mobil Kafe (Karavan)',
                  location: 'Fabrika Binası – Erkilet girişi arası'),
              PlaceCard(
                  emoji: '🏪',
                  name: 'Fabrika Binası Kantin',
                  location: 'Ana yemekhane yanı'),
              PlaceCard(
                  emoji: '🎨',
                  name: 'The House Cafe Müze',
                  location: 'Müze binası içi'),
            ],
          ),

          // İpucu
          const InfoBanner(
            text:
                'Öğrenci bütçesi ipucu: Yemekhane en ekonomik seçenek. Hafta içi kantinlerde de uygun fiyatlı sandviç ve tost bulabilirsin.',
            icon: Icons.savings_outlined,
            color: Color(0xFF66BB6A),
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
                'Kayseray tramvay, otobüs hatları, güzergah sorgu ve yoğun saat önerileri.',
            gradient: const [Color(0xFF00897B), Color(0xFF1976D2)],
            backgroundIcon: Icons.directions_bus_rounded,
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

          // Kayseray
          SectionCard(
            icon: Icons.directions_railway_filled_rounded,
            title: 'Tramvay (Kayseray)',
            iconColor: const Color(0xFF1976D2),
            iconBgColor: const Color(0xFF1976D2).withOpacity(0.1),
            children: const [
              Bullet(
                'Ana hat: Talas ↔ Şehir Merkezi — kampüse en yakın ulaşım.',
                leadEmoji: '🚊',
              ),
              Bullet(
                'Sınav ve iş çıkış saatlerinde kalabalık olabilir (17:00-18:30).',
                leadEmoji: '⏰',
              ),
              Bullet(
                'Talas yönünde son tramvay saatini mutlaka kontrol et!',
                leadEmoji: '⚠️',
              ),
              Bullet(
                'Alternatif: Yoğun saatlerde otobüs hatları daha rahat olabilir.',
                leadEmoji: '💡',
              ),
            ],
          ),

          // Otobüs
          SectionCard(
            icon: Icons.directions_bus_filled_rounded,
            title: 'Otobüs',
            iconColor: const Color(0xFF00897B),
            iconBgColor: const Color(0xFF00897B).withOpacity(0.1),
            children: const [
              Bullet(
                'Çok sayıda hat, Talas–Merkez ve çevre ilçelere bağlantı sağlar.',
                leadEmoji: '🚌',
              ),
              Bullet(
                'Hat ve saatleri web sitesinden anlık kontrol edebilirsin.',
                leadEmoji: '📱',
              ),
              Bullet(
                'Yoğun saatlerde alternatif durakları kullan — birkaç durak yürü, boş binesin.',
                leadEmoji: '🏃',
              ),
            ],
          ),

          // Ulaşım Kartı
          const SectionCard(
            icon: Icons.credit_card_rounded,
            title: 'Ulaşım Kartı (Kart38)',
            iconColor: Color(0xFFF57C00),
            iconBgColor: Color(0x1AF57C00),
            children: [
              NumberedStep(
                number: 1,
                title: 'Kart Al',
                description:
                    'Kart38 işlem merkezinden veya yetkili bayilerden öğrenci kartı temin et.',
                color: Color(0xFFF57C00),
              ),
              NumberedStep(
                number: 2,
                title: 'HES Kodu Eşle',
                description:
                    'Kartını HES kodunla eşleştirmeyi unutma (gerekiyorsa).',
                color: Color(0xFFF57C00),
              ),
              NumberedStep(
                number: 3,
                title: 'Bakiye Yükle',
                description:
                    'Online, ATM veya kart bayilerinden bakiye yükleyebilirsin.',
                color: Color(0xFFF57C00),
              ),
              NumberedStep(
                number: 4,
                title: 'Biniş Yap',
                description:
                    'Öğrenci kartıyla indirimli biniş hakkını kullan. Aktarma 60 dk içinde ücretsiz!',
                color: Color(0xFFF57C00),
                isLast: true,
              ),
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
                'SIS, danışman onayı, e-Devlet belgeleri ve kayıt süreci için adım adım rehber.',
            gradient: const [Color(0xFF7B1FA2), Color(0xFF512DA8)],
            backgroundIcon: Icons.assignment_rounded,
            actions: [
              Builder(builder: (ctx) => QuickActionChip(
                icon: Icons.assignment_outlined,
                label: 'Öğrenci Belgesi',
                onTap: () => _openSIS(ctx),
              )),
              Builder(builder: (ctx) => QuickActionChip(
                icon: Icons.note_alt_outlined,
                label: 'Transkript',
                onTap: () => _openSIS(ctx),
              )),
            ],
          ),

          // Kayıt Adımları
          const SectionCard(
            icon: Icons.checklist_rounded,
            title: 'Kayıt Adımları',
            iconColor: Color(0xFF7B1FA2),
            iconBgColor: Color(0x1A7B1FA2),
            children: [
              NumberedStep(
                number: 1,
                title: 'Belgeleri Hazırla',
                description:
                    'Kimlik, vesikalık fotoğraf, YKS yerleştirme belgesi, lise diploması. Varsa muafiyet belgeleri de getir.',
                color: Color(0xFF7B1FA2),
              ),
              NumberedStep(
                number: 2,
                title: 'SIS Hesabını Aktifleştir',
                description:
                    'sis.agu.edu.tr adresinden bilgilerini güncelle; danışmanını ve bölümünü kontrol et.',
                color: Color(0xFF7B1FA2),
              ),
              NumberedStep(
                number: 3,
                title: 'Ders Kaydını Yap',
                description:
                    'Akademik takvime göre ders kaydını aç, danışman onayını mutlaka al. Onaysız kayıt geçersiz!',
                color: Color(0xFF7B1FA2),
              ),
              NumberedStep(
                number: 4,
                title: 'Harç/Katkı Payı',
                description:
                    'Varsa harç ödemesini bankadan veya online yap. Ödeme sonrası dekontu sakla.',
                color: Color(0xFF7B1FA2),
              ),
              NumberedStep(
                number: 5,
                title: 'Öğrenci Kimliği & E-posta',
                description:
                    'Kampüste öğrenci kimliğini al, @agu.edu.tr e-posta hesabını aktifleştir.',
                color: Color(0xFF7B1FA2),
                isLast: true,
              ),
            ],
          ),

          // Önemli Bağlantılar
          SectionCard(
            icon: Icons.link_rounded,
            title: 'Önemli Bağlantılar',
            iconColor: const Color(0xFF512DA8),
            iconBgColor: const Color(0xFF512DA8).withOpacity(0.1),
            children: [
              LinkCard(
                icon: Icons.school_outlined,
                label: 'SIS Girişi',
                subtitle: 'Ders kayıt, not ve transkript',
                url: 'https://sis.agu.edu.tr/oibs/std/login.aspx',
                color: const Color(0xFF7B1FA2),
                onTapOverride: _openSIS,
              ),
              const LinkCard(
                icon: Icons.business_center_outlined,
                label: 'Öğrenci İşleri Daire Başkanlığı',
                subtitle: 'İletişim ve randevu',
                url: 'https://oidb-tr.agu.edu.tr/',
                color: Color(0xFF512DA8),
              ),
            ],
          ),

          // İpuçları
          const InfoBanner(
            text:
                'Tüm belgeleri PDF olarak yedekle ve e-Devlet şifrelerini güvenli tut. Kayıt döneminde yoğunluk olur, işlemleri erken tamamla!',
            icon: Icons.warning_amber_rounded,
            color: Color(0xFFFFA726),
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
                'Ders seçimi, not sistemi, sınav stratejileri ve akademik başarı için ipuçları.',
            gradient: const [Color(0xFF3949AB), Color(0xFF00ACC1)],
            backgroundIcon: Icons.auto_stories_rounded,
            actions: [
              Builder(builder: (ctx) => QuickActionChip(
                icon: Icons.school_outlined,
                label: 'SIS',
                onTap: () => _openSIS(ctx),
              )),
              Builder(builder: (ctx) => QuickActionChip(
                icon: Icons.laptop_mac,
                label: 'Canvas/Hazırlık',
                onTap: () => _openCanvasHazirlik(ctx),
              )),
              Builder(builder: (ctx) => QuickActionChip(
                icon: Icons.laptop_chromebook,
                label: 'Canvas/Bölüm',
                onTap: () => _openCanvasBolum(ctx),
              )),
              QuickActionChip(
                icon: Icons.local_library_outlined,
                label: 'Kütüphane',
                onTap: () => openLinkInApp(
                    'https://katalog.agu.edu.tr/yordam/?p=0&dil=0'),
              ),
            ],
          ),

          // Not Sistemi
          const SectionCard(
            icon: Icons.grading_rounded,
            title: 'Not Sistemi & Devamsızlık',
            iconColor: Color(0xFF3949AB),
            iconBgColor: Color(0x1A3949AB),
            children: [
              Bullet(
                "Her dersin syllabus'ında % ağırlıkları (quiz, ödev, midterm, final) belirtilir.",
                leadEmoji: '📊',
              ),
              Bullet(
                'Genel not ortalaması (GPA) 4.00 üzerinden hesaplanır.',
                leadEmoji: '📈',
              ),
              Bullet(
                'Devamsızlık limitleri ders bazında değişir — genelde %20-30 arası. Aş!ma!',
                leadEmoji: '⚠️',
              ),
              Bullet(
                'Dersten W (withdraw) çekmek notunu etkilemez ama kredi kaybedersin.',
                leadEmoji: '📝',
              ),
            ],
          ),

          // Çalışma Taktikleri
          const SectionCard(
            icon: Icons.psychology_outlined,
            title: 'Çalışma Stratejileri',
            iconColor: Color(0xFF00ACC1),
            iconBgColor: Color(0x1A00ACC1),
            children: [
              NumberedStep(
                number: 1,
                title: 'Düzenli Tekrar Yap',
                description:
                    'Her dersten sonra 20-30 dk tekrar. Spaced repetition tekniğini kullan.',
                color: Color(0xFF00ACC1),
              ),
              NumberedStep(
                number: 2,
                title: 'Çalışma Ortamını Seç',
                description:
                    'Kütüphanedeki sessiz alanlar, grup çalışma odaları veya kafeler — sana uygun olanı bul.',
                color: Color(0xFF00ACC1),
              ),
              NumberedStep(
                number: 3,
                title: 'Haftalık Plan Oluştur',
                description:
                    'Dersleri, ödev deadlineları ve kişisel zamanı dengele. Google Calendar veya Notion kullan.',
                color: Color(0xFF00ACC1),
              ),
              NumberedStep(
                number: 4,
                title: 'Sınav Haftası Stratejisi',
                description:
                    'Eski sınav sorularını çöz, özet defteri hazırla, 25 dk çalış - 5 dk mola (Pomodoro).',
                color: Color(0xFF00ACC1),
                isLast: true,
              ),
            ],
          ),

          // Faydalı Araçlar
          const SectionCard(
            icon: Icons.build_circle_outlined,
            title: 'Faydalı Araçlar',
            iconColor: Color(0xFF7E57C2),
            iconBgColor: Color(0x1A7E57C2),
            children: [
              Bullet('Notion / OneNote — ders notları organize etmek için.',
                  leadEmoji: '📓'),
              Bullet('Anki / Quizlet — flashcard ile etkili tekrar.',
                  leadEmoji: '🃏'),
              Bullet('Forest / Focus To-Do — odaklanma uygulamaları.',
                  leadEmoji: '🌳'),
              Bullet(
                  'ChatGPT / Perplexity — kavram araştırma (kopyala değil!).',
                  leadEmoji: '🤖'),
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
            subtitle:
                'Kulüpler, etkinlikler, spor aktiviteleri ve kampüs sosyal hayatı.',
            gradient: const [Color(0xFF8E24AA), Color(0xFFE53935)],
            backgroundIcon: Icons.celebration_rounded,
            actions: [
              QuickActionChip(
                icon: Icons.groups_2_outlined,
                label: 'Kulüpler',
                onTap: () => openLinkInApp('https://od-tr.agu.edu.tr/kulupler'),
              ),
              QuickActionChip(
                icon: Icons.sports_soccer_outlined,
                label: 'Spor Rezervasyon',
                onTap: () => openLinkInApp(
                    'https://booked.agu.edu.tr/Web/view-calendar.php'),
              ),
            ],
          ),

          // Kulüpler
          const SectionCard(
            icon: Icons.groups_rounded,
            title: 'Öğrenci Kulüpleri',
            iconColor: Color(0xFF8E24AA),
            iconBgColor: Color(0x1A8E24AA),
            children: [
              Bullet(
                'Tanıtım haftasında stantları gez, etkinliklere katıl, 1-2 kulüp seç.',
                leadEmoji: '🎪',
              ),
              Bullet(
                'Teknik kulüpler: Bilim ve Teknoloji, AGU Automotive Robotik, IEEE.',
                leadEmoji: '💻',
              ),
              Bullet(
                'Sosyal/kültürel: Tiyatro, Müzik, Fotoğrafçılık, Münazara.',
                leadEmoji: '🎭',
              ),
              Bullet(
                'Doğa/spor: Dağcılık, Kayak, Bisiklet.',
                leadEmoji: '🏔️',
              ),
              Bullet(
                'Gönüllülük: Toplum hizmeti, mentörlük ve yardımlaşma grupları.',
                leadEmoji: '🤝',
              ),
            ],
          ),

          // Spor
          const SectionCard(
            icon: Icons.fitness_center_rounded,
            title: 'Spor İmkanları',
            iconColor: Color(0xFFE53935),
            iconBgColor: Color(0x1AE53935),
            children: [
              PlaceCard(
                  emoji: '🏋️',
                  name: 'Fitness Salonu',
                  location: 'Spor Kompleksi'),
              PlaceCard(
                  emoji: '🏀', name: 'Basketbol Sahası', location: 'Açık Saha'),
              PlaceCard(
                  emoji: '🏐', name: 'Voleybol Sahası', location: 'Açık Alan'),
              PlaceCard(
                  emoji: '🎾', name: 'Tenis Kortu', location: 'Açık Alan'),
              InfoBanner(
                text:
                    'Spor tesislerini kullanmak için booked.agu.edu.tr üzerinden online rezervasyon yapman gerekiyor.',
                icon: Icons.event_available_rounded,
                color: Color(0xFFE53935),
              ),
            ],
          ),

          // Sosyalleşme tüyoları
          const SectionCard(
            icon: Icons.emoji_people_rounded,
            title: 'Sosyalleşme Rehberi',
            iconColor: Color(0xFFFF7043),
            iconBgColor: Color(0x1AFF7043),
            children: [
              Bullet(
                'İlk haftalarda oryantasyon etkinliklerine mutlaka katıl.',
                leadEmoji: '🌟',
              ),
              Bullet(
                'Kampüs kafelerinde zaman geçir, yeni insanlarla tanış.',
                leadEmoji: '☕',
              ),
              Bullet(
                'Talas merkezde öğrenci dostu kafeler ve buluşma noktaları var.',
                leadEmoji: '📍',
              ),
              Bullet(
                'Instagram\'da @aguogrenci ve kulüp hesaplarını takip et.',
                leadEmoji: '📱',
              ),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🏠',
            title: 'Yurt & Barınma',
            subtitle:
                'Yurt başvurusu, ev kiralama rehberi ve taşınma ipuçları.',
            gradient: const [Color(0xFF00796B), Color(0xFF43A047)],
            backgroundIcon: Icons.home_rounded,
            actions: [
              QuickActionChip(
                icon: Icons.home_work_outlined,
                label: 'KYK Yurt Başvurusu',
                onTap: () => openLinkInApp(
                    'https://www.turkiye.gov.tr/gsb-yurt-basvurusu'),
              ),
            ],
          ),

          // Yurt
          const SectionCard(
            icon: Icons.domain_outlined,
            title: 'Yurt Hayatı',
            iconColor: Color(0xFF00796B),
            iconBgColor: Color(0x1A00796B),
            children: [
              Bullet(
                'KYK yurtlarına başvuru e-Devlet üzerinden yapılır. Son tarihleri takip et.',
                leadEmoji: '📅',
              ),
              Bullet(
                'Yurt kurallarını öğren: sessiz saatler, misafir politikası, ortak alan düzeni.',
                leadEmoji: '📋',
              ),
              Bullet(
                'Yanında getir: dolap kilidi, priz çoklayıcı, kulaklık ve göz bandı.',
                leadEmoji: '🎒',
              ),
              Bullet(
                'Oda arkadaşıyla iletişimi sağlam tut — temizlik ve uyku düzeni konuşun.',
                leadEmoji: '🤝',
              ),
            ],
          ),

          // Ev Kiralama
          const SectionCard(
            icon: Icons.key_rounded,
            title: 'Ev Kiralama Rehberi',
            iconColor: Color(0xFF43A047),
            iconBgColor: Color(0x1A43A047),
            children: [
              NumberedStep(
                number: 1,
                title: 'Lokasyon Araştır',
                description:
                    'Tramvaya yürüme mesafesi, market/eczane yakınlığı ve güvenli mahalle seç.',
                color: Color(0xFF43A047),
              ),
              NumberedStep(
                number: 2,
                title: 'Evi İncele',
                description:
                    'Isınma türü (doğalgaz/merkezi), nem durumu, yalıtım ve tesisat kontrol et.',
                color: Color(0xFF43A047),
              ),
              NumberedStep(
                number: 3,
                title: 'Sözleşme & Depozito',
                description:
                    'Sözleşmeyi dikkatlice oku, depozito miktarını ve ödeme takvimini netleştir.',
                color: Color(0xFF43A047),
              ),
              NumberedStep(
                number: 4,
                title: 'Faturaları Ayarla',
                description:
                    'Elektrik, su, doğalgaz ve internet aboneliklerini hemen devral veya yeni aç.',
                color: Color(0xFF43A047),
              ),
              NumberedStep(
                number: 5,
                title: 'Ev Arkadaşı Bul',
                description:
                    'Sosyal medya grupları ve üniversite panoları üzerinden güvenilir ev arkadaşı ara.',
                color: Color(0xFF43A047),
                isLast: true,
              ),
            ],
          ),

          // Tavsiye mahalleler
          const SectionCard(
            icon: Icons.map_rounded,
            title: 'Önerilen Bölgeler',
            iconColor: Color(0xFF0288D1),
            iconBgColor: Color(0x1A0288D1),
            children: [
              PlaceCard(
                  emoji: '📍',
                  name: 'Talas Merkez',
                  location: 'Tramvay hattı üzeri, kampüse yakın'),
              PlaceCard(
                  emoji: '📍',
                  name: 'Mevlana Mahallesi',
                  location: 'Uygun fiyatlı, öğrenci yoğun'),
              PlaceCard(
                  emoji: '📍',
                  name: 'Kıranardı',
                  location: 'Sakin, yeni binalar'),
            ],
          ),

          const InfoBanner(
            text:
                'İlk kez ev tutuyorsan, tecrübeli bir arkadaşını veya ailen yanına alarak evi gezmenizi öneriyoruz.',
            icon: Icons.family_restroom_rounded,
            color: Color(0xFF00796B),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// 9) ACİL DURUMLAR & İLETİŞİM
/// ------------------------------------------------------------
class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
      child: Column(
        children: [
          HeroHeader(
            emoji: '🚨',
            title: 'Acil Durumlar & İletişim',
            subtitle:
                'Acil numaralar, kampüs güvenliği ve psikolojik destek bilgileri.',
            gradient: const [Color(0xFFD32F2F), Color(0xFFFF5722)],
            backgroundIcon: Icons.emergency_rounded,
            actions: [
              QuickActionChip(
                icon: Icons.phone_in_talk_rounded,
                label: '112 Acil',
                onTap: () => launchUrl(Uri.parse('tel:112')),
              ),
              QuickActionChip(
                icon: Icons.local_hospital_outlined,
                label: 'Sağlık Merkezi',
                onTap: () {},
              ),
            ],
          ),

          // Acil Numaralar
          const SectionCard(
            icon: Icons.phone_rounded,
            title: 'Acil Numaralar',
            iconColor: Color(0xFFD32F2F),
            iconBgColor: Color(0x1AD32F2F),
            children: [
              Bullet('112 — Genel Acil Yardım',
                  leadIcon: Icons.emergency_rounded,
                  leadColor: Color(0xFFD32F2F)),
              Bullet('155 — Polis İmdat',
                  leadIcon: Icons.local_police_rounded,
                  leadColor: Color(0xFF1565C0)),
              Bullet('110 — İtfaiye',
                  leadIcon: Icons.local_fire_department_rounded,
                  leadColor: Color(0xFFE65100)),
              Bullet('182 — Alo Psikolojik Destek Hattı',
                  leadIcon: Icons.psychology_rounded,
                  leadColor: Color(0xFF7B1FA2)),
              Bullet('183 — Sosyal Destek Hattı',
                  leadIcon: Icons.support_agent_rounded,
                  leadColor: Color(0xFF00897B)),
            ],
          ),

          // Kampüs Güvenliği
          SectionCard(
            icon: Icons.shield_rounded,
            title: 'Kampüs İçi Destek',
            iconColor: const Color(0xFF1565C0),
            iconBgColor: const Color(0xFF1565C0).withOpacity(0.1),
            children: const [
              Bullet(
                'Kampüs güvenlik birimi 7/24 aktif. Ana girişten veya telefonla ulaşabilirsin.',
                leadEmoji: '🛡️',
              ),
              Bullet(
                'Sağlık ünitesi kampüste mevcut — küçük müdahaleler ve yönlendirme yapılır.',
                leadEmoji: '🏥',
              ),
              Bullet(
                'Psikolojik Danışmanlık Birimi: Stres, uyum sorunları ve kişisel destek için randevu al.',
                leadEmoji: '🧠',
              ),
            ],
          ),

          // Öğrenci İşleri
          SectionCard(
            icon: Icons.support_outlined,
            title: 'Öğrenci Destek Birimleri',
            iconColor: const Color(0xFF00897B),
            iconBgColor: const Color(0xFF00897B).withOpacity(0.1),
            children: const [
              LinkCard(
                icon: Icons.business_center_outlined,
                label: 'Öğrenci İşleri Daire Başkanlığı',
                subtitle: 'Kayıt, belge ve genel işlemler',
                url: 'https://oidb-tr.agu.edu.tr/',
                color: Color(0xFF00897B),
              ),
              LinkCard(
                icon: Icons.people_outline_rounded,
                label: 'Öğrenci Dekanlığı',
                subtitle: 'Danışmanlık ve yönlendirme',
                url: 'https://od-tr.agu.edu.tr/',
                color: Color(0xFF5C6BC0),
              ),
            ],
          ),

          const InfoBanner(
            text:
                'Acil bir durumda panik yapma. Önce güvenli bir yere geç, ardından 112\'yi ara. Kampüs güvenliğe de mutlaka haber ver.',
            icon: Icons.warning_amber_rounded,
            color: Color(0xFFD32F2F),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PAGEVIEW: REHBER — Geliştirilmiş navigasyon
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

  // Her sayfanın başlık bilgisi
  static const List<_PageInfo> _pageInfos = [
    _PageInfo('Kayseri', Icons.location_city_rounded),
    _PageInfo('Üniversite', Icons.school_rounded),
    _PageInfo('Yemek', Icons.restaurant_rounded),
    _PageInfo('Ulaşım', Icons.directions_bus_rounded),
    _PageInfo('Kayıt', Icons.assignment_rounded),
    _PageInfo('Akademik', Icons.auto_stories_rounded),
    _PageInfo('Sosyal', Icons.celebration_rounded),
    _PageInfo('Barınma', Icons.home_rounded),
    _PageInfo('Acil', Icons.emergency_rounded),
  ];

  late final List<Widget> _pages = [
    const CityKayseriPage(key: PageStorageKey('city_kayseri')),
    const UniversityOverviewPage(key: PageStorageKey('univ_overview')),
    const FoodCafesPage(key: PageStorageKey('food_cafes')),
    const TransportPage(key: PageStorageKey('transport')),
    const RegistrationDocsPage(key: PageStorageKey('reg_docs')),
    const AcademicSurvivalPage(key: PageStorageKey('academic_survival')),
    const SocialLifePage(key: PageStorageKey('social_life')),
    const HousingPage(key: PageStorageKey('housing')),
    const EmergencyContactsPage(key: PageStorageKey('emergency')),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_isAnimating) return;
    final isLast = _index >= _pages.length - 1;
    if (isLast) return;
    _isAnimating = true;
    await _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _isAnimating = false;
  }

  Future<void> _goPrev() async {
    if (_isAnimating) return;
    final isFirst = _index <= 0;
    if (isFirst) return;
    _isAnimating = true;
    await _controller.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isFirst = _index == 0;
    final bool isLast = _index == _pages.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rehber',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _pages[i],
          ),

          // ← Sol ok
          if (!isFirst)
            Positioned(
              left: 4,
              top: size.height * 0.38,
              child: _NavArrow(
                icon: Icons.chevron_left_rounded,
                onTap: _goPrev,
                tooltip: 'Önceki sayfa',
              ),
            ),

          // → Sağ ok
          if (!isLast)
            Positioned(
              right: 4,
              top: size.height * 0.38,
              child: _NavArrow(
                icon: Icons.chevron_right_rounded,
                onTap: _goNext,
                tooltip: 'Sonraki sayfa',
              ),
            ),

          // Alt bar: sayfa göstergeleri + başlık
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sayfa göstergeleri
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _index ? 24 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == _index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Sayfa başlığı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _pageInfos[_index].icon,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_index + 1}/${_pages.length} • ${_pageInfos[_index].title}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
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

/// Sayfa bilgi modeli
class _PageInfo {
  final String title;
  final IconData icon;
  const _PageInfo(this.title, this.icon);
}

/// Gelişmiş navigasyon ok butonu
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _NavArrow({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
