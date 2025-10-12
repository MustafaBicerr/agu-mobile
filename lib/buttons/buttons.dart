import 'package:flutter/material.dart';
import 'package:home_page/buttons/customButton.dart';
import 'package:home_page/buttons/loginService.dart';
import 'package:home_page/buttons/sis_agu.dart';
import 'package:home_page/buttons/zimbra_agu.dart';
import 'package:home_page/methods.dart';
import 'package:home_page/screens/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Buttons extends StatefulWidget {
  @override
  State<Buttons> createState() => _Buttons();
}

class _Buttons extends State<Buttons> {
  Methods methods = Methods();

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveDialogPreference(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("showAutoEntryDialog", value);
  }

  Future<bool> shouldShowAutoEntryDialog() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("showAutoEntryDialog") ?? true;
  }

  Future<void> saveManualLoginOnly(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("manualLoginOnly", value);
  }

  Future<bool> shouldUseManualLoginOnly() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("manualLoginOnly") ?? false;
  }

  void showAutoEntryDialog(
      VoidCallback onManualLogin, VoidCallback onAutoLogin) async {
    bool showDialogPreference = await shouldShowAutoEntryDialog();

    if (!showDialogPreference) {
      onManualLogin();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Otomatik Giriş"),
          content: const Text(
            "Bu uygulama, sizin adınıza giriş yapabilen bir bot özelliği sunmaktadır.\n\n"
            "🔹 Hesap bilgileriniz güvende tutulur.\n"
            "🔹 Bu özellik isteğe bağlıdır.\n"
            "🔹 Manuel giriş seçeneğiniz her zaman mevcuttur.\n\n"
            "Bu özelliği kullanmak istiyor musunuz?",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // AlertDialog tekrar gösterilecek, manuel giriş zorunlu hale getirilmedi
                Navigator.of(context).pop();
                onManualLogin();
              },
              child: const Text("Hayır"),
            ),
            TextButton(
              onPressed: () async {
                await saveManualLoginOnly(false); // Otomatik giriş seçildi
                Navigator.of(context).pop();
                onAutoLogin();
              },
              child: const Text("Evet"),
            ),
          ],
        );
      },
    );
  }

  void handleButtonPress({
    required String title,
    required String url,
    required String mailPrefKey,
    required String passwordPrefKey,
    required String mailFieldName,
    required String passwordFieldName,
    required String loginButtonFieldXPath,
    required String keyword,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String savedMail = preferences.getString(mailPrefKey) ?? "";
    String savedPassword = preferences.getString(passwordPrefKey) ?? "";

    if (savedMail.isNotEmpty && savedPassword.isNotEmpty) {
      // Eğer giriş bilgileri varsa direkt giriş yap
      methods.navigateToPage(
        context,
        LoginService(
          title: title,
          url: url,
          mail: savedMail,
          password: savedPassword,
          mailFieldName: mailFieldName,
          passwordFieldName: passwordFieldName,
          loginButtonFieldXPath: loginButtonFieldXPath,
          keyword: keyword,
        ),
      );
      return;
    }

    // Manuel giriş zorunlu hale getirilmediği sürece AlertDialog göster
    showAutoEntryDialog(
      // 🔹 "Zimbra" ise özel sayfaya yönlendir
      () {
        methods.navigateToPage(context, WebPage(url: url, title: title));
      },
      () {
        methods.navigateToPage(context, PasswordScreen());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 60, right: 30),
          child: Row(
            children: [
              Column(
                children: [
                  CustomImageButton(
                    assetPath: "assets/images/Canvas_logo_single_mark.png",
                    onTap: () {
                      handleButtonPress(
                        title: "Canvas AGU",
                        url: "https://canvas.agu.edu.tr/login/canvas",
                        mailPrefKey: "canvasMail",
                        passwordPrefKey: "canvasPassword",
                        mailFieldName: "pseudonym_session[unique_id]",
                        passwordFieldName: "pseudonym_session[password]",
                        loginButtonFieldXPath: "//*[@id='login_form']/button",
                        keyword: "success",
                      );
                    },
                    backgroundColor: Colors.redAccent,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "CANVAS",
                  ),
                ],
              ),
              const SizedBox(
                width: 30,
              ),
              Column(
                children: [
                  CustomImageButton(
                    assetPath: "assets/images/Canvas_logo_single_mark.png",
                    onTap: () {
                      handleButtonPress(
                        title: "Canvas PREP",
                        url: "https://canvasfl.agu.edu.tr/login/canvas",
                        mailPrefKey: "prepCanvasMail",
                        passwordPrefKey: "prepCanvasPassword",
                        mailFieldName: "pseudonym_session[unique_id]",
                        passwordFieldName: "pseudonym_session[password]",
                        loginButtonFieldXPath: "//*[@id='login_form']/button",
                        keyword: "success",
                      );
                    },
                    backgroundColor: Colors.redAccent,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "PREP",
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                children: [
                  CustomImageButton(
                    assetPath: "assets/images/unnamed.png",
                    onTap: () {
                      handleButtonPress(
                        title: "Zimbra AGU",
                        url: "https://posta.agu.edu.tr",
                        mailPrefKey: "zimbraMail",
                        passwordPrefKey: "zimbraPassword",
                        mailFieldName: "username",
                        passwordFieldName: "password",
                        loginButtonFieldXPath: "//*[@id='loginButton']",
                        keyword: "#1",
                      );

                      // methods.navigateToPage(context, ZimbraPage());
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "ZİMBRA",
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Column(
                children: [
                  CustomImageButton(
                    assetPath: "assets/images/images.png",
                    onTap: () {
                      handleButtonPress(
                        title: "SIS AGU",
                        url: "https://sis.agu.edu.tr/oibs/std/login.aspx",
                        mailPrefKey: "sisMail",
                        passwordPrefKey: "sisPassword",
                        mailFieldName: "txtParamT01",
                        passwordFieldName: "txtParamT02",
                        loginButtonFieldXPath: "//*[@id='btnLoginn']",
                        keyword: "index",
                      );
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "SİS",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
