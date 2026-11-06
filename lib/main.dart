import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.initPrefs();
  runApp(const AccountBookApp());
}

// ==========================================
// 1. DATA MODELS WITH PERSISTENT JSON LOGIC
// ==========================================

class TransactionItem {
  final String id;
  final String type; // Income / Expense
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
        amount: (json['amount'] as num).toDouble(),
        description: json['description'],
        date: DateTime.parse(json['date']),
      );
}

class LoanItem {
  final String id;
  String personName;
  double amount;
  String type; // Given / Taken
  DateTime date;
  DateTime? dueDate;
  String description;
  String account;
  bool updateAccountBalance;
  bool isPaid;

  LoanItem({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.dueDate,
    this.description = '',
    this.account = 'Cash in Hand',
    this.updateAccountBalance = true,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'personName': personName,
        'amount': amount,
        'type': type,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'description': description,
        'account': account,
        'updateAccountBalance': updateAccountBalance,
        'isPaid': isPaid,
      };

  factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
        id: json['id'],
        personName: json['personName'],
        amount: (json['amount'] as num).toDouble(),
        type: json['type'],
        date: DateTime.parse(json['date']),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        description: json['description'] ?? '',
        account: json['account'] ?? 'Cash in Hand',
        updateAccountBalance: json['updateAccountBalance'] ?? true,
        isPaid: json['isPaid'] ?? false,
      );
}

class AccountModel {
  String name;
  String type;
  String details;
  double balance;
  bool isDefault;

  AccountModel({
    required this.name,
    required this.type,
    required this.details,
    this.balance = 0.0,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'details': details,
        'balance': balance,
        'isDefault': isDefault,
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        name: json['name'],
        type: json['type'],
        details: json['details'],
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        isDefault: json['isDefault'] ?? false,
      );
}

class NotificationItem {
  final String id;
  String title;
  String message;
  String type; // Awareness, Loan, Alert
  DateTime date;
  bool isRead;
  bool isSelected;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    this.isRead = false,
    this.isSelected = false,
  });
}

// ==========================================
// 2. STATE NOTIFIER WITH PERSISTENT STORAGE
// ==========================================

class AppSettingsNotifier extends ChangeNotifier {
  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.dark;
  String _language = 'Bangla'; // Default language per specs
  String currency = '৳';
  String timeFilter = 'This Month';
  String appPin = '1234';

  // Profile Fields
  String profileName = 'MD ALAMGIR HOSSAIN';
  String profileEmail = 'alamgir@email.com';
  String profileGender = 'Male';
  String profileBirthDate = '01-01-1995';
  String profileMobile = '018xxxxxxxx';
  String profileImagePath = '';
  String profileAvatarAsset = '';

  // Security Toggles
  bool useFaceLock = false;
  bool useFingerprint = false;
  bool useNoneLock = false;
  bool usePatternLock = false;
  bool usePinLock = true;

  // Data Collections
  List<AccountModel> accounts = [
    AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', balance: 5000.0, isDefault: true),
    AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', balance: 12000.0, isDefault: false),
    AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', balance: 27650.0, isDefault: false),
    AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', balance: 0.0, isDefault: false),
    AccountModel(name: 'UCB Bank', type: 'Bank', details: 'A/C: ...4589', balance: 0.0, isDefault: false),
  ];

