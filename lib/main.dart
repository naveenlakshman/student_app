import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global IT ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF203A43)),
      ),
      home: const RootHandler(),
    );
  }
}

class RootHandler extends StatefulWidget {
  const RootHandler({super.key});

  @override
  State<RootHandler> createState() => _RootHandlerState();
}

class _RootHandlerState extends State<RootHandler> {
  String? _savedRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    setState(() {
      _savedRole = role;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_savedRole != null) {
      final url = _savedRole == 'student'
          ? 'https://www.globaliterp.com/student/login?app=1'
          : 'https://www.globaliterp.com/login';
      return LMSWebView(initialUrl: url);
    }

    return const WelcomeScreen();
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);

    final url = role == 'student'
        ? 'https://www.globaliterp.com/student/login?app=1'
        : 'https://www.globaliterp.com/login';

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LMSWebView(initialUrl: url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo with glassmorphism/elevated card style
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback in case of asset issues
                        return const Icon(
                          Icons.school,
                          size: 100,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'GLOBAL IT ERP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome! Please choose your portal to login.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Student Button
                _buildRoleButton(
                  context: context,
                  title: 'Student Portal',
                  subtitle: 'Access assignments, attendance, fees & more',
                  icon: Icons.school_rounded,
                  colors: [const Color(0xFF00c6ff), const Color(0xFF0072ff)],
                  onTap: () => _selectRole(context, 'student'),
                ),
                const SizedBox(height: 20),
                // Staff Button
                _buildRoleButton(
                  context: context,
                  title: 'Staff Portal',
                  subtitle: 'Manage classes, billing & student records',
                  icon: Icons.admin_panel_settings_rounded,
                  colors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                  onTap: () => _selectRole(context, 'staff'),
                ),
                const Spacer(),
                Text(
                  'Global IT Education',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LMSWebView extends StatefulWidget {
  final String initialUrl;
  const LMSWebView({super.key, required this.initialUrl});

  @override
  State<LMSWebView> createState() => _LMSWebViewState();
}

class _LMSWebViewState extends State<LMSWebView> {
  late final WebViewController controller;
  String _currentUrl = '';
  bool _canGoBack = false;

  Future<void> _updateCanGoBack() async {
    final canGo = await controller.canGoBack();
    if (mounted) {
      setState(() {
        _canGoBack = canGo;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 attnandbillingapp')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _currentUrl = url;
            });
            _updateCanGoBack();
          },
          onPageFinished: (String url) {
            setState(() {
              _currentUrl = url;
            });
            _updateCanGoBack();
          },
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
        Uri.parse(widget.initialUrl),
      );
  }

  Future<void> _resetRoleAndGoToWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    }
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
    final url = _currentUrl.toLowerCase();
    final showSwitchButton = url.contains('/login') || url.endsWith('/student');

    return PopScope<Object?>(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        if (_canGoBack) {
          await controller.goBack();
          _updateCanGoBack();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: controller),
        ),
        floatingActionButton: showSwitchButton
            ? FloatingActionButton.extended(
                onPressed: _resetRoleAndGoToWelcome,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Switch Portal'),
                backgroundColor: const Color(0xFF203A43),
                foregroundColor: Colors.white,
              )
            : null,
      ),
    );
  }
}