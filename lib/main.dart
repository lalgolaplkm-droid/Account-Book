import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.initPrefs();
  runApp(const AccountBookApp());
}

// ----------------- Models -----------------
class TransactionItem {
  final String id;
  final String type;
  String account;
  String category;
  double amount;
  String description;
  DateTime date;

  TransactionItem({
    required this.id,
    required this.type,
    required this.account,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'account': account,
    'category': category,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
    id: json['id'],
    type: json['type'],
    account: json['account'],
    category: json['category'],
    amount: json['amount'],
    description: json['description'],
    date: DateTime.parse(json['date']),
  );
}

class LoanItem {
  final String id;
  String personName;
  double amount;
  String type;
  DateTime date;
  bool isPaid;

  LoanItem({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'personName': personName,
    'amount': amount,
    'type': type,
    'date': date.toIso8601String(),
    'isPaid': isPaid,
  };

  factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
    id: json['id'],
    personName: json['personName'],
    amount: json['amount'],
    type: json['type'],
    date: DateTime.parse(json['date']),
    isPaid: json['isPaid'],
  );
}

class ShoppingItem {
  String name;
  double amount;
  bool isChecked;
  ShoppingItem({required this.name, this.amount = 0.0, this.isChecked = false});

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount, 'isChecked': isChecked};
  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(name: json['name'], amount: json['amount'], isChecked: json['isChecked']);
}

class BudgetModel {
  String category;
  double amount;
  BudgetModel({required this.category, required this.amount});

  Map<String, dynamic> toJson() => {'category': category, 'amount': amount};
  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(category: json['category'], amount: json['amount']);
}

class SavingsModel {
  String title;
  double targetAmount;
  double currentAmount;
  bool isCompleted;
  SavingsModel({required this.title, required this.targetAmount, required this.currentAmount, this.isCompleted = false});

  Map<String, dynamic> toJson() => {'title': title, 'targetAmount': targetAmount, 'currentAmount': currentAmount, 'isCompleted': isCompleted};
  factory SavingsModel.fromJson(Map<String, dynamic> json) => SavingsModel(title: json['title'], targetAmount: json['targetAmount'], currentAmount: json['currentAmount'], isCompleted: json['isCompleted']);
}

class AccountModel {
  String name;
  String type;
  String details;
  bool isDefault;

  AccountModel({
    required this.name,
    required this.type,
    required this.details,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {'name': name, 'type': type, 'details': details, 'isDefault': isDefault};
  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(name: json['name'], type: json['type'], details: json['details'], isDefault: json['isDefault']);
}

class RepeatedTransactionModel {
  String title;
  double amount;
  String frequency;
  RepeatedTransactionModel({required this.title, required this.amount, required this.frequency});

  Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'frequency': frequency};
  factory RepeatedTransactionModel.fromJson(Map<String, dynamic> json) => RepeatedTransactionModel(title: json['title'], amount: json['amount'], frequency: json['frequency']);
}

class ReminderModel {
  String title;
  double amount;
  String dueDate;
  ReminderModel({required this.title, required this.amount, required this.dueDate});

  Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'dueDate': dueDate};
  factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(title: json['title'], amount: json['amount'], dueDate: json['dueDate']);
}

// ----------------- State Management with Persistent Storage -----------------
class AppSettingsNotifier extends ChangeNotifier {
  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.dark;
  String _language = 'English'; 
  String currency = '৳';
  String timeFilter = 'Month';
  String appPin = '1234';

  String profileName = 'MD ALAMGIR HOSSAIN';
  String profileEmail = 'alamgir@email.com';
  String profileGender = 'Male';
  String profileBirthDate = '01-01-1995';
  String profileMobile = '018xxxxxxxx';
  String profileImagePath = '';

  bool useFaceLock = false;
  bool useFingerprint = false;
  bool useNoneLock = false;
  bool usePatternLock = false;
  bool usePinLock = true;

  bool dailyReminder = true;
  bool budgetAlert = true;
  bool loanAlert = true;
  String notificationSound = 'Default';

