import 'package:flutter/material.dart';
import 'package:home_page/methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordScreen extends StatefulWidget {
  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  TextEditingController canvasMail = TextEditingController();
  TextEditingController canvasPassword = TextEditingController();
  TextEditingController prepCanvasMail = TextEditingController();
  TextEditingController prepCanvasPassword = TextEditingController();
  TextEditingController zimbraMail = TextEditingController();
  TextEditingController zimbraPassword = TextEditingController();
  TextEditingController sisMail = TextEditingController();
  TextEditingController sisPassword = TextEditingController();
  bool isChecked = false;
  bool _isDialogShown = false;
  Methods methods = Methods();

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
    checkDialogPreference(); // Dialog tercih kontrolü
  }

  Future<void> loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      canvasMail.text = prefs.getString("canvasMail") ?? "";
      canvasPassword.text = prefs.getString("canvasPassword") ?? "";
      prepCanvasMail.text = prefs.getString("prepCanvasMail") ?? "";
      prepCanvasPassword.text = prefs.getString("prepCanvasPassword") ?? "";
      zimbraMail.text = prefs.getString("zimbraMail") ?? "";
      zimbraPassword.text = prefs.getString("zimbraPassword") ?? "";
      sisMail.text = prefs.getString("sisMail") ?? "";
      sisPassword.text = prefs.getString("sisPassword") ?? "";
    });
  }

  Future<void> checkDialogPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shouldShowDialog =
        prefs.getBool("showPrivacyDialog") ?? true; // Varsayılan: true
    if (shouldShowDialog && !_isDialogShown) {
      _isDialogShown = true;
      Future.microtask(() => _showPrivacyDialog());
    }
  }

  Future<void> saveCredentials(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("canvasMail", canvasMail.text);
    await prefs.setString("canvasPassword", canvasPassword.text);
    await prefs.setString("prepCanvasMail", prepCanvasMail.text);
    await prefs.setString("prepCanvasPassword", prepCanvasPassword.text);
    await prefs.setString("zimbraMail", zimbraMail.text);
    await prefs.setString("zimbraPassword", zimbraPassword.text);
    await prefs.setString("sisMail", sisMail.text);
    await prefs.setString("sisPassword", sisPassword.text);

    // Kullanıcıya bilgilendirme mesajı göster
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[900],
            title: const Text(
              "Başarılı",
              style: TextStyle(color: Colors.amber),
            ),
            content: const Text(
              "Bilgiler başarıyla kaydedildi!",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog'u kapat
                  // Navigator.of(context).popUntil((route) => route.isFirst),
                },
                child: const Text(
                  "Tamam",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          );
        });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text("Bilgiler başarıyla kaydedildi!"),
    //     backgroundColor: Colors.green,
    //   ),
    // );
  }

  Future<void> _saveDialogPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("showPrivacyDialog", value);
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Gizlilik Bildirimi"),
              content: const Text(
                "Merak etmeyin, girdiğiniz bilgiler yalnızca sizin erişiminiz için kendi cihazınızda güvenli bir şekilde saklanmaktadır."
                "Bu veriler, yalnızca uygulama içerisindeki öğrenci giriş işlemlerinizi kolaylaştırmak amacıyla tutulmaktadır. Güvenliğiniz bizim önceliğimizdir.",
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          isChecked = value ?? false;
                        });
                      },
                    ),
                    const Text("Bir daha gösterme"),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    _saveDialogPreference(
                        !isChecked); // Kullanıcı tercihini kaydet
                    Navigator.of(context).pop(); // Dialog'u kapat
                  },
                  child: const Text("Anladım"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için controller'ları temizle
    canvasMail.dispose();
    canvasPassword.dispose();
    prepCanvasMail.dispose();
    prepCanvasPassword.dispose();
    zimbraMail.dispose();
    zimbraPassword.dispose();
    sisMail.dispose();
    sisPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Bilgileri"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 255, 255, 255),
          Color.fromARGB(255, 39, 113, 148),
          Color.fromARGB(255, 255, 255, 255),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      bottom: BorderSide(color: Colors.black, width: 4),
                      right: BorderSide(color: Colors.black, width: 3),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Canvas Bilgileri",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        methods.buildTextField(
                            "Canvas Mail", const Icon(Icons.email), canvasMail),
                        const SizedBox(height: 10),
                        methods.buildPasswordField("Canvas Şifre",
                            const Icon(Icons.lock), canvasPassword),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      bottom: BorderSide(color: Colors.black, width: 4),
                      right: BorderSide(color: Colors.black, width: 3),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Hazırlık Canvas Bilgileri",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        methods.buildTextField("Canvas Mail",
                            const Icon(Icons.email), prepCanvasMail),
                        const SizedBox(height: 10),
                        methods.buildPasswordField("Canvas Şifre",
                            const Icon(Icons.lock), prepCanvasPassword),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      bottom: BorderSide(color: Colors.black, width: 4),
                      right: BorderSide(color: Colors.black, width: 3),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Zimbra Bilgileri",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        methods.buildTextField(
                            "Zimbra Mail", const Icon(Icons.email), zimbraMail),
                        const SizedBox(height: 10),
                        methods.buildPasswordField("Zimbra Şifre",
                            const Icon(Icons.lock), zimbraPassword),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: const Border(
                      bottom: BorderSide(color: Colors.black, width: 4),
                      right: BorderSide(color: Colors.black, width: 3),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "SIS Bilgileri",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        methods.buildTextField("Öğrenci ID numarası",
                            const Icon(Icons.email), sisMail),
                        const SizedBox(height: 10),
                        methods.buildPasswordField(
                            "SIS Şifre", const Icon(Icons.lock), sisPassword),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton.icon(
                  onPressed: () => saveCredentials(context),
                  icon: const Icon(Icons.save),
                  label: const Text("Kaydet"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
