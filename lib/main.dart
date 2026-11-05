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
  String _language = 'English'; // Default Language English
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
        case 'Goals': return 'লক্ষ্য';
        case 'Settings': return 'সেটিংস';
        case 'Financial Calculators': return 'ফাইন্যান্সিয়াল ক্যালকুলেটর';
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
        case 'Settings': return 'الإعدادات';
        case 'Financial Calculators': return 'الآلات الحاسبة المالية';
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
    budgets.sort((a, b) => a.category.compareTo(b.category));
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

  void addRepeatedTransaction(String title, double amount, String frequency) {
    if (title.isNotEmpty) {
      repeatedTransactions.add(RepeatedTransactionModel(title: title, amount: amount, frequency: frequency));
      repeatedTransactions.sort((a, b) => a.title.compareTo(b.title));
      notifyListeners();
    }
  }

  void updateRepeatedTransaction(int index, String title, double amount, String frequency) {
    repeatedTransactions[index] = RepeatedTransactionModel(title: title, amount: amount, frequency: frequency);
    repeatedTransactions.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }

  void removeRepeatedTransaction(int index) {
    repeatedTransactions.removeAt(index);
    notifyListeners();
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
            primaryColor: const Color(0xFF0284C7),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black87),
            dialogTheme: const DialogTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
            bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
            textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black87), bodyMedium: TextStyle(color: Colors.black87)),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF10B981),
            cardColor: const Color(0xFF1E293B),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white),
            dialogTheme: const DialogTheme(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
            bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
            textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white), bodyMedium: TextStyle(color: Colors.white70)),
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
  String previewText = lang == 'Bangla' ? 'প্রিভিউ' : (lang == 'Arabic' ? 'معاينة' : 'Preview');
  String pdfText = lang == 'Bangla' ? 'পিডিএফ ডাউনলোড' : (lang == 'Arabic' ? 'تحميل كـ PDF' : 'Download as PDF');
  String excelText = lang == 'Bangla' ? 'এক্সেল ডাউনলোড' : (lang == 'Arabic' ? 'تحميل كـ Excel' : 'Download as Excel');

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 20, 0),
    items: [
      PopupMenuItem(
        value: 'preview',
        child: Row(
          children: [
            const Icon(Icons.visibility, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(previewText),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'pdf',
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(pdfText),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'excel',
        child: Row(
          children: [
            const Icon(Icons.table_chart, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(excelText),
          ],
        ),
      ),
    ],
  ).then((value) {
    if (value != null) {
      if (value == 'preview') {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(lang == 'Bangla' ? 'রিপোর্ট প্রিভিউ' : (lang == 'Arabic' ? 'معاينة التقرير' : 'Report Preview')),
            content: Text(lang == 'Bangla' ? 'এখানে আপনার বর্তমান হিসাবের সংক্ষিপ্ত প্রিভিউ দেখানো হচ্ছে।' : (lang == 'Arabic' ? 'هذا معاينة موجزة لحسابك الحالي.' : 'Here is a preview of your financial summary.')),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      } else {
        String formatType = value.toUpperCase();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved to device storage as $formatType successfully!')),
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
    if (value != null) {
      onSelected(value);
    }
  });
}

void showLocalizedDeleteDialog({
  required BuildContext context,
  required bool isImportant,
  required String itemName,
  required VoidCallback onDeleteConfirmed,
}) {
  String lang = appSettings.language;
  String title1 = lang == 'Bangla' ? 'নিশ্চিতকরণ' : (lang == 'Arabic' ? 'تأكيد' : 'Confirmation');
  String msg1 = lang == 'Bangla' ? 'আপনি কি আসলেই "$itemName" ডিলিট করতে চান?' : 'Are you sure you want to delete "$itemName"?';
  String warningMsg = lang == 'Bangla' ? 'সতর্কতা: এটি অন্য কোনো রেকর্ডের সাথে জড়িত। নিশ্চিত?' : 'Warning: This is linked with other records. Are you sure?';
  String yesText = lang == 'Bangla' ? 'হ্যাঁ' : 'Yes';
  String noText = lang == 'Bangla' ? 'না' : 'No';

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title1),
      content: Text(isImportant ? warningMsg : msg1),
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

// ----------------- Financial Calculators Hub -----------------
class FinancialCalculatorsHub extends StatelessWidget {
  const FinancialCalculatorsHub({super.key});

  Widget _calcTile(BuildContext context, String title, Widget screen) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Financial Calculators")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _calcTile(context, "General Calculator", const GeneralCalculatorScreen()),
          _calcTile(context, "EMI Calculator", const EmiCalculatorScreen()),
          _calcTile(context, "Interest Calculator", const InterestCalculatorScreen()),
          _calcTile(context, "SIP Calculator", const SipCalculatorScreen()),
          _calcTile(context, "Tax Calculator", const TaxCalculatorScreen()),
        ],
      ),
    );
  }
}