  int selectedMonthIndex = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  List<String> categories = ['Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport'];
  
  List<AccountModel> accounts = [
    AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', isDefault: false),
    AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', isDefault: true),
    AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', isDefault: false),
    AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', isDefault: false),
    AccountModel(name: 'UCB Bank', type: 'Bank', details: 'A/C: ...4589', isDefault: false),
  ];

  double monthlyBudget = 15000.0;

  List<TransactionItem> transactions = [
    TransactionItem(
      id: '1',
      type: 'Income',
      account: 'Cash in Hand',
      category: 'Salary',
      amount: 45000.0,
      description: 'Monthly Salary',
      date: DateTime.now(),
    ),
  ];

  List<LoanItem> loans = [
    LoanItem(
      id: '101',
      personName: 'Rafiqul Islam',
      amount: 2000.0,
      type: 'Given',
      date: DateTime.now(),
      isPaid: false,
    ),
  ];

  List<ShoppingItem> shoppingList = [
    ShoppingItem(name: 'Cooking Oil', amount: 150.0, isChecked: true),
  ];

  List<BudgetModel> budgets = [
    BudgetModel(category: 'Food & Hotel', amount: 5000.0),
  ];

  List<SavingsModel> savingsList = [
    SavingsModel(title: 'Arufa Savings', targetAmount: 500000, currentAmount: 25000)
  ];

  List<RepeatedTransactionModel> repeatedTransactions = [
    RepeatedTransactionModel(title: 'House Rent', amount: 8000, frequency: '1st of every month'),
  ];

  List<ReminderModel> reminders = [
    ReminderModel(title: 'Electricity Bill', amount: 1200, dueDate: '15th of every month'),
  ];

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
    await _prefs.setString('profileName', profileName);
    await _prefs.setString('profileEmail', profileEmail);
    await _prefs.setString('profileGender', profileGender);
    await _prefs.setString('profileBirthDate', profileBirthDate);
    await _prefs.setString('profileMobile', profileMobile);
    await _prefs.setString('profileImagePath', profileImagePath);
  }

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  
  String getAppTitle() {
    if (_language == 'Bangla') return 'হিসাব বই';
    if (_language == 'Arabic') return 'دفتر الحسابات';
    return 'Account Book';
  }

  String translate(String key) {
    if (_language == 'Bangla') {
      switch (key) {
        case 'Account Book': return 'হিসাব বই';
        case 'Dashboard Analytics': return 'ড্যাশবোর্ড অ্যানালিটিক্স';
        case 'Categories': return 'ক্যাটাগরি সমূহ';
        case 'Accounts': return 'অ্যাকাউন্ট সমূহ';
        case 'Theme': return 'থিম';
        case 'Language': return 'ভাষা';
        case 'About App': return 'অ্যাপ সম্পর্কে';
        case 'Current Balance': return 'বর্তমান ব্যালেন্স';
        case 'Income': return 'আয়';
        case 'Expense': return 'ব্যয়';
        case 'Account': return 'হিসাব';
        case 'Loan': return 'লোন';
        case 'Transactions': return 'লেনদেন';
        case 'Report': return 'রিপোর্ট';
        case 'Profile': return 'প্রোফাইল';
        default: return key;
      }
    } else if (_language == 'Arabic') {
      switch (key) {
        case 'Account Book': return 'دفتر الحسابات';
        case 'Dashboard Analytics': return 'تحليلات لوحة القيادة';
        case 'Categories': return 'الفئات';
        case 'Accounts': return 'الحسابات';
        case 'Theme': return 'المظهر';
        case 'Language': return 'اللغة';
        case 'Income': return 'إيرادات';
        case 'Expense': return 'مصروفات';
        default: return key;
      }
    }
    return key;
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    _saveToPrefs();
    notifyListeners();
  }

  void updatePin(String newPin) {
    appPin = newPin;
    _saveToPrefs();
    notifyListeners();
  }

  void updateProfile({required String name, required String email, required String gender, required String birthDate, required String mobile, String? imagePath}) {
    profileName = name;
    profileEmail = email;
    profileGender = gender;
    profileBirthDate = birthDate;
    profileMobile = mobile;
    if (imagePath != null) profileImagePath = imagePath;
    _saveToPrefs();
    notifyListeners();
  }

  void updateSecurityToggles({required bool face, required bool fingerprint, required bool none, required bool pattern, required bool pin}) {
    useFaceLock = face;
    useFingerprint = fingerprint;
    useNoneLock = none;
    usePatternLock = pattern;
    usePinLock = pin;
    notifyListeners();
  }

  double getTotalIncome() {
    double total = 0;
    for (var txn in transactions) {
      if (txn.type == 'Income') total += txn.amount;
    }
    return total;
  }

  double getTotalExpense() {
    double total = 0;
    for (var txn in transactions) {
      if (txn.type == 'Expense') total += txn.amount;
    }
    return total;
  }

  double getTotalBalance() => getTotalIncome() - getTotalExpense();
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
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF10B981),
            cardColor: const Color(0xFF1E293B),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white),
          ),
          home: const PinLockScreen(),
        );
      },
    );
  }
}

