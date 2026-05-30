import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LMSWebView(),
    );
  }
}

class LMSWebView extends StatefulWidget {
  const LMSWebView({super.key});

  @override
  State<LMSWebView> createState() => _LMSWebViewState();
}

class _LMSWebViewState extends State<LMSWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('WebView navigation request: $url');
            // Intercept external schemes and WhatsApp links
            if (url.startsWith('whatsapp:') ||
                url.contains('wa.me') ||
                url.contains('api.whatsapp.com') ||
                url.startsWith('tel:') ||
                url.startsWith('mailto:') ||
                url.startsWith('sms:') ||
                url.startsWith('intent:')) {
              debugPrint('Intercepting external URL: $url');
              _launchExternalUrl(url);
              debugPrint('Navigation prevented for: $url');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://www.globaliterp.com/student/login'),
      );
  }

  Future<void> _launchExternalUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      debugPrint('Attempting to launch external URL: $uri');

      final can = await canLaunchUrl(uri);
      debugPrint('canLaunchUrl($uri) => $can');
      if (can) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('launchUrl($uri) => $launched');
        return;
      }

      if (uri.scheme == 'whatsapp') {
        final phone = uri.queryParameters['phone'] ?? '';
        final text = uri.queryParameters['text'] ?? '';
        final whatsappUrl = Uri(
          scheme: 'https',
          host: 'wa.me',
          path: phone,
          queryParameters: text.isNotEmpty ? {'text': text} : null,
        );
        debugPrint('Trying WhatsApp wa.me fallback: $whatsappUrl');
        if (await canLaunchUrl(whatsappUrl)) {
          final launched = await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          debugPrint('launchUrl($whatsappUrl) => $launched');
          return;
        }

        final apiUrl = Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$text');
        debugPrint('Trying WhatsApp api fallback: $apiUrl');
        if (await canLaunchUrl(apiUrl)) {
          final launched = await launchUrl(apiUrl, mode: LaunchMode.externalApplication);
          debugPrint('launchUrl($apiUrl) => $launched');
          return;
        }
      }

      final httpUri = uri.scheme.isEmpty ? Uri.parse('https://$urlString') : uri;
      debugPrint('Trying final httpUri: $httpUri');
      if (await canLaunchUrl(httpUri)) {
        final launched = await launchUrl(httpUri, mode: LaunchMode.externalApplication);
        debugPrint('launchUrl($httpUri) => $launched');
        return;
      }
    } catch (e, st) {
      debugPrint('Error launching external url: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
      // Temporary test button to verify url_launcher behavior
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          const testNumber = '919166348818'; // replace with a reachable test number if needed
          final testUrl = 'whatsapp://send?phone=$testNumber&text=Hello%20from%20test';
          debugPrint('FAB test launching: $testUrl');
          await _launchExternalUrl(testUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tried launching WhatsApp URL (check logs).')),
          );
        },
        label: const Text('Test WhatsApp'),
        icon: const Icon(Icons.open_in_new),
      ),
    );
  }
}