import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GelistiricilerScreen extends StatelessWidget {
  final List<Map<String, String>> developers = [
    {
      "name": "Mustafa Biçer",
      "bio": "Bilgisayar Mühendisliği 3. sınıf öğrencisi",
      "image": "assets/images/gelistiriciler/mustafa_bicer.jpg",
      "link_url": "https://www.linkedin.com/in/mustafa-bi%C3%A7er-a31753204/"
    },
    {
      "name": "Yunus Başkan",
      "bio":
          "Bilgisayar Mühendisliği 3. sınıf öğrencisiyim ve yapay zeka, veri bilimi ve blockchain teknolojilerine ilgi duyuyorum. Bu alanlarda kendimi geliştirmek için araştırmalar yapıyor, projeler üretiyor ve yeni teknolojileri yakından takip ediyorum.",
      "image": "assets/images/gelistiriciler/yunus_baskan2.jpg",
      "link_url": "https://www.linkedin.com/in/yunus-ba%C5%9Fkan-7b0830204/"
    },
    {
      "name": "Mustafa Uğur Karaköse",
      "bio":
          "Merhaba, ben bilgisayar mühendisliği 3. sınıf öğrencisiyim. Flutter ile mobil uygulama geliştirip, java spring boot ile servis geliştirmekteyim.",
      "image": "assets/images/gelistiriciler/karakose.jpg",
      "link_url":
          "https://www.linkedin.com/in/mustafa-u%C4%9Fur-karak%C3%B6se-091769339/"
    },
    {
      "name": "Turgut Alp Yeşil",
      "bio":
          "Bilgisayar Mühendisliği 3. sınıf öğrencisi olarak, yazılım geliştirme, veri yapıları ve problem çözme becerilerimi projelerle güçlendiriyorum. Gelecekte yazılım mühendisliği, yapay zeka, veri bilimi veya siber güvenlik alanlarında başarılı olmayı hedefliyorum.",
      "image": "assets/images/gelistiriciler/turgut_alp.jpg",
      "link_url": "https://www.linkedin.com/in/turgut-alp-ye%C5%9Fil/"
    }
  ];

  /// LinkedIn profil/link açma yardımcı metodu.
  /// - [linkUrl] örn: "https://www.linkedin.com/in/mustafa-bicer-12345"
  /// - Eğer cihazda LinkedIn uygulaması varsa uygulamadan açmaya çalışır,
  ///   yoksa varsayılan tarayıcıda web linkini açar.
  Future<void> openLinkedInProfile(String linkUrl) async {
    if (linkUrl.trim().isEmpty) return;

    Uri? webUri;
    try {
      webUri = Uri.parse(linkUrl);
    } catch (e) {
      // Geçersiz URL ise işlem yapma
      return;
    }

    // Try to build app-specific URI from common LinkedIn patterns
    //  - personal: https://www.linkedin.com/in/<slug>
    //  - company:  https://www.linkedin.com/company/<slug>
    Uri? appUri;

    final path = webUri.path; // örn: /in/mustafa-bicer-12345/
    final segments = webUri.pathSegments;

    if (segments.isNotEmpty) {
      if (segments.length >= 2 && segments[0].toLowerCase() == 'in') {
        final slug = segments.sublist(1).join('/');
        // linkedin app deep link for people profiles
        appUri = Uri.parse('linkedin://in/$slug');
      } else if (segments.length >= 2 &&
          segments[0].toLowerCase() == 'company') {
        final slug = segments.sublist(1).join('/');
        // linkedin app deep link for company pages
        appUri = Uri.parse('linkedin://company/$slug');
      }
    }

    // Eğer özel appUri oluşturulabildiyse, önce onu dene
    if (appUri != null) {
      try {
        final canOpenApp = await canLaunchUrl(appUri);
        if (canOpenApp) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {
        // bir hata olursa web fallback'a düşecek
      }
    }

    // Genel fallback: uygulama açılmıyorsa tarayıcıda web URL'sini aç
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // açma işlemi başarısız olursa sessizce dön (veya istersen hata logla)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Geliştiriciler"),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          //Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: 15,
            ),
            Expanded(
              flex: 3, // GridView'in ekrana yayılmasını sağlar
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8), // Sağdan ve soldan 8 px boşluk

                // shrinkWrap: true, // Yüksekliği içeriğe göre ayarlar
                physics:
                    const NeverScrollableScrollPhysics(), // Scroll'u kapatarak sabit bir görünüm sağlar
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 40,
                  childAspectRatio: 0.55,
                ),
                itemCount: developers.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(15), // Card köşe yuvarlatma
                      gradient: const LinearGradient(
                        colors: [
                          //const Color.fromARGB(255, 32, 32, 32),
                          //const Color.fromARGB(255, 39, 113, 148)
                          Color.fromARGB(255, 32, 32, 32),
                          Color.fromARGB(255, 39, 113, 148)
                        ], // Gradyan renkler
                        begin: Alignment.topLeft, // Başlangıç noktası
                        end: Alignment.bottomRight, // Bitiş noktası
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment(0, 1.1),
                      children: [
                        SizedBox(
                          // height: 1500,
                          child: Card(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(
                                      developers[index]["image"]!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    developers[index]["name"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      // Uzun bio'ların taşmasını önler
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          developers[index]["bio"]!,
                                          //textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70),
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Colors.transparent,
                              elevation: 0),
                          onPressed: () {
                            openLinkedInProfile(developers[index]["link_url"]!);
                            // printColored(
                            //     "linkedin linki: ${developers[index]["link_url"]!}",
                            //     "32");
                          },
                          child: Image.asset(
                            "assets/images/linkedin_logo.png",
                            height: 42,
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            // const Spacer(), // Alt boşluk ekleyerek GridView'ı ortalamaya yardımcı olur
          ],
        ),
      ),
    );
  }
}