// ----------------- Pin & Lock Screen with Language Selector -----------------
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _verifyPin(BuildContext context) {
    if (_pinController.text == appSettings.appPin || appSettings.useNoneLock) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong PIN!')),
      );
    }
  }

  void _showLockScreenLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text(appSettings.translate('Language')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('English (Default)'),
                    value: 'English',
                    groupValue: appSettings.language,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setLanguage(val);
                        setStateDialog(() {});
                        setState(() {});
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Bangla (বাংলা)'),
                    value: 'Bangla',
                    groupValue: appSettings.language,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setLanguage(val);
                        setStateDialog(() {});
                        setState(() {});
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                tooltip: 'Language',
                onPressed: () => _showLockScreenLanguageDialog(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, size: 70, color: Color(0xFF10B981)),
                  const SizedBox(height: 16),
                  Text(
                    appSettings.getAppTitle(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('Enter Your PIN', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: Center(
                              child: Text(_pinController.text.length > index ? '•' : '', style: const TextStyle(color: Colors.white, fontSize: 28)),
                            ),
                          );
                        }),
                      ),
                      SizedBox(
                        width: 250,
                        height: 60,
                        child: TextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          style: const TextStyle(color: Colors.transparent),
                          cursorColor: Colors.transparent,
                          decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                          onChanged: (value) {
                            setState(() {});
                            if (value.length == 4) _verifyPin(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                      onPressed: () => _verifyPin(context),
                      child: const Text('Unlock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------- Profile Screen with Camera, Gallery & Avatar Selector -----------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showProfileImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF10B981)),
            title: const Text('Take Photo with Camera'),
            onTap: () async {
              Navigator.pop(ctx);
              final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                appSettings.updateProfile(
                  name: appSettings.profileName,
                  email: appSettings.profileEmail,
                  gender: appSettings.profileGender,
                  birthDate: appSettings.profileBirthDate,
                  mobile: appSettings.profileMobile,
                  imagePath: image.path,
                );
                setState(() {});
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Color(0xFF10B981)),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(ctx);
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                appSettings.updateProfile(
                  name: appSettings.profileName,
                  email: appSettings.profileEmail,
                  gender: appSettings.profileGender,
                  birthDate: appSettings.profileBirthDate,
                  mobile: appSettings.profileMobile,
                  imagePath: image.path,
                );
                setState(() {});
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.face, color: Color(0xFF10B981)),
            title: const Text('Choose from Avatar List'),
            onTap: () {
              Navigator.pop(ctx);
              _showAvatarListDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showAvatarListDialog() {
    List<String> avatars = [
      'https://cdn-icons-png.flaticon.com/512/147/147144.png',
      'https://cdn-icons-png.flaticon.com/512/147/147142.png',
      'https://cdn-icons-png.flaticon.com/512/147/147140.png',
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Avatar'),
        content: SizedBox(
          width: 200,
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: avatars.map((url) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  appSettings.updateProfile(
                    name: appSettings.profileName,
                    email: appSettings.profileEmail,
                    gender: appSettings.profileGender,
                    birthDate: appSettings.profileBirthDate,
                    mobile: appSettings.profileMobile,
                    imagePath: url,
                  );
                  Navigator.pop(ctx);
                  setState(() {});
                },
                child: CircleAvatar(backgroundImage: NetworkImage(url), radius: 30),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Profile & Settings')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        backgroundImage: appSettings.profileImagePath.isNotEmpty 
                            ? (appSettings.profileImagePath.startsWith('http') ? NetworkImage(appSettings.profileImagePath) as ImageProvider : FileImage(File(appSettings.profileImagePath))) 
                            : null,
                        child: appSettings.profileImagePath.isEmpty ? const Icon(Icons.person, size: 45, color: Color(0xFF10B981)) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _showProfileImagePicker,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(appSettings.profileName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: Color(0xFF10B981)),
                title: const Text('Privacy & Security'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySecurityScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Privacy & Security Screen (Functional Locks) -----------------
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  late TextEditingController _pinController;
  bool _faceLock = false;
  bool _fingerprint = false;
  bool _noneLock = false;
  bool _patternLock = false;
  bool _pinLock = true;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController(text: appSettings.appPin);
    _faceLock = appSettings.useFaceLock;
    _fingerprint = appSettings.useFingerprint;
    _noneLock = appSettings.useNoneLock;
    _patternLock = appSettings.usePatternLock;
    _pinLock = appSettings.usePinLock;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Privacy & Security')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Face Unlock'),
                    value: _faceLock,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() { _faceLock = val; if (val) _noneLock = false; }),
                  ),
                  SwitchListTile(
                    title: const Text('Fingerprint Sensor'),
                    value: _fingerprint,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() { _fingerprint = val; if (val) _noneLock = false; }),
                  ),
                  SwitchListTile(
                    title: const Text('None (No Lock)'),
                    value: _noneLock,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() {
                      _noneLock = val;
                      if (val) { _faceLock = false; _fingerprint = false; _patternLock = false; _pinLock = false; }
                    }),
                  ),
                  SwitchListTile(
                    title: const Text('Pattern Lock'),
                    value: _patternLock,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() { _patternLock = val; if (val) _noneLock = false; }),
                  ),
                  SwitchListTile(
                    title: const Text('PIN Code Lock'),
                    value: _pinLock,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() { _pinLock = val; if (val) _noneLock = false; }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_pinLock) ...[
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(labelText: '4-Digit PIN', border: OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_pinController.text.length == 4 || _noneLock || !_pinLock) {
                  if (_pinLock) appSettings.updatePin(_pinController.text);
                  appSettings.updateSecurityToggles(
                    face: _faceLock,
                    fingerprint: _fingerprint,
                    none: _noneLock,
                    pattern: _patternLock,
                    pin: _pinLock,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security updated successfully!')));
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Main Navigation Container -----------------
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Scaffold(appBar: AppBar(title: Text(appSettings.getAppTitle())), body: Center(child: Text('Balance: ${appSettings.getTotalBalance()} ${appSettings.currency}'))),
      const Scaffold(body: Center(child: Text('Loan Module'))),
      const Scaffold(body: Center(child: Text('Transactions Module'))),
      const Scaffold(body: Center(child: Text('Reports Module'))),
      const ProfileScreen(),
    ];

    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).cardColor,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home), label: appSettings.translate('Account')),
            BottomNavigationBarItem(icon: const Icon(Icons.money), label: appSettings.translate('Loan')),
            BottomNavigationBarItem(icon: const Icon(Icons.list_alt), label: appSettings.translate('Transactions')),
            BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: appSettings.translate('Report')),
            BottomNavigationBarItem(icon: const Icon(Icons.person), label: appSettings.translate('Profile')),
          ],
        ),
      ),
    );
  }
}
