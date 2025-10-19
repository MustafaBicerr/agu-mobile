import 'package:flutter/material.dart';
import 'package:home_page/bottom.dart';

import 'package:webview_flutter/webview_flutter.dart'; // WebView için gerekli paket

class NewsPage extends StatefulWidget {
  final String url;

  const NewsPage({super.key, required this.url});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 1),
      body: WebViewWidget(controller: _controller),
    );
  }
}
