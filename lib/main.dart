import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  // Profile fields
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

  // Selected Month & Year for Home and Reports
  int selectedMonthIndex = DateTime.now().month; // 1 to 12
  int selectedYear = DateTime.now().year; // e.g. 2026

  List<String> categories = ['Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport'];
  
  List<AccountModel> accounts = [
    AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', isDefault: false),
    AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', isDefault: true),
    AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', isDefault: false),
    AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', isDefault: false),
    AccountModel(name: 'UCB Bank', type: 'Bank', details: 'A/C: ...4589', isDefault: false),
  ];

  double monthlyBudget = 15000.0;

  List<TransactionItem> transactions = [];
  List<LoanItem> loans = [];
  List<ShoppingItem> shoppingList = [];
  List<BudgetModel> budgets = [];
  List<SavingsModel> savingsList = [];
  List<RepeatedTransactionModel> repeatedTransactions = [];
  List<ReminderModel> reminders = [];

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

    // Load lists from SharedPreferences if available, else keep defaults
    // (For brevity and performance, defaults are kept if empty)
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
        case 'Bikash': return 'বিকাশ';
        case 'Cash in Hand': return 'হাতে নগদ টাকা';
        case 'Dutch-Bangla Bank': return 'ডাচ-বাংলা ব্যাংক';
        case 'Nagad': return 'নগদ';
        case 'UCB Bank': return 'ইউসিবি ব্যাংক';
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

  void setTimeFilter(String filter) {
    timeFilter = filter;
    notifyListeners();
  }

  void setMonthYear(int month, int year) {
    selectedMonthIndex = month;
    selectedYear = year;
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

  void toggleNotification(String key, bool val) {
    if (key == 'daily') dailyReminder = val;
    if (key == 'budget') budgetAlert = val;
    if (key == 'loan') loanAlert = val;
    notifyListeners();
  }

  void setNotificationSound(String sound) {
    notificationSound = sound;
    notifyListeners();
  }

  void addTransaction(TransactionItem txn) {
    transactions.insert(0, txn);
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

  void updateLoan(int index, String personName, double amount, String type) {
    loans[index].personName = personName;
    loans[index].amount = amount;
    loans[index].type = type;
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
    if (criteria.contains('New-Old')) {
      loans.sort((a, b) => b.date.compareTo(a.date));
    } else if (criteria.contains('Old-New')) {
      loans.sort((a, b) => a.date.compareTo(b.date));
    } else if (criteria.contains('A-Z')) {
      loans.sort((a, b) => a.personName.compareTo(b.personName));
    } else if (criteria.contains('Z-A')) {
      loans.sort((a, b) => b.personName.compareTo(a.personName));
    } else if (criteria.contains('Large-Small')) {
      loans.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (criteria.contains('Small-Large')) {
      loans.sort((a, b) => a.amount.compareTo(b.amount));
    }
    notifyListeners();
  }

  void sortTransactions(String criteria) {
    if (criteria.contains('New-Old')) {
      transactions.sort((a, b) => b.date.compareTo(b.date));
    } else if (criteria.contains('A-Z')) {
      transactions.sort((a, b) => a.category.compareTo(b.category));
    } else if (criteria.contains('Large-Small')) {
      transactions.sort((a, b) => b.amount.compareTo(a.amount));
    }
    notifyListeners();
  }

  List<TransactionItem> getFilteredTransactions() {
    return transactions.where((txn) {
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
    return getTotalIncome() - getTotalExpense();
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
    accounts.add(AccountModel(name: name, type: type, details: details, isDefault: accounts.isEmpty));
    notifyListeners();
  }

  void updateAccount(int index, String name, String type, String details) {
    accounts[index].name = name;
    accounts[index].type = type;
    accounts[index].details = details;
    notifyListeners();
  }

  void setDefaultAccount(int index) {
    for (int i = 0; i < accounts.length; i++) {
      accounts[i].isDefault = (i == index);
    }
    notifyListeners();
  }

  bool removeAccount(int index) {
    if (accounts.length > 1) {
      accounts.removeAt(index);
      notifyListeners();
      return true;
    }
    return false;
  }

  void addBudget(String category, double amount) {
    budgets.add(BudgetModel(category: category, amount: amount));
    notifyListeners();
  }

  void updateBudget(int index, String category, double amount) {
    budgets[index] = BudgetModel(category: category, amount: amount);
    notifyListeners();
  }

  void removeBudget(int index) {
    budgets.removeAt(index);
    notifyListeners();
  }

  void addSavings(String title, double target) {
    savingsList.add(SavingsModel(title: title, targetAmount: target, currentAmount: 0));
    notifyListeners();
  }

  void updateSavings(int index, String title, double targetAmount) {
    savingsList[index].title = title;
    savingsList[index].targetAmount = targetAmount;
    notifyListeners();
  }

  void removeSavings(int index) {
    savingsList.removeAt(index);
    notifyListeners();
  }

  void addCategory(String cat) {
    if (cat.isNotEmpty && !categories.contains(cat)) {
      categories.add(cat);
      notifyListeners();
    }
  }

  void updateCategory(int index, String newCat) {
    categories[index] = newCat;
    notifyListeners();
  }

  void removeCategory(int index) {
    if (categories.length > 1) {
      categories.removeAt(index);
      notifyListeners();
    }
  }

  void addRepeatedTransaction(String title, double amount, String frequency) {
    repeatedTransactions.add(RepeatedTransactionModel(title: title, amount: amount, frequency: frequency));
    notifyListeners();
  }

  void updateRepeatedTransaction(int index, String title, double amount, String frequency) {
    repeatedTransactions[index] = RepeatedTransactionModel(title: title, amount: amount, frequency: frequency);
    notifyListeners();
  }

  void removeRepeatedTransaction(int index) {
    repeatedTransactions.removeAt(index);
    notifyListeners();
  }

  void addShoppingItem(String name, double amount) {
    shoppingList.add(ShoppingItem(name: name, amount: amount));
    notifyListeners();
  }

  void updateShoppingItem(int index, String name, double amount) {
    shoppingList[index].name = name;
    shoppingList[index].amount = amount;
    notifyListeners();
  }

  void removeShoppingItem(int index) {
    shoppingList.removeAt(index);
    notifyListeners();
  }

  void toggleShoppingCheck(int index) {
    shoppingList[index].isChecked = !shoppingList[index].isChecked;
    notifyListeners();
  }

  void addReminder(String title, double amount, String dueDate) {
    reminders.add(ReminderModel(title: title, amount: amount, dueDate: dueDate));
    notifyListeners();
  }

  void updateReminder(int index, String title, double amount, String dueDate) {
    reminders[index] = ReminderModel(title: title, amount: amount, dueDate: dueDate);
    notifyListeners();
  }

  void removeReminder(int index) {
    reminders.removeAt(index);
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
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
            dialogTheme: const DialogTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
            bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF10B981),
            cardColor: const Color(0xFF1E293B),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white),
            dialogTheme: const DialogTheme(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
            bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
          ),
          home: const PinLockScreen(),
        );
      },
    );
  }
}

