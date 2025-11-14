import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polycards_app/config/theme.dart';
import 'package:polycards_app/providers/settings_provider.dart';
import 'package:polycards_app/screens/multi_language_word_cards_screen.dart';
import 'package:polycards_app/screens/settings_screen.dart';
import 'package:polycards_app/services/notification_service.dart';

void main() {
  runApp(const PolyCardsApp());
}

class PolyCardsApp extends StatefulWidget {
  const PolyCardsApp({super.key});

  @override
  State<PolyCardsApp> createState() => _PolyCardsAppState();
}

class _PolyCardsAppState extends State<PolyCardsApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final NotificationService _notificationService = NotificationService();
  int? _initialNotificationWordIndex;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Check if app was launched from notification
    final wordIndex = await _notificationService.getInitialNotificationWordIndex();
    
    // Set up notification tap callback for when app is already running
    NotificationService.onNotificationTap = (int wordIndex) {
      debugPrint('Notification tapped with word index: $wordIndex');
      
      // Navigate to word cards screen with the specific word index
      navigatorKey.currentState?.pushNamed(
        '/cards',
        arguments: wordIndex,
      );
    };
    
    setState(() {
      _initialNotificationWordIndex = wordIndex;
      _isInitialized = true;
    });
    
    if (wordIndex != null) {
      debugPrint('App launched from notification with word index: $wordIndex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'PolyCards',
            debugShowCheckedModeBanner: false,
            
            // Use custom Material Design 3 theme with dynamic theme mode
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.settings.themeMode.toThemeMode(),
            
            // Start directly with word cards screen
            home: _isInitialized
                ? MultiLanguageWordCardsScreen(
                    initialWordIndex: _initialNotificationWordIndex,
                  )
                : const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/settings':
                  return MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  );
                case '/cards':
                  final wordIndex = settings.arguments as int?;
                  return MaterialPageRoute(
                    builder: (context) => MultiLanguageWordCardsScreen(
                      initialWordIndex: wordIndex,
                    ),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
