import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_page/bottom.dart';

class YemekhanePage extends StatefulWidget {
  const YemekhanePage({super.key});

  @override
  _YemekhanePageState createState() => _YemekhanePageState();
}

class _YemekhanePageState extends State<YemekhanePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> imageUrls = [
    'https://mudugida.com/wp-content/uploads/2022/11/mercimek.jpg',
    'https://cdn.ye-mek.net/App_UI/Img/out/650/2022/05/lokanta-usulu-tavuk-sote-resimli-yemek-tarifi(12).jpg',
    'https://ideacdn.net/idea/dm/86/myassets/blogs/pilav-tarifi-tane-tane.jpg?revision=1628682122',
    'https://cdn.ye-mek.net/App_UI/Img/out/650/2017/10/brokolili-karnabahar-salatasi-resimli-yemek-tarifi(12).jpg',
    'https://www.41kocaeli.net/files/uploads/news/default/20230427-en-kolay-trilice-tarifi-612354-05ffad975ed5acb56031.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 3),
      appBar: AppBar(
        title: const Text("Yemekhane"),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        thickness: 8.0,
        radius: const Radius.circular(10),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 15),
                _buildMenuCard("Mercimek Çorbası", 'corba', imageUrls[0]),
                const SizedBox(height: 20),
                _buildMenuCard("Tavuk Sote", 'ana_yemek', imageUrls[1]),
                const SizedBox(height: 20),
                _buildMenuCard(
                    "Pirinç Pilavı", 'vejeteryan_yemek', imageUrls[2]),
                const SizedBox(height: 20),
                _buildMenuCard(
                    "Vejeteryan Menü", 'yardimci_yemek', imageUrls[3]),
                const SizedBox(height: 20),
                _buildMenuCard("Triliçe", 'tamamlayici_grup', imageUrls[4]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title2, String firestoreId, String imageUrl) {
    double? userRating;
    bool showSubmitButton = false;
    bool showRatingStars = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('yemekhane').doc(firestoreId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // Hata kontrolü ekleyelim
            if (!snapshot.hasData ||
                snapshot.data == null ||
                !snapshot.data!.exists) {
              return Text("Veri bulunamadı");
            }

            // Firebase'den gelen veriyi map olarak alalım
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            // Eğer ilgili değerler yoksa varsayılan değer atayalım
            double averageRating = (data['averageRating'] ?? 0).toDouble();
            int totalVotes = data['totalVotes'] ?? 0;
            String title2 = data['yemek_adi'] ?? "Bilinmeyen Yemek";

            return Card(
              child: Column(
                children: [
                  Image.network(imageUrl,
                      height: 250, width: double.infinity, fit: BoxFit.cover),
                  ListTile(
                    title: Text(title2,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Ortalama Puan: ${averageRating.toStringAsFixed(1)}"),
                          Text("Toplam Oy: $totalVotes"),
                        ],
                      ),
                      if (!showRatingStars)
                        RatingBarIndicator(
                          rating: averageRating,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 30.0,
                          direction: Axis.horizontal,
                        ),
                      if (showRatingStars)
                        RatingBar.builder(
                          initialRating: userRating?.toDouble() ?? 0.0,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              userRating = rating;
                              showSubmitButton = true;
                            });
                          },
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!showSubmitButton)
                        ElevatedButton(
                          onPressed: () async {
                            bool alreadyRated =
                                await _checkIfUserRated(firestoreId);
                            if (alreadyRated) {
                              _showFeedback(context,
                                  "Bu yemeği zaten puanladınız!", imageUrl);
                              return;
                            }
                            setState(() {
                              showRatingStars = true;
                              showSubmitButton = true;
                            });
                          },
                          child: const Text("Puan Ver"),
                        ),
                      if (showSubmitButton) ...[
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showSubmitButton = false;
                              showRatingStars = false;
                              userRating = null;
                            });
                          },
                          child: const Text("Vazgeç"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await _submitRating(
                                  firestoreId, userRating ?? 0.0);
                              setState(() {
                                showSubmitButton = false;
                                showRatingStars = false;
                                userRating = null;
                              });
                              _showFeedback(
                                  context,
                                  "Puanınız gönderildi ($title2)\nOrtalama puan: ${averageRating.toStringAsFixed(1)}",
                                  imageUrl);
                            } catch (e) {
                              _showFeedback(
                                  context, "Bir hata oluştu: $e", imageUrl);
                            }
                          },
                          child: Text(
                              "${userRating?.toStringAsFixed(1) ?? "0.0"} Puan Gönder"),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _checkIfUserRated(String firestoreId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final docRef = _firestore
        .collection('yemekhane')
        .doc(firestoreId)
        .collection('votes')
        .doc(user.uid);
    final snapshot = await docRef.get();
    return snapshot.exists;
  }

  Future<void> _submitRating(String firestoreId, double rating) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('yemekhane').doc(firestoreId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      int totalVotes = snapshot['totalVotes'] ?? 0;
      double totalRating = snapshot['totalRating']?.toDouble() ?? 0.0;

      totalVotes++;
      totalRating += rating;

      await docRef.update({
        'totalVotes': totalVotes,
        'totalRating': totalRating,
        'averageRating': totalRating / totalVotes,
      });
    } else {
      await docRef.set({
        'totalVotes': 1,
        'totalRating': rating,
        'averageRating': rating,
      });
    }

    // Kullanıcının verdiği puanı votes koleksiyonuna kaydet
    final userDocRef = docRef.collection('votes').doc(user.uid);
    await userDocRef.set({
      'rating': rating,
    });
  }

  void _showFeedback(BuildContext context, String message, String imageUrl) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Expanded(child: Text(message)),
          const SizedBox(width: 10),
          Image.network(
            imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ],
      ),
      duration: const Duration(milliseconds: 500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