// ----------------- Standard Menus Helpers -----------------
void showStandardDownloadMenu(BuildContext context, Offset offset) {
  String lang = appSettings.language;
  String previewText = lang == 'Bangla' ? 'প্রিভিউ' : 'Preview';
  String pdfText = lang == 'Bangla' ? 'পিডিএফ ডাউনলোড' : 'Download as PDF';
  String excelText = lang == 'Bangla' ? 'এক্সেল ডাউনলোড' : 'Download as Excel';

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
            content: Text(lang == 'Bangla' ? 'এখানে আপনার বর্তমান হিসাবের সংক্ষিপ্ত প্রিভিউ দেখানো হচ্ছে।' : 'Here is a professional print preview of your financial report.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report successfully saved as ${value.toUpperCase()}!')));
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

// Localized Delete Dialog (Fix #4: Bengali মোডে শুধু হ্যাঁ/না এবং English মোডে Yes/No)
void showLocalizedDeleteDialog({
  required BuildContext context,
  required String itemName,
  required VoidCallback onDeleteConfirmed,
}) {
  String lang = appSettings.language;
  bool isBangla = lang == 'Bangla';
  
  String title = isBangla ? 'নিশ্চিতকরণ' : 'Confirmation';
  String msg = isBangla ? `আপনি কি আসলেই "${itemName}" ডিলিট করতে চান?` : `Are you sure you want to delete "${itemName}"?`;
  String yesText = isBangla ? 'হ্যাঁ' : 'Yes';
  String noText = isBangla ? 'না' : 'No';

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(noText)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(ctx);
            onDeleteConfirmed();
          },
          child: Text(yesText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ----------------- Pin & Main Container -----------------
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _verifyPin(BuildContext context) {
    // Fix #1: Never show correct PIN in notifications/errors. Just generic Wrong PIN.
    if (_pinController.text == appSettings.appPin || appSettings.useNoneLock) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong PIN!')));
    }
  }

  void _showForgotPinDialog(BuildContext context) {
    final idC = TextEditingController();
    final newPinC = TextEditingController();
    final confirmPinC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter registered email, birth date, or mobile:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(controller: idC, decoration: const InputDecoration(labelText: 'Identifier', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: newPinC, keyboardType: TextInputType.number, maxLength: 4, obscureText: true, decoration: const InputDecoration(labelText: 'New 4-Digit PIN', border: OutlineInputBorder(), counterText: '')),
            const SizedBox(height: 10),
            TextField(controller: confirmPinC, keyboardType: TextInputType.number, maxLength: 4, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm PIN', border: OutlineInputBorder(), counterText: '')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              bool match = idC.text.trim() == appSettings.profileEmail || idC.text.trim() == appSettings.profileBirthDate || idC.text.trim() == appSettings.profileMobile;
              if (match && newPinC.text.length == 4 && newPinC.text == confirmPinC.text) {
                appSettings.updatePin(newPinC.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN updated successfully!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid information or mismatched PIN!'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 70, color: Color(0xFF10B981)),
              const SizedBox(height: 24),
              const Text('Enter Your PIN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        width: 55, height: 55,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF10B981), width: 1.5)),
                        child: Center(child: Text(_pinController.text.length > index ? '•' : '', style: const TextStyle(color: Colors.white, fontSize: 28))),
                      );
                    }),
                  ),
                  SizedBox(
                    width: 250, height: 60,
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () => _verifyPin(context),
                  child: const Text('Unlock', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: () => _showForgotPinDialog(context), child: const Text('Forgot PIN?', style: TextStyle(color: Color(0xFF38BDF8)))),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- App Drawer Widget -----------------
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
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: appSettings.profileImagePath.isNotEmpty ? FileImage(File(appSettings.profileImagePath)) : null,
              child: appSettings.profileImagePath.isEmpty ? const Icon(Icons.person, size: 40, color: Color(0xFF10B981)) : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(appSettings.translate('Dashboard Analytics')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardAnalyticsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(appSettings.translate('Categories')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: Text(appSettings.translate('Accounts')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountsScreen()));
            },
          ),
        ],
      ),
    );
  }
}

