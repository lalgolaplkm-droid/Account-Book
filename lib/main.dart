Import 'package:flutter/material.dart';
Import 'package:shared_preferences/shared_preferences.dart';
Import 'package:image_picker/image_picker.dart';
Import 'dart:io';

Void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.initPrefs();
  RunApp(const AccountBookApp());
}

// ----------------- Models -----------------
class TransactionItem {
  final String id;
  Final String type;
  String account;
  String category;
  Double amount;
  String description;
  DateTime date;

  TransactionItem({
    Required this.id,
    Required this.type,
    Required this.account,
    Required this.category,
    Required this.amount,
    Required this.description,
    Required this.date,
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

  Factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
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
  Double amount;
  String type;
  DateTime date;
  Bool isPaid;

  LoanItem({
    Required this.id,
    Required this.personName,
    Required this.amount,
    Required this.type,
    Required this.date,
    This.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'personName': personName,
    'amount': amount,
    'type': type,
    'date': date.toIso8601String(),
    'isPaid': isPaid,
  };

  Factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
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
  Double amount;
  Bool isChecked;
  ShoppingItem({required this.name, this.amount = 0.0, this.isChecked = false});

  Map<String, dynamic> toJson() => {'name': name, 'amount': amount, 'isChecked': isChecked};
  Factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(name: json['name'], amount: json['amount'], isChecked: json['isChecked']);
}

class BudgetModel {
  String category;
  Double amount;
  BudgetModel({required this.category, required this.amount});

  Map<String, dynamic> toJson() => {'category': category, 'amount': amount};
  Factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(category: json['category'], amount: json['amount']);
}

class SavingsModel {
  String title;
  Double targetAmount;
  Double currentAmount;
  Bool isCompleted;
  SavingsModel({required this.title, required this.targetAmount, required this.currentAmount, this.isCompleted = false});

  Map<String, dynamic> toJson() => {'title': title, 'targetAmount': targetAmount, 'currentAmount': currentAmount, 'isCompleted': isCompleted};
  Factory SavingsModel.fromJson(Map<String, dynamic> json) => SavingsModel(title: json['title'], targetAmount: json['targetAmount'], currentAmount: json['currentAmount'], isCompleted: json['isCompleted']);
}

class AccountModel {
  String name;
  String type;
  String details;
  Bool isDefault;

  AccountModel({
    Required this.name,
    Required this.type,
    Required this.details,
    This.isDefault = false,
  });

  Map<String, dynamic> toJson() => {'name': name, 'type': type, 'details': details, 'isDefault': isDefault};
  Factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(name: json['name'], type: json['type'], details: json['details'], isDefault: json['isDefault']);
}

class RepeatedTransactionModel {
  String title;
  Double amount;
  String frequency;
  RepeatedTransactionModel({required this.title, required this.amount, required this.frequency});

  Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'frequency': frequency};
  Factory RepeatedTransactionModel.fromJson(Map<String, dynamic> json) => RepeatedTransactionModel(title: json['title'], amount: json['amount'], frequency: json['frequency']);
}

class ReminderModel {
  String title;
  Double amount;
  String dueDate;
  ReminderModel({required this.title, required this.amount, required this.dueDate});

  Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'dueDate': dueDate};
  Factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(title: json['title'], amount: json['amount'], dueDate: json['dueDate']);
}

// ----------------- State Management with Persistent Storage -----------------
class AppSettingsNotifier extends ChangeNotifier {
  Late SharedPreferences _prefs;

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

  Bool useFaceLock = false;
  Bool useFingerprint = false;
  Bool useNoneLock = false;
  Bool usePatternLock = false;
  Bool usePinLock = true;

  Bool dailyReminder = true;
  Bool budgetAlert = true;
  Bool loanAlert = true;
  String notificationSound = 'Default';

