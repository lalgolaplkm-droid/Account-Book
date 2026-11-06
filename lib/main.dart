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
  String _language = 'English'; // Default Language strictly English
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
  int selectedMonthIndex = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  // Custom Date Range for Reports/Filtering
  DateTime? customStartDate;
  DateTime? customEndDate;

  List<String> categories = ['Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport'];
  
  List<AccountModel> accounts = [
    AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', isDefault: false),
    AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', isDefault: true),
    AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', isDefault: false),
    AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', isDefault: false),
    AccountModel(name: 'UCB Bank', type: 'Bank', details: 'A/C: ...4589', isDefault: false),
  ];

  String defaultCategory = 'Others';
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
        case 'Goals': return 'الأهداف';
        case 'Calculators': return 'الحاسبات';
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

  void setCustomDateRange(DateTime? start, DateTime? end) {
    customStartDate = start;
    customEndDate = end;
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
      transactions.sort((a, b) => b.date.compareTo(a.date));
    } else if (criteria.contains('Old-New')) {
      transactions.sort((a, b) => a.date.compareTo(b.date));
    } else if (criteria.contains('A-Z')) {
      transactions.sort((a, b) => a.category.compareTo(b.category));
    } else if (criteria.contains('Z-A')) {
      transactions.sort((a, b) => b.category.compareTo(a.category));
    } else if (criteria.contains('Number Large-Small')) {
      transactions.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (criteria.contains('Number Small-Large')) {
      transactions.sort((a, b) => a.amount.compareTo(b.amount));
    }
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

  double getNetBalance() {
    return getTotalGiven() - getTotalTaken();
  }

  void addAccount(String name, String type, String details) {
    if (name.isNotEmpty) {
      accounts.add(AccountModel(
        name: name,
        type: type,
        details: details.isEmpty ? (type == 'Cash' ? 'Hand Cash' : 'N/A') : details,
        isDefault: accounts.isEmpty,
      ));
      accounts.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  void updateAccount(int index, String name, String type, String details) {
    accounts[index].name = name;
    accounts[index].type = type;
    accounts[index].details = details;
    accounts.sort((a, b) => a.name.compareTo(b.name));
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
      bool wasDefault = accounts[index].isDefault;
      String deletedAccName = accounts[index].name;
      accounts.removeAt(index);
      if (wasDefault) {
        accounts[0].isDefault = true;
      }
      String defaultAccName = accounts.firstWhere((acc) => acc.isDefault, orElse: () => accounts[0]).name;
      for (var txn in transactions) {
        if (txn.account == deletedAccName) {
          txn.account = defaultAccName;
        }
      }
      accounts.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return true;
    }
    return false;
  }

  void addBudget(String category, double amount) {
    budgets.add(BudgetModel(category: category, amount: amount));
    budgets.sort((a, b) => a.category.compareTo(b.category));
    notifyListeners();
  }

  void updateBudget(int index, String category, double amount) {
    budgets[index] = BudgetModel(category: category, amount: amount);
    budgets.sort((b1, b2) => b1.category.compareTo(b2.category));
    notifyListeners();
  }

  void removeBudget(int index) {
    budgets.removeAt(index);
    notifyListeners();
  }

  void addSavings(String title, double target) {
    savingsList.add(SavingsModel(title: title, targetAmount: target, currentAmount: 0));
    savingsList.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }

  void updateSavings(int index, String title, double targetAmount) {
    savingsList[index].title = title;
    savingsList[index].targetAmount = targetAmount;
    savingsList.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }

  void removeSavings(int index) {
    savingsList.removeAt(index);
    notifyListeners();
  }

  void addCategory(String cat) {
    if (cat.isNotEmpty && !categories.contains(cat)) {
      categories.add(cat);
      categories.sort();
      notifyListeners();
    }
  }

  void updateCategory(int index, String newCat) {
    if (newCat.isNotEmpty) {
      categories[index] = newCat;
      categories.sort();
      notifyListeners();
    }
  }

  void removeCategory(int index) {
    if (categories.length > 1) {
      categories.removeAt(index);
      notifyListeners();
    }
  }

  void addShoppingItem(String name, double amount) {
    if (name.isNotEmpty) {
      shoppingList.add(ShoppingItem(name: name, amount: amount));
      shoppingList.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  void updateShoppingItem(int index, String name, double amount) {
    if (name.isNotEmpty) {
      shoppingList[index].name = name;
      shoppingList[index].amount = amount;
      shoppingList.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  void removeShoppingItem(int index) {
    shoppingList.removeAt(index);
    notifyListeners();
  }

  void toggleShoppingCheck(int index) {
    shoppingList[index].isChecked = !shoppingList[index].isChecked;
    if (shoppingList[index].isChecked && shoppingList[index].amount > 0) {
      String defaultAcc = accounts.firstWhere((acc) => acc.isDefault, orElse: () => accounts[0]).name;
      transactions.insert(0, TransactionItem(
        id: DateTime.now().toString(),
        type: 'Expense',
        account: defaultAcc,
        category: categories.first,
        amount: shoppingList[index].amount,
        description: 'Shopping: ${shoppingList[index].name}',
        date: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  void addReminder(String title, double amount, String dueDate) {
    if (title.isNotEmpty) {
      reminders.add(ReminderModel(title: title, amount: amount, dueDate: dueDate));
      reminders.sort((a, b) => a.title.compareTo(b.title));
      notifyListeners();
    }
  }

  void updateReminder(int index, String title, double amount, String dueDate) {
    reminders[index] = ReminderModel(title: title, amount: amount, dueDate: dueDate);
    reminders.sort((a, b) => a.title.compareTo(b.title));
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

// ----------------- Standard Menus & Helpers -----------------
void showStandardDownloadMenu(BuildContext context, Offset offset) {
  String lang = appSettings.language;
  String previewText = lang == 'Bangla' ? 'প্রিভিউ' : 'Preview';
  String pdfText = lang == 'Bangla' ? 'পিডিএফ ডাউনলোড' : 'Download as PDF';
  String excelText = lang == 'Bangla' ? 'এক্সেল ডাউনলোড' : 'Download as Excel';

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 20, 0),
    items: [
      PopupMenuItem(value: 'preview', child: Row(children: [const Icon(Icons.visibility, color: Colors.blue, size: 20), const SizedBox(width: 8), Text(previewText)])),
      PopupMenuItem(value: 'pdf', child: Row(children: [const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20), const SizedBox(width: 8), Text(pdfText)])),
      PopupMenuItem(value: 'excel', child: Row(children: [const Icon(Icons.table_chart, color: Colors.green, size: 20), const SizedBox(width: 8), Text(excelText)])),
    ],
  ).then((value) {
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report saved as $value successfully!')));
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

void showLocalizedDeleteDialog({
  required BuildContext context,
  required bool isImportant,
  required String itemName,
  required VoidCallback onDeleteConfirmed,
}) {
  String lang = appSettings.language;
  String title1 = lang == 'Bangla' ? 'নিশ্চিতকরণ' : 'Confirmation';
  String msg1 = lang == 'Bangla' ? 'আপনি কি আসলেই "$itemName" ডিলিট করতে চান?' : 'Are you sure you want to delete "$itemName"?';
  
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title1),
      content: Text(msg1),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(ctx);
            onDeleteConfirmed();
          },
          child: const Text('Yes', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ----------------- App Drawer Widget -----------------
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text(appSettings.translate('Theme')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(title: const Text('Dark'), value: ThemeMode.dark, groupValue: appSettings.themeMode, activeColor: const Color(0xFF10B981), onChanged: (val) { if (val != null) { appSettings.setTheme(val); setStateDialog(() {}); } }),
                  RadioListTile<ThemeMode>(title: const Text('Light'), value: ThemeMode.light, groupValue: appSettings.themeMode, activeColor: const Color(0xFF10B981), onChanged: (val) { if (val != null) { appSettings.setTheme(val); setStateDialog(() {}); } }),
                  RadioListTile<ThemeMode>(title: const Text('System Default'), value: ThemeMode.system, groupValue: appSettings.themeMode, activeColor: const Color(0xFF10B981), onChanged: (val) { if (val != null) { appSettings.setTheme(val); setStateDialog(() {}); } }),
                ],
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
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
                  RadioListTile<String>(title: const Text('Arabic (العربية)'), value: 'Arabic', groupValue: appSettings.language, activeColor: const Color(0xFF10B981), onChanged: (val) { if (val != null) { appSettings.setLanguage(val); setStateDialog(() {}); } }),
                  RadioListTile<String>(title: const Text('Bangla (বাংলা)'), value: 'Bangla', groupValue: appSettings.language, activeColor: const Color(0xFF10B981), onChanged: (val) { if (val != null) { appSettings.setLanguage(val); setStateDialog(() {}); } }),
                  RadioListTile<String>(title: const Text('English'), value: 'English', groupValue: appSettings.language, activeColor: const Color(0xFF10B981), onChanged: (val) { if (val != null) { appSettings.setLanguage(val); setStateDialog(() {}); } }),
                ],
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
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
      builder: (context, _) => Drawer(
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
            ListTile(leading: const Icon(Icons.palette), title: Text(appSettings.translate('Theme')), onTap: () { Navigator.pop(context); _showThemeDialog(context); }),
            ListTile(leading: const Icon(Icons.language), title: Text(appSettings.translate('Language')), onTap: () { Navigator.pop(context); _showLanguageDialog(context); }),
          ],
        ),
      ),
    );
  }
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

  void _showForgotPinDialog(BuildContext context) {
    final TextEditingController identifierController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();
    bool obscureNewPin = true;
    bool obscureConfirmPin = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Forgot PIN'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Enter your registered Email, Birth Date (DD-MM-YYYY), or Mobile Number to verify your identity.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 16),
                    TextField(controller: identifierController, decoration: const InputDecoration(labelText: 'Email / Birth Date / Mobile', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: obscureNewPin,
                      decoration: InputDecoration(
                        labelText: 'New 4-Digit PIN',
                        border: const OutlineInputBorder(),
                        counterText: '',
                        suffixIcon: IconButton(
                          icon: Icon(obscureNewPin ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setStateDialog(() => obscureNewPin = !obscureNewPin),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: obscureConfirmPin,
                      decoration: InputDecoration(
                        labelText: 'Re-Type 4-Digit PIN',
                        border: const OutlineInputBorder(),
                        counterText: '',
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirmPin ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setStateDialog(() => obscureConfirmPin = !obscureConfirmPin),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    String input = identifierController.text.trim();
                    bool isValidUser = input == appSettings.profileEmail || input == appSettings.profileBirthDate || input == appSettings.profileMobile;

                    if (!isValidUser) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Information does not match!'), backgroundColor: Colors.red));
                      return;
                    }

                    if (newPinController.text.length != 4 || newPinController.text != confirmPinController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: PIN must be 4 digits and match!'), backgroundColor: Colors.red));
                      return;
                    }

                    appSettings.updatePin(newPinController.text);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN successfully updated')));
                    setState(() {});
                  },
                  child: const Text('Reset'),
                ),
              ],
            );
          },
        );
      },
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
                        width: 55,
                        height: 55,
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
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _showForgotPinDialog(context),
                child: const Text('Forgot PIN?', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- Home Screen Content -----------------
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  void _showAddTransactionDialog(BuildContext context) {
    String transactionType = 'Expense';
    String selectedCategory = appSettings.categories[0];
    String selectedAccount = appSettings.accounts.firstWhere((acc) => acc.isDefault, orElse: () => appSettings.accounts[0]).name;
    
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descController = TextEditingController();

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
                    const Text('Add New Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Income' ? Colors.green : const Color(0xFF1E293B)),
                            onPressed: () => setStateModal(() => transactionType = 'Income'),
                            child: const Text('Cash In'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Expense' ? Colors.red : const Color(0xFF1E293B)),
                            onPressed: () => setStateModal(() => transactionType = 'Expense'),
                            child: const Text('Cash Out'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedAccount,
                      dropdownColor: Theme.of(context).cardColor,
                      decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
                      items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text(appSettings.translate(acc.name)))).toList(),
                      onChanged: (val) { if (val != null) setStateModal(() => selectedAccount = val); },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: Theme.of(context).cardColor,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: appSettings.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(appSettings.translate(cat)))).toList(),
                      onChanged: (val) { if (val != null) setStateModal(() => selectedCategory = val); },
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
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

  Widget _buildQuickAccessIcon(BuildContext context, IconData icon, String label, Widget targetScreen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: const Color(0xFF10B981), size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
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
          appBar: AppBar(title: Text(appSettings.getAppTitle(), style: const TextStyle(fontWeight: FontWeight.bold))),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
                          Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${appSettings.getTotalBalance()}$curr', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.grey)),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appSettings.translate('Income'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('${appSettings.getTotalIncome()}$curr', style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appSettings.translate('Expense'), style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('${appSettings.getTotalExpense()}$curr', style: const TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(appSettings.translate('Quick Access'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAccessIcon(context, Icons.account_balance_wallet, appSettings.translate('Account'), const AccountsScreen()),
                    _buildQuickAccessIcon(context, Icons.track_changes, appSettings.translate('Budget'), const BudgetScreen()),
                    _buildQuickAccessIcon(context, Icons.category, appSettings.translate('Categories'), const CategoriesScreen()),
                    _buildQuickAccessIcon(context, Icons.notifications_active, appSettings.translate('Reminder'), const RemindersScreen()),
                    _buildQuickAccessIcon(context, Icons.repeat, appSettings.translate('Repeat'), const RepeatedTransactionsScreen()),
                    _buildQuickAccessIcon(context, Icons.savings, appSettings.translate('Savings'), const SavingsScreen()),
                    _buildQuickAccessIcon(context, Icons.shopping_cart, appSettings.translate('Shopping'), const FundShoppingScreen()),
                  ],
                ),
                const SizedBox(height: 24),
                Text(appSettings.translate('Recent Transactions'), style: const TextStyle(