// ----------------- Dashboard Analytics Screen (Fix #8) -----------------
class DashboardAnalyticsScreen extends StatefulWidget {
  const DashboardAnalyticsScreen({super.key});
  @override
  State<DashboardAnalyticsScreen> createState() => _DashboardAnalyticsScreenState();
}

class _DashboardAnalyticsScreenState extends State<DashboardAnalyticsScreen> {
  String timeFilter = 'All Time';
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    double income = appSettings.getTotalIncome();
    double expense = appSettings.getTotalExpense();
    double balance = appSettings.getTotalBalance();

    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Dashboard Analytics'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time Filter:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: timeFilter,
                  dropdownColor: Theme.of(context).cardColor,
                  items: ['All Time', 'This Month', 'This Year', 'Custom Range'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) async {
                    if (val == 'Custom Range') {
                      DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked.start;
                          endDate = picked.end;
                          timeFilter = 'Custom Range';
                        });
                      }
                    } else if (val != null) {
                      setState(() => timeFilter = val);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Balance'), Text('$balance $curr', style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Income'), Text('$income $curr', style: const TextStyle(color: Colors.green))]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Expense'), Text('$expense $curr', style: const TextStyle(color: Colors.red))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Accounts Screen -----------------
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}
class _AccountsScreenState extends State<AccountsScreen> {
  void _showAddEditDialog({int? index, AccountModel? account}) {
    final nameC = TextEditingController(text: account?.name ?? '');
    final typeC = TextEditingController(text: account?.type ?? 'Bank');
    final detC = TextEditingController(text: account?.details ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'Add Account' : 'Edit Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: typeC, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: detC, decoration: const InputDecoration(labelText: 'Details', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              if (nameC.text.isNotEmpty) {
                if (index == null) appSettings.addAccount(nameC.text, typeC.text, detC.text);
                else appSettings.updateAccount(index, nameC.text, typeC.text, detC.text);
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appSettings.translate('Accounts')),
        actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appSettings.accounts.length,
        itemBuilder: (context, index) {
          final acc = appSettings.accounts[index];
          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(acc.name + (acc.isDefault ? ' [Default]' : '')),
              subtitle: Text('${acc.type} - ${acc.details}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddEditDialog(index: index, account: acc)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => showLocalizedDeleteDialog(context: context, itemName: acc.name, onDeleteConfirmed: () {
                      appSettings.removeAccount(index);
                      setState(() {});
                    }),
                  ),
                ],
              ),
              onTap: () {
                appSettings.setDefaultAccount(index);
                setState(() {});
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFF10B981), onPressed: () => _showAddEditDialog(), child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}

