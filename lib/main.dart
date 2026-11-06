import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.initPrefs();
  runApp(const AccountBookApp());
}

// ----------------- Global App Settings & Multi-Language Engine -----------------
class AppSettingsNotifier extends ChangeNotifier {
  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.dark;
  String _language = 'English'; 
  String currency = '৳';
  String appPin = '1234';

  // Profile Fields
  String profileName = 'MD ALAMGIR HOSSAIN';
  String profileEmail = 'alamgir@email.com';
  String profileGender = 'Male';
  String profileBirthDate = '01-01-1995';
  String profileMobile = '018xxxxxxxx';
  String profileImagePath = '';

  // Security Toggles
  bool useFaceLock = false;
  bool useFingerprint = false;
  bool useNoneLock = false;
  bool usePatternLock = false;
  bool usePinLock = true;

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    appPin = _prefs.getString('appPin') ?? '1234';
    _language = _prefs.getString('language') ?? 'English';
    String themeStr = _prefs.getString('themeMode') ?? 'dark';
    if (themeStr == 'light') _themeMode = ThemeMode.light;
    else if (themeStr == 'system') _themeMode = ThemeMode.system;
    else _themeMode = ThemeMode.dark;

    profileName = _prefs.getString('profileName') ?? 'MD ALAMGIR HOSSAIN';
    profileEmail = _prefs.getString('profileEmail') ?? 'alamgir@email.com';
    profileGender = _prefs.getString('profileGender') ?? 'Male';
    profileBirthDate = _prefs.getString('profileBirthDate') ?? '01-01-1995';
    profileMobile = _prefs.getString('profileMobile') ?? '018xxxxxxxx';
    profileImagePath = _prefs.getString('profileImagePath') ?? '';
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setString('appPin', appPin);
    await _prefs.setString('language', _language);
    await _prefs.setString('themeMode', _themeMode == ThemeMode.light ? 'light' : (_themeMode == ThemeMode.system ? 'system' : 'dark'));
  }

  ThemeMode get themeMode => _themeMode;
  String get language => _language;

  String getAppTitle() {
    if (_language == 'Bangla') return 'হিসাবের খাতা';
    if (_language == 'Arabic') return 'دفتر الحسابات';
    return 'Account Book';
  }

  // Pure Multi-Language Translator Engine
  String translate(String key) {
    if (_language == 'Bangla') {
      switch (key) {
        case 'Account Book': return 'হিসাবের খাতা';
        case 'Enter Your PIN': return 'আপনার পিন প্রদান করুন';
        case 'Unlock': return 'আনলক করুন';
        case 'Forgot PIN?': return 'পিন ভুলে গেছেন?';
        case 'Wrong PIN!': return 'ভুল পিন কোড!';
        case 'Language': return 'ভাষা নির্বাচন';
        case 'Current Balance': return 'বর্তমান ব্যালেন্স';
        case 'Income': return 'আয়';
        case 'Expense': return 'ব্যয়';
        default: return key;
      }
    } else if (_language == 'Arabic') {
      switch (key) {
        case 'Account Book': return 'دفتر الحسابات';
        case 'Enter Your PIN': return 'أدخل رمز PIN الخاص بك';
        case 'Unlock': return 'فتح';
        case 'Forgot PIN?': return 'هل نسيت رمز PIN؟';
        case 'Wrong PIN!': return 'رمز PIN غير صحيح!';
        case 'Language': return 'اختر اللغة';
        case 'Current Balance': return 'الرصيد الحالي';
        case 'Income': return 'إيرادات';
        case 'Expense': return 'مصروفات';
        default: return key;
      }
    }
    return key;
  }

  void setLanguage(String lang) {
    _language = lang;
    _saveToPrefs();
    notifyListeners();
  }
}

final appSettings = AppSettingsNotifier();

// ----------------- App Entry Point -----------------
class AccountBookApp extends StatelessWidget {
  const AccountBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, child) {
        return MaterialApp(
          title: appSettings.getAppTitle(),
          debugShowCheckedModeBanner: false,
          themeMode: appSettings.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
            primaryColor: const Color(0xFF38BDF8),
            cardColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF10B981),
            cardColor: const Color(0xFF1E293B),
          ),
          home: const PinLockScreen(),
        );
      },
    );
  }
}

// ----------------- Brand Header & Lock Screen -----------------
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';

  void _verifyPin() {
    if (_pinController.text == appSettings.appPin || appSettings.useNoneLock) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainHomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = appSettings.translate('Wrong PIN!');
        _pinController.clear();
      });
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appSettings.translate('Language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Arabic (العربية)'),
              onTap: () { appSettings.setLanguage('Arabic'); Navigator.pop(ctx); },
            ),
            ListTile(
              title: const Text('Bangla (বাংলা)'),
              onTap: () { appSettings.setLanguage('Bangla'); Navigator.pop(ctx); },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () { appSettings.setLanguage('English'); Navigator.pop(ctx); },
            ),
            ListTile(
              title: const Text('System Default'),
              onTap: () { appSettings.setLanguage('English'); Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.language, color: Colors.white),
              onPressed: _showLanguageDialog,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF10B981),
                  child: Icon(Icons.menu_book_rounded, size: 45, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  appSettings.getAppTitle(),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 30),
                Text(
                  appSettings.translate('Enter Your PIN'),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _pinController.text.length > index ? '•' : '',
                          style: const TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  width: 220,
                  height: 40,
                  child: TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    autofocus: true,
                    style: const TextStyle(color: Colors.transparent),
                    cursorColor: Colors.transparent,
                    decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                    onChanged: (val) {
                      setState(() { _errorMessage = ''; });
                      if (val.length == 4) _verifyPin();
                    },
                  ),
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: _verifyPin,
                    child: Text(appSettings.translate('Unlock'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- Temporary Main Home Screen Placeholder -----------------
class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.getAppTitle())),
      body: const Center(
        child: Text('Main Home Screen Loaded Successfully!', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
