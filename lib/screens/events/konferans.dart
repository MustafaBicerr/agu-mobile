import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/models/events.dart';

class ConferencePage extends StatelessWidget {
  final Speaker speaker;
  const ConferencePage({super.key, required this.speaker});

  @override
  Widget build(BuildContext context) {
    final items = _extractSpeakers(speaker);

    return Scaffold(
      appBar: AppBar(
        // title: const Text("Konferans"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      bottomNavigationBar: bottomBar2(context, 2),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 39, 113, 148),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      speaker.etkinlik_adi ?? "ETKİNLİK",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .2),
                    ),
                    const SizedBox(height: 6),
                    Text("Konuşmacılar",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontSize: 22,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ——— ÇAPRAZ GRID ———
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                itemBuilder: (context, i) {
                  // 2. sütundaki kartları biraz aşağı kaydır
                  final isSecondColumn = i.isOdd;
                  return Padding(
                    padding: EdgeInsets.only(top: isSecondColumn ? 80 : 0),
                    child: _SpeakerCard(item: items[i], index: i),
                  );
                },
                childCount: items.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  /// API alanlarını (unvanX, adX, urlX) -> listeye çevir
  List<_SpeakerItem> _extractSpeakers(Speaker s) {
    String? t(Object? v) {
      final x = (v ?? "").toString().trim();
      return x.isEmpty ? null : x;
    }

    final list = <_SpeakerItem>[];
    void add(String? u, String? a, String? r) {
      final unvan = t(u), ad = t(a), url = t(r);
      if (unvan != null || ad != null || url != null) {
        list.add(_SpeakerItem(unvan: unvan ?? "-", ad: ad ?? "-", url: url));
      }
    }

    add(s.unvan1, s.ad1, s.url1);
    add(s.unvan2, s.ad2, s.url2);
    add(s.unvan3, s.ad3, s.url3);
    add(s.unvan4, s.ad4, s.url4);
    add(s.unvan5, s.ad5, s.url5);

    return list;
  }
}

// ————————————————————————————————————————

class _SpeakerCard extends StatelessWidget {
  const _SpeakerCard({required this.item, required this.index});
  final _SpeakerItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(.96);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index % 4) * 90),
      curve: Curves.easeOut,
      builder: (context, v, child) => Transform.translate(
        offset: Offset(0, (1 - v) * 24),
        child: Opacity(opacity: v, child: child),
      ),
      child: _Pressable(
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar + renkli halka
              _RingAvatar(url: item.url, initialsName: item.ad),
              const SizedBox(height: 14),

              // Unvan (vurgulu)
              Text(
                item.unvan.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // İsim
              Text(
                item.ad,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Rozet/etiket
              Container(
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Konuşmacı",
                  style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Renkli halka + dairesel avatar
class _RingAvatar extends StatelessWidget {
  const _RingAvatar({this.url, required this.initialsName});
  final String? url;
  final String initialsName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 116,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // hafif canlı halka
        gradient:
            LinearGradient(colors: [Color(0xFF7C89FF), Color(0xFF4CD2E0)]),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.2),
        child: ClipOval(
          child: Container(
            color: const Color(0xFFE9ECF6),
            child: url == null
                ? _PlaceholderAvatar(name: initialsName)
                : Image.network(
                    url!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _PlaceholderAvatar(name: initialsName),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? "?"
        : name
            .trim()
            .split(RegExp(r"\s+"))
            .take(2)
            .map((e) => e[0])
            .join()
            .toUpperCase();

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
            fontSize: 34, fontWeight: FontWeight.w800, color: Colors.black45),
      ),
    );
  }
}

// Hafif basma/hover efekti
class _Pressable extends StatefulWidget {
  const _Pressable({required this.child});
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _down ? .98 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.translationValues(0, _down ? 2 : 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}

// ————————————————————————————————————————

class _SpeakerItem {
  final String unvan;
  final String ad;
  final String? url;
  _SpeakerItem({required this.unvan, required this.ad, this.url});
}