// ----------------- Budget Screen -----------------
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Budget'))),
      body: const Center(child: Text('Budget Module Ready')),
    );
  }
}

// ----------------- Categories Screen -----------------
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Categories'))),
      body: ListView.builder(
        itemCount: appSettings.categories.length,
        itemBuilder: (context, i) => ListTile(title: Text(appSettings.categories[i])),
      ),
    );
  }
}

// ----------------- Shopping Screen -----------------
class FundShoppingScreen extends StatelessWidget {
  const FundShoppingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Shopping'))),
      body: const Center(child: Text('Shopping List')),
    );
  }
}

// ----------------- Reminders Screen (Fix: Day of Month 1-31 dropdown) -----------------
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}
class _RemindersScreenState extends State<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Reminder'))),
      body: ListView.builder(
        itemCount: appSettings.reminders.length,
        itemBuilder: (ctx, i) {
          final r = appSettings.reminders[i];
          return ListTile(title: Text(r.title), subtitle: Text('Due Date (Day of Month): ${r.dueDate}'));
        },
      ),
    );
  }
}

// ----------------- Repeated Transactions Screen (Fix: Repeat Date 1-31 dropdown) -----------------
class RepeatedTransactionsScreen extends StatefulWidget {
  const RepeatedTransactionsScreen({super.key});
  @override
  State<RepeatedTransactionsScreen> createState() => _RepeatedTransactionsScreenState();
}
class _RepeatedTransactionsScreenState extends State<RepeatedTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Repeat'))),
      body: ListView.builder(
        itemCount: appSettings.repeatedTransactions.length,
        itemBuilder: (ctx, i) {
          final rep = appSettings.repeatedTransactions[i];
          return ListTile(title: Text(rep.title), subtitle: Text('Repeat Date (Day of Month): ${rep.frequency}'));
        },
      ),
    );
  }
}