  // Selected Month & Year for Home and Reports
  Int selectedMonthIndex = DateTime.now().month;
  Int selectedYear = DateTime.now().year;

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
  Double monthlyBudget = 15000.0;

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
      Switch (key) {
        Case 'Account Book': return 'হিসাবের খাতা';
        Case 'Dashboard Analytics': return 'ড্যাশবোর্ড অ্যানালিটিক্স';
        Case 'Categories': return 'ক্যাটাগরি সমূহ';
        Case 'Accounts': return 'অ্যাকাউন্ট সমূহ';
        Case 'Theme': return 'থিম';
        Case 'Language': return 'ভাষা';
        Case 'About App': return 'অ্যাপ সম্পর্কে';
        Case 'Current Balance': return 'বর্তমান ব্যালেন্স';
        Case 'Month': return 'মাস';
        Case 'Year': return 'বছর';
        Case 'Income': return 'আয়';
        Case 'Expense': return 'ব্যয়';
        Case 'Quick Access': return 'কুইক এক্সেস';
        Case 'Recent Transactions': return 'সাম্প্রতিক লেনদেন';
        Case 'Budget': return 'বাজেট';
        Case 'Reminder': return 'রিমাইন্ডার';
        Case 'Repeat': return 'রিপিট';
        Case 'Savings': return 'সেভিংস';
        Case 'Shopping': return 'শপিং';
        Case 'Account': return 'হিসাব';
        Case 'Loan': return 'লোন';
        Case 'Transactions': return 'লেনদেন';
        Case 'Report': return 'রিপোর্ট';
        Case 'Profile': return 'প্রোফাইল';
        Case 'Grocery': return 'মুদি বাজার';
        Case 'Others': return 'অন্যান্য';
        Case 'Salary': return 'বেতন';
        Case 'Tea & Snacks': return 'চা ও নাস্তা';
        Case 'Transport': return 'যাতায়াত';
        Case 'Food & Hotel': return 'খাবার ও হোটেল';
        Case 'Bikash': return 'বিকাশ';
        Case 'Cash in Hand': return 'হাতে নগদ টাকা';
        Case 'Dutch-Bangla Bank': return 'ডাচ-বাংলা ব্যাংক';
        Case 'Nagad': return 'নগদ';
        Case 'UCB Bank': return 'ইউসিবি ব্যাংক';
        Case 'Mobile Banking': return 'মোবাইল ব্যাংকিং';
        Case 'Cash': return 'নগদ';
        Case 'Bank': return 'ব্যাংক';
        Case 'Settings': return 'সেটিংস';
        Case 'Goals': return 'লক্ষ্য';
        Case 'Calculators': return 'ক্যালকুলেটর হাব';
        Default: return key;
      }
    } else if (_language == 'Arabic') {
      Switch (key) {
        Case 'Account Book': return 'دفتر الحسابات';
        Case 'Dashboard Analytics': return 'تحليلات لوحة القيادة';
        Case 'Categories': return 'الفئات';
        Case 'Accounts': return 'الحسابات';
        Case 'Theme': return 'المظهر';
        Case 'Language': return 'اللغة';
        Case 'About App': return 'حول التطبيق';
        Case 'Current Balance': return 'الرصيد الحالي';
        Case 'Month': return 'شهر';
        Case 'Year': return 'سنة';
        Case 'Income': return 'إيرادات';
        Case 'Expense': return 'مصروفات';
        Case 'Quick Access': return 'وصول سريع';
        Case 'Recent Transactions': return 'المعاملات الأخيرة';
        Case 'Budget': return 'الميزانية';
        Case 'Reminder': return 'التذكيرات';
        Case 'Repeat': return 'متكرر';
        Case 'Savings': return 'المدخرات';
        Case 'Shopping': return 'التسوق';
        Case 'Account': return 'حساب';
        Case 'Loan': return 'قرض';
        Case 'Transactions': return 'المعاملات';
        Case 'Report': return 'تقرير';
        Case 'Profile': return 'الملف الشخصي';
        Case 'Grocery': return 'بقالة';
        Case 'Others': return 'أخرى';
        Case 'Salary': return 'راتب';
        Case 'Tea & Snacks': return 'شاي ووجبات خفيفة';
        Case 'Transport': return 'مواصلات';
        Case 'Food & Hotel': return 'طعام وفنادق';
        Case 'Bikash': return 'ب বিকাশ';
        Case 'Cash in Hand': return 'نقداً في اليد';
        Case 'Dutch-Bangla Bank': return 'بنك دتش بنگلا';
        Case 'Nagad': return 'نقد';
        Case 'UCB Bank': return 'بنك UCB';
        Case 'Mobile Banking': return 'خدمات مصرفية عبر الهاتف المحمول';
        Case 'Cash': return 'نقدي';
        Case 'Bank': return 'بنك';
        Case 'Settings': return 'الإعدادات';
        Case 'Goals': return 'الأهداف';
        Case 'Calculators': return 'الحاسبات';
        Default: return key;
      }
    }
    Return key;
  }

  Void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs();
    NotifyListeners();
  }

  Void setLanguage(String lang) {
    _language = lang;
    _saveToPrefs();
    NotifyListeners();
  }

  Void setTimeFilter(String filter) {
    timeFilter = filter;
    NotifyListeners();
  }

  Void setMonthYear(int month, int year) {
    selectedMonthIndex = month;
    selectedYear = year;
    NotifyListeners();
  }

  Void setCustomDateRange(DateTime? start, DateTime? end) {
    customStartDate = start;
    customEndDate = end;
    NotifyListeners();
  }

  Void setCurrency(String newCurrency) {
    currency = newCurrency;
    NotifyListeners();
  }

  Void updatePin(String newPin) {
    appPin = newPin;
    _saveToPrefs();
    NotifyListeners();
  }

  Void updateProfile({required String name, required String email, required String gender, required String birthDate, required String mobile, String? imagePath}) {
    profileName = name;
    profileEmail = email;
    profileGender = gender;
    profileBirthDate = birthDate;
    profileMobile = mobile;
    If (imagePath != null) profileImagePath = imagePath;
    _saveToPrefs();
    NotifyListeners();
  }

  Void updateSecurityToggles({required bool face, required bool fingerprint, required bool none, required bool pattern, required bool pin}) {
    useFaceLock = face;
    useFingerprint = fingerprint;
    useNoneLock = none;
    usePatternLock = pattern;
    usePinLock = pin;
    NotifyListeners();
  }

  Void toggleNotification(String key, bool val) {
    If (key == 'daily') dailyReminder = val;
    If (key == 'budget') budgetAlert = val;
    If (key == 'loan') loanAlert = val;
    NotifyListeners();
  }

  Void setNotificationSound(String sound) {
    notificationSound = sound;
    NotifyListeners();
  }

  Void addTransaction(TransactionItem txn) {
    transactions.insert(0, txn);
    NotifyListeners();
  }

  Void updateTransaction(int index, TransactionItem txn) {
    transactions[index] = txn;
    NotifyListeners();
  }

  Void removeTransaction(int index) {
    transactions.removeAt(index);
    NotifyListeners();
  }

  Void addLoan(LoanItem loan) {
    loans.insert(0, loan);
    NotifyListeners();
  }

  Void updateLoan(int index, String personName, double amount, String type) {
    Loans[index].personName = personName;
    Loans[index].amount = amount;
    Loans[index].type = type;
    NotifyListeners();
  }

  Void removeLoan(int index) {
    loans.removeAt(index);
    NotifyListeners();
  }

  Void toggleLoanStatus(String id) {
    For (var loan in loans) {
      If (loan.id == id) {
        Loan.isPaid = !loan.isPaid;
        NotifyListeners();
        Break;
      }
    }
  }

  Void sortLoans(String criteria) {
    If (criteria.contains('New-Old')) {
      Loans.sort((a, b) => b.date.compareTo(a.date));
    } else if (criteria.contains('Old-New')) {
      Loans.sort((a, b) => a.date.compareTo(b.date));
    } else if (criteria.contains('A-Z')) {
      Loans.sort((a, b) => a.personName.compareTo(b.personName));
    } else if (criteria.contains('Z-A')) {
      Loans.sort((a, b) => b.personName.compareTo(a.personName));
    } else if (criteria.contains('Large-Small')) {
      Loans.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (criteria.contains('Small-Large')) {
      Loans.sort((a, b) => a.amount.compareTo(b.amount));
    }
    NotifyListeners();
  }

  Void sortTransactions(String criteria) {
    If (criteria.contains('New-Old')) {
      Transactions.sort((a, b) => b.date.compareTo(a.date));
    } else if (criteria.contains('Old-New')) {
      Transactions.sort((a, b) => a.date.compareTo(b.date));
    } else if (criteria.contains('A-Z')) {
      Transactions.sort((a, b) => a.category.compareTo(b.category));
    } else if (criteria.contains('Z-A')) {
      Transactions.sort((a, b) => b.category.compareTo(a.category));
    } else if (criteria.contains('Number Large-Small')) {
      Transactions.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (criteria.contains('Number Small-Large')) {
      Transactions.sort((a, b) => a.amount.compareTo(b.amount));
    }
    NotifyListeners();
  }

  List<TransactionItem> getFilteredTransactions() {
    Return transactions.where((txn) {
      If (timeFilter == 'Custom Range' && customStartDate != null && customEndDate != null) {
        Return txn.date.isAfter(customStartDate!.subtract(const Duration(days: 1))) &&
               Txn.date.isBefore(customEndDate!.add(const Duration(days: 1)));
      }
      Return txn.date.year == selectedYear && txn.date.month == selectedMonthIndex;
    }).toList();
  }

  Double getTotalIncome() {
    Double total = 0;
    For (var txn in getFilteredTransactions()) {
      If (txn.type == 'Income') total += txn.amount;
    }
    Return total;
  }

  Double getTotalExpense() {
    Double total = 0;
    For (var txn in getFilteredTransactions()) {
      If (txn.type == 'Expense') total += txn.amount;
    }
    Return total;
  }

  Double getTotalBalance() {
    Return getTotalIncome() - getTotalExpense();
  }

  Double getTotalGiven() {
    Double total = 0;
    For (var loan in loans) {
      If (loan.type == 'Given' && !loan.isPaid) total += loan.amount;
    }
    Return total;
  }

  Double getTotalTaken() {
    Double total = 0;
    For (var loan in loans) {
      If (loan.type == 'Taken' && !loan.isPaid) total += loan.amount;
    }
    Return total;
  }

  Double getNetBalance() {
    Return getTotalGiven() - getTotalTaken();
  }

  Void addAccount(String name, String type, String details) {
    If (name.isNotEmpty) {
      Accounts.add(AccountModel(
        Name: name,
        Type: type,
        Details: details.isEmpty ? (type == 'Cash' ? 'Hand Cash' : 'N/A') : details,
        IsDefault: accounts.isEmpty,
      ));
      Accounts.sort((a, b) => a.name.compareTo(b.name));
      NotifyListeners();
    }
  }

  Void updateAccount(int index, String name, String type, String details) {
    Accounts[index].name = name;
    Accounts[index].type = type;
    Accounts[index].details = details;
    Accounts.sort((a, b) => a.name.compareTo(b.name));
    NotifyListeners();
  }

  Void setDefaultAccount(int index) {
    For (int i = 0; i < accounts.length; i++) {
      Accounts[i].isDefault = (i == index);
    }
    NotifyListeners();
  }

  Bool removeAccount(int index) {
    If (accounts.length > 1) {
      Bool wasDefault = accounts[index].isDefault;
      String deletedAccName = accounts[index].name;
      Accounts.removeAt(index);
      If (wasDefault) {
        Accounts[0].isDefault = true;
      }
      String defaultAccName = accounts.firstWhere((acc) => acc.isDefault, orElse: () => accounts[0]).name;
      For (var txn in transactions) {
        If (txn.account == deletedAccName) {
          Txn.account = defaultAccName;
        }
      }
      Accounts.sort((a, b) => a.name.compareTo(b.name));
      NotifyListeners();
      Return true;
    }
    Return false;
  }

  Void addBudget(String category, double amount) {
    Budgets.add(BudgetModel(category: category, amount: amount));
    Budgets.sort((a, b) => a.category.compareTo(b.category));
    NotifyListeners();
  }

  Void updateBudget(int index, String category, double amount) {
    Budgets[index] = BudgetModel(category: category, amount: amount);
    Budgets.sort((a, b) => a.category.compareTo(b.category));
    NotifyListeners();
  }

  Void removeBudget(int index) {
    Budgets.removeAt(index);
    NotifyListeners();
  }

  Void addSavings(String title, double target) {
    SavingsList.add(SavingsModel(title: title, targetAmount: target, currentAmount: 0));
    SavingsList.sort((a, b) => a.title.compareTo(b.title));
    NotifyListeners();
  }

  Void updateSavings(int index, String title, double targetAmount) {
    SavingsList[index].title = title;
    SavingsList[index].targetAmount = targetAmount;
    SavingsList.sort((a, b) => a.title.compareTo(b.title));
    NotifyListeners();
  }

  Void removeSavings(int index) {
    SavingsList.removeAt(index);
    NotifyListeners();
  }

  Void addCategory(String cat) {
    If (cat.isNotEmpty && !categories.contains(cat)) {
      Categories.add(cat);
      Categories.sort();
      NotifyListeners();
    }
  }

  Void updateCategory(int index, String newCat) {
    If (newCat.isNotEmpty) {
      Categories[index] = newCat;
      Categories.sort();
      NotifyListeners();
    }
  }

  Void removeCategory(int index) {
    If (categories.length > 1) {
      Categories.removeAt(index);
      NotifyListeners();
    }
  }

  Void addRepeatedTransaction(String title, double amount, String frequency) {
    If (title.isNotEmpty) {
      RepeatedTransactions.add(RepeatedTransactionModel(title: title, amount: amount, frequency: frequency));
      RepeatedTransactions.sort((a, b) => a.title.compareTo(b.title));
      NotifyListeners();
    }
  }

  Void updateRepeatedTransaction(int index, String title, double amount, String frequency) {
    RepeatedTransactions[index] = RepeatedTransactionModel(title: title, amount: amount, frequency: frequency);
    RepeatedTransactions.sort((a, b) => a.title.compareTo(b.title));
    NotifyListeners();
  }

  Void removeRepeatedTransaction(int index) {
    RepeatedTransactions.removeAt(index);
    NotifyListeners();
  }

  Void addShoppingItem(String name, double amount) {
    If (name.isNotEmpty) {
      ShoppingList.add(ShoppingItem(name: name, amount: amount));
      ShoppingList.sort((a, b) => a.name.compareTo(b.name));
      NotifyListeners();
    }
  }

  Void updateShoppingItem(int index, String name, double amount) {
    If (name.isNotEmpty) {
      ShoppingList[index].name = name;
      ShoppingList[index].amount = amount;
      ShoppingList.sort((a, b) => a.name.compareTo(b.name));
      NotifyListeners();
    }
  }

  Void removeShoppingItem(int index) {
    ShoppingList.removeAt(index);
    NotifyListeners();
  }

  Void toggleShoppingCheck(int index) {
    ShoppingList[index].isChecked = !shoppingList[index].isChecked;
    If (shoppingList[index].isChecked && shoppingList[index].amount > 0) {
      String defaultAcc = accounts.firstWhere((acc) => acc.isDefault, orElse: () => accounts[0]).name;
      Transactions.insert(0, TransactionItem(
        Id: DateTime.now().toString(),
        Type: 'Expense',
        Account: defaultAcc,
        Category: categories.first,
        Amount: shoppingList[index].amount,
        Description: 'Shopping: ${shoppingList[index].name}',
        Date: DateTime.now(),
      ));
    }
    NotifyListeners();
  }

  Void addReminder(String title, double amount, String dueDate) {
    If (title.isNotEmpty) {
      Reminders.add(ReminderModel(title: title, amount: amount, dueDate: dueDate));
      Reminders.sort((a, b) => a.title.compareTo(b.title));
      NotifyListeners();
    }
  }

  Void updateReminder(int index, String title, double amount, String dueDate) {
    Reminders[index] = ReminderModel(title: title, amount: amount, dueDate: dueDate);
    Reminders.sort((a, b) => a.title.compareTo(b.title));
    NotifyListeners();
  }

  Void removeReminder(int index) {
    Reminders.removeAt(index);
    NotifyListeners();
  }
}

Final appSettings = AppSettingsNotifier();

// ----------------- App Entry Point -----------------
class AccountBookApp extends StatelessWidget {
  Const AccountBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    Return AnimatedBuilder(
      Animation: appSettings,
      Builder: (context, child) {
        Return MaterialApp(
          Title: appSettings.getAppTitle(),
          DebugShowCheckedModeBanner: false,
          ThemeMode: appSettings.themeMode,
          Theme: ThemeData(
            Brightness: Brightness.light,
            ScaffoldBackgroundColor: const Color(0xFFF3F4F6),
            PrimaryColor: const Color(0xFF38BDF8),
            CardColor: Colors.white,
            AppBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
            DialogTheme: const DialogTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
            BottomSheetThemeData: const BottomSheetThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
            ElevatedButtonTheme: ElevatedButtonThemeData(
              Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ),
          DarkTheme: ThemeData(
            Brightness: Brightness.dark,
            ScaffoldBackgroundColor: const Color(0xFF0F172A),
            PrimaryColor: const Color(0xFF10B981),
            CardColor: const Color(0xFF1E293B),
            AppBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white),
            DialogTheme: const DialogTheme(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
            BottomSheetThemeData: const BottomSheetThemeData(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
            ElevatedButtonTheme: ElevatedButtonThemeData(
              Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ),
          Home: const PinLockScreen(),
        );
      },
    );
  }
}

// ----------------- Standard Menus & Helpers -----------------
void showStandardDownloadMenu(BuildContext context, Offset offset) {
  String lang = appSettings.language;
  String previewText = lang == 'Bangla' ? 'প্রিভিউ' : (lang == 'Arabic' ? 'معاينة' : 'Preview');
  String pdfText = lang == 'Bangla' ? 'পিডিএফ ডাউনলোড' : (lang == 'Arabic' ? 'تحميل كـ PDF' : 'Download as PDF');
  String excelText = lang == 'Bangla' ? 'এক্সেল ডাউনলোড' : (lang == 'Arabic' ? 'تحميل كـ Excel' : 'Download as Excel');

  ShowMenu(
    Context: context,
    Position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 20, 0),
    Items: [
      PopupMenuItem(
        Value: 'preview',
        Child: Row(
          Children: [
            Const Icon(Icons.visibility, color: Colors.blue, size: 20),
            Const SizedBox(width: 8),
            Text(previewText),
          ],
        ),
      ),
      PopupMenuItem(
        Value: 'pdf',
        Child: Row(
          Children: [
            Const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
            Const SizedBox(width: 8),
            Text(pdfText),
          ],
        ),
      ),
      PopupMenuItem(
        Value: 'excel',
        Child: Row(
          Children: [
            Const Icon(Icons.table_chart, color: Colors.green, size: 20),
            Const SizedBox(width: 8),
            Text(excelText),
          ],
        ),
      ),
    ],
  ).then((value) {
    If (value != null) {
      If (value == 'preview') {
        ShowDialog(
          Context: context,
          Builder: (ctx) => AlertDialog(
            Title: Text(lang == 'Bangla' ? 'রিপোর্ট প্রিভিউ' : (lang == 'Arabic' ? 'معاينة التقرير' : 'Report Preview')),
            Content: Text(lang == 'Bangla' ? 'এখানে আপনার বর্তমান হিসাবের সংক্ষিপ্ত প্রিভিউ দেখানো হচ্ছে।' : (lang == 'Arabic' ? 'هذا معاينة موجزة لحسابك الحالي.' : 'Here is a preview of your financial summary.')),
            Actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
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
  ShowMenu(
    Context: context,
    Position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 20, 0),
    Items: const [
      PopupMenuItem(value: 'Date New-Old', child: Text('Sort by Date (Newest to Oldest)')),
      PopupMenuItem(value: 'Date Old-New', child: Text('Sort by Date (Oldest to Newest)')),
      PopupMenuItem(value: 'Name A-Z', child: Text('Sort by Name (A to Z)')),
      PopupMenuItem(value: 'Name Z-A', child: Text('Sort by Name (Z to A)')),
      PopupMenuItem(value: 'Number Large-Small', child: Text('Sort by Number (Large to Small)')),
      PopupMenuItem(value: 'Number Small-Large', child: Text('Sort by Number (Small to Large)')),
    ],
  ).then((value) {
    If (value != null) {
      OnSelected(value);
    }
  });
}

void showLocalizedDeleteDialog({
  Required BuildContext context,
  Required bool isImportant,
  Required String itemName,
  Required VoidCallback onDeleteConfirmed,
}) {
  String lang = appSettings.language;
  String title1 = lang == 'Bangla' ? 'নিশ্চিতকরণ' : (lang == 'Arabic' ? 'تأكيد' : 'Confirmation');
  String msg1 = lang == 'Bangla' 
      ? 'আপনি কি আসলেই "$itemName" ডিলিট করতে চান?' 
      : (lang == 'Arabic' ? 'هل أنت متأكد أنك تريد حذف "$itemName"؟' : 'Are you sure you want to delete "$itemName"?');
  
  String warningMsg = lang == 'Bangla'
      ? 'সতর্কতা: এটি অন্য কোনো রেকর্ডের সাথে জড়িত। ডিলিট করলে ডাটা প্রভাবিত হতে পারে। নিশ্চিত?'
      : (lang == 'Arabic' ? 'تحذير: هذا مرتبط بسجل آخر. هل أنت متأكد؟' : 'Warning: This is linked with other records. Are you sure?');
  
  String yesText = lang == 'Bangla' ? 'হ্যাঁ' : (lang == 'Arabic' ? 'نعم' : 'Yes');
  String noText = lang == 'Bangla' ? 'না' : (lang == 'Arabic' ? 'لا' : 'No');

  ShowDialog(
    Context: context,
    Builder: (ctx) => AlertDialog(
      Title: Text(title1),
      Content: Text(isImportant ? warningMsg : msg1),
      Actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(noText)),
        ElevatedButton(
          Style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          OnPressed: () {
            Navigator.pop(ctx);
            OnDeleteConfirmed();
          },
          Child: Text(yesText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ----------------- Dashboard Analytics Screen -----------------
class DashboardAnalyticsScreen extends StatelessWidget {
  Const DashboardAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    Double income = appSettings.getTotalIncome();
    Double expense = appSettings.getTotalExpense();
    Double balance = appSettings.getTotalBalance();
    Double totalGiven = appSettings.getTotalGiven();
    Double totalTaken = appSettings.getTotalTaken();

    Return AnimatedBuilder(
      Animation: appSettings,
      Builder: (context, _) => Scaffold(
        AppBar: AppBar(title: Text(appSettings.translate('Dashboard Analytics'))),
        Body: SingleChildScrollView(
          Padding: const EdgeInsets.all(16),
          Child: Column(
            CrossAxisAlignment: CrossAxisAlignment.start,
            Children: [
              Const Text('Financial Overview Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Const SizedBox(height: 12),
              Container(
                Padding: const EdgeInsets.all(16),
                Decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                Child: Column(
                  Children: [
                    Row(
                      MainAxisAlignment: MainAxisAlignment.spaceBetween,
                      Children: [
                        Const Text('Total Balance', style: TextStyle(color: Colors.grey)),
                        Text('$balance$curr', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: balance >= 0 ? const Color(0xFF10B981) : Colors.redAccent)),
                      ],
                    ),
                    Const Divider(height: 24),
                    Row(
                      MainAxisAlignment: MainAxisAlignment.spaceBetween,
                      Children: [
                        Const Text('Total Income', style: TextStyle(color: Colors.grey)),
                        Text('$income$curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    Const SizedBox(height: 8),
                    Row(
                      MainAxisAlignment: MainAxisAlignment.spaceBetween,
                      Children: [
                        Const Text('Total Expense', style: TextStyle(color: Colors.grey)),
                        Text('$expense$curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                  ],
                ),
              ),
              Const SizedBox(height: 24),
              Const Text('Loan & Debt Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Const SizedBox(height: 12),
              Container(
                Padding: const EdgeInsets.all(16),
                Decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                Child: Column(
                  Children: [
                    Row(
                      MainAxisAlignment: MainAxisAlignment.spaceBetween,
                      Children: [
                        Const Text('Total Loan Given', style: TextStyle(color: Colors.grey)),
                        Text('$totalGiven$curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    Const SizedBox(height: 8),
                    Row(
                      MainAxisAlignment: MainAxisAlignment.spaceBetween,
                      Children: [
                        Const Text('Total Loan Taken', style: TextStyle(color: Colors.grey)),
                        Text('$totalTaken$curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- Calculators Screen -----------------
class
