import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'core/constants/app_colors.dart';
import 'services/auth_service.dart';
import 'services/ml_service.dart';
import 'services/notification_service.dart';
import 'screens/splash/flash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/email_verification_pending_screen.dart';
import 'screens/profile/input_data_diri_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/tips/tips_harian_screen.dart';
import 'screens/edukasi/edukasi_screen.dart';
import 'screens/faskes/faskes_screen.dart';
import 'screens/rutinitas/rutinitas_harian_screen.dart';
import 'screens/rutinitas/tambah_kebiasaan_screen.dart';
import 'screens/skrining/scan_lidah_screen.dart';
import 'screens/riwayat/riwayat_scan_screen.dart';
import 'screens/profil/profil_screen.dart';
import 'screens/profil/edit_profil_screen.dart';
import 'screens/pengaturan/pengaturan_screen.dart';

// Tambah import ini untuk battery optimization
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Supabase dulu
  await Supabase.initialize(
    url: 'https://tscuzprqqjxkwfqyainh.supabase.co',
    anonKey: 'sb_publishable_7azgNwsT0VTBgddFUzmpOg_RnhuRMks',
  );

  // 2. Notifikasi — sebelum runApp, setelah Supabase
  await NotificationService().initialize();

  // 3. Request izin battery optimization (khusus Android)
  //    Ini penting untuk Samsung, Xiaomi, OPPO, Vivo, dll
  if (Platform.isAndroid) {
    await _requestBatteryOptimizationExemption();
  }

  // 4. Auth state listener
  Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    debugPrint('Auth event: ${event.event}');

    if (event.event == AuthChangeEvent.passwordRecovery) {
      debugPrint('Password recovery event detected');
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/reset-password',
        (route) => false,
      );
    } else if (event.event == AuthChangeEvent.signedIn) {
      final user = event.session?.user;
      if (user != null) {
        final isEmailVerified = user.emailConfirmedAt != null;
        debugPrint('User signed in - Email verified: $isEmailVerified');

        if (!isEmailVerified) {
          Future.delayed(const Duration(milliseconds: 500), () {
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/email-verification-pending',
              (route) =>
                  route.settings.name == '/' ||
                  route.settings.name == '/login' ||
                  route.settings.name == '/register',
            );
          });
        }
      }
    }
  });

  // 5. Date formatting
  await initializeDateFormatting('id_ID', null);

  // 6. Status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

/// Minta izin agar aplikasi tidak di-kill oleh battery optimizer.
/// Dialog hanya muncul sekali saat pertama install — Android ingat pilihannya.
Future<void> _requestBatteryOptimizationExemption() async {
  try {
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl == null) return;

    await androidImpl.requestNotificationsPermission();

    final bool? canScheduleExact =
        await androidImpl.canScheduleExactNotifications();
    if (canScheduleExact == false) {
      await androidImpl.requestExactAlarmsPermission();
    }
  } catch (e) {
    debugPrint('Battery/alarm permission request error: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _deepLinkSubscription;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        final link = uri.toString();
        debugPrint('Deep link received: $link');
        _handleDeepLink(link);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    debugPrint('Deep link URI: $uri');
    debugPrint('Deep link path: ${uri.path}');
    debugPrint('Deep link query: ${uri.queryParameters}');

    if (uri.scheme == 'glicera' && uri.host == 'auth-callback') {
      debugPrint('Verification callback detected');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content:
                Text('Email berhasil diverifikasi! Silakan login kembali.'),
            backgroundColor: AppColors.teal,
            duration: Duration(seconds: 3),
          ),
        );

        Supabase.instance.client.auth.signOut().then((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        });
      });
    } else if (uri.scheme == 'glicera' && uri.host == 'reset-password') {
      debugPrint('Reset password callback detected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<MLService>(create: (_) => MLService()),
      ],
      child: MaterialApp(
        title: 'Glicera',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          useMaterial3: true,
        ),
        navigatorObservers: [routeObserver],
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => const FlashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/email-verification-pending': (context) =>
              const EmailVerificationPendingScreen(),
          '/input-data-diri': (context) => const InputDataDiriScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/tips': (context) => const TipsHarianScreen(),
          '/edukasi': (context) => const EdukasiScreen(),
          '/faskes': (context) => const FaskesScreen(),
          '/rutinitas': (context) => const RutinitasHarianScreen(),
          '/tambah-kebiasaan': (context) => const TambahKebiasaanScreen(),
          '/scan': (context) => const ScanLidahScreen(),
          '/riwayat': (context) => const RiwayatScanScreen(),
          '/profil': (context) => const ProfilScreen(),
          '/edit-profil': (context) => const EditProfilScreen(),
          '/pengaturan': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as int?;
            return PengaturanScreen(initialIndex: args ?? 3);
          },
        },
      ),
    );
  }
}