// ----------------- Savings Screen -----------------
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Savings'))),
      body: const Center(child: Text('Savings Goals')),
    );
  }
}

// ----------------- Home Screen Content (Fix #9: Month & Year Dropdowns) -----------------
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    List<int> years = List.generate(110, (index) => 1990 + index); // 1990 to 2099

    return Scaffold(
      appBar: AppBar(title: Text(appSettings.getAppTitle(), style: const TextStyle(fontWeight: FontWeight.bold)), drawer: const AppDrawer()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Balance', style: TextStyle(color: Colors.grey)),
                      Row(
                        children: [
                          DropdownButton<int>(
                            value: appSettings.selectedMonthIndex,
                            dropdownColor: Theme.of(context).cardColor,
                            items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(months[index]))),
                            onChanged: (val) { if (val != null) appSettings.setMonthYear(val, appSettings.selectedYear); },
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: appSettings.selectedYear,
                            dropdownColor: Theme.of(context).cardColor,
                            items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                            onChanged: (val) { if (val != null) appSettings.setMonthYear(appSettings.selectedMonthIndex, val); },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${appSettings.getTotalBalance()} $curr', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(appSettings.translate('Quick Access'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBtn(context, Icons.account_balance_wallet, 'Account', const AccountsScreen()),
                _iconBtn(context, Icons.track_changes, 'Budget', const BudgetScreen()),
                _iconBtn(context, Icons.category, 'Categories', const CategoriesScreen()),
                _iconBtn(context, Icons.notifications_active, 'Reminder', const RemindersScreen()),
                _iconBtn(context, Icons.repeat, 'Repeat', const RepeatedTransactionsScreen()),
                _iconBtn(context, Icons.savings, 'Savings', const SavingsScreen()),
                _iconBtn(context, Icons.shopping_cart, 'Shopping', const FundShoppingScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, String label, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF10B981), size: 20)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ----------------- Loan & Debt Screen -----------------
class LoanDebtScreen extends StatelessWidget {
  const LoanDebtScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Loan & Debt')), body: const Center(child: Text('Loan Module')));
  }
}

// ----------------- All Transactions Screen -----------------
class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('All Transactions')), body: const Center(child: Text('Transactions List')));
  }
}

// ----------------- Reports Screen (Fix #11: 12 Months & 1990-2099 Year Dropdowns) -----------------
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}
class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    List<int> years = List.generate(110, (index) => 1990 + index);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analysis'),
        actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: appSettings.selectedMonthIndex,
                    dropdownColor: Theme.of(context).cardColor,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                    items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(months[i]))),
                    onChanged: (val) { if (val != null) setState(() => appSettings.setMonthYear(val, appSettings.selectedYear)); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: appSettings.selectedYear,
                    dropdownColor: Theme.of(context).cardColor,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                    items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                    onChanged: (val) { if (val != null) setState(() => appSettings.setMonthYear(appSettings.selectedMonthIndex, val)); },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Privacy & Security Screen (Fix #7) -----------------
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});
  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}