class GeneralCalculatorScreen extends StatefulWidget {
  const GeneralCalculatorScreen({super.key});
  @override
  State<GeneralCalculatorScreen> createState() => _GeneralCalculatorScreenState();
}

class _GeneralCalculatorScreenState extends State<GeneralCalculatorScreen> {
  String _output = "0";
  
  void _buttonPressed(String val) {
    setState(() {
      if (_output == "0") {
        _output = val;
      } else {
        _output += val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("General Calculator")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(_output, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ),
          ),
          // Left side minus (-), Right side plus (+)
          Row(children: [_btn("-"), _btn("7"), _btn("8"), _btn("9"), _btn("+")]),
          Row(children: [_btn("-"), _btn("4"), _btn("5"), _btn("6"), _btn("+")]),
          Row(children: [_btn("0"), _btn("C"), _btn("=")]),
        ],
      ),
    );
  }

  Widget _btn(String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          if (label == "C") {
            setState(() => _output = "0");
          } else {
            _buttonPressed(label);
          }
        },
        child: Text(label, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class SipCalculatorScreen extends StatelessWidget {
  const SipCalculatorScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('SIP Calculator')), body: const Center(child: Text('SIP Calculator Module')));
}

class EmiCalculatorScreen extends StatelessWidget {
  const EmiCalculatorScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('EMI Calculator')), body: const Center(child: Text('EMI Calculator Module')));
}

class InterestCalculatorScreen extends StatelessWidget {
  const InterestCalculatorScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Interest Calculator')), body: const Center(child: Text('Interest Calculator Module')));
}

class TaxCalculatorScreen extends StatelessWidget {
  const TaxCalculatorScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Tax Calculator')), body: const Center(child: Text('Tax Calculator Module')));
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Goals')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appSettings.savingsList.length,
        itemBuilder: (context, index) {
          final goal = appSettings.savingsList[index];
          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.track_changes, color: Color(0xFF10B981)),
              title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Target: ${goal.targetAmount} | Saved: ${goal.currentAmount}'),
            ),
          );
        },
      ),
    );
  }
}

// ----------------- Dashboard Analytics Screen -----------------
class DashboardAnalyticsScreen extends StatelessWidget {
  const DashboardAnalyticsScreen({super.key});

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
            const Text('Financial Overview Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Balance', style: TextStyle(color: Colors.grey)),
                      Text('$balance $curr', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: balance >= 0 ? const Color(0xFF10B981) : Colors.redAccent)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Income', style: TextStyle(color: Colors.grey)),
                      Text('$income $curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Expense', style: TextStyle(color: Colors.grey)),
                      Text('$expense $curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- App Drawer Widget (Alphabetically Sorted Languages) -----------------
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
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: appSettings.themeMode,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setTheme(val);
                        setStateDialog(() {});
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: appSettings.themeMode,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setTheme(val);
                        setStateDialog(() {});
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    value: ThemeMode.system,
                    groupValue: appSettings.themeMode,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setTheme(val);
                        setStateDialog(() {});
                      }
                    },
                  ),
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
                  // Alphabetically sorted language items
                  RadioListTile<String>(
                    title: const Text('Arabic (العربية)'),
                    value: 'Arabic',
                    groupValue: appSettings.language,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setLanguage(val);
                        setStateDialog(() {});
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
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'English',
                    groupValue: appSettings.language,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setLanguage(val);
                        setStateDialog(() {});
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('System Default'),
                    value: 'System Default',
                    groupValue: appSettings.language,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setLanguage('English');
                        setStateDialog(() {});
                      }
                    },
                  ),
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
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardAnalyticsScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: Text(appSettings.translate('Goals')),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: Text(appSettings.translate('Financial Calculators')),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialCalculatorsHub())); },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(appSettings.translate('Categories')),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: Text(appSettings.translate('Accounts')),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountsScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(appSettings.translate('Settings')),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(appSettings.translate('Theme')),
            onTap: () { Navigator.pop(context); _showThemeDialog(context); },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(appSettings.translate('Language')),
            onTap: () { Navigator.pop(context); _showLanguageDialog(context); },
          ),
        ],
      ),
    );
  }
}

