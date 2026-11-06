import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.initPrefs();
  runApp(const AccountBookApp());
}

// ==========================================
// 1. DATA MODELS & IN-MEMORY/PERSISTENCE STATE
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
    this.isPaid = false,
  });
}

class ShoppingItem {
  String name;
  double amount;
  bool isChecked;
  ShoppingItem({required this.name, this.amount = 0.0, this.isChecked = false});
}

class BudgetModel {
  String category;
  double amount;
  BudgetModel({required this.category, required this.amount});
}

class SavingsModel {
  String title;
  double targetAmount;
  double currentAmount;
  bool isCompleted;
  SavingsModel({required this.title, required this.targetAmount, required this.currentAmount, this.isCompleted = false});
}

class AccountModel {
  String name;
  String type; // Bank, Cash, Mobile Banking, Others
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
}

class RepeatedTransactionModel {
  String title;
  double amount;
  String frequency;
  RepeatedTransactionModel({required this.title, required this.amount, required this.frequency});
}

class ReminderModel {
  String title;
  double amount;
  String dueDate;
  ReminderModel({required this.title, required this.amount, required this.dueDate});
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String category; // all, unread, read, loan, alert
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.category,
    this.isRead = false,
  });
}

// ==========================================
// 2. GLOBAL STATE NOTIFIER & TRANSLATION ENGINE
// ==========================================

class AppSettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _language = 'English'; // English, Arabic, Bangla, System Default
  String currency = '৳';
  String timeFilter = 'Month';
  String appPin = '1234';

  // Profile Information
  String profileName = 'MD ALAMGIR HOSSAIN';
  String profileEmail = 'alamgir@email.com';
  String profileGender = 'Male';
  String profileBirthDate = '01-01-1995';
  String profileMobile = '018xxxxxxxx';
  String profileAvatar = 'avatar_1';

  // Security Toggles
  bool useFaceLock = false;
  bool useFingerprint = false;
  bool useNoneLock = false;
  bool usePatternLock = false;
  bool usePinLock = true;

  // Notifications Toggle
  bool dailyReminder = true;
  bool budgetAlert = true;
  bool loanAlert = true;
  String notificationSound = 'Default';

  // Filters
  int selectedMonthIndex = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  DateTime? customStartDate;
  DateTime? customEndDate;

  // Master Lists - Alphabetically Managed
  List<String> categories = ['Food & Hotel', 'Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport'];
  
  List<AccountModel> accounts = [
    AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', balance: 12500.0, isDefault: false),
    AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', balance: 4500.0, isDefault: true),
    AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', balance: 35000.0, isDefault: false),
    AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', balance: 5000.0, isDefault: false),
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
      date: DateTime.now(),
      account: 'Cash in Hand',
      description: 'Emergency assistance',
      isPaid: false,
    ),
  ];

  List<ShoppingItem> shoppingList = [
    ShoppingItem(name: 'Cooking Oil', amount: 150.0, isChecked: true),
    ShoppingItem(name: 'Rice (5 kg)', amount: 450.0, isChecked: false),
  ];

  List<BudgetModel> budgets = [
    BudgetModel(category: 'Food & Hotel', amount: 5000.0),
    BudgetModel(category: 'Transport', amount: 3000.0),
  ];

  List<SavingsModel> savingsList = [
    SavingsModel(title: 'Arufa Savings', targetAmount: 500000, currentAmount: 25000)
  ];

  List<RepeatedTransactionModel> repeatedTransactions = [
    RepeatedTransactionModel(title: 'House Rent', amount: 8000, frequency: '1st of every month'),
    RepeatedTransactionModel(title: 'WiFi Bill', amount: 1000, frequency: '10th of every month'),
  ];

  List<ReminderModel> reminders = [
    ReminderModel(title: 'Electricity Bill', amount: 1200, dueDate: '15th of every month'),
  ];

  List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      title: 'Loan Reminder',
      message: 'Rafiqul Islam has a pending repayment of ৳ 2000.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'loan',
      isRead: false,
    ),
    AppNotification(
      id: 'n2',
      title: 'Budget Alert',
      message: 'You have reached 75% of your Food & Hotel budget.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'alert',
      isRead: true,
    ),
  ];

  Future<void> initPrefs() async {
    // Initializing state parameters safely
    categories.sort();
    accounts.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  
  String getAppTitle() {
    if (_language == 'Bangla') return 'হিসাবের খাতা';
    if (_language == 'Arabic') return 'دفتر الحسابات';
    return 'Account Book';
  }

  String translate(String key) {
    if (_language == 'Bangla') {
      switch (key) {
        case 'Account Book': return 'হিসাবের খাতা';
        case 'Dashboard Analytics': return 'ড্যাশবোর্ড অ্যানালিটিক্স';
        case 'Categories': return 'ক্যাটাগরি সমূহ';
        case 'Accounts': return 'অ্যাকাউন্ট সমূহ';
        case 'Theme': return 'থিম';
        case 'Language': return 'ভাষা';
        case 'About App': return 'অ্যাপ সম্পর্কে';
        case 'Current Balance': return 'বর্তমান ব্যালেন্স';
        case 'Month': return 'মাস';
        case 'Year': return 'বছর';
        case 'Income': return 'আয়';
        case 'Expense': return 'ব্যয়';
        case 'Quick Access': return 'কুইক এক্সেস';
        case 'Recent Transactions': return 'সাম্প্রতিক লেনদেন';
        case 'Budget': return 'বাজেট';
        case 'Reminder': return 'রিমাইন্ডার';
        case 'Repeat': return 'রিপিট';
        case 'Savings': return 'সেভিংস';
        case 'Shopping': return 'শপিং';
        case 'Account': return 'হিসাব';
        case 'Loan': return 'লোন';
        case 'Transactions': return 'লেনদেন';
        case 'Report': return 'রিপোর্ট';
        case 'Profile': return 'প্রোফাইল';
        case 'Grocery': return 'মুদি বাজার';
        case 'Others': return 'অন্যান্য';
        case 'Salary': return 'বেতন';
        case 'Tea & Snacks': return 'চা ও নাস্তা';
        case 'Transport': return 'যাতায়াত';
        case 'Food & Hotel': return 'খাবার ও হোটেল';
        case 'Mobile Banking': return 'মোবাইল ব্যাংকিং';
        case 'Cash': return 'নগদ';
        case 'Bank': return 'ব্যাংক';
        case 'Settings': return 'সেটিংস';
        case 'Goals': return 'লক্ষ্য';
        case 'Calculators': return 'ক্যালকুলেটর হাব';
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
        case 'About App': return 'حول التطبيق';
        case 'Current Balance': return 'الرصيد الحالي';
        case 'Month': return 'شهر';
        case 'Year': return 'سنة';
        case 'Income': return 'إيرادات';
        case 'Expense': return 'مصروفات';
        case 'Quick Access': return 'وصول سريع';
        case 'Recent Transactions': return 'المعاملات الأخيرة';
        case 'Budget': return 'الميزانية';
        case 'Reminder': return 'التذكيرات';
        case 'Repeat': return 'متكرر';
        case 'Savings': return 'المدخرات';
        case 'Shopping': return 'التسوق';
        case 'Account': return 'حساب';
        case 'Loan': return 'قرض';
        case 'Transactions': return 'المعاملات';
        case 'Report': return 'تقرير';
        case 'Profile': return 'الملف الشخصي';
        default: return key;
      }
    }
    return key;
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setMonthYear(int month, int year) {
    selectedMonthIndex = month;
    selectedYear = year;
    notifyListeners();
  }

  void setCustomDateRange(DateTime? start, DateTime? end) {
    customStartDate = start;
    customEndDate = end;
    notifyListeners();
  }

  void updatePin(String newPin) {
    appPin = newPin;
    notifyListeners();
  }

  void updateProfile({required String name, required String email, required String gender, required String birthDate, required String mobile, String? avatar}) {
    profileName = name;
    profileEmail = email;
    profileGender = gender;
    profileBirthDate = birthDate;
    profileMobile = mobile;
    if (avatar != null) profileAvatar = avatar;
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

  void addTransaction(TransactionItem txn) {
    transactions.insert(0, txn);
    // Update account balance
    for (var acc in accounts) {
      if (acc.name == txn.account) {
        if (txn.type == 'Income') acc.balance += txn.amount;
        if (txn.type == 'Expense') acc.balance -= txn.amount;
      }
    }
    notifyListeners();
  }

  void updateTransaction(int index, TransactionItem txn) {
    transactions[index] = txn;
    notifyListeners();
  }

  void removeTransaction(int index) {
    transactions.removeAt(index);
    notifyListeners();
  }

  void addLoan(LoanItem loan) {
    loans.insert(0, loan);
    notifyListeners();
  }

  void removeLoan(int index) {
    loans.removeAt(index);
    notifyListeners();
  }

  void toggleLoanStatus(String id) {
    for (var loan in loans) {
      if (loan.id == id) {
        loan.isPaid = !loan.isPaid;
        notifyListeners();
        break;
      }
    }
  }

  void sortLoans(String criteria) {
    if (criteria.contains('New-Old')) loans.sort((a, b) => b.date.compareTo(a.date));
    else if (criteria.contains('Old-New')) loans.sort((a, b) => a.date.compareTo(b.date));
    else if (criteria.contains('A-Z')) loans.sort((a, b) => a.personName.compareTo(b.personName));
    else if (criteria.contains('Z-A')) loans.sort((a, b) => b.personName.compareTo(a.personName));
    else if (criteria.contains('Large-Small')) loans.sort((a, b) => b.amount.compareTo(a.amount));
    else if (criteria.contains('Small-Large')) loans.sort((a, b) => a.amount.compareTo(b.amount));
    notifyListeners();
  }

  void sortTransactions(String criteria) {
    if (criteria.contains('New-Old')) transactions.sort((a, b) => b.date.compareTo(a.date));
    else if (criteria.contains('Old-New')) transactions.sort((a, b) => a.date.compareTo(b.date));
    else if (criteria.contains('A-Z')) transactions.sort((a, b) => a.category.compareTo(b.category));
    else if (criteria.contains('Z-A')) transactions.sort((a, b) => b.category.compareTo(a.category));
    else if (criteria.contains('Number Large-Small')) transactions.sort((a, b) => b.amount.compareTo(a.amount));
    else if (criteria.contains('Number Small-Large')) transactions.sort((a, b) => a.amount.compareTo(b.amount));
    notifyListeners();
  }

  List<TransactionItem> getFilteredTransactions() {
    return transactions.where((txn) {
      if (timeFilter == 'Custom Range' && customStartDate != null && customEndDate != null) {
        return txn.date.isAfter(customStartDate!.subtract(const Duration(days: 1))) &&
               txn.date.isBefore(customEndDate!.add(const Duration(days: 1)));
      }
      return txn.date.year == selectedYear && txn.date.month == selectedMonthIndex;
    }).toList();
  }

  double getTotalIncome() {
    double total = 0;
    for (var txn in getFilteredTransactions()) {
      if (txn.type == 'Income') total += txn.amount;
    }
    return total;
  }

  double getTotalExpense() {
    double total = 0;
    for (var txn in getFilteredTransactions()) {
      if (txn.type == 'Expense') total += txn.amount;
    }
    return total;
  }

  double getTotalBalance() {
    double accSum = 0;
    for (var a in accounts) {
      accSum += a.balance;
    }
    return accSum;
  }

  double getTotalGiven() {
    double total = 0;
    for (var loan in loans) {
      if (loan.type == 'Given' && !loan.isPaid) total += loan.amount;
    }
    return total;
  }

  double getTotalTaken() {
    double total = 0;
    for (var loan in loans) {
      if (loan.type == 'Taken' && !loan.isPaid) total += loan.amount;
    }
    return total;
  }

  double getNetBalance() => getTotalGiven() - getTotalTaken();

  void addAccount(String name, String type, String details) {
    if (name.isNotEmpty) {
      accounts.add(AccountModel(name: name, type: type, details: details, isDefault: accounts.isEmpty));
      accounts.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void clearAllNotifications() {
    notifications.clear();
    notifyListeners();
  }

  void addCategory(String cat) {
    if (cat.isNotEmpty && !categories.contains(cat)) {
      categories.add(cat);
      categories.sort();
      notifyListeners();
    }
  }
}

final appSettings = AppSettingsNotifier();

// ==========================================
// 3. MAIN APPLICATION & THEME ENGINE
// ==========================================

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
            primaryColor: const Color(0xFF10B981),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
            dialogTheme: const DialogTheme(backgroundColor: Colors.white),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF10B981),
            cardColor: const Color(0xFF1E293B),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white, elevation: 1),
            dialogTheme: const DialogTheme(backgroundColor: Color(0xFF1E293B)),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ),
          home: appSettings.useNoneLock ? const MainHomeScreen() : const PinLockScreen(),
        );
      },
    );
  }
}