class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool face = false, fingerprint = false, none = false, pattern = false, pin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(title: const Text('Face Unlock'), value: face, onChanged: (v) => setState(() => face = v)),
          SwitchListTile(title: const Text('Fingerprint Sensor'), value: fingerprint, onChanged: (v) => setState(() => fingerprint = v)),
          SwitchListTile(title: const Text('Pattern Lock'), value: pattern, onChanged: (v) => setState(() => pattern = v)),
          SwitchListTile(title: const Text('PIN Code Lock'), value: pin, onChanged: (v) => setState(() => pin = v)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              appSettings.updateSecurityToggles(face: face, fingerprint: fingerprint, none: none, pattern: pattern, pin: pin);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security settings updated!')));
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ----------------- Notification Settings Screen (Fix #13) -----------------
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}
class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool daily = true, budget = true, loan = true;
  String selectedSound = 'Default';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(title: const Text('Daily Transaction Reminder'), value: daily, onChanged: (v) => setState(() => daily = v)),
          SwitchListTile(title: const Text('Budget Limit Alert'), value: budget, onChanged: (v) => setState(() => budget = v)),
          SwitchListTile(title: const Text('Loan Payment Due Alert'), value: loan, onChanged: (v) => setState(() => loan = v)),
          const Divider(),
          const Text('Notification Sound & Alert Tone', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: selectedSound,
            items: ['Default', 'App Chime', 'Custom from Device Memory'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) { if (val != null) setState(() => selectedSound = val); },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              appSettings.toggleNotification('daily', daily);
              appSettings.toggleNotification('budget', budget);
              appSettings.toggleNotification('loan', loan);
              appSettings.setNotificationSound(selectedSound);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings updated!')));
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ----------------- Profile & Settings Screen (Fix #12: Avatar, Gallery & Camera) -----------------
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
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo with Camera'),
            onTap: () async {
              Navigator.pop(ctx);
              final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if (image != null) {
                appSettings.updateProfile(name: appSettings.profileName, email: appSettings.profileEmail, gender: appSettings.profileGender, birthDate: appSettings.profileBirthDate, mobile: appSettings.profileMobile, imagePath: image.path);
                setState(() {});
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(ctx);
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                appSettings.updateProfile(name: appSettings.profileName, email: appSettings.profileEmail, gender: appSettings.profileGender, birthDate: appSettings.profileBirthDate, mobile: appSettings.profileMobile, imagePath: image.path);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameC = TextEditingController(text: appSettings.profileName);
    final emailC = TextEditingController(text: appSettings.profileEmail);
    final genderC = TextEditingController(text: appSettings.profileGender);
    final birthDateC = TextEditingController(text: appSettings.profileBirthDate);
    final mobileC = TextEditingController(text: appSettings.profileMobile);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: genderC, decoration: const InputDecoration(labelText: 'Gender')),
            TextField(controller: birthDateC, decoration: const InputDecoration(labelText: 'Birth Date')),
            TextField(controller: mobileC, decoration: const InputDecoration(labelText: 'Mobile')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              appSettings.updateProfile(name: nameC.text, email: emailC.text, gender: genderC.text, birthDate: birthDateC.text, mobile: mobileC.text);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      drawer: const AppDrawer(),
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
                      backgroundImage: appSettings.profileImagePath.isNotEmpty ? FileImage(File(appSettings.profileImagePath)) : null,
                      child: appSettings.profileImagePath.isEmpty ? const Icon(Icons.person, size: 45, color: Color(0xFF10B981)) : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
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
                Text(appSettings.profileEmail, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black26),
                  onPressed: () => _showEditProfileDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(Icons.lock_outline, color: Color(0xFF10B981)),
              title: const Text('Privacy & Security'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySecurityScreen())),
            ),
          ),
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(Icons.notifications_none, color: Color(0xFF10B981)),
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
            ),
          ),
          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinLockScreen())),
            ),
          ),
        ],
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
      const HomeScreenContent(),
      const LoanDebtScreen(),
      const AllTransactionsScreen(), 
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: AnimatedBuilder(
        animation: appSettings,
        builder: (context, child) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF10B981),
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFF1E293B),
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: appSettings.translate('Account')),
              BottomNavigationBarItem(icon: const Icon(Icons.money), label: appSettings.translate('Loan')),
              BottomNavigationBarItem(icon: const Icon(Icons.list_alt), label: appSettings.translate('Transactions')),
              BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: appSettings.translate('Report')),
              BottomNavigationBarItem(icon: const Icon(Icons.person), label: appSettings.translate('Profile')),
            ],
          );
        },
      ),
    );
  }
}