// ----------------- Quick Access & Sub Screens -----------------
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}
class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Accounts'))),
      body: ListView.builder(
        itemCount: appSettings.accounts.length,
        itemBuilder: (context, index) {
          final acc = appSettings.accounts[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(acc.name),
              subtitle: Text(acc.type),
            ),
          );
        },
      ),
    );
  }
}

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Budget')), body: const Center(child: Text('Budget Module')));
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Categories')), body: const Center(child: Text('Categories Module')));
}

class FundShoppingScreen extends StatelessWidget {
  const FundShoppingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Shopping')), body: const Center(child: Text('Shopping Module')));
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Reminder')), body: const Center(child: Text('Reminder Module')));
}

class RepeatedTransactionsScreen extends StatelessWidget {
  const RepeatedTransactionsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Repeat')), body: const Center(child: Text('Repeat Module')));
}

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Savings')), body: const Center(child: Text('Savings Module')));
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong PIN!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 70, color: Color(0xFF10B981)),
              const SizedBox(height: 24),
              const Text('Enter Your PIN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
                onChanged: (val) { if (val.length == 4) _verifyPin(context); },
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
                  Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
                _buildQuickAccessIcon(context, Icons.account_balance_wallet, appSettings.translate('Account'), const AccountsScreen()),
                _buildQuickAccessIcon(context, Icons.track_changes, appSettings.translate('Budget'), const BudgetScreen()),
                _buildQuickAccessIcon(context, Icons.category, appSettings.translate('Categories'), const CategoriesScreen()),
                _buildQuickAccessIcon(context, Icons.savings, appSettings.translate('Savings'), const SavingsScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Profile & Settings Screen -----------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showEditProfileDialog(BuildContext context) {
    final nameC = TextEditingController(text: appSettings.profileName);
    final emailC = TextEditingController(text: appSettings.profileEmail);
    String selectedGender = appSettings.profileGender;
    final birthDateC = TextEditingController(text: appSettings.profileBirthDate);
    final mobileC = TextEditingController(text: appSettings.profileMobile);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                  items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) { if (val != null) setStateDialog(() => selectedGender = val); },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: birthDateC,
                  decoration: const InputDecoration(labelText: 'Birth Date (DD-MM-YYYY)', border: OutlineInputBorder()),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1995, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      birthDateC.text = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: mobileC, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                appSettings.updateProfile(name: nameC.text, email: emailC.text, gender: selectedGender, birthDate: birthDateC.text, mobile: mobileC.text);
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: appSettings.profileImagePath.isNotEmpty ? FileImage(File(appSettings.profileImagePath)) : null,
                  child: appSettings.profileImagePath.isEmpty ? const Icon(Icons.person, size: 45, color: Color(0xFF10B981)) : null,
                ),
                const SizedBox(height: 12),
                Text(appSettings.profileName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(appSettings.profileEmail, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => _showEditProfileDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_none, color: Color(0xFF10B981)),
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Notification Sound'),
                    content: DropdownButtonFormField<String>(
                      value: appSettings.notificationSound,
                      items: ['Default', 'App Chime', 'Custom from Device Memory'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) { if (val != null) appSettings.setNotificationSound(val); },
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
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
      const Scaffold(body: Center(child: Text('Loan Screen'))),
      const Scaffold(body: Center(child: Text('Transactions Screen'))),
      const Scaffold(body: Center(child: Text('Reports Screen'))),
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
            backgroundColor: Theme.of(context).cardColor,
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
