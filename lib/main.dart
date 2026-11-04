Import 'package:flutter/material.dart';
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
  Final String id;
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
  Final String id;
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
    If (themeStr == 'light') _themeMode = ThemeMode.light;
    Else if (themeStr == 'system') _themeMode = ThemeMode.system;
    Else _themeMode = ThemeMode.dark;

    profileName = _prefs.getString('profileName') ?? 'MD ALAMGIR HOSSAIN';
    profileEmail = _prefs.getString('profileEmail') ?? 'alamgir@email.com';
    profileGender = _prefs.getString('profileGender') ?? 'Male';
    profileBirthDate = _prefs.getString('profileBirthDate') ?? '01-01-1995';
    profileMobile = _prefs.getString('profileMobile') ?? '018xxxxxxxx';
    profileImagePath = _prefs.getString('profileImagePath') ?? '';
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    Await _prefs.setString('appPin', appPin);
    Await _prefs.setString('language', _language);
    Await _prefs.setString('themeMode', _themeMode == ThemeMode.light ? 'light' : (_themeMode == ThemeMode.system ? 'system' : 'dark'));
    Await _prefs.setString('profileName', profileName);
    Await _prefs.setString('profileEmail', profileEmail);
    Await _prefs.setString('profileGender', profileGender);
    Await _prefs.setString('profileBirthDate', profileBirthDate);
    Await _prefs.setString('profileMobile', profileMobile);
    Await _prefs.setString('profileImagePath', profileImagePath);
  }

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  
  String getAppTitle() {
    If (_language == 'Bangla') return 'হিসাবের খাতা';
    If (_language == 'Arabic') return 'دفتر الحسابات';
    Return 'Account Book';
  }

  String translate(String key) {
    If (_language == 'Bangla') {
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
        Default: return key;
      }
    }
    Return key;
  }

  Void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  Void setLanguage(String lang) {
    _language = lang;
    _saveToPrefs();
    notifyListeners();
  }

  Void setTimeFilter(String filter) {
    TimeFilter = filter;
    notifyListeners();
  }

  Void setMonthYear(int month, int year) {
    SelectedMonthIndex = month;
    SelectedYear = year;
    notifyListeners();
  }

  Void setCurrency(String newCurrency) {
    Currency = newCurrency;
    notifyListeners();
  }

  Void updatePin(String newPin) {
    AppPin = newPin;
    _saveToPrefs();
    notifyListeners();
  }

  Void updateProfile({required String name, required String email, required String gender, required String birthDate, required String mobile, String? imagePath}) {
    ProfileName = name;
    ProfileEmail = email;
    ProfileGender = gender;
    ProfileBirthDate = birthDate;
    ProfileMobile = mobile;
    If (imagePath != null) profileImagePath = imagePath;
    _saveToPrefs();
    notifyListeners();
  }

  Void updateSecurityToggles({required bool face, required bool fingerprint, required bool none, required bool pattern, required bool pin}) {
    UseFaceLock = face;
    UseFingerprint = fingerprint;
    UseNoneLock = none;
    UsePatternLock = pattern;
    UsePinLock = pin;
    notifyListeners();
  }

  Void toggleNotification(String key, bool val) {
    If (key == 'daily') dailyReminder = val;
    If (key == 'budget') budgetAlert = val;
    If (key == 'loan') loanAlert = val;
    notifyListeners();
  }

  Void setNotificationSound(String sound) {
    NotificationSound = sound;
    notifyListeners();
  }

  Void addTransaction(TransactionItem txn) {
    Transactions.insert(0, txn);
    notifyListeners();
  }

  Void updateTransaction(int index, TransactionItem txn) {
    Transactions[index] = txn;
    notifyListeners();
  }

  Void removeTransaction(int index) {
    Transactions.removeAt(index);
    notifyListeners();
  }

  Void addLoan(LoanItem loan) {
    Loans.insert(0, loan);
    notifyListeners();
  }

  Void updateLoan(int index, String personName, double amount, String type) {
    Loans[index].personName = personName;
    Loans[index].amount = amount;
    Loans[index].type = type;
    notifyListeners();
  }

  Void removeLoan(int index) {
    Loans.removeAt(index);
    notifyListeners();
  }

  Void toggleLoanStatus(String id) {
    For (var loan in loans) {
      If (loan.id == id) {
        Loan.isPaid = !loan.isPaid;
        notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }

  List<TransactionItem> getFilteredTransactions() {
    Return transactions.where((txn) {
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
      notifyListeners();
    }
  }

  Void updateAccount(int index, String name, String type, String details) {
    Accounts[index].name = name;
    Accounts[index].type = type;
    Accounts[index].details = details;
    Accounts.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Void setDefaultAccount(int index) {
    For (int i = 0; i < accounts.length; i++) {
      Accounts[i].isDefault = (i == index);
    }
    notifyListeners();
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
      notifyListeners();
      Return true;
    }
    Return false;
  }

  Void addBudget(String category, double amount) {
    Budgets.add(BudgetModel(category: category, amount: amount));
    Budgets.sort((a, b) => a.category.compareTo(b.category));
    notifyListeners();
  }

  Void updateBudget(int index, String category, double amount) {
    Budgets[index] = BudgetModel(category: category, amount: amount);
    Budgets.sort((a, b) => a.category.compareTo(b.category));
    notifyListeners();
  }

  Void removeBudget(int index) {
    Budgets.removeAt(index);
    notifyListeners();
  }

  Void addSavings(String title, double target) {
    SavingsList.add(SavingsModel(title: title, targetAmount: target, currentAmount: 0));
    SavingsList.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }

  Void updateSavings(int index, String title, double targetAmount) {
    SavingsList[index].title = title;
    SavingsList[index].targetAmount = targetAmount;
    SavingsList.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }

  Void removeSavings(int index) {
    SavingsList.removeAt(index);
    notifyListeners();
  }

  Void addCategory(String cat) {
    If (cat.isNotEmpty && !categories.contains(cat)) {
      Categories.add(cat);
      Categories.sort();
      notifyListeners();
    }
  }

  Void updateCategory(int index, String newCat) {
    If (newCat.isNotEmpty) {
      Categories[index] = newCat;
      Categories.sort();
      notifyListeners();
    }
  }

  Void removeCategory(int index) {
    If (categories.length > 1) {
      Categories.removeAt(index);
      notifyListeners();
    }
  }

  Void addRepeatedTransaction(String title, double amount, String frequency) {
    If (title.isNotEmpty) {
      RepeatedTransactions.add(RepeatedTransactionModel(title: title, amount: amount, frequency: frequency));
      RepeatedTransactions.sort((a, b) => a.title.compareTo(b.title));
      notifyListeners();
    }
  }

  Void updateRepeatedTransaction(int index, String title, double amount, String frequency) {
    RepeatedTransactions[index] = RepeatedTransactionModel(title: title, amount: amount, frequency: frequency);
    RepeatedTransactions.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }

  Void removeRepeatedTransaction(int index) {
    RepeatedTransactions.removeAt(index);
    notifyListeners();
  }

  Void addShoppingItem(String name, double amount) {
    If (name.isNotEmpty) {
      ShoppingList.add(ShoppingItem(name: name, amount: amount));
      ShoppingList.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  Void updateShoppingItem(int index, String name, double amount) {
    If (name.isNotEmpty) {
      ShoppingList[index].name = name;
      ShoppingList[index].amount = amount;
      ShoppingList.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  Void removeShoppingItem(int index) {
    ShoppingList.removeAt(index);
    notifyListeners();
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
    notifyListeners();
  }

  Void addReminder(String title, double amount, String dueDate) {
    If (title.isNotEmpty) {
      Reminders.add(ReminderModel(title: title, amount: amount, dueDate: dueDate));
      Reminders.sort((a, b) => a.title.compareTo(b.title));
      notifyListeners();
    }
  }

  Void updateReminder(int index, String title, double amount, String dueDate) {
    Reminders[index] = ReminderModel(title: title, amount: amount, dueDate: dueDate);
    Reminders.sort((a, b) => a.title.compareTo(b.title));
    notifyListeners();
  }

  Void removeReminder(int index) {
    Reminders.removeAt(index);
    notifyListeners();
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
          ),
          DarkTheme: ThemeData(
            Brightness: Brightness.dark,
            ScaffoldBackgroundColor: const Color(0xFF0F172A),
            PrimaryColor: const Color(0xFF10B981),
            CardColor: const Color(0xFF1E293B),
            AppBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white),
            DialogTheme: const DialogTheme(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
            BottomSheetThemeData: const BottomSheetThemeData(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
          ),
          Home: const PinLockScreen(),
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

  If (!isImportant) {
    ShowDialog(
      Context: context,
      Builder: (ctx) => AlertDialog(
        Title: Text(title1),
        Content: Text(msg1),
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
  } else {
    ShowDialog(
      Context: context,
      Builder: (ctx) => AlertDialog(
        Title: Text(title1),
        Content: Text(warningMsg),
        Actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(noText)),
          ElevatedButton(
            Style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            OnPressed: () {
              Navigator.pop(ctx);
              ShowDialog(
                Context: context,
                Builder: (ctx2) => AlertDialog(
                  Title: Text(title1),
                  Content: Text(msg1),
                  Actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx2), child: Text(noText)),
                    ElevatedButton(
                      Style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      OnPressed: () {
                        Navigator.pop(ctx2);
                        OnDeleteConfirmed();
                      },
                      Child: Text(yesText, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            Child: Text(yesText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
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

    Return Scaffold(
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
                      Text('$balance $curr', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: balance >= 0 ? const Color(0xFF10B981) : Colors.redAccent)),
                    ],
                  ),
                  Const Divider(height: 24),
                  Row(
                    MainAxisAlignment: MainAxisAlignment.spaceBetween,
                    Children: [
                      Const Text('Total Income', style: TextStyle(color: Colors.grey)),
                      Text('$income $curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Const SizedBox(height: 8),
                  Row(
                    MainAxisAlignment: MainAxisAlignment.spaceBetween,
                    Children: [
                      Const Text('Total Expense', style: TextStyle(color: Colors.grey)),
                      Text('$expense $curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
                      Text('$totalGiven $curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  Const SizedBox(height: 8),
                  Row(
                    MainAxisAlignment: MainAxisAlignment.spaceBetween,
                    Children: [
                      Const Text('Total Loan Taken', style: TextStyle(color: Colors.grey)),
                      Text('$totalTaken $curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
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

// ----------------- App Drawer Widget -----------------
class AppDrawer extends StatelessWidget {
  Const AppDrawer({super.key});

  Void _showThemeDialog(BuildContext context) {
    ShowDialog(
      Context: context,
      Builder: (ctx) {
        Return StatefulBuilder(
          Builder: (ctx, setStateDialog) {
            Return AlertDialog(
              Title: Text(appSettings.translate('Theme')),
              Content: Column(
                MainAxisSize: MainAxisSize.min,
                Children: [
                  RadioListTile<ThemeMode>(
                    Title: const Text('Dark'),
                    Value: ThemeMode.dark,
                    GroupValue: appSettings.themeMode,
                    ActiveColor: const Color(0xFF10B981),
                    OnChanged: (val) {
                      If (val != null) {
                        AppSettings.setTheme(val);
                        SetStateDialog(() {});
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    Title: const Text('Light'),
                    Value: ThemeMode.light,
                    GroupValue: appSettings.themeMode,
                    ActiveColor: const Color(0xFF10B981),
                    OnChanged: (val) {
                      If (val != null) {
                        AppSettings.setTheme(val);
                        SetStateDialog(() {});
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    Title: const Text('System Default'),
                    Value: ThemeMode.system,
                    GroupValue: appSettings.themeMode,
                    ActiveColor: const Color(0xFF10B981),
                    OnChanged: (val) {
                      If (val != null) {
                        AppSettings.setTheme(val);
                        SetStateDialog(() {});
                      }
                    },
                  ),
                ],
              ),
              Actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }

  Void _showLanguageDialog(BuildContext context) {
    ShowDialog(
      Context: context,
      Builder: (ctx) {
        Return StatefulBuilder(
          Builder: (ctx, setStateDialog) {
            Return AlertDialog(
              Title: Text(appSettings.translate('Language')),
              Content: Column(
                MainAxisSize: MainAxisSize.min,
                Children: [
                  RadioListTile<String>(
                    Title: const Text('System Default'),
                    Value: 'System Default',
                    GroupValue: appSettings.language,
                    ActiveColor: const Color(0xFF10B981),
                    OnChanged: (val) {
                      If (val != null) {
                        AppSettings.setLanguage('English');
                        SetStateDialog(() {});
                      }
                    },
                  ),
                  RadioListTile<String>(
                    Title: const Text('Arabic (العربية)'),
                    Value: 'Arabic',
                    GroupValue: appSettings.language,
                    ActiveColor: const Color(0xFF10B981),
                    OnChanged: (val) {
                      If (val != null) {
                        AppSettings.setLanguage(val);
                        SetStateDialog(() {});
                      }
                    },
                  ),
                  RadioListTile<String>(
                    Title: const Text('Bangla (বাংলা)'),
                    Value: 'Bangla',
                    GroupValue: appSettings.language,
                    ActiveColor: const Color(0xFF10B981),
                    OnChanged: (val) {
                      If (val != null) {
                        AppSettings.setLanguage(val);
                        SetStateDialog(() {});
                      }
                    },
                  ),
                  RadioListTile<String>(
                    Title: const Text('English'),
                    Value: 'English',
                    GroupValue: appSettings.language,
                    ActiveColor: const Color(0xFF10B981),
                    OnChanged: (val) {
                      If (val != null) {
                        AppSettings.setLanguage(val);
                        SetStateDialog(() {});
                      }
                    },
                  ),
                ],
              ),
              Actions: [
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
    Return Drawer(
      Child: ListView(
        Padding: EdgeInsets.zero,
        Children: [
          UserAccountsDrawerHeader(
            Decoration: const BoxDecoration(color: Color(0xFF10B981)),
            AccountName: Text(appSettings.profileName, style: const TextStyle(fontWeight: FontWeight.bold)),
            AccountEmail: Text(appSettings.profileEmail),
            CurrentAccountPicture: CircleAvatar(
              BackgroundColor: Colors.white,
              BackgroundImage: appSettings.profileImagePath.isNotEmpty ? FileImage(File(appSettings.profileImagePath)) : null,
              Child: appSettings.profileImagePath.isEmpty ? const Icon(Icons.person, size: 40, color: Color(0xFF10B981)) : null,
            ),
          ),
          ListTile(
            Leading: const Icon(Icons.dashboard),
            Title: Text(appSettings.translate('Dashboard Analytics')),
            OnTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardAnalyticsScreen()));
            },
          ),
          ListTile(
            Leading: const Icon(Icons.category),
            Title: Text(appSettings.translate('Categories')),
            OnTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
            },
          ),
          ListTile(
            Leading: const Icon(Icons.account_balance),
            Title: Text(appSettings.translate('Accounts')),
            OnTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountsScreen()));
            },
          ),
          ListTile(
            Leading: const Icon(Icons.palette),
            Title: Text(appSettings.translate('Theme')),
            OnTap: () {
              Navigator.pop(context);
              _showThemeDialog(context);
            },
          ),
          ListTile(
            Leading: const Icon(Icons.language),
            Title: Text(appSettings.translate('Language')),
            OnTap: () {
              Navigator.pop(context);
              _showLanguageDialog(context);
            },
          ),
          Const Divider(),
          ListTile(
            Leading: const Icon(Icons.info),
            Title: Text(appSettings.translate('About App')),
            OnTap: () {
              Navigator.pop(context);
              ShowDialog(
                Context: context,
                Builder: (ctx) => AlertDialog(
                  Title: Text(appSettings.translate('About App')),
                  Content: const Text('Account Book v1.0.0\nDeveloped for daily financial ledger & transaction management.'),
                  Actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------- Quick Access Interactive Screens -----------------

// 1. Accounts Screen
class AccountsScreen extends StatefulWidget {
  Const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}
class _AccountsScreenState extends State<AccountsScreen> {
  Void _showAddEditDialog({int? index, AccountModel? account}) {
    Final nameC = TextEditingController(text: account?.name ?? '');
    Final typeC = TextEditingController(text: account?.type ?? 'Bank');
    Final detC = TextEditingController(text: account?.details ?? '');
    ShowDialog(
      Context: context,
      Builder: (ctx) => AlertDialog(
        Title: Text(index == null ? 'Add Account' : 'Edit Account'),
        Content: Column(
          MainAxisSize: MainAxisSize.min,
          Children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Account Name', border: OutlineInputBorder())),
            Const SizedBox(height: 10),
            TextField(controller: typeC, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder())),
            Const SizedBox(height: 10),
            TextField(controller: detC, decoration: const InputDecoration(labelText: 'Details / Account Number', border: OutlineInputBorder())),
          ],
        ),
        Actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            OnPressed: () {
              If (nameC.text.isNotEmpty) {
                If (index == null) {
                  AppPreferences.addAccount(nameC.text, typeC.text, detC.text); // Note: using appSettings
                  AppSettings.addAccount(nameC.text, typeC.text, detC.text);
                } else {
                  AppSettings.updateAccount(index, nameC.text, typeC.text, detC.text);
                }
                Navigator.pop(ctx);
                SetState(() {});
              }
            },
            Child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
      AppBar: AppBar(
        Title: Text(appSettings.translate('Accounts')),
        Actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: ListView.builder(
          ItemCount: appSettings.accounts.length,
          ItemBuilder: (context, index) {
            Final acc = appSettings.accounts[index];
            Return Card(
              Color: Theme.of(context).cardColor,
              Margin: const EdgeInsets.only(bottom: 10),
              Child: ListTile(
                OnTap: () {
                  AppSettings.setDefaultAccount(index);
                  SetState(() {});
                },
                Leading: CircleAvatar(
                  BackgroundColor: acc.isDefault ? const Color(0xFF10B981).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  Child: Icon(
                    Acc.isDefault ? Icons.check : Icons.account_balance_wallet,
                    Color: acc.isDefault ? const Color(0xFF10B981) : Colors.grey,
                  ),
                ),
                Title: Text(appSettings.translate(acc.name) + (acc.isDefault ? ' [Default]' : ''), style: const TextStyle(fontWeight: FontWeight.bold)),
                Subtitle: Column(
                  CrossAxisAlignment: CrossAxisAlignment.start,
                  Children: [
                    Const SizedBox(height: 4),
                    Text(appSettings.translate(acc.type)),
                    Const SizedBox(height: 2),
                    Text(acc.details, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                IsThreeLine: true,
                Trailing: Row(
                  MainAxisSize: MainAxisSize.min,
                  Children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddEditDialog(index: index, account: acc)),
                    IconButton(
                      Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                      OnPressed: () {
                        If (appSettings.accounts.length <= 1) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot delete the last remaining account!')));
                          Return;
                        }
                        ShowLocalizedDeleteDialog(
                          Context: context,
                          IsImportant: true,
                          ItemName: acc.name,
                          OnDeleteConfirmed: () {
                            AppSettings.removeAccount(index);
                            SetState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddEditDialog(),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 2. Budget Screen
class BudgetScreen extends StatefulWidget {
  Const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}
class _BudgetScreenState extends State<BudgetScreen> {
  Void _showAddEditBudgetDialog({int? index, BudgetModel? budget}) {
    String selectedCategory = budget?.category ?? appSettings.categories[0];
    Final amountC = TextEditingController(text: budget != null ? budget.amount.toString() : '');
    
    ShowModalBottomSheet(
      Context: context,
      IsScrollControlled: true,
      Builder: (ctx) => StatefulBuilder(
        Builder: (ctx, setStateSheet) => Padding(
          Padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          Child: Column(
            MainAxisSize: MainAxisSize.min,
            CrossAxisAlignment: CrossAxisAlignment.start,
            Children: [
              Text(index == null ? 'Add New Budget' : 'Edit Budget', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                Value: selectedCategory,
                DropdownColor: Theme.of(context).cardColor,
                Decoration: const InputDecoration(labelText: 'Select Category', border: OutlineInputBorder()),
                Items: appSettings.categories.map((c) => DropdownMenuItem(value: c, child: Text(appSettings.translate(c)))).toList(),
                OnChanged: (val) { if (val != null) setStateSheet(() => selectedCategory = val); },
              ),
              Const SizedBox(height: 12),
              TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
              Const SizedBox(height: 16),
              SizedBox(
                Width: double.infinity,
                Child: ElevatedButton(
                  Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  OnPressed: () {
                    If (amountC.text.isNotEmpty) {
                      Double amt = double.tryParse(amountC.text) ?? 0.0;
                      If (index == null) {
                        AppSettings.addBudget(selectedCategory, amt);
                      } else {
                        AppSettings.updateBudget(index, selectedCategory, amt);
                      }
                      Navigator.pop(ctx);
                      SetState(() {});
                    }
                  },
                  Child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    Return Scaffold(
      AppBar: AppBar(
        Title: Text(appSettings.translate('Budget')),
        Actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: appSettings.budgets.isEmpty
            ? const Center(child: Text('No budget found', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                ItemCount: appSettings.budgets.length,
                ItemBuilder: (context, index) {
                  Final b = appSettings.budgets[index];
                  Return Card(
                    Color: Theme.of(context).cardColor,
                    Margin: const EdgeInsets.only(bottom: 8),
                    Child: ListTile(
                      Leading: const Icon(Icons.track_changes, color: Color(0xFF10B981)),
                      Title: Text(appSettings.translate(b.category)),
                      Trailing: Row(
                        MainAxisSize: MainAxisSize.min,
                        Children: [
                          Text('$curr ${b.amount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          Const SizedBox(width: 8),
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddEditBudgetDialog(index: index, budget: b)),
                          IconButton(
                            Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                            OnPressed: () {
                              ShowLocalizedDeleteDialog(
                                Context: context,
                                IsImportant: false,
                                ItemName: b.category,
                                OnDeleteConfirmed: () {
                                  AppSettings.removeBudget(index);
                                  SetState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddEditBudgetDialog(),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 3. Categories Screen
class CategoriesScreen extends StatefulWidget {
  Const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}
class _CategoriesScreenState extends State<CategoriesScreen> {
  Void _showAddCategoryDialog({int? index, String? category}) {
    Final catController = TextEditingController(text: category ?? '');
    ShowDialog(
      Context: context,
      Builder: (ctx) => AlertDialog(
        Title: Text(index == null ? 'Add Category' : 'Edit Category'),
        Content: TextField(controller: catController, decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder())),
        Actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            OnPressed: () {
              If (catController.text.isNotEmpty) {
                If (index == null) {
                  AppSettings.addCategory(catController.text);
                } else {
                  AppSettings.updateCategory(index, catController.text);
                }
                Navigator.pop(ctx);
                SetState(() {});
              }
            },
            Child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
      AppBar: AppBar(
        Title: Text(appSettings.translate('Categories')),
        Actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: ListView.builder(
          ItemCount: appSettings.categories.length,
          ItemBuilder: (context, index) {
            Final cat = appSettings.categories[index];
            Return Card(
              Color: Theme.of(context).cardColor,
              Margin: const EdgeInsets.only(bottom: 8),
              Child: ListTile(
                Leading: const Icon(Icons.category, color: Color(0xFF10B981)),
                Title: Text(appSettings.translate(cat)),
                Trailing: Row(
                  MainAxisSize: MainAxisSize.min,
                  Children: [
                    IconButton(
                      Icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                      OnPressed: () => _showAddCategoryDialog(index: index, category: cat),
                    ),
                    IconButton(
                      Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                      OnPressed: () {
                        If (appSettings.categories.length > 1) {
                          ShowLocalizedDeleteDialog(
                            Context: context,
                            IsImportant: true,
                            ItemName: cat,
                            OnDeleteConfirmed: () {
                              AppSettings.removeCategory(index);
                              SetState(() {});
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot delete all categories!')));
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddCategoryDialog(),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 4. Fund Shopping Screen
class FundShoppingScreen extends StatefulWidget {
  Const FundShoppingScreen({super.key});
  @override
  State<FundShoppingScreen> createState() => _FundShoppingScreenState();
}
class _FundShoppingScreenState extends State<FundShoppingScreen> {
  Void _showAddShoppingDialog({int? index, ShoppingItem? item}) {
    Final itemController = TextEditingController(text: item?.name ?? '');
    Final amountController = TextEditingController(text: item != null ? item.amount.toString() : '');
    ShowDialog(
      Context: context,
      Builder: (ctx) => AlertDialog(
        Title: Text(index == null ? 'Add Shopping Item' : 'Edit Shopping Item'),
        Content: Column(
          MainAxisSize: MainAxisSize.min,
          Children: [
            TextField(controller: itemController, decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder())),
            Const SizedBox(height: 10),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated Amount', border: OutlineInputBorder())),
          ],
        ),
        Actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            OnPressed: () {
              If (itemController.text.isNotEmpty) {
                Double amt = double.tryParse(amountController.text) ?? 0.0;
                If (index == null) {
                  AppSettings.addShoppingItem(itemController.text, amt);
                } else {
                  AppSettings.updateShoppingItem(index, itemController.text, amt);
                }
                Navigator.pop(ctx);
                SetState(() {});
              }
            },
            Child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    Return Scaffold(
      AppBar: AppBar(
        Title: Text(appSettings.translate('Shopping')),
        Actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: appSettings.shoppingList.isEmpty
            ? const Center(child: Text('Your shopping list is empty', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                ItemCount: appSettings.shoppingList.length,
                ItemBuilder: (context, index) {
                  Final item = appSettings.shoppingList[index];
                  Return Card(
                    Color: Theme.of(context).cardColor,
                    Margin: const EdgeInsets.only(bottom: 8),
                    Child: ListTile(
                      Leading: Checkbox(
                        Value: item.isChecked,
                        ActiveColor: const Color(0xFF10B981),
                        OnChanged: (val) {
                          AppSettings.toggleShoppingCheck(index);
                          SetState(() {});
                        },
                      ),
                      Title: Text(
                        AppSettings.translate(item.name),
                        Style: TextStyle(decoration: item.isChecked ? TextDecoration.lineThrough : null),
                      ),
                      Subtitle: Text('$curr ${item.amount}'),
                      Trailing: Row(
                        MainAxisSize: MainAxisSize.min,
                        Children: [
                          IconButton(
                            Icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                            OnPressed: () => _showAddShoppingDialog(index: index, item: item),
                          ),
                          IconButton(
                            Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            OnPressed: () {
                              ShowLocalizedDeleteDialog(
                                Context: context,
                                IsImportant: false,
                                ItemName: item.name,
                                OnDeleteConfirmed: () {
                                  AppSettings.removeShoppingItem(index);
                                  SetState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddShoppingDialog(),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 5. Reminders Screen
class RemindersScreen extends StatefulWidget {
  Const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}
class _RemindersScreenState extends State<RemindersScreen> {
  Void _showAddReminderDialog({int? index, ReminderModel? reminder}) {
    Final titleC = TextEditingController(text: reminder?.title ?? '');
    Final amountC = TextEditingController(text: reminder != null ? reminder.amount.toString() : '');
    String selectedDay = reminder?.dueDate ?? '1';
    List<String> daysList = List.generate(31, (i) => (i + 1).toString());

    ShowDialog(
      Context: context,
      Builder: (ctx) => StatefulBuilder(
        Builder: (ctx, setStateDialog) => AlertDialog(
          Title: Text(index == null ? 'Add Bill Reminder' : 'Edit Bill Reminder'),
          Content: Column(
            MainAxisSize: MainAxisSize.min,
            Children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Bill Title', border: OutlineInputBorder())),
              Const SizedBox(height: 10),
              TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
              Const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                Value: selectedDay,
                DropdownColor: Theme.of(context).cardColor,
                Decoration: const InputDecoration(labelText: 'Due Date (Day of Month)', border: OutlineInputBorder()),
                Items: daysList.map((d) => DropdownMenuItem(value: d, child: Text('Day $d'))).toList(),
                OnChanged: (val) { if (val != null) setStateDialog(() => selectedDay = val); },
              ),
            ],
          ),
          Actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              OnPressed: () {
                If (titleC.text.isNotEmpty && amountC.text.isNotEmpty) {
                  Double amt = double.tryParse(amountC.text) ?? 0.0;
                  If (index == null) {
                    AppSettings.addReminder(titleC.text, amt, selectedDay);
                  } else {
                    AppSettings.updateReminder(index, titleC.text, amt, selectedDay);
                  }
                  Navigator.pop(ctx);
                  SetState(() {});
                }
              },
              Child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    Return Scaffold(
      AppBar: AppBar(
        Title: Text(appSettings.translate('Reminder')),
        Actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: appSettings.reminders.isEmpty
            ? const Center(child: Text('No reminders found', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                ItemCount: appSettings.reminders.length,
                ItemBuilder: (context, index) {
                  Final rem = appSettings.reminders[index];
                  Return Card(
                    Color: Theme.of(context).cardColor,
                    Margin: const EdgeInsets.only(bottom: 8),
                    Child: ListTile(
                      Leading: const Icon(Icons.notifications_active, color: Color(0xFF10B981)),
                      Title: Text(appSettings.translate(rem.title)),
                      Subtitle: Text('Due Day: ${rem.dueDate}'),
                      Trailing: Row(
                        MainAxisSize: MainAxisSize.min,
                        Children: [
                          Text('$curr ${rem.amount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          Const SizedBox(width: 8),
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddReminderDialog(index: index, reminder: rem)),
                          IconButton(
                            Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                            OnPressed: () {
                              ShowLocalizedDeleteDialog(
                                Context: context,
                                IsImportant: false,
                                ItemName: rem.title,
                                OnDeleteConfirmed: () {
                                  AppSettings.removeReminder(index);
                                  SetState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddReminderDialog(),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 6. Repeated Transactions Screen
class RepeatedTransactionsScreen extends StatefulWidget {
  Const RepeatedTransactionsScreen({super.key});
  @override
  State<RepeatedTransactionsScreen> createState() => _RepeatedTransactionsScreenState();
}
class _RepeatedTransactionsScreenState extends State<RepeatedTransactionsScreen> {
  Void _showAddRepeatedDialog({int? index, RepeatedTransactionModel? repeated}) {
    Final titleC = TextEditingController(text: repeated?.title ?? '');
    Final amountC = TextEditingController(text: repeated != null ? repeated.amount.toString() : '');
    String selectedDay = repeated?.frequency ?? '1';
    List<String> daysList = List.generate(31, (i) => (i + 1).toString());

    ShowDialog(
      Context: context,
      Builder: (ctx) => StatefulBuilder(
        Builder: (ctx, setStateDialog) => AlertDialog(
          Title: Text(index == null ? 'Add Repeated Transaction' : 'Edit Repeated Transaction'),
          Content: Column(
            MainAxisSize: MainAxisSize.min,
            Children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
              Const SizedBox(height: 10),
              TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
              Const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                Value: selectedDay,
                DropdownColor: Theme.of(context).cardColor,
                Decoration: const InputDecoration(labelText: 'Frequency (Day of Month)', border: OutlineInputBorder()),
                Items: daysList.map((d) => DropdownMenuItem(value: d, child: Text('Day $d of every month'))).toList(),
                OnChanged: (val) { if (val != null) setStateDialog(() => selectedDay = val); },
              ),
            ],
          ),
          Actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              OnPressed: () {
                If (titleC.text.isNotEmpty && amountC.text.isNotEmpty) {
                  Double amt = double.tryParse(amountC.text) ?? 0.0;
                  If (index == null) {
                    AppSettings.addRepeatedTransaction(titleC.text, amt, selectedDay);
                  } else {
                    AppSettings.updateRepeatedTransaction(index, titleC.text, amt, selectedDay);
                  }
                  Navigator.pop(ctx);
                  SetState(() {});
                }
              },
              Child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    Return Scaffold(
      AppBar: AppBar(
        Title: Text(appSettings.translate('Repeat')),
        Actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: ListView.builder(
          ItemCount: appSettings.repeatedTransactions.length,
          ItemBuilder: (context, index) {
            Final rep = appSettings.repeatedTransactions[index];
            Return Card(
              Color: Theme.of(context).cardColor,
              Margin: const EdgeInsets.only(bottom: 8),
              Child: ListTile(
                Leading: const Icon(Icons.repeat, color: Color(0xFF10B981)),
                Title: Text(appSettings.translate(rep.title)),
                Subtitle: Text('Day ${rep.frequency} of every month'),
                Trailing: Row(
                  MainAxisSize: MainAxisSize.min,
                  Children: [
                    Text('$curr ${rep.amount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    Const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddRepeatedDialog(index: index, repeated: rep)),
                    IconButton(
                      Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                      OnPressed: () {
                        ShowLocalizedDeleteDialog(
                          Context: context,
                          IsImportant: false,
                          ItemName: rep.title,
                          OnDeleteConfirmed: () {
                            AppSettings.removeRepeatedTransaction(index);
                            SetState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddRepeatedDialog(),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 7. Savings Screen
class SavingsScreen extends StatefulWidget {
  Const SavingsScreen({super.key});
  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}
class _SavingsScreenState extends State<SavingsScreen> {
  Void _showAddSavingsDialog({int? index, SavingsModel? savings}) {
    Final titleC = TextEditingController(text: savings?.title ?? '');
    Final targetC = TextEditingController(text: savings != null ? savings.targetAmount.toString() : '');
    ShowDialog(
      Context: context,
      Builder: (ctx) => AlertDialog(
        Title: Text(index == null ? 'Add Savings Goal' : 'Edit Savings Goal'),
        Content: Column(
          MainAxisSize: MainAxisSize.min,
          Children: [
            TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Savings Title', border: OutlineInputBorder())),
            Const SizedBox(height: 10),
            TextField(controller: targetC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder())),
          ],
        ),
        Actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            OnPressed: () {
              If (titleC.text.isNotEmpty && targetC.text.isNotEmpty) {
                Double target = double.tryParse(targetC.text) ?? 0.0;
                If (index == null) {
                  AppSettings.addSavings(titleC.text, target);
                } else {
                  AppSettings.updateSavings(index, titleC.text, target);
                }
                Navigator.pop(ctx);
                SetState(() {});
              }
            },
            Child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    Return Scaffold(
      AppBar: AppBar(
        Title: Text(appSettings.translate('Savings')),
        Actions: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
        ],
      ),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: ListView.builder(
          ItemCount: appSettings.savingsList.length,
          ItemBuilder: (context, index) {
            Final sav = appSettings.savingsList[index];
            Return Card(
              Color: Theme.of(context).cardColor,
              Margin: const EdgeInsets.only(bottom: 8),
              Child: ListTile(
                Leading: const Icon(Icons.savings, color: Color(0xFF10B981)),
                Title: Text(appSettings.translate(sav.title), style: const TextStyle(fontWeight: FontWeight.bold)),
                Subtitle: Text('Saved: ${sav.currentAmount} $curr'),
                Trailing: Row(
                  MainAxisSize: MainAxisSize.min,
                  Children: [
                    Text('Target: ${sav.targetAmount} $curr', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddSavingsDialog(index: index, savings: sav)),
                    IconButton(
                      Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                      OnPressed: () {
                        ShowLocalizedDeleteDialog(
                          Context: context,
                          IsImportant: false,
                          ItemName: sav.title,
                          OnDeleteConfirmed: () {
                            AppSettings.removeSavings(index);
                            SetState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddSavingsDialog(),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ----------------- Pin & Main Container -----------------
class PinLockScreen extends StatefulWidget {
  Const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  Final TextEditingController _pinController = TextEditingController();

  Void _verifyPin(BuildContext context) {
    If (_pinController.text == appSettings.appPin || appSettings.useNoneLock) {
      Navigator.pushReplacement(
        Context,
        MaterialPageRoute(builder: (context) => const MainHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        Const SnackBar(content: Text('Wrong PIN!')),
      );
    }
  }

  Void _showForgotPinDialog(BuildContext context) {
    Final TextEditingController identifierController = TextEditingController();
    Final TextEditingController newPinController = TextEditingController();
    Final TextEditingController confirmPinController = TextEditingController();
    Bool obscureNewPin = true;
    Bool obscureConfirmPin = true;

    ShowDialog(
      Context: context,
      Builder: (ctx) {
        Return StatefulBuilder(
          Builder: (ctx, setStateDialog) {
            Return AlertDialog(
              Title: const Text('Forgot PIN'),
              Content: SingleChildScrollView(
                Child: Column(
                  MainAxisSize: MainAxisSize.min,
                  Children: [
                    Const Text('Enter your registered Email, Birth Date (DD-MM-YYYY), or Mobile Number to verify your identity.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Const SizedBox(height: 16),
                    TextField(controller: identifierController, decoration: const InputDecoration(labelText: 'Email / Birth Date / Mobile', border: OutlineInputBorder())),
                    Const SizedBox(height: 12),
                    TextField(
                      Controller: newPinController,
                      KeyboardType: TextInputType.number,
                      MaxLength: 4,
                      ObscureText: obscureNewPin,
                      Decoration: InputDecoration(
                        LabelText: 'New 4-Digit PIN',
                        Border: const OutlineInputBorder(),
                        CounterText: '',
                        SuffixIcon: IconButton(
                          Icon: Icon(obscureNewPin ? Icons.visibility_off : Icons.visibility),
                          OnPressed: () => setStateDialog(() => obscureNewPin = !obscureNewPin),
                        ),
                      ),
                    ),
                    Const SizedBox(height: 12),
                    TextField(
                      Controller: confirmPinController,
                      KeyboardType: TextInputType.number,
                      MaxLength: 4,
                      ObscureText: obscureConfirmPin,
                      Decoration: InputDecoration(
                        LabelText: 'Re-Type 4-Digit PIN',
                        Border: const OutlineInputBorder(),
                        CounterText: '',
                        SuffixIcon: IconButton(
                          Icon: Icon(obscureConfirmPin ? Icons.visibility_off : Icons.visibility),
                          OnPressed: () => setStateDialog(() => obscureConfirmPin = !obscureConfirmPin),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  OnPressed: () {
                    String input = identifierController.text.trim();
                    Bool isValidUser = input == appSettings.profileEmail || input == appSettings.profileBirthDate || input == appSettings.profileMobile;

                    If (!isValidUser) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Information does not match!'), backgroundColor: Colors.red));
                      Return;
                    }

                    If (newPinController.text.length != 4 || newPinController.text != confirmPinController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: PIN must be 4 digits and match!'), backgroundColor: Colors.red));
                      Return;
                    }

                    AppSettings.updatePin(newPinController.text);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN successfully updated and saved!')));
                    SetState(() {});
                  },
                  Child: const Text('Reset', style: TextStyle(color: Colors.white)),
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
    Return Scaffold(
      BackgroundColor: const Color(0xFF0F172A),
      Body: SafeArea(
        Child: Padding(
          Padding: const EdgeInsets.symmetric(horizontal: 24.0),
          Child: Column(
            MainAxisAlignment: MainAxisAlignment.center,
            Children: [
              Const Icon(Icons.lock_rounded, size: 70, color: Color(0xFF10B981)),
              Const SizedBox(height: 24),
              Const Text('Enter Your PIN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Const SizedBox(height: 40),
              Stack(
                Alignment: Alignment.center,
                Children: [
                  Row(
                    MainAxisAlignment: MainAxisAlignment.center,
                    Children: List.generate(4, (index) {
                      Return Container(
                        Width: 55,
                        Height: 55,
                        Margin: const EdgeInsets.symmetric(horizontal: 6),
                        Decoration: BoxDecoration(
                          Color: const Color(0xFF1E293B),
                          BorderRadius: BorderRadius.circular(12),
                          Border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                        ),
                        Child: Center(
                          Child: Text(_pinController.text.length > index ? '•' : '', style: const TextStyle(color: Colors.white, fontSize: 28)),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    Width: 250,
                    Height: 60,
                    Child: TextField(
                      Controller: _pinController,
                      KeyboardType: TextInputType.number,
                      MaxLength: 4,
                      Style: const TextStyle(color: Colors.transparent),
                      CursorColor: Colors.transparent,
                      Decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                      OnChanged: (value) {
                        SetState(() {});
                        If (value.length == 4) _verifyPin(context);
                      },
                    ),
                  ),
                ],
              ),
              Const SizedBox(height: 30),
              SizedBox(
                Width: double.infinity,
                Child: ElevatedButton(
                  Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  OnPressed: () => _verifyPin(context),
                  Child: const Text('Unlock', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              Const SizedBox(height: 20),
              TextButton(
                OnPressed: () => _showForgotPinDialog(context),
                Child: const Text('Forgot PIN?', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.w500)),
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
  Const HomeScreenContent({super.key});

  Void _showAddTransactionDialog(BuildContext context) {
    String transactionType = 'Expense';
    String selectedCategory = appSettings.categories[0];
    String selectedAccount = appSettings.accounts.firstWhere((acc) => acc.isDefault, orElse: () => appSettings.accounts[0]).name;
    
    Final TextEditingController amountController = TextEditingController();
    Final TextEditingController descController = TextEditingController();

    ShowModalBottomSheet(
      Context: context,
      IsScrollControlled: true,
      Shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      Builder: (ctx) {
        Return StatefulBuilder(
          Builder: (ctx, setStateModal) {
            Return Padding(
              Padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              Child: SingleChildScrollView(
                Child: Column(
                  MainAxisSize: MainAxisSize.min,
                  CrossAxisAlignment: CrossAxisAlignment.start,
                  Children: [
                    Const Text('Add New Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Const SizedBox(height: 16),
                    Row(
                      Children: [
                        Expanded(
                          Child: ElevatedButton(
                            Style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Income' ? Colors.green : const Color(0xFF1E293B)),
                            OnPressed: () => setStateModal(() => transactionType = 'Income'),
                            Child: const Text('Cash In', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        Const SizedBox(width: 10),
                        Expanded(
                          Child: ElevatedButton(
                            Style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Expense' ? Colors.red : const Color(0xFF1E293B)),
                            OnPressed: () => setStateModal(() => transactionType = 'Expense'),
                            Child: const Text('Cash Out', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    Const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      Value: selectedAccount,
                      DropdownColor: Theme.of(context).cardColor,
                      Decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
                      Items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text(appSettings.translate(acc.name)))).toList(),
                      OnChanged: (val) { if (val != null) setStateModal(() => selectedAccount = val); },
                    ),
                    Const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      Value: selectedCategory,
                      DropdownColor: Theme.of(context).cardColor,
                      Decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      Items: appSettings.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(appSettings.translate(cat)))).toList(),
                      OnChanged: (val) { if (val != null) setStateModal(() => selectedCategory = val); },
                    ),
                    Const SizedBox(height: 12),
                    TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
                    Const SizedBox(height: 12),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                    Const SizedBox(height: 20),
                    SizedBox(
                      Width: double.infinity,
                      Child: ElevatedButton(
                        Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 14)),
                        OnPressed: () {
                          If (amountController.text.isNotEmpty) {
                            Double amount = double.tryParse(amountController.text) ?? 0.0;
                            AppSettings.addTransaction(TransactionItem(
                              Id: DateTime.now().toString(),
                              Type: transactionType,
                              Account: selectedAccount,
                              Category: selectedCategory,
                              Amount: amount,
                              Description: descController.text,
                              Date: DateTime.now(),
                            ));
                            Navigator.pop(ctx);
                          }
                        },
                        Child: const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
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
    Return InkWell(
      OnTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)),
      Child: Column(
        Children: [
          Container(
            Padding: const EdgeInsets.all(10),
            Decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
            Child: Icon(icon, color: const Color(0xFF10B981), size: 22),
          ),
          Const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    List<int> years = List.generate(110, (index) => 1990 + index);

    Return AnimatedBuilder(
      Animation: appSettings,
      Builder: (context, child) {
        Return Scaffold(
          AppBar: AppBar(title: Text(appSettings.getAppTitle(), style: const TextStyle(fontWeight: FontWeight.bold))),
          Drawer: const AppDrawer(),
          Body: SingleChildScrollView(
            Padding: const EdgeInsets.all(16.0),
            Child: Column(
              CrossAxisAlignment: CrossAxisAlignment.start,
              Children: [
                Container(
                  Padding: const EdgeInsets.all(18),
                  Decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                  Child: Column(
                    CrossAxisAlignment: CrossAxisAlignment.start,
                    Children: [
                      Row(
                        MainAxisAlignment: MainAxisAlignment.spaceBetween,
                        Children: [
                          Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          Row(
                            Children: [
                              DropdownButton<int>(
                                Value: appSettings.selectedMonthIndex,
                                DropdownColor: Theme.of(context).cardColor,
                                Items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(months[index], style: const TextStyle(fontSize: 12)))),
                                OnChanged: (val) { if (val != null) appSettings.setMonthYear(val, appSettings.selectedYear); },
                              ),
                              Const SizedBox(width: 6),
                              DropdownButton<int>(
                                Value: appSettings.selectedYear,
                                DropdownColor: Theme.of(context).cardColor,
                                Items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString(), style: const TextStyle(fontSize: 12)))).toList(),
                                OnChanged: (val) { if (val != null) appSettings.setMonthYear(appSettings.selectedMonthIndex, val); },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Const SizedBox(height: 8),
                      Text('${appSettings.getTotalBalance()} $curr', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.grey)),
                      Row(
                        Children: [
                          Expanded(
                            Child: Container(
                              Padding: const EdgeInsets.all(10),
                              Decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              Child: Column(
                                CrossAxisAlignment: CrossAxisAlignment.start,
                                Children: [
                                  Text(appSettings.translate('Income'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                                  Const SizedBox(height: 4),
                                  Text('${appSettings.getTotalIncome()} $curr', style: const TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          Const SizedBox(width: 12),
                          Expanded(
                            Child: Container(
                              Padding: const EdgeInsets.all(10),
                              Decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              Child: Column(
                                CrossAxisAlignment: CrossAxisAlignment.start,
                                Children: [
                                  Text(appSettings.translate('Expense'), style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                  Const SizedBox(height: 4),
                                  Text('${appSettings.getTotalExpense()} $curr', style: const TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Const SizedBox(height: 24),
                Text(appSettings.translate('Quick Access'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Const SizedBox(height: 12),
                Row(
                  MainAxisAlignment: MainAxisAlignment.spaceBetween,
                  Children: [
                    _buildQuickAccessIcon(context, Icons.account_balance_wallet, appSettings.translate('Account'), const AccountsScreen()),
                    _buildQuickAccessIcon(context, Icons.track_changes, appSettings.translate('Budget'), const BudgetScreen()),
                    _buildQuickAccessIcon(context, Icons.category, appSettings.translate('Categories'), const CategoriesScreen()),
                    _buildQuickAccessIcon(context, Icons.notifications_active, appSettings.translate('Reminder'), const RemindersScreen()),
                    _buildQuickAccessIcon(context, Icons.repeat, appSettings.translate('Repeat'), const RepeatedTransactionsScreen()),
                    _buildQuickAccessIcon(context, Icons.savings, appSettings.translate('Savings'), const SavingsScreen()),
                    _buildQuickAccessIcon(context, Icons.shopping_cart, appSettings.translate('Shopping'), const FundShoppingScreen()),
                  ],
                ),
                Const SizedBox(height: 24),
                Text(appSettings.translate('Recent Transactions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Const SizedBox(height: 12),
                appSettings.transactions.isEmpty
                    ? const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text('No transactions found')))
                    : ListView.builder(
                        ShrinkWrap: true,
                        Physics: const NeverScrollableScrollPhysics(),
                        ItemCount: appSettings.transactions.length > 4 ? 4 : appSettings.transactions.length,
                        ItemBuilder: (context, index) {
                          Final txn = appSettings.transactions[index];
                          Bool isIncome = txn.type == 'Income';
                          Return Container(
                            Margin: const EdgeInsets.only(bottom: 10),
                            Decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                            Child: ListTile(
                              Leading: CircleAvatar(
                                BackgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.2),
                                Child: Icon(isIncome ? Icons.add : Icons.remove, color: isIncome ? Colors.green : Colors.red),
                              ),
                              Title: Text('${appSettings.translate(txn.category)} (${appSettings.translate(txn.account)})'),
                              Subtitle: Text(appSettings.translate(txn.description)),
                              Trailing: Text(
                                '${isIncome ? '+' : '-'} $curr ${txn.amount}',
                                Style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
          FloatingActionButton: FloatingActionButton(
            BackgroundColor: const Color(0xFF10B981),
            OnPressed: () => _showAddTransactionDialog(context),
            Child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

// ----------------- Loan & Debt Screen -----------------
class LoanDebtScreen extends StatefulWidget {
  Const LoanDebtScreen({super.key});

  @override
  State<LoanDebtScreen> createState() => _LoanDebtScreenState();
}

class _LoanDebtScreenState extends State<LoanDebtScreen> {
  String selectedFilter = 'All';

  Void _showAddEditLoanDialog(BuildContext context, {int? index, LoanItem? loan}) {
    String loanType = loan?.type ?? 'Given';
    Final TextEditingController nameController = TextEditingController(text: loan?.personName ?? '');
    Final TextEditingController amountController = TextEditingController(text: loan != null ? loan.amount.toString() : '');

    ShowDialog(
      Context: context,
      Builder: (ctx) {
        Return StatefulBuilder(
          Builder: (ctx, setStateModal) {
            Return AlertDialog(
              Title: Text(index == null ? 'Add New Loan / Debt' : 'Edit Loan / Debt'),
              Content: Column(
                MainAxisSize: MainAxisSize.min,
                Children: [
                  Row(
                    Children: [
                      Expanded(
                        Child: ElevatedButton(
                          Style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Given' ? Colors.green : const Color(0xFF1E293B)),
                          OnPressed: () => setStateModal(() => loanType = 'Given'),
                          Child: const Text('Given', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                      Const SizedBox(width: 8),
                      Expanded(
                        Child: ElevatedButton(
                          Style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Taken' ? Colors.red : const Color(0xFF1E293B)),
                          OnPressed: () => setStateModal(() => loanType = 'Taken'),
                          Child: const Text('Taken', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                  Const SizedBox(height: 12),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Person Name', border: OutlineInputBorder())),
                  Const SizedBox(height: 12),
                  TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
                ],
              ),
              Actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  OnPressed: () {
                    If (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      Double amt = double.tryParse(amountController.text) ?? 0.0;
                      If (index == null) {
                        AppSettings.addLoan(LoanItem(
                          Id: DateTime.now().toString(),
                          PersonName: nameController.text,
                          Amount: amt,
                          Type: loanType,
                          Date: DateTime.now(),
                        ));
                      } else {
                        AppSettings.updateLoan(index, nameController.text, amt, loanType);
                      }
                      Navigator.pop(ctx);
                      SetState(() {});
                    }
                  },
                  Child: const Text('Save', style: TextStyle(color: Colors.white)),
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
    String curr = appSettings.currency;

    Var filteredLoans = appSettings.loans.where((loan) {
      If (selectedFilter == 'Given') return loan.type == 'Given' && !loan.isPaid;
      If (selectedFilter == 'Taken') return loan.type == 'Taken' && !loan.isPaid;
      If (selectedFilter == 'Paid') return loan.isPaid;
      Return true;
    }).toList();

    Return Scaffold(
      AppBar: AppBar(
        Title: const Text('Loan & Debt'),
        Actions: [
          Builder(
            Builder: (ctx) => IconButton(
              Icon: const Icon(Icons.download),
              Tooltip: 'Download',
              OnPressed: () {
                Final RenderBox box = ctx.findRenderObject() as RenderBox;
                Final offset = box.localToGlobal(Offset.zero);
                ShowStandardDownloadMenu(context, offset);
              },
            ),
          ),
          Builder(
            Builder: (ctx) => IconButton(
              Icon: const Icon(Icons.sort),
              Tooltip: 'Sort Loans',
              OnPressed: () {
                Final RenderBox box = ctx.findRenderObject() as RenderBox;
                Final offset = box.localToGlobal(Offset.zero);
                ShowStandardSortMenu(context, offset, (val) {
                  AppSettings.sortLoans(val);
                  SetState(() {});
                });
              },
            ),
          ),
        ],
      ),
      Drawer: const AppDrawer(),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: Column(
          Children: [
            Container(
              Padding: const EdgeInsets.all(20),
              Decoration: BoxDecoration(
                Color: const Color(0xFF1E293B),
                BorderRadius: BorderRadius.circular(16),
                Border: Border.all(color: const Color(0xFF38BDF8), width: 1),
              ),
              Child: Column(
                Children: [
                  Const Text('Net Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Const SizedBox(height: 6),
                  Text('${appSettings.getNetBalance()} $curr', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                  Const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white24)),
                  Row(
                    MainAxisAlignment: MainAxisAlignment.spaceAround,
                    Children: [
                      Column(
                        Children: [
                          Const Row(children: [Icon(Icons.arrow_downward, size: 14, color: Colors.green), SizedBox(width: 4), Text('Given', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))]),
                          Const SizedBox(height: 4),
                          Text('${appSettings.getTotalGiven()} $curr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      Container(height: 30, width: 1, color: Colors.white24),
                      Column(
                        Children: [
                          Const Row(children: [Icon(Icons.arrow_upward, size: 14, color: Colors.redAccent), SizedBox(width: 4), Text('Taken', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))]),
                          Const SizedBox(height: 4),
                          Text('${appSettings.getTotalTaken()} $curr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Const SizedBox(height: 16),
            Row(
              Children: ['All', 'Given', 'Taken', 'Paid'].map((filter) {
                Bool isSelected = selectedFilter == filter;
                Return Padding(
                  Padding: const EdgeInsets.only(right: 8.0),
                  Child: ChoiceChip(
                    Label: Text(filter),
                    Selected: isSelected,
                    SelectedColor: const Color(0xFF10B981),
                    BackgroundColor: const Color(0xFF1E293B),
                    LabelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                    OnSelected: (val) => setState(() => selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
            Const SizedBox(height: 16),
            Const Align(
              Alignment: Alignment.centerLeft,
              Child: Text('Loan List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Const SizedBox(height: 10),
            Expanded(
              Child: filteredLoans.isEmpty
                  ? const Center(child: Text('No loans found', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      ItemCount: filteredLoans.length,
                      ItemBuilder: (context, index) {
                        Final loan = filteredLoans[index];
                        Bool isGiven = loan.type == 'Given';
                        Return Card(
                          Color: Theme.of(context).cardColor,
                          Margin: const EdgeInsets.only(bottom: 8),
                          Child: ListTile(
                            Leading: CircleAvatar(
                              BackgroundColor: (isGiven ? Colors.green : Colors.red).withOpacity(0.2),
                              Child: Icon(isGiven ? Icons.arrow_upward : Icons.arrow_downward, color: isGiven ? Colors.green : Colors.red),
                            ),
                            Title: Text(appSettings.translate(loan.personName), style: TextStyle(fontWeight: FontWeight.bold, decoration: loan.isPaid ? TextDecoration.lineThrough : null)),
                            Subtitle: Text('${loan.type} - ${loan.date.toString().substring(0, 10)}'),
                            Trailing: Row(
                              MainAxisSize: MainAxisSize.min,
                              Children: [
                                Text('$curr ${loan.amount}', style: TextStyle(color: isGiven ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold)),
                                Checkbox(
                                  Value: loan.isPaid,
                                  ActiveColor: const Color(0xFF10B981),
                                  OnChanged: (val) {
                                    AppSettings.toggleLoanStatus(loan.id);
                                    SetState(() {});
                                  },
                                ),
                                IconButton(
                                  Icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                  OnPressed: () => _showAddEditLoanDialog(context, index: index, loan: loan),
                                ),
                                IconButton(
                                  Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                  OnPressed: () {
                                    ShowLocalizedDeleteDialog(
                                      Context: context,
                                      IsImportant: true,
                                      ItemName: loan.personName,
                                      OnDeleteConfirmed: () {
                                        AppSettings.removeLoan(index);
                                        SetState(() {});
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddEditLoanDialog(context),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ----------------- All Transactions Screen -----------------
class AllTransactionsScreen extends StatefulWidget {
  Const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String searchQuery = '';
  String filterType = 'All';

  Void _showAddEditTransactionDialog(BuildContext context, {int? index, TransactionItem? txn}) {
    String transactionType = txn?.type ?? 'Expense';
    String selectedCategory = txn?.category ?? appSettings.categories[0];
    String selectedAccount = txn?.account ?? appSettings.accounts.firstWhere((acc) => acc.isDefault, orElse: () => appSettings.accounts[0]).name;
    
    Final TextEditingController amountController = TextEditingController(text: txn != null ? txn.amount.toString() : '');
    Final TextEditingController descController = TextEditingController(text: txn?.description ?? '');

    ShowModalBottomSheet(
      Context: context,
      IsScrollControlled: true,
      Shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      Builder: (ctx) {
        Return StatefulBuilder(
          Builder: (ctx, setStateModal) {
            Return Padding(
              Padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              Child: SingleChildScrollView(
                Child: Column(
                  MainAxisSize: MainAxisSize.min,
                  CrossAxisAlignment: CrossAxisAlignment.start,
                  Children: [
                    Text(index == null ? 'Add New Transaction' : 'Edit Transaction', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Const SizedBox(height: 16),
                    Row(
                      Children: [
                        Expanded(
                          Child: ElevatedButton(
                            Style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Income' ? Colors.green : const Color(0xFF1E293B)),
                            OnPressed: () => setStateModal(() => transactionType = 'Income'),
                            Child: const Text('Cash In', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        Const SizedBox(width: 10),
                        Expanded(
                          Child: ElevatedButton(
                            Style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Expense' ? Colors.red : const Color(0xFF1E293B)),
                            OnPressed: () => setStateModal(() => transactionType = 'Expense'),
                            Child: const Text('Cash Out', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    Const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      Value: selectedAccount,
                      DropdownColor: Theme.of(context).cardColor,
                      Decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
                      Items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text(appSettings.translate(acc.name)))).toList(),
                      OnChanged: (val) { if (val != null) setStateModal(() => selectedAccount = val); },
                    ),
                    Const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      Value: selectedCategory,
                      DropdownColor: Theme.of(context).cardColor,
                      Decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      Items: appSettings.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(appSettings.translate(cat)))).toList(),
                      OnChanged: (val) { if (val != null) setStateModal(() => selectedCategory = val); },
                    ),
                    Const SizedBox(height: 12),
                    TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
                    Const SizedBox(height: 12),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                    Const SizedBox(height: 20),
                    SizedBox(
                      Width: double.infinity,
                      Child: ElevatedButton(
                        Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 14)),
                        OnPressed: () {
                          If (amountController.text.isNotEmpty) {
                            Double amount = double.tryParse(amountController.text) ?? 0.0;
                            If (index == null) {
                              AppSettings.addTransaction(TransactionItem(
                                Id: DateTime.now().toString(),
                                Type: transactionType,
                                Account: selectedAccount,
                                Category: selectedCategory,
                                Amount: amount,
                                Description: descController.text,
                                Date: DateTime.now(),
                              ));
                            } else {
                              AppSettings.updateTransaction(index, TransactionItem(
                                Id: txn!.id,
                                Type: transactionType,
                                Account: selectedAccount,
                                Category: selectedCategory,
                                Amount: amount,
                                Description: descController.text,
                                Date: txn.date,
                              ));
                            }
                            Navigator.pop(ctx);
                            SetState(() {});
                          }
                        },
                        Child: const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
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

  Void _showFilterDialog(BuildContext context) {
    ShowDialog(
      Context: context,
      Builder: (ctx) => AlertDialog(
        Title: const Text('Filter Transactions'),
        Content: Column(
          MainAxisSize: MainAxisSize.min,
          Children: ['All', 'Income', 'Expense'].map((type) {
            Return ListTile(
              Title: Text(type),
              OnTap: () {
                SetState(() => filterType = type);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;

    Var list = appSettings.transactions.where((txn) {
      Bool matchesSearch = txn.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
          Txn.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          Txn.account.toLowerCase().contains(searchQuery.toLowerCase());
      If (filterType == 'Income') return matchesSearch && txn.type == 'Income';
      If (filterType == 'Expense') return matchesSearch && txn.type == 'Expense';
      Return matchesSearch;
    }).toList();

    Return Scaffold(
      AppBar: AppBar(
        Title: const Text('All Transactions'),
        Actions: [
          Builder(
            Builder: (ctx) => IconButton(
              Icon: const Icon(Icons.download),
              Tooltip: 'Download',
              OnPressed: () {
                Final RenderBox box = ctx.findRenderObject() as RenderBox;
                Final offset = box.localToGlobal(Offset.zero);
                ShowStandardDownloadMenu(context, offset);
              },
            ),
          ),
          Builder(
            Builder: (ctx) => IconButton(
              Icon: const Icon(Icons.sort),
              Tooltip: 'Sort Transactions',
              OnPressed: () {
                Final RenderBox box = ctx.findRenderObject() as RenderBox;
                Final offset = box.localToGlobal(Offset.zero);
                ShowStandardSortMenu(context, offset, (val) {
                  AppSettings.sortTransactions(val);
                  SetState(() {});
                });
              },
            ),
          ),
        ],
      ),
      Drawer: const AppDrawer(),
      Body: Padding(
        Padding: const EdgeInsets.all(16.0),
        Child: Column(
          Children: [
            Row(
              Children: [
                Expanded(
                  Child: TextField(
                    OnChanged: (val) => setState(() => searchQuery = val),
                    Decoration: InputDecoration(
                      HintText: 'Search (note, category)...',
                      PrefixIcon: const Icon(Icons.search, color: Colors.grey),
                      Filled: true,
                      FillColor: Theme.of(context).cardColor,
                      Border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Const SizedBox(width: 8),
                InkWell(
                  OnTap: () => _showFilterDialog(context),
                  Child: Container(
                    Padding: const EdgeInsets.all(12),
                    Decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                    Child: const Icon(Icons.filter_list, color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
            Const SizedBox(height: 16),
            Expanded(
              Child: list.isEmpty
                  ? const Center(child: Text('No transactions found', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      ItemCount: list.length,
                      ItemBuilder: (context, index) {
                        Final txn = list[index];
                        Bool isIncome = txn.type == 'Income';
                        Return Card(
                          Color: Theme.of(context).cardColor,
                          Margin: const EdgeInsets.only(bottom: 8),
                          Child: ListTile(
                            Leading: CircleAvatar(
                              BackgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.2),
                              Child: Icon(isIncome ? Icons.add : Icons.remove, color: isIncome ? Colors.green : Colors.red),
                            ),
                            Title: Text('${appSettings.translate(txn.category)} (${appSettings.translate(txn.account)})', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Subtitle: Text(appSettings.translate(txn.description)),
                            Trailing: Row(
                              MainAxisSize: MainAxisSize.min,
                              Children: [
                                Text(
                                  '${isIncome ? '+' : '-'} $curr ${txn.amount}',
                                  Style: TextStyle(color: isIncome ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  Icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                  OnPressed: () => _showAddEditTransactionDialog(context, index: index, txn: txn),
                                ),
                                IconButton(
                                  Icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                  OnPressed: () {
                                    ShowLocalizedDeleteDialog(
                                      Context: context,
                                      IsImportant: true,
                                      ItemName: txn.category,
                                      OnDeleteConfirmed: () {
                                        AppSettings.removeTransaction(index);
                                        SetState(() {});
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      FloatingActionButton: FloatingActionButton(
        BackgroundColor: const Color(0xFF10B981),
        OnPressed: () => _showAddEditTransactionDialog(context),
        Child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ----------------- Reports & Analysis Screen -----------------
class ReportsScreen extends StatefulWidget {
  Const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Bool isSortedAscending = true;

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    Double income = appSettings.getTotalIncome();
    Double expense = appSettings.getTotalExpense();
    Double budget = appSettings.monthlyBudget;
    Double progress = budget > 0 ? (expense / budget).clamp(0.0, 1.0) : 0.0;

    List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    List<int> years = List.generate(110, (index) => 1990 + index);

    Map<String, double> categoryExpenses = {};
    For (var txn in appSettings.getFilteredTransactions()) {
      If (txn.type == 'Expense') {
        CategoryExpenses[txn.category] = (categoryExpenses[txn.category] ?? 0.0) + txn.amount;
      }
    }

    Var categoryList = categoryExpenses.entries.toList();
    If (isSortedAscending) {
      CategoryList.sort((a, b) => a.value.compareTo(b.value));
    } else {
      CategoryList.sort((a, b) => b.value.compareTo(a.value));
    }

    Return Scaffold(
      AppBar: AppBar(
        Title: const Text('Reports & Analysis'),
        Actions: [
          Builder(
            Builder: (ctx) => IconButton(
              Icon: const Icon(Icons.download),
              Tooltip: 'Download',
              OnPressed: () {
                Final RenderBox box = ctx.findRenderObject() as RenderBox;
                Final offset = box.localToGlobal(Offset.zero);
                ShowStandardDownloadMenu(context, offset);
              },
            ),
          ),
          Builder(
            Builder: (ctx) => IconButton(
              Icon: const Icon(Icons.sort),
              Tooltip: 'Sort Categories',
              OnPressed: () {
                Final RenderBox box = ctx.findRenderObject() as RenderBox;
                Final offset = box.localToGlobal(Offset.zero);
                ShowStandardSortMenu(context, offset, (val) {
                  SetState(() => isSortedAscending = val.contains('Small-Large') || val.contains('A-Z') || val.contains('Old-New'));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report Sorted by: $val')));
                });
              },
            ),
          ),
        ],
      ),
      Drawer: const AppDrawer(),
      Body: SingleChildScrollView(
        Padding: const EdgeInsets.all(16.0),
        Child: Column(
          CrossAxisAlignment: CrossAxisAlignment.start,
          Children: [
            Row(
              Children: [
                Expanded(
                  Child: DropdownButtonFormField<int>(
                    Value: appSettings.selectedMonthIndex,
                    DropdownColor: Theme.of(context).cardColor,
                    Decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    Items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(months[i]))),
                    OnChanged: (val) { if (val != null) setState(() => appSettings.setMonthYear(val, appSettings.selectedYear)); },
                  ),
                ),
                Const SizedBox(width: 12),
                Expanded(
                  Child: DropdownButtonFormField<int>(
                    Value: appSettings.selectedYear,
                    DropdownColor: Theme.of(context).cardColor,
                    Decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    Items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                    OnChanged: (val) { if (val != null) setState(() => appSettings.setMonthYear(appSettings.selectedMonthIndex, val)); },
                  ),
                ),
              ],
            ),
            Const SizedBox(height: 16),
            Container(
              Padding: const EdgeInsets.all(16),
              Decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
              Child: Column(
                CrossAxisAlignment: CrossAxisAlignment.start,
                Children: [
                  Const Text('Monthly Budget Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Const SizedBox(height: 8),
                  Text('Budget: $budget $curr | Spent: $expense $curr', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  Const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress, color: const Color(0xFF10B981), backgroundColor: Colors.white12),
                  Const SizedBox(height: 16),
                  Row(
                    MainAxisAlignment: MainAxisAlignment.spaceBetween,
                    Children: [
                      Text('Total Income: $income $curr', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      Text('Total Expense: $expense $curr', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Const SizedBox(height: 20),
            Row(
              MainAxisAlignment: MainAxisAlignment.spaceBetween,
              Children: [
                Const Text('Expense Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  OnPressed: () {
                    SetState(() => isSortedAscending = !isSortedAscending);
                  },
                  Icon: const Icon(Icons.sort, size: 16, color: Color(0xFF10B981)),
                  Label: Text(isSortedAscending ? 'Sort: Low-High' : 'Sort: High-Low', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                ),
              ],
            ),
            Const SizedBox(height: 8),
            CategoryList.isEmpty
                ? const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text('No expense categories found', style: TextStyle(color: Colors.grey))))
                : ListView.builder(
                    ShrinkWrap: true,
                    Physics: const NeverScrollableScrollPhysics(),
                    ItemCount: categoryList.length,
                    ItemBuilder: (context, index) {
                      Final catEntry = categoryList[index];
                      Return Card(
                        Color: Theme.of(context).cardColor,
                        Margin: const EdgeInsets.only(bottom: 8),
                        Child: ListTile(
                          Leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.2), child: const Icon(Icons.category, color: Colors.redAccent)),
                          Title: Text(appSettings.translate(catEntry.key), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Trailing: Text('${catEntry.value} $curr', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Privacy & Security Screen -----------------
class PrivacySecurityScreen extends StatefulWidget {
  Const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  Late TextEditingController _pinController;
  Bool _obscurePin = true;

  Bool _faceLock = false;
  Bool _fingerprint = false;
  Bool _noneLock = false;
  Bool _patternLock = false;
  Bool _pinLock = true;

  @override
  Void initState() {
    Super.initState();
    _pinController = TextEditingController(text: appSettings.appPin);
    _faceLock = appSettings.useFaceLock;
    _fingerprint = appSettings.useFingerprint;
    _noneLock = appSettings.useNoneLock;
    _patternLock = appSettings.usePatternLock;
    _pinLock = appSettings.usePinLock;
  }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
      AppBar: AppBar(title: const Text('Privacy & Security')),
      Body: ListView(
        Padding: const EdgeInsets.all(16),
        Children: [
          Const Text('Security Options (Alphabetically Sorted)', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          Const SizedBox(height: 10),
          Card(
            Color: Theme.of(context).cardColor,
            Child: Column(
              Children: [
                SwitchListTile(
                  Title: const Text('Face Unlock'),
                  Subtitle: const Text('Scan & unlock with camera'),
                  Value: _faceLock,
                  ActiveColor: const Color(0xFF10B981),
                  OnChanged: (val) {
                    SetState(() {
                      _faceLock = val;
                      If (val) _noneLock = false;
                    });
                  },
                ),
                SwitchListTile(
                  Title: const Text('Fingerprint Sensor'),
                  Subtitle: const Text('Unlock using device fingerprint'),
                  Value: _fingerprint,
                  ActiveColor: const Color(0xFF10B981),
                  OnChanged: (val) {
                    SetState(() {
                      _fingerprint = val;
                      If (val) _noneLock = false;
                    });
                  },
                ),
                SwitchListTile(
                  Title: const Text('None (No Lock)'),
                  Subtitle: const Text('Bypass lock screen security'),
                  Value: _noneLock,
                  ActiveColor: const Color(0xFF10B981),
                  OnChanged: (val) {
                    SetState(() {
                      _noneLock = val;
                      If (val) {
                        _faceLock = false;
                        _fingerprint = false;
                        _patternLock = false;
                        _pinLock = false;
                      }
                    });
                  },
                ),
                SwitchListTile(
                  Title: const Text('Pattern Lock'),
                  Subtitle: const Text('Draw a secure pattern shape'),
                  Value: _patternLock,
                  ActiveColor: const Color(0xFF10B981),
                  OnChanged: (val) {
                    SetState(() {
                      _patternLock = val;
                      If (val) _noneLock = false;
                    });
                  },
                ),
                SwitchListTile(
                  Title: const Text('PIN Code Lock'),
                  Subtitle: const Text('Use a 4-digit numeric code'),
                  Value: _pinLock,
                  ActiveColor: const Color(0xFF10B981),
                  OnChanged: (val) {
                    SetState(() {
                      _pinLock = val;
                      If (val) _noneLock = false;
                    });
                  },
                ),
              ],
            ),
          ),
          Const SizedBox(height: 20),
          If (_pinLock) ...[
            Const Text('Change PIN Code', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            Const SizedBox(height: 10),
            Card(
              Color: Theme.of(context).cardColor,
              Child: Padding(
                Padding: const EdgeInsets.all(16.0),
                Child: TextField(
                  Controller: _pinController,
                  KeyboardType: TextInputType.number,
                  MaxLength: 4,
                  ObscureText: _obscurePin,
                  Decoration: InputDecoration(
                    LabelText: '4-Digit App PIN',
                    Border: const OutlineInputBorder(),
                    CounterText: '',
                    SuffixIcon: IconButton(
                      Icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                      OnPressed: () => setState(() => _obscurePin = !_obscurePin),
                    ),
                  ),
                ),
              ),
            ),
          ],
          Const SizedBox(height: 30),
          SizedBox(
            Width: double.infinity,
            Child: ElevatedButton(
              Style: ElevatedButton.styleFrom(
                BackgroundColor: const Color(0xFF10B981),
                Padding: const EdgeInsets.symmetric(vertical: 16),
                Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              OnPressed: () {
                If (_pinController.text.length == 4 || _noneLock || !_pinLock) {
                  If (_pinLock) appSettings.updatePin(_pinController.text);
                  AppSettings.updateSecurityToggles(
                    Face: _faceLock,
                    Fingerprint: _fingerprint,
                    None: _noneLock,
                    Pattern: _patternLock,
                    Pin: _pinLock,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security settings updated successfully!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be exactly 4 digits!')));
                }
              },
              Child: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- Notification Settings Screen -----------------
class NotificationSettingsScreen extends StatefulWidget {
  Const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  Late bool daily;
  Late bool budget;
  Late bool loan;
  String selectedSound = 'Default';

  @override
  Void initState() {
    Super.initState();
    Daily = appSettings.dailyReminder;
    Budget = appSettings.budgetAlert;
    Loan = appSettings.loanAlert;
    SelectedSound = appSettings.notificationSound;
  }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
      AppBar: AppBar(title: const Text('Notification Settings')),
      Body: ListView(
        Padding: const EdgeInsets.all(16),
        Children: [
          Const Text('Manage App Alerts & Reminders', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          Const SizedBox(height: 10),
          Card(
            Color: Theme.of(context).cardColor,
            Child: Column(
              Children: [
                SwitchListTile(
                  Title: const Text('Daily Transaction Reminder'),
                  Subtitle: const Text('Get reminded to record daily expenses'),
                  Value: daily,
                  ActiveColor: const Color(0xFF10B981),
                  OnChanged: (val) => setState(() => daily = val),
                ),
                SwitchListTile(
                  Title: const Text('Budget Limit Alert'),
                  Subtitle: const Text('Notify when expenses reach near budget limit'),
                  Value: budget,
                  ActiveColor: const Color(0xFF10B981),
                  OnChanged: (val) => setState(() => budget = val),
                ),
                SwitchListTile(
                  Title: const Text('Loan Payment Due Alert'),
                  Subtitle: const Text('Alert on upcoming loan settlement dates'),
                  Value: loan,
                  ActiveColor: const Color(0xFF10B981),
                  OnChanged: (val) => setState(() => loan = val),
                ),
              ],
            ),
          ),
          Const SizedBox(height: 20),
          Const Text('Notification Sound & Alert Tone', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          Const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            Value: selectedSound,
            DropdownColor: Theme.of(context).cardColor,
            Decoration: const InputDecoration(border: OutlineInputBorder()),
            Items: ['Default', 'App Chime', 'Custom from Device Memory'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            OnChanged: (val) { if (val != null) setState(() => selectedSound = val); },
          ),
          Const SizedBox(height: 30),
          SizedBox(
            Width: double.infinity,
            Child: ElevatedButton(
              Style: ElevatedButton.styleFrom(
                BackgroundColor: const Color(0xFF10B981),
                Padding: const EdgeInsets.symmetric(vertical: 16),
                Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              OnPressed: () {
                AppSettings.toggleNotification('daily', daily);
                AppSettings.toggleNotification('budget', budget);
                AppSettings.toggleNotification('loan', loan);
                AppSettings.setNotificationSound(selectedSound);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings updated successfully!')));
              },
              Child: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- Profile & Settings Screen -----------------
class ProfileScreen extends StatefulWidget {
  Const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Final ImagePicker _picker = ImagePicker();

  Void _showProfileImagePicker() {
    ShowModalBottomSheet(
      Context: context,
      Builder: (ctx) => Wrap(
        Children: [
          ListTile(
            Leading: const Icon(Icons.camera_alt, color: Color(0xFF10B981)),
            Title: const Text('Take Photo with Camera'),
            OnTap: () async {
              Navigator.pop(ctx);
              Final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              If (image != null) {
                AppSettings.updateProfile(
                  Name: appSettings.profileName,
                  Email: appSettings.profileEmail,
                  Gender: appSettings.profileGender,
                  BirthDate: appSettings.profileBirthDate,
                  Mobile: appSettings.profileMobile,
                  ImagePath: image.path,
                );
                SetState(() {});
              }
            },
          ),
          ListTile(
            Leading: const Icon(Icons.photo_library, color: Color(0xFF10B981)),
            Title: const Text('Choose from Gallery'),
            OnTap: () async {
              Navigator.pop(ctx);
              Final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              If (image != null) {
                AppSettings.updateProfile(
                  Name: appSettings.profileName,
                  Email: appSettings.profileEmail,
                  Gender: appSettings.profileGender,
                  BirthDate: appSettings.profileBirthDate,
                  Mobile: appSettings.profileMobile,
                  ImagePath: image.path,
                );
                SetState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  Void _showEditProfileDialog(BuildContext context) {
    Final nameC = TextEditingController(text: appSettings.profileName);
    Final emailC = TextEditingController(text: appSettings.profileEmail);
    Final genderC = TextEditingController(text: appSettings.profileGender);
    Final birthDateC = TextEditingController(text: appSettings.profileBirthDate);
    Final mobileC = TextEditingController(text: appSettings.profileMobile);

    ShowDialog(
      Context: context,
      Builder: (ctx) => AlertDialog(
        Title: const Text('Edit Profile'),
        Content: SingleChildScrollView(
          Child: Column(
            MainAxisSize: MainAxisSize.min,
            Children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
              Const SizedBox(height: 12),
              TextField(controller: emailC, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              Const SizedBox(height: 12),
              TextField(controller: genderC, decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder())),
              Const SizedBox(height: 12),
              TextField(controller: birthDateC, decoration: const InputDecoration(labelText: 'Birth Date (DD-MM-YYYY)', border: OutlineInputBorder())),
              Const SizedBox(height: 12),
              TextField(controller: mobileC, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
            ],
          ),
        ),
        Actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            Style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            OnPressed: () {
              AppSettings.updateProfile(
                Name: nameC.text,
                Email: emailC.text,
                Gender: genderC.text,
                BirthDate: birthDateC.text,
                Mobile: mobileC.text,
              );
              Navigator.pop(ctx);
              SetState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
            },
            Child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
      AppBar: AppBar(title: const Text('Profile & Settings')),
      Drawer: const AppDrawer(),
      Body: ListView(
        Padding: const EdgeInsets.all(16),
        Children: [
          Container(
            Padding: const EdgeInsets.all(20),
            Decoration: BoxDecoration(
              Color: const Color(0xFF10B981),
              BorderRadius: BorderRadius.circular(16),
            ),
            Child: Column(
              Children: [
                Stack(
                  Children: [
                    CircleAvatar(
                      Radius: 35,
                      BackgroundColor: Colors.white,
                      BackgroundImage: appSettings.profileImagePath.isNotEmpty ? FileImage(File(appSettings.profileImagePath)) : null,
                      Child: appSettings.profileImagePath.isEmpty ? const Icon(Icons.person, size: 45, color: Color(0xFF10B981)) : null,
                    ),
                    Positioned(
                      Bottom: 0,
                      Right: 0,
                      Child: InkWell(
                        OnTap: _showProfileImagePicker,
                        Child: Container(
                          Padding: const EdgeInsets.all(6),
                          Decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                          Child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Const SizedBox(height: 12),
                Text(appSettings.profileName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Const SizedBox(height: 4),
                Text(appSettings.profileEmail, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Const SizedBox(height: 8),
                Text('Gender: ${appSettings.profileGender} | DOB: ${appSettings.profileBirthDate}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Const SizedBox(height: 4),
                Text('Mobile: ${appSettings.profileMobile}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Const SizedBox(height: 14),
                ElevatedButton.icon(
                  Style: ElevatedButton.styleFrom(
                    BackgroundColor: Colors.black26,
                    ForegroundColor: Colors.white,
                    Elevation: 0,
                    Shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  OnPressed: () => _showEditProfileDialog(context),
                  Icon: const Icon(Icons.edit, size: 16),
                  Label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          Const SizedBox(height: 20),
          Const Text('Account', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          Const SizedBox(height: 8),
          Card(
            Color: Theme.of(context).cardColor,
            Child: ListTile(
              Leading: const Icon(Icons.lock_outline, color: Color(0xFF10B981)),
              Title: const Text('Privacy & Security'),
              Trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              OnTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySecurityScreen())),
            ),
          ),
          Const SizedBox(height: 16),
          Const Text('Preferences', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          Const SizedBox(height: 8),
          Card(
            Color: Theme.of(context).cardColor,
            Child: ListTile(
              Leading: const Icon(Icons.notifications_none, color: Color(0xFF10B981)),
              Title: const Text('Notification Settings'),
              Trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              OnTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
            ),
          ),
          Const SizedBox(height: 16),
          Card(
            Color: Theme.of(context).cardColor,
            Child: ListTile(
              Leading: const Icon(Icons.logout, color: Colors.redAccent),
              Title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              OnTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinLockScreen()));
              },
            ),
          ),
          Const SizedBox(height: 20),
          Const Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }
}

// ----------------- Main Navigation Container -----------------
class MainHomeScreen extends StatefulWidget {
  Const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  Int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Final List<Widget> pages = [
      Const HomeScreenContent(),
      Const LoanDebtScreen(),
      Const AllTransactionsScreen(), 
      Const ReportsScreen(),
      Const ProfileScreen(),
    ];

    Return Scaffold(
      Body: pages[_currentIndex],
      BottomNavigationBar: AnimatedBuilder(
        Animation: appSettings,
        Builder: (context, child) {
          Return BottomNavigationBar(
            CurrentIndex: _currentIndex,
            OnTap: (index) => setState(() => _currentIndex = index),
            Type: BottomNavigationBarType.fixed,
            SelectedItemColor: const Color(0xFF10B981),
            UnselectedItemColor: Colors.grey,
            BackgroundColor: const Color(0xFF1E293B),
            Items: [
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