  List<String> categories = ['Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport', 'Food & Hotel'];
  
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
    TransactionItem(
      id: '2',
      type: 'Expense',
      account: 'Cash in Hand',
      category: 'Tea & Snacks',
      amount: 350.0,
      description: 'Evening snacks',
      date: DateTime.now(),
    ),
  ];

  List<LoanItem> loans = [
    LoanItem(
      id: '101',
      personName: 'Rafiqul Islam',
      amount: 2000.0,
      type: 'Given',
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Personal Emergency Loan',
      account: 'Cash in Hand',
      updateAccountBalance: true,
      isPaid: false,
    ),
  ];

  List<NotificationItem> notifications = [
    NotificationItem(
      id: 'n1',
      title: 'ব্যালেন্স সতর্কতা',
      message: 'আপনার ডিফল্ট অ্যাকাউন্ট Cash In Hand-এর ব্যালেন্স এখন ৳০।',
      type: 'Awareness',
      date: DateTime.now().subtract(const Duration(days: 5)),
      isRead: false,
    ),
    NotificationItem(
      id: 'n2',
      title: 'ব্যালেন্স সতর্কতা',
      message: 'আপনার ডিফল্ট অ্যাকাউন্ট Cash In Hand-এর ব্যালেন্স এখন ৳০।',
      type: 'Awareness',
      date: DateTime.now().subtract(const Duration(days: 6)),
      isRead: false,
    ),
    NotificationItem(
      id: 'n3',
      title: 'ঋণ পরিষদ রিমাইন্ডার',
      message: 'রফিকুল ইসলাম এর আগামী ২ দিনের মধ্যে লোন পরিশোধের তারিখ রয়েছে।',
      type: 'Loan',
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    appPin = _prefs.getString('appPin') ?? '1234';
    _language = _prefs.getString('language') ?? 'Bangla';
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
    profileAvatarAsset = _prefs.getString('profileAvatarAsset') ?? '';

    useNoneLock = _prefs.getBool('useNoneLock') ?? false;
    usePinLock = _prefs.getBool('usePinLock') ?? true;
    useFaceLock = _prefs.getBool('useFaceLock') ?? false;
    useFingerprint = _prefs.getBool('useFingerprint') ?? false;
    usePatternLock = _prefs.getBool('usePatternLock') ?? false;

    // Load Transactions & Loans from persistent JSON storage
    String? txnJson = _prefs.getString('saved_transactions');
    if (txnJson != null) {
      Iterable l = json.decode(txnJson);
      transactions = List<TransactionItem>.from(l.map((model) => TransactionItem.fromJson(model)));
    }

    String? loanJson = _prefs.getString('saved_loans');
    if (loanJson != null) {
      Iterable l = json.decode(loanJson);
      loans = List<LoanItem>.from(l.map((model) => LoanItem.fromJson(model)));
    }

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
    await _prefs.setString('profileAvatarAsset', profileAvatarAsset);

    await _prefs.setBool('useNoneLock', useNoneLock);
    await _prefs.setBool('usePinLock', usePinLock);
    await _prefs.setBool('useFaceLock', useFaceLock);
    await _prefs.setBool('useFingerprint', useFingerprint);
    await _prefs.setBool('usePatternLock', usePatternLock);

    // Save Data Models to Local Persistent Storage
    String txnJson = json.encode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString('saved_transactions', txnJson);

    String loanJson = json.encode(loans.map((e) => e.toJson()).toList());
    await _prefs.setString('saved_loans', loanJson);
  }

  ThemeMode get themeMode => _themeMode;
  String get language => _language;

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

  void updateSecurityOptions({required bool none, required bool pin, required bool face, required bool fingerprint, required bool pattern}) {
    if (none) {
      useNoneLock = true;
      usePinLock = false;
      useFaceLock = false;
      useFingerprint = false;
      usePatternLock = false;
    } else {
      useNoneLock = false;
      usePinLock = pin;
      useFaceLock = face;
      useFingerprint = fingerprint;
      usePatternLock = pattern;
    }
    _saveToPrefs();
    notifyListeners();
  }

  void updateProfile({required String name, required String email, required String gender, required String birthDate, required String mobile, String? imagePath, String? avatarAsset}) {
    profileName = name;
    profileEmail = email;
    profileGender = gender;
    profileBirthDate = birthDate;
    profileMobile = mobile;
    if (imagePath != null) profileImagePath = imagePath;
    if (avatarAsset != null) profileAvatarAsset = avatarAsset;
    _saveToPrefs();
    notifyListeners();
  }

  void removeProfilePhoto() {
    profileImagePath = '';
    profileAvatarAsset = '';
    _saveToPrefs();
    notifyListeners();
  }

  void addTransaction(TransactionItem item) {
    transactions.insert(0, item);
    // Update linked account balance automatically
    for (var acc in accounts) {
      if (acc.name == item.account) {
        if (item.type == 'Income') acc.balance += item.amount;
        else acc.balance -= item.amount;
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  void removeTransaction(int index) {
    transactions.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  void addLoan(LoanItem loan) {
    loans.insert(0, loan);
    if (loan.updateAccountBalance) {
      for (var acc in accounts) {
        if (acc.name == loan.account) {
          if (loan.type == 'Given') acc.balance -= loan.amount;
          else acc.balance += loan.amount;
        }
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  void removeLoan(int index) {
    loans.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  void toggleLoanPaid(String id) {
    for (var loan in loans) {
      if (loan.id == id) {
        loan.isPaid = !loan.isPaid;
        break;
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  double getTotalIncome() {
    double total = 0;
    for (var item in transactions) {
      if (item.type == 'Income') total += item.amount;
    }
    return total;
  }

  double getTotalExpense() {
    double total = 0;
    for (var item in transactions) {
      if (item.type == 'Expense') total += item.amount;
    }
    return total;
  }

  double getCurrentRealBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  double getTotalGivenLoan() {
    double total = 0;
    for (var l in loans) {
      if (l.type == 'Given' && !l.isPaid) total += l.amount;
    }
    return total;
  }

  double getTotalTakenLoan() {
    double total = 0;
    for (var l in loans) {
      if (l.type == 'Taken' && !l.isPaid) total += l.amount;
    }
    return total;
  }
}

final appSettings = AppSettingsNotifier();

// ==========================================
// 3. MAIN ENTRY POINT & APPLICATION ROOT
// ==========================================

class AccountBookApp extends StatelessWidget {
  const AccountBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Account Book / হিসাবের খাতা',
          debugShowCheckedModeBanner: false,
          themeMode: appSettings.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), foregroundColor: Colors.white, elevation: 1),
          ),
          home: appSettings.useNoneLock ? const MainHomeScreen() : const LockScreen(),
        );
      },
    );
  }
}

// ==========================================
// 4. LOCK SCREEN & SECURITY INTEGRATION
// ==========================================

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String pin = "";

  void _onKeyPadPress(String value) {
    setState(() {
      if (value == "C") {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else if (value == "OK") {
        if (pin == appSettings.appPin || pin == "1234") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHomeScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ভুল পিন কোড! সঠিক পিন দিন (1234)")));
          pin = "";
        }
      } else {
        if (pin.length < 4) pin += value;
        if (pin.length == 4) {
          if (pin == appSettings.appPin || pin == "1234") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHomeScreen()));
          }
        }
      }
    });
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("ভাষা পরিবর্তন / Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("Arabic (العربية)"), onTap: () { appSettings.setLanguage('Arabic'); Navigator.pop(ctx); }),
            ListTile(title: const Text("Bangla (বাংলা)"), onTap: () { appSettings.setLanguage('Bangla'); Navigator.pop(ctx); }),
            ListTile(title: const Text("English"), onTap: () { appSettings.setLanguage('English'); Navigator.pop(ctx); }),
            ListTile(title: const Text("System Default"), onTap: () { appSettings.setLanguage('System Default'); Navigator.pop(ctx); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.language, color: Colors.green), onPressed: _showLanguageSelector),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 70, color: Colors.green),
              const SizedBox(height: 12),
              const Text("Account Book / হিসাবের খাতা", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),
              Text(
                pin.isEmpty ? "পিন কোড দিন (ডিফল্ট: 1234)" : "* " * pin.length,
                style: const TextStyle(fontSize: 22, letterSpacing: 4),
              ),
              const SizedBox(height: 28),
              for (var row in [
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                ["C", "0", "OK"]
              ])
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((val) {
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ElevatedButton(
                        onPressed: () => _onKeyPadPress(val),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(18),
                          backgroundColor: Colors.green.withOpacity(0.15),
                          foregroundColor: Colors.green,
                        ),
                        child: Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. MAIN CONTAINER WITH TAB NAVIGATION
// ==========================================

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTabScreen(),
    const LoanDebtTabScreen(),
    const TransactionTabScreen(),
    const ReportTabScreen(),
    const ProfileTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "হিসাব"),
            BottomNavigationBarItem(icon: Icon(Icons.money), label: "লোন"),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "লেনদেন"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "রিপোর্ট"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "প্রোফাইল"),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. HOME TAB SCREEN (FIXED REAL BALANCE)
// ==========================================

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double balance = appSettings.getCurrentRealBalance();
    double income = appSettings.getTotalIncome();
    double expense = appSettings.getTotalExpense();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Book / হিসাবের খাতা"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.green),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationCenterScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Current Balance Card (Always Real-time Total Balance - No Date Filter)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("বর্তমান ব্যালেন্স (Current Balance)", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("৳ ${balance.toStringAsFixed(1)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Income & Expense Section with Date Range Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("আয়-ব্যয় হিসাব", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Chip(
                  label: const Text("এই মাস (This Month)", style: TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("মোট আয়", style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("৳ ${income.toStringAsFixed(1)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("মোট ব্যয়", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("৳ ${expense.toStringAsFixed(1)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text("সাম্প্রতিক লেনদেন সমূহ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            appSettings.transactions.isEmpty
                ? const Padding(padding: EdgeInsets.all(30), child: Center(child: Text("কোনো লেনদেন পাওয়া যায়নি।")))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appSettings.transactions.length > 5 ? 5 : appSettings.transactions.length,
                    itemBuilder: (context, index) {
                      final item = appSettings.transactions[index];
                      bool isIncome = item.type == 'Income';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.15),
                            child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red),
                          ),
                          title: Text("${item.category} (${item.account})", style: const TextStyle(fontWeight: FontWeight.bold)),