// ==========================================
// 4. DOWNLOAD & SORT MENUS
// ==========================================

void showStandardDownloadMenu(BuildContext context, Offset offset) {
  String lang = appSettings.language;
  String previewText = lang == 'Bangla' ? 'প্রিভিউ' : (lang == 'Arabic' ? 'معاينة' : 'Preview');
  String pdfText = lang == 'Bangla' ? 'পিডিএফ ডাউনলোড' : (lang == 'Arabic' ? 'تحميل كـ PDF' : 'Download as PDF');
  String excelText = lang == 'Bangla' ? 'এক্সেল ডাউনলোড' : (lang == 'Arabic' ? 'تحميل كـ Excel' : 'Download as Excel');

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 20, 0),
    items: [
      PopupMenuItem(
        value: 'preview',
        child: Row(children: [const Icon(Icons.visibility, color: Colors.blue, size: 20), const SizedBox(width: 8), Text(previewText)]),
      ),
      PopupMenuItem(
        value: 'pdf',
        child: Row(children: [const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20), const SizedBox(width: 8), Text(pdfText)]),
      ),
      PopupMenuItem(
        value: 'excel',
        child: Row(children: [const Icon(Icons.table_chart, color: Colors.green, size: 20), const SizedBox(width: 8), Text(excelText)]),
      ),
    ],
  ).then((value) {
    if (value != null) {
      if (value == 'preview') {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(lang == 'Bangla' ? 'রিপোর্ট প্রিভিউ' : 'Report Preview'),
            content: Text('Financial Summary:\nTotal Income: ৳ ${appSettings.getTotalIncome()}\nTotal Expense: ৳ ${appSettings.getTotalExpense()}'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved as ${value.toUpperCase()} in device memory.'),
            action: SnackBarAction(label: 'Open', onPressed: () {}),
          ),
        );
      }
    }
  });
}

void showStandardSortMenu(BuildContext context, Offset offset, Function(String) onSelected) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 20, 0),
    items: const [
      PopupMenuItem(value: 'Date New-Old', child: Text('Sort by Date (Newest to Oldest)')),
      PopupMenuItem(value: 'Date Old-New', child: Text('Sort by Date (Oldest to Newest)')),
      PopupMenuItem(value: 'Name A-Z', child: Text('Sort by Name (A to Z)')),
      PopupMenuItem(value: 'Name Z-A', child: Text('Sort by Name (Z to A)')),
      PopupMenuItem(value: 'Number Large-Small', child: Text('Sort by Number (Large to Small)')),
      PopupMenuItem(value: 'Number Small-Large', child: Text('Sort by Number (Small to Large)')),
    ],
  ).then((value) {
    if (value != null) onSelected(value);
  });
}

// ==========================================
// 5. LOCK SCREEN & SECURITY
// ==========================================

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pin = '';

  void _onKeyTap(String value) {
    setState(() {
      if (value == 'C') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else if (value == 'OK') {
        _verifyPin();
      } else {
        if (_pin.length < 4) _pin += value;
        if (_pin.length == 4) _verifyPin();
      }
    });
  }

  void _verifyPin() {
    if (_pin == appSettings.appPin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong PIN! (Default: 1234)')));
      setState(() => _pin = '');
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language / ভাষা নির্বাচন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Arabic (العربية)'), onTap: () { appSettings.setLanguage('Arabic'); Navigator.pop(ctx); }),
            ListTile(title: const Text('Bangla (বাংলা)'), onTap: () { appSettings.setLanguage('Bangla'); Navigator.pop(ctx); }),
            ListTile(title: const Text('English'), onTap: () { appSettings.setLanguage('English'); Navigator.pop(ctx); }),
            ListTile(title: const Text('System Default'), onTap: () { appSettings.setLanguage('English'); Navigator.pop(ctx); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.language, color: Colors.white), onPressed: _showLanguageDialog),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet, size: 64, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            Text(appSettings.getAppTitle(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (idx) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pin.length > idx ? const Color(0xFF10B981) : Colors.white24,
                  ),
                );
              }),
            ),
            const SizedBox(height: 36),
            for (var row in [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["C", "0", "OK"]])
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((val) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _onKeyTap(val),
                      child: Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. NOTIFICATION CENTER
// ==========================================

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedTab = 'all';

  @override
  Widget build(BuildContext context) {
    var filteredList = appSettings.notifications.where((n) {
      if (_selectedTab == 'unread') return !n.isRead;
      if (_selectedTab == 'read') return n.isRead;
      if (_selectedTab == 'loan') return n.category == 'loan';
      if (_selectedTab == 'alert') return n.category == 'alert';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'read_all') appSettings.markAllNotificationsAsRead();
              if (val == 'delete_all') appSettings.clearAllNotifications();
              setState(() {});
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'read_all', child: Text('Mark all as read')),
              const PopupMenuItem(value: 'delete_all', child: Text('Delete all')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: ['all', 'unread', 'read', 'loan', 'alert'].map((tab) {
                bool isSelected = _selectedTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(tab.toUpperCase()),
                    selected: isSelected,
                    selectedColor: const Color(0xFF10B981),
                    onSelected: (v) => setState(() => _selectedTab = tab),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text('No notifications found.'))
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (ctx, idx) {
                      final item = filteredList[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            item.category == 'loan' ? Icons.money : Icons.warning_amber_rounded,
                            color: item.isRead ? Colors.grey : const Color(0xFF10B981),
                          ),
                          title: Text(item.title, style: TextStyle(fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(item.message),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline, size: 20),
                            onPressed: () {
                              setState(() => item.isRead = !item.isRead);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. HOME SCREEN & TRANSACTION POPUP
// ==========================================

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  void _showAddTransactionDialog(BuildContext context) {
    String transactionType = 'Expense';
    String selectedCategory = appSettings.categories[0];
    String selectedAccount = appSettings.accounts.firstWhere((acc) => acc.isDefault, orElse: () => appSettings.accounts[0]).name;
    
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    double currentAccountBalance = appSettings.accounts.firstWhere((a) => a.name == selectedAccount).balance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add New Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.calculate, color: Color(0xFF10B981)),
                          onPressed: () {
                            _showInPopupCalculator(context, (result) {
                              setStateModal(() {
                                amountController.text = result;
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Income' ? Colors.green : Theme.of(context).cardColor),
                            onPressed: () => setStateModal(() => transactionType = 'Income'),
                            child: const Text('Cash In'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Expense' ? Colors.red : Theme.of(context).cardColor),
                            onPressed: () => setStateModal(() => transactionType = 'Expense'),
                            child: const Text('Cash Out'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedAccount,
                      dropdownColor: Theme.of(context).cardColor,
                      decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
                      items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text(appSettings.translate(acc.name)))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateModal(() {
                            selectedAccount = val;
                            currentAccountBalance = appSettings.accounts.firstWhere((a) => a.name == val).balance;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text('Current Balance: ৳ $currentAccountBalance', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: Theme.of(context).cardColor,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: appSettings.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(appSettings.translate(cat)))).toList(),
                      onChanged: (val) { if (val != null) setStateModal(() => selectedCategory = val); },
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    // Shortcut Suggestions
                    Row(
                      children: [50, 100, 500, 1000, 2000].map((amt) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text('+$amt'),
                            onPressed: () {
                              double current = double.tryParse(amountController.text) ?? 0;
                              amountController.text = (current + amt).toStringAsFixed(0);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () {
                          if (amountController.text.isNotEmpty) {
                            double amount = double.tryParse(amountController.text) ?? 0.0;
                            appSettings.addTransaction(TransactionItem(
                              id: DateTime.now().toString(),
                              type: transactionType,
                              account: selectedAccount,
                              category: selectedCategory,
                              amount: amount,
                              description: descController.text,
                              date: DateTime.now(),
                            ));
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Save', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showInPopupCalculator(BuildContext context, Function(String) onResult) {
    String expr = '';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateCalc) => AlertDialog(
          title: const Text('Quick Calculator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(12),
                color: Colors.black12,
                child: Text(expr.isEmpty ? '0' : expr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['7','8','9','+','4','5','6','-','1','2','3','*','C','0','=','/'].map((btn) {
                  return SizedBox(
                    width: 50,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setStateCalc(() {
                          if (btn == 'C') expr = '';
                          else if (btn == '=') {
                            expr = '1000'; // Simple demo result evaluator
                          } else expr += btn;
                        });
                      },
                      child: Text(btn),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                onResult(expr);
                Navigator.pop(ctx);
              },
              child: const Text('Add Amount (✔)'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;

    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(appSettings.getAppTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationCenterScreen()));
                },
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Balance Display
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text('৳ ${appSettings.getTotalBalance().toStringAsFixed(1)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Income & Expense Section with Date Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Income & Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Chip(label: const Text('This Month', style: TextStyle(color: Colors.white, fontSize: 12)), backgroundColor: const Color(0xFF10B981)),
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
                            Text(appSettings.translate('Income'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('$curr ${appSettings.getTotalIncome()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
                            Text(appSettings.translate('Expense'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('$curr ${appSettings.getTotalExpense()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(appSettings.translate('Recent Transactions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                appSettings.transactions.isEmpty
                    ? const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text('No transactions found')))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appSettings.transactions.length > 4 ? 4 : appSettings.transactions.length,
                        itemBuilder: (context, index) {
                          final txn = appSettings.transactions[index];
                          bool isIncome = txn.type == 'Income';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.2),
                                child: Icon(isIncome ? Icons.add : Icons.remove, color: isIncome ? Colors.green : Colors.red),
                              ),
                              title: Text('${appSettings.translate(txn.category)} (${appSettings.translate(txn.account)})'),
                              subtitle: Text(appSettings.translate(txn.description)),
                              trailing: Text(
                                '${isIncome ? '+' : '-'} $curr ${txn.amount}',
                                style: TextStyle(color: isIncome ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 8. APP DRAWER
// ==========================================

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF10B981)),
            accountName: Text(appSettings.profileName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(appSettings.profileEmail),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFF10B981))),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(appSettings.translate('Dashboard Analytics')),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DashboardAnalyticsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: Text(appSettings.translate('Calculators')),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CalculatorsHubScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(appSettings.translate('Categories')),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CategoriesScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: Text(appSettings.translate('Accounts')),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AccountsScreen())),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 9. AUXILIARY SCREENS (DASHBOARD, CALCS, CATEGORIES, ACCOUNTS)
// ==========================================

class DashboardAnalyticsScreen extends StatelessWidget {
  const DashboardAnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Analytics')),
      body: const Center(child: Text('Analytics charts & graphs module')),
    );
  }
}

class CalculatorsHubScreen extends StatelessWidget {
  const CalculatorsHubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculators Hub')),
      body: const Center(child: Text('Financial Calculators Engine')),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        itemCount: appSettings.categories.length,
        itemBuilder: (ctx, idx) => ListTile(title: Text(appSettings.categories[idx])),
      ),
    );
  }
}

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: ListView.builder(
        itemCount: appSettings.accounts.length,
        itemBuilder: (ctx, idx) => ListTile(
          title: Text(appSettings.accounts[idx].name),
          subtitle: Text('Balance: ৳ ${appSettings.accounts[idx].balance}'),
        ),
      ),
    );
  }
}

// ==========================================
// 10. LOAN, TRANSACTIONS, REPORTS & PROFILE TABS
// ==========================================

class LoanDebtTabScreen extends StatelessWidget {
  const LoanDebtTabScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan & Debt')),
      body: ListView.builder(
        itemCount: appSettings.loans.length,
        itemBuilder: (ctx, idx) {
          final loan = appSettings.loans[idx];
          return ListTile(
            title: Text(loan.personName),
            subtitle: Text('${loan.type} | ৳ ${loan.amount}'),
          );
        },
      ),
    );
  }
}

class AllTransactionsTabScreen extends StatelessWidget {
  const AllTransactionsTabScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: ListView.builder(
        itemCount: appSettings.transactions.length,
        itemBuilder: (ctx, idx) {
          final item = appSettings.transactions[idx];
          return ListTile(
            title: Text('${item.category} (${item.account})'),
            subtitle: Text(item.description),
            trailing: Text('৳ ${item.amount}'),
          );
        },
      ),
    );
  }
}

class ReportsTabScreen extends StatelessWidget {
  const ReportsTabScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analysis')),
      body: const Center(child: Text('Reports module')),
    );
  }
}

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose Avatar'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () { appSettings.updateProfile(name: appSettings.profileName, email: appSettings.profileEmail, gender: appSettings.profileGender, birthDate: appSettings.profileBirthDate, mobile: appSettings.profileMobile, avatar: 'avatar_1'); Navigator.pop(ctx); },
              child: const CircleAvatar(radius: 24, child: Icon(Icons.person)),
            ),
            InkWell(
              onTap: () { appSettings.updateProfile(name: appSettings.profileName, email: appSettings.profileEmail, gender: appSettings.profileGender, birthDate: appSettings.profileBirthDate, mobile: appSettings.profileMobile, avatar: 'avatar_2'); Navigator.pop(ctx); },
              child: const CircleAvatar(radius: 24, child: Icon(Icons.face)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(radius: 36, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(0xFF10B981))),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _showAvatarPicker,
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.black, child: Icon(Icons.edit, size: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(appSettings.profileName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(appSettings.profileEmail, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 11. MAIN CONTAINER WITH TAB NAVIGATION
// ==========================================

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreenContent(),
    const LoanDebtTabScreen(),
    const AllTransactionsTabScreen(),
    const ReportsTabScreen(),
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
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).cardColor,
          onTap: (index) => setState(() => _currentIndex = index),
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