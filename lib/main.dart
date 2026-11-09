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

// ----------------- State Management -----------------
class AppSettingsNotifier extends ChangeNotifier {
  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.dark;
  String _language = 'System Default'; 
  String currency = '৳';
  String timeFilter = 'This Month';
  String appPin = '1234';

  String profileName = 'Md. Alamgir Hossain';
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

  final Map<String, bool> _hiddenStatusMap = {};

  bool isHidden(String key) {
    return _hiddenStatusMap[key] ?? true; 
  }

  void toggleHide(String key) {
    _hiddenStatusMap[key] = !isHidden(key);
    notifyListeners();
  }

  int selectedMonthIndex = DateTime.now().month;
  int selectedYear = DateTime.now().year;

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
      personName: 'Rofiqul Islam',
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
    _language = _prefs.getString('language') ?? 'System Default'; 
    String themeStr = _prefs.getString('themeMode') ?? 'dark';
    if (themeStr == 'light') _themeMode = ThemeMode.light;
    else if (themeStr == 'system') _themeMode = ThemeMode.system;
    else _themeMode = ThemeMode.dark;

    profileName = _prefs.getString('profileName') ?? 'Md. Alamgir Hossain';
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

  Locale? getLocale() {
    if (_language == 'Bangla') return const Locale('bn', 'BD');
    if (_language == 'Arabic') return const Locale('ar', 'AE');
    if (_language == 'English') return const Locale('en', 'US');
    return null; 
  }

  String localizeNumber(dynamic number) {
    String str = number.toString();
    if (_language != 'Bangla') return str;
    const EnglishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const BanglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < EnglishDigits.length; i++) {
      str = str.replaceAll(EnglishDigits[i], BanglaDigits[i]);
    }
    return str;
  }

  String getLocalizedMonth(int monthIndex) {
    List<String> engMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    List<String> banMonths = ['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    List<String> arbMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    
    if (monthIndex < 1 || monthIndex > 12) return engMonths[0];
    if (_language == 'Bangla') return banMonths[monthIndex - 1];
    if (_language == 'Arabic') return arbMonths[monthIndex - 1];
    return engMonths[monthIndex - 1];
  }

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
        case 'System Default': return 'সিস্টেম ডিফল্ট';
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
        case 'Enter Your PIN': return 'আপনার পিন লিখুন';
        case 'Unlock': return 'আনলক করুন';
        case 'Forgot PIN?': return 'পিন ভুলে গেছেন?';
        case 'This Month': return 'চলতি মাস';
        case 'Custom Months': return 'কাস্টম মাস';
        case 'Custom Years': return 'কাস্টম বছর';
        case 'Custom Range': return 'কাস্টম রেঞ্জ';
        case 'Financial Overview Summary': return 'আর্থিক সারসংক্ষেপ';
        case 'Total Balance': return 'মোট ব্যালেন্স';
        case 'Total Income': return 'মোট আয়';
        case 'Total Expense': return 'মোট ব্যয়';
        case 'Loan & Debt Overview': return 'ঋণ ও দেনার বিবরণী';
        case 'Total Loan Given': return 'মোট প্রদত্ত লোন';
        case 'Total Loan Taken': return 'মোট গৃহীত লোন';
        case 'Start Date': return 'শুরুর তারিখ';
        case 'End Date': return 'শেষ তারিখ';
        case 'Loan & Debt': return 'লোন ও দেনা';
        case 'Search (note, category)...': return 'অনুসন্ধান (নোট, ক্যাটাগরি)...';
        case 'Reports & Analysis': return 'রিপোর্ট ও বিশ্লেষণ';
        case 'Monthly Budget Overview': return 'মাসিক বাজেট সারসংক্ষেপ';
        case 'Expense Categories': return 'ব্যয়ের ক্যাটাগরি';
        case 'All Transactions': return 'সকল লেনদেন';
        case 'All': return 'সকল';
        case 'Given': return 'প্রদত্ত';
        case 'Taken': return 'গৃহীত';
        case 'Paid': return 'পরিশোধিত';
        case 'Loan List': return 'লোনের তালিকা';
        case 'No loans found': return 'কোনো লোন পাওয়া যায়নি';
        case 'Sort: Low-High': return 'সর্ট: কম থেকে বেশি';
        case 'Sort: High-Low': return 'সর্ট: বেশি থেকে কম';
        case 'Profile & Settings': return 'প্রোফাইল ও সেটিংস';
        case 'Edit Profile': return 'প্রোফাইল সম্পাদনা করুন';
        case 'Privacy & Security': return 'গোপনীয়তা ও নিরাপত্তা';
        case 'Notification Settings': return 'নোটিফিকেশন সেটিংস';
        case 'Sign Out': return 'লগআউট';
        case 'Version 1.0.0': return 'সংস্করণ ১.০.০';
        case 'Security Options': return 'নিরাপত্তা অপশনসমূহ';
        case 'Face Unlock': return 'ফেস আনলক';
        case 'Scan & unlock with camera': return 'ক্যামেরা স্ক্যান করে আনলক করুন';
        case 'Fingerprint Sensor': return 'ফিঙ্গারপ্রিন্ট সেন্সর';
        case 'Unlock using device fingerprint': return 'ডিভাইস ফিঙ্গারপ্রিন্ট ব্যবহার করুন';
        case 'None (No Lock)': return 'কোনো লক নেই';
        case 'Bypass lock screen security': return 'লক স্ক্রিন নিরাপত্তা বাইপাস করুন';
        case 'Pattern Lock': return 'প্যাটার্ন লক';
        case 'Draw a secure pattern shape': return 'নিরাপদ প্যাটার্ন আঁকুন';
        case 'PIN Code Lock': return 'পিন কোড লক';
        case 'Use a 4-digit numeric code': return '৪-সংখ্যার সংখ্যাসূচক কোড ব্যবহার করুন';
        case 'Change PIN Code': return 'পিন কোড পরিবর্তন করুন';
        case '4-Digit App PIN': return '৪-সংখ্যার অ্যাপ পিন';
        case 'Save Changes': return 'পরিবর্তন সংরক্ষণ করুন';
        case 'Manage App Alerts & Reminders': return 'অ্যাপ অ্যালার্ট ও রিমাইন্ডার ম্যানেজ করুন';
        case 'Daily Transaction Reminder': return 'দৈনিক লেনদেন রিমাইন্ডার';
        case 'Get reminded to record daily expenses': return 'প্রতিদিনের খরচ রেকর্ড করার কথা মনে করিয়ে দিন';
        case 'Budget Limit Alert': return 'বাজেট সীমা অ্যালার্ট';
        case 'Notify when expenses reach near budget limit': return 'ব্যয় বাজেট সীমার কাছাকাছি পৌঁছালে জানান';
        case 'Loan Payment Due Alert': return 'লোন পরিশোধের তারিখের অ্যালার্ট';
        case 'Alert on upcoming loan settlement dates': return 'আসন্ন লোন পরিশোধের তারিখ সম্পর্কে সতর্ক করুন';
        case 'Notification Sound & Alert Tone': return 'নোটিফিকেশন সাউন্ড ও অ্যালার্ট টোন';
        case 'Default': return 'ডিফল্ট';
        case 'App Chime': return 'অ্যাপ চইম';
        case 'Custom from Device Memory': return 'ডিভাইস মেমোরি থেকে কাস্টম';
        case 'Monthly Salary': return 'মাসিক বেতন';
        case 'Evening snacks': return 'বিকেলের নাস্তা';
        case 'Preferences': return 'পছন্দসমূহ';
        case 'Male': return 'পুরুষ';
        case 'Female': return 'মহিলা';
        case 'Other': return 'অন্যান্য';
        case 'Gender': return 'লিঙ্গ';
        case 'DOB': return 'জন্মতারিখ';
        case 'Birth Date (DD-MM-YYYY)': return 'জন্মতারিখ (দিন-মাস-বছর)';
        case 'Mobile': return 'মোবাইল';
        case 'Mobile Number': return 'মোবাইল নম্বর';
        case 'Name': return 'নাম';
        case 'Email': return 'ইমেল';
        case 'Net Balance': return 'নিট ব্যালেন্স';
        case 'Spent': return 'ব্যয় হয়েছে';
        case 'Budget:': return 'বাজেট:';
        case 'Spent:': return 'ব্যয়:';
        case 'Total Income:': return 'মোট আয়:';
        case 'Total Expense:': return 'মোট ব্যয়:';
        case 'Cancel': return 'বাতিল';
        case 'Save': return 'সংরক্ষণ';
        case 'Add Account': return 'অ্যাকাউন্ট যোগ করুন';
        case 'Edit Account': return 'অ্যাকাউন্ট সম্পাদনা';
        case 'Account Name': return 'অ্যাকাউন্টের নাম';
        case 'Type': return 'ধরন';
        case 'Details / Account Number': return 'বিবরণ / অ্যাকাউন্ট নম্বর';
        case 'Add New Transaction': return 'নতুন লেনদেন যোগ করুন';
        case 'Edit Transaction': return 'লেনদেন সম্পাদনা';
        case 'Cash In': return 'আয় (Cash In)';
        case 'Cash Out': return 'ব্যয় (Cash Out)';
        case 'Description': return 'বিবরণ';
        case 'Amount': return 'পরিমাণ';
        case 'Person Name': return 'ব্যক্তির নাম';
        case 'Add New Loan / Debt': return 'নতুন লোন বা দেনা যোগ করুন';
        case 'Edit Loan / Debt': return 'লোন বা দেনা সম্পাদনা করুন';
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
        case 'System Default': return 'النظام الافتراضي';
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
        case 'Grocery': return 'بقالة';
        case 'Others': return 'أخرى';
        case 'Salary': return 'راتب';
        case 'Tea & Snacks': return 'شاي ووجبات خفيفة';
        case 'Transport': return 'مواصلات';
        case 'Food & Hotel': return 'طعام وفنادق';
        case 'Bikash': return 'بیکاش';
        case 'Cash in Hand': return 'نقداً في اليد';
        case 'Dutch-Bangla Bank': return 'بنك دتش بنگلا';
        case 'Nagad': return 'نقد';
        case 'UCB Bank': return 'بنك UCB';
        case 'Mobile Banking': return 'خدمات مصرفية عبر الهاتف المحمول';
        case 'Cash': return 'نقدي';
        case 'Bank': return 'بنك';
        case 'Settings': return 'الإعدادات';
        case 'Goals': return 'الأهداف';
        case 'Calculators': return 'الحاسبات';
        case 'Enter Your PIN': return 'أدخل رقم التعريف الشخصي';
        case 'Unlock': return 'فتح القفل';
        case 'Forgot PIN?': return 'هل نسيت رقم التعريف الشخصي؟';
        case 'This Month': return 'هذا الشهر';
        case 'Custom Months': return 'أشهر مخصصة';
        case 'Custom Years': return 'سنوات مخصصة';
        case 'Custom Range': return 'نطاق مخصص';
        case 'Financial Overview Summary': return 'ملخص النظرة العامة المالية';
        case 'Total Balance': return 'الإجمالي الكلي';
        case 'Total Income': return 'إجمالي الدخل';
        case 'Total Expense': return 'إجمالي المصروفات';
        case 'Loan & Debt Overview': return 'نظرة عامة على القروض والديون';
        case 'Total Loan Given': return 'إجمالي القروض الممنوحة';
        case 'Total Loan Taken': return 'إجمالي القروض المستلمة';
        case 'Start Date': return 'تاريخ البدء';
        case 'End Date': return 'تاريخ الانتهاء';
        case 'Loan & Debt': return 'القروض والديون';
        case 'Search (note, category)...': return 'بحث (ملاحظة، فئة)...';
        case 'Reports & Analysis': return 'التقارير والتحليلات';
        case 'Monthly Budget Overview': return 'نظرة عامة على الميزانية الشهرية';
        case 'Expense Categories': return 'فئات المصروفات';
        case 'All Transactions': return 'جميع المعاملات';
        case 'All': return 'الكل';
        case 'Given': return 'ممنوح';
        case 'Taken': return 'مستلم';
        case 'Paid': return 'مدفوع';
        case 'Loan List': return 'قائمة القروض';
        case 'No loans found': return 'لم يتم العثور على قروض';
        case 'Sort: Low-High': return 'ترتيب: من الأقل إلى الأعلى';
        case 'Sort: High-Low': return 'ترتيب: من الأعلى إلى الأقل';
        case 'Profile & Settings': return 'الملف الشخصي والإعدادات';
        case 'Edit Profile': return 'تعديل الملف الشخصي';
        case 'Privacy & Security': return 'الخصوصية والأمان';
        case 'Notification Settings': return 'إعدادات الإشعارات';
        case 'Sign Out': return 'تسجيل الخروج';
        case 'Version 1.0.0': return 'الإصدار 1.0.0';
        case 'Security Options': return 'خيارات الأمان';
        case 'Face Unlock': return 'فتح القفل بالوجه';
        case 'Scan & unlock with camera': return 'الفتح بالكاميرا';
        case 'Fingerprint Sensor': return 'مستشعر بصمة الإصبع';
        case 'Unlock using device fingerprint': return 'فتح القفل باستخدام بصمة الجهاز';
        case 'None (No Lock)': return 'بلا (بدون قفل)';
        case 'Bypass lock screen security': return 'تجاوز أمان شاشة القفل';
        case 'Pattern Lock': return 'قفل النمط';
        case 'Draw a secure pattern shape': return 'رسم نمط آمن';
        case 'PIN Code Lock': return 'قفل رمز PIN';
        case 'Use a 4-digit numeric code': return 'استخدام رمز مكون من 4 أرقام';
        case 'Change PIN Code': return 'تغيير رمز PIN';
        case '4-Digit App PIN': return 'رمز PIN للتطبيق مكون من 4 أرقام';
        case 'Save Changes': return 'حفظ التغييرات';
        case 'Manage App Alerts & Reminders': return 'إدارة تنبيهات وتذكيرات التطبيق';
        case 'Daily Transaction Reminder': return 'تذكير المعاملات اليومية';
        case 'Get reminded to record daily expenses': return 'التذكير بتسجيل المصروفات اليومية';
        case 'Budget Limit Alert': return 'تنبيه حد الميزانية';
        case 'Notify when expenses reach near budget limit': return 'التنبيه عند وصول المصروفات إلى حد الميزانية';
        case 'Loan Payment Due Alert': return 'تنبيه استحقاق سداد القرض';
        case 'Alert on upcoming loan settlement dates': return 'التنبيه بمواعيد تسوية القروض القادمة';
        case 'Notification Sound & Alert Tone': return 'صوت الإشعار ونغمة التنبيه';
        case 'Default': return 'افتراضي';
        case 'App Chime': return 'رنين التطبيق';
        case 'Custom from Device Memory': return 'مخصص من ذاكرة الجهاز';
        case 'Monthly Salary': return 'راتب شهري';
        case 'Evening snacks': return 'وجبة خفيفة المساء';
        case 'Preferences': return 'التفضيلات';
        case 'Male': return 'ذكر';
        case 'Female': return 'أنثى';
        case 'Other': return 'آخر';
        case 'Gender': return 'الجنس';
        case 'DOB': return 'تاريخ الميلاد';
        case 'Birth Date (DD-MM-YYYY)': return 'تاريخ الميلاد (يوم-شهر-سنة)';
        case 'Mobile': return 'محمول';
        case 'Mobile Number': return 'رقم الهاتف المحمول';
        case 'Name': return 'الاسم';
        case 'Email': return 'البريد الإلكتروني';
        case 'Net Balance': return 'الرصيد الصافي';
        case 'Spent': return 'المصروف';
        case 'Budget:': return 'الميزانية:';
        case 'Spent:': return 'المصروف:';
        case 'Total Income:': return 'إجمالي الدخل:';
        case 'Total Expense:': return 'إجمالي المصروفات:';
        case 'Cancel': return 'إلغاء';
        case 'Save': return 'حفظ';
        case 'Add Account': return 'إضافة حساب';
        case 'Edit Account': return 'تعديل الحساب';
        case 'Account Name': return 'اسم الحساب';
        case 'Type': return 'النوع';
        case 'Details / Account Number': return 'التفاصيل / رقم الحساب';
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

  void setCurrency(String newCurrency) {
    currency = newCurrency;
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

  double getAccountBalance(String accountName) {
    double balance = 0;
    for (var txn in transactions) {
      if (txn.account == accountName) {
        if (txn.type == 'Income') {
          balance += txn.amount;
        } else if (txn.type == 'Expense') {
          balance -= txn.amount;
        }
      }
    }
    return balance;
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
      } else if (timeFilter == 'Custom Years') {
        return txn.date.year == selectedYear;
      } else if (timeFilter == 'Custom Months') {
        return txn.date.year == selectedYear && txn.date.month == selectedMonthIndex;
      } else {
        return txn.date.year == DateTime.now().year && txn.date.month == DateTime.now().month;
      }
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
    double total = 0;
    for (var txn in transactions) {
      if (txn.type == 'Income') total += txn.amount;
      if (txn.type == 'Expense') total -= txn.amount;
    }
    return total;
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

// ----------------- Helper for Language-Adaptive DatePicker -----------------
Future<DateTime?> showLocalizedDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  Locale? currentLocale = appSettings.getLocale();
  bool isDark = Theme.of(context).brightness == Brightness.dark;
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    locale: currentLocale,
    builder: (context, child) {
      return Localizations.override(
        context: context,
        locale: currentLocale ?? Localizations.localeOf(context),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF10B981),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF10B981),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
            dialogBackgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          ),
          child: child!,
        ),
      );
    },
  );
}

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
          locale: appSettings.getLocale(),
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
            primaryColor: const Color(0xFF38BDF8),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
            dialogTheme: const DialogTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
            bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF10B981),
            cardColor: const Color(0xFF1E293B),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white),
            dialogTheme: const DialogTheme(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
            bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFF1E293B), surfaceTintColor: Color(0xFF1E293B)),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            ),
          ),
          home: const PinLockScreen(),
        );
      },
    );
  }
}

// ----------------- Menus & Helpers -----------------
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
  String msg1 = lang == 'Bangla' 
      ? 'আপনি কি আসলেই "$itemName" ডিলিট করতে চান?' 
      : (lang == 'Arabic' ? 'هل أنت متأكد أنك تريد حذف "$itemName"؟' : 'Are you sure you want to delete "$itemName"?');
  
  String warningMsg = lang == 'Bangla'
      ? 'সতর্কতা: এটি অন্য কোনো রেকর্ডের সাথে জড়িত। ডিলিট করলে ডাটা প্রভাবিত হতে পারে। নিশ্চিত?'
      : (lang == 'Arabic' ? 'تحذير: هذا مرتبط بسجل آخر. هل أنت متأكد؟' : 'Warning: This is linked with other records. Are you sure?');
  
  String yesText = lang == 'Bangla' ? 'হ্যাঁ' : (lang == 'Arabic' ? 'نعم' : 'Yes');
  String noText = lang == 'Bangla' ? 'না' : (lang == 'Arabic' ? 'لا' : 'No');

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
        const SnackBar(content: Text('Wrong PIN! Please try again.'), backgroundColor: Colors.red),
      );
      _pinController.clear();
      setState(() {});
    }
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
                  RadioListTile<String>(
                    title: const Text('Arabic (العربية)'),
                    value: 'Arabic',
                    groupValue: appSettings.language,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      if (val != null) {
                        appSettings.setLanguage(val);
                        setStateDialog(() {});
                        setState(() {});
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
                        setState(() {});
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
                        appSettings.setLanguage(val);
                        setStateDialog(() {});
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.language == 'Bangla' ? 'বন্ধ করুন' : (appSettings.language == 'Arabic' ? 'إغلاق' : 'Close'))),
              ],
            );
          },
        );
      },
    );
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
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, size: 60, color: Color(0xFF10B981)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appSettings.getAppTitle(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(appSettings.translate('Enter Your PIN'), style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                  const SizedBox(height: 24),
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
                      child: Text(appSettings.translate('Unlock'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _showForgotPinDialog(context),
                    child: Text(appSettings.translate('Forgot PIN?'), style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: () => _showLanguageDialog(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, color: Color(0xFF38BDF8), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              appSettings.language == 'Bangla' ? 'ভাষা পরিবর্তন' : (appSettings.language == 'Arabic' ? 'تغيير اللغة' : 'Change Language'),
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- Dashboard Analytics Screen -----------------
class DashboardAnalyticsScreen extends StatefulWidget {
  const DashboardAnalyticsScreen({super.key});

  @override
  State<DashboardAnalyticsScreen> createState() => _DashboardAnalyticsScreenState();
}

class _DashboardAnalyticsScreenState extends State<DashboardAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    double income = appSettings.getTotalIncome();
    double expense = appSettings.getTotalExpense();
    double balance = appSettings.getTotalBalance();
    double totalGiven = appSettings.getTotalGiven();
    double totalTaken = appSettings.getTotalTaken();

    List<int> years = List.generate(110, (index) => 1990 + index);

    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(appSettings.translate('Dashboard Analytics'))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(appSettings.translate('This Month')),
                      selected: appSettings.timeFilter == 'This Month',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (val) {
                        appSettings.setTimeFilter('This Month');
                        appSettings.setMonthYear(DateTime.now().month, DateTime.now().year);
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(appSettings.translate('Custom Months')),
                      selected: appSettings.timeFilter == 'Custom Months',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (val) {
                        appSettings.setTimeFilter('Custom Months');
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(appSettings.translate('Custom Years')),
                      selected: appSettings.timeFilter == 'Custom Years',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (val) {
                        appSettings.setTimeFilter('Custom Years');
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(appSettings.translate('Custom Range')),
                      selected: appSettings.timeFilter == 'Custom Range',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (val) {
                        appSettings.setTimeFilter('Custom Range');
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (appSettings.timeFilter == 'Custom Months')
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: appSettings.selectedMonthIndex,
                        dropdownColor: Theme.of(context).cardColor,
                        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(appSettings.getLocalizedMonth(i + 1)))),
                        onChanged: (val) { if (val != null) { appSettings.setMonthYear(val, appSettings.selectedYear); setState(() {}); } },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: appSettings.selectedYear,
                        dropdownColor: Theme.of(context).cardColor,
                        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: years.map((y) => DropdownMenuItem(value: y, child: Text(appSettings.localizeNumber(y)))).toList(),
                        onChanged: (val) { if (val != null) { appSettings.setMonthYear(appSettings.selectedMonthIndex, val); setState(() {}); } },
                      ),
                    ),
                  ],
                ),
              if (appSettings.timeFilter == 'Custom Years')
                DropdownButtonFormField<int>(
                  value: appSettings.selectedYear,
                  dropdownColor: Theme.of(context).cardColor,
                  decoration: InputDecoration(labelText: appSettings.translate('Year'), border: const OutlineInputBorder()),
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text(appSettings.localizeNumber(y)))).toList(),
                  onChanged: (val) { if (val != null) { appSettings.setMonthYear(appSettings.selectedMonthIndex, val); setState(() {}); } },
                ),
              if (appSettings.timeFilter == 'Custom Range')
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showLocalizedDatePicker(
                            context: context,
                            initialDate: appSettings.customStartDate ?? DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            appSettings.setCustomDateRange(picked, appSettings.customEndDate ?? picked);
                            setState(() {});
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: TextEditingController(text: appSettings.customStartDate != null ? appSettings.localizeNumber(appSettings.customStartDate.toString().substring(0, 10)) : appSettings.translate('Start Date')),
                            decoration: InputDecoration(border: const OutlineInputBorder(), labelText: appSettings.translate('Start Date'), suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showLocalizedDatePicker(
                            context: context,
                            initialDate: appSettings.customEndDate ?? DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            appSettings.setCustomDateRange(appSettings.customStartDate ?? picked, picked);
                            setState(() {});
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: TextEditingController(text: appSettings.customEndDate != null ? appSettings.localizeNumber(appSettings.customEndDate.toString().substring(0, 10)) : appSettings.translate('End Date')),
                            decoration: InputDecoration(border: const OutlineInputBorder(), labelText: appSettings.translate('End Date'), suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Text(appSettings.translate('Financial Overview Summary'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(appSettings.translate('Total Balance'), style: const TextStyle(color: Colors.grey)),
                        Text(
                          '${appSettings.localizeNumber(balance)} $curr', 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: balance >= 0 ? const Color(0xFF10B981) : Colors.redAccent)
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(appSettings.translate('Total Income'), style: const TextStyle(color: Colors.grey)),
                        Text(
                          '${appSettings.localizeNumber(income)} $curr', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(appSettings.translate('Total Expense'), style: const TextStyle(color: Colors.grey)),
                        Text(
                          '${appSettings.localizeNumber(expense)} $curr', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(appSettings.translate('Loan & Debt Overview'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(appSettings.translate('Total Loan Given'), style: const TextStyle(color: Colors.grey)),
                        Text(
                          '${appSettings.localizeNumber(totalGiven)} $curr', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(appSettings.translate('Total Loan Taken'), style: const TextStyle(color: Colors.grey)),
                        Text(
                          '${appSettings.localizeNumber(totalTaken)} $curr', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)
                        ),
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
class CalculatorsHubScreen extends StatefulWidget {
  const CalculatorsHubScreen({super.key});

  @override
  State<CalculatorsHubScreen> createState() => _CalculatorsHubScreenState();
}

class _CalculatorsHubScreenState extends State<CalculatorsHubScreen> {
  int selectedCalcIndex = 0;
  String calcDisplay = '0';
  double loanAmount = 100000;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(appSettings.translate('Calculators'))),
        body: Column(
          children: [
            Container(
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(onPressed: () => setState(() => selectedCalcIndex = 0), child: Text('General', style: TextStyle(color: selectedCalcIndex == 0 ? const Color(0xFF10B981) : Colors.grey))),
                  TextButton(onPressed: () => setState(() => selectedCalcIndex = 1), child: Text('Loan / EMI', style: TextStyle(color: selectedCalcIndex == 1 ? const Color(0xFF10B981) : Colors.grey))),
                  TextButton(onPressed: () => setState(() => selectedCalcIndex = 2), child: Text('SIP / Interest', style: TextStyle(color: selectedCalcIndex == 2 ? const Color(0xFF10B981) : Colors.grey))),
                ],
              ),
            ),
            Expanded(
              child: selectedCalcIndex == 0 
                ? _buildGeneralCalculator()
                : (selectedCalcIndex == 1 ? _buildLoanCalculator() : _buildSipCalculator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralCalculator() {
    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(24),
            child: Text(appSettings.localizeNumber(calcDisplay), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _calcBtn('C', Colors.red),
                  _calcBtn('(', Colors.grey),
                  _calcBtn(')', Colors.grey),
                  _calcBtn('/', Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _calcBtn('7', Colors.blueGrey),
                  _calcBtn('8', Colors.blueGrey),
                  _calcBtn('9', Colors.blueGrey),
                  _calcBtn('*', Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _calcBtn('4', Colors.blueGrey),
                  _calcBtn('5', Colors.blueGrey),
                  _calcBtn('6', Colors.blueGrey),
                  _calcBtn('-', Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _calcBtn('1', Colors.blueGrey),
                  _calcBtn('2', Colors.blueGrey),
                  _calcBtn('3', Colors.blueGrey),
                  _calcBtn('+', Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _calcBtn('0', Colors.blueGrey),
                  _calcBtn('.', Colors.blueGrey),
                  _calcBtn('=', const Color(0xFF10B981)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _calcBtn(String val, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(70, 50)),
      onPressed: () {
        setState(() {
          if (val == 'C') {
            calcDisplay = '0';
          } else if (calcDisplay == '0') {
            calcDisplay = val;
          } else {
            calcDisplay += val;
          }
        });
      },
      child: Text(appSettings.localizeNumber(val), style: const TextStyle(fontSize: 20, color: Colors.white)),
    );
  }

  Widget _buildLoanCalculator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const Text('Loan Amount & EMI Estimator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Principal: ${appSettings.localizeNumber(loanAmount)}'),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => loanAmount = (loanAmount - 5000).clamp(1000, 10000000))),
                  IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => setState(() => loanAmount = (loanAmount + 5000).clamp(1000, 10000000))),
                ],
              )
            ],
          ),
          Slider(value: loanAmount, min: 1000, max: 1000000, divisions: 100, activeColor: const Color(0xFF10B981), onChanged: (v) => setState(() => loanAmount = v)),
        ],
      ),
    );
  }

  Widget _buildSipCalculator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('SIP & Long-term Growth Calculator Hub', style: TextStyle(color: Colors.grey))),
    );
  }
}

// ----------------- App Drawer -----------------
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
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
              ],
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
                        appSettings.setLanguage(val);
                        setStateDialog(() {});
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
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
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(appSettings.translate('Dashboard Analytics')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardAnalyticsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: Text(appSettings.translate('Goals')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: Text(appSettings.translate('Calculators')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorsHubScreen()));
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
            ListTile(
              leading: const Icon(Icons.palette),
              title: Text(appSettings.translate('Theme')),
              onTap: () {
                Navigator.pop(context);
                _showThemeDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(appSettings.translate('Language')),
              onTap: () {
                Navigator.pop(context);
                _showLanguageDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(appSettings.translate('About App')),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(appSettings.translate('About App')),
                    content: const Text('Account Book v1.0.0\nDeveloped for daily financial ledger & transaction management.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
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

// ----------------- Quick Access Screens -----------------

// 1. Accounts Screen (Single Common Eye Icon at Header)
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
        title: Text(appSettings.translate(index == null ? 'Add Account' : 'Edit Account')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: InputDecoration(labelText: appSettings.translate('Account Name'), border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: typeC, decoration: InputDecoration(labelText: appSettings.translate('Type'), border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: detC, decoration: InputDecoration(labelText: appSettings.translate('Details / Account Number'), border: const OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
          ElevatedButton(
            onPressed: () {
              if (nameC.text.isNotEmpty) {
                if (index == null) {
                  appSettings.addAccount(nameC.text, typeC.text, detC.text);
                } else {
                  appSettings.updateAccount(index, nameC.text, typeC.text, detC.text);
                }
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: Text(appSettings.translate('Save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    bool isAllAccountsHidden = appSettings.isHidden('common_accounts_visibility');

    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Accounts')),
          actions: [
            IconButton(
              icon: Icon(
                isAllAccountsHidden ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF10B981),
              ),
              tooltip: 'Toggle Balances Visibility',
              onPressed: () {
                appSettings.toggleHide('common_accounts_visibility');
                setState(() {});
              },
            ),
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: appSettings.accounts.length,
            itemBuilder: (context, index) {
              final acc = appSettings.accounts[index];
              double accBal = appSettings.getAccountBalance(acc.name);

              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () {
                    appSettings.setDefaultAccount(index);
                    setState(() {});
                  },
                  leading: CircleAvatar(
                    backgroundColor: acc.isDefault ? const Color(0xFF10B981).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    child: Icon(
                      acc.isDefault ? Icons.check : Icons.account_balance_wallet,
                      color: acc.isDefault ? const Color(0xFF10B981) : Colors.grey,
                    ),
                  ),
                  title: Text(appSettings.translate(acc.name), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(appSettings.translate(acc.type)),
                      const SizedBox(height: 2),
                      Text(appSettings.localizeNumber(acc.details), style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        isAllAccountsHidden ? 'Balance: ********' : 'Balance: ${appSettings.localizeNumber(accBal)} $curr',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddEditDialog(index: index, account: acc)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                        onPressed: () {
                          if (appSettings.accounts.length <= 1) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot delete the last remaining account!')));
                            return;
                          }
                          showLocalizedDeleteDialog(
                            context: context,
                            isImportant: true,
                            itemName: acc.name,
                            onDeleteConfirmed: () {
                              appSettings.removeAccount(index);
                              setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddEditDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// 2. Budget Screen
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}
class _BudgetScreenState extends State<BudgetScreen> {
  void _showAddEditBudgetDialog({int? index, BudgetModel? budget}) {
    String selectedCategory = budget?.category ?? appSettings.categories[0];
    final amountC = TextEditingController(text: budget != null ? budget.amount.toString() : '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSheet) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(index == null ? 'Add New Budget' : 'Edit Budget', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: Theme.of(context).cardColor,
                decoration: const InputDecoration(labelText: 'Select Category', border: OutlineInputBorder()),
                items: appSettings.categories.map((c) => DropdownMenuItem(value: c, child: Text(appSettings.translate(c)))).toList(),
                onChanged: (val) { if (val != null) setStateSheet(() => selectedCategory = val); },
              ),
              const SizedBox(height: 12),
              TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (amountC.text.isNotEmpty) {
                      double amt = double.tryParse(amountC.text) ?? 0.0;
                      if (index == null) {
                        appSettings.addBudget(selectedCategory, amt);
                      } else {
                        appSettings.updateBudget(index, selectedCategory, amt);
                      }
                      Navigator.pop(ctx);
                      setState(() {});
                    }
                  },
                  child: const Text('Save'),
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
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Budget')),
          actions: [
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {})))),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: appSettings.budgets.isEmpty
              ? const Center(child: Text('No budget found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: appSettings.budgets.length,
                  itemBuilder: (context, index) {
                    final b = appSettings.budgets[index];
                    return Card(
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.track_changes, color: Color(0xFF10B981)),
                        title: Text(appSettings.translate(b.category)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$curr ${appSettings.localizeNumber(b.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddEditBudgetDialog(index: index, budget: b)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                              onPressed: () {
                                showLocalizedDeleteDialog(
                                  context: context,
                                  isImportant: false,
                                  itemName: b.category,
                                  onDeleteConfirmed: () {
                                    appSettings.removeBudget(index);
                                    setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddEditBudgetDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// 3. Categories Screen
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}
class _CategoriesScreenState extends State<CategoriesScreen> {
  void _showAddCategoryDialog({int? index, String? category}) {
    final catController = TextEditingController(text: category ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'Add Category' : 'Edit Category'),
        content: TextField(controller: catController, decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (catController.text.isNotEmpty) {
                if (index == null) {
                  appSettings.addCategory(catController.text);
                } else {
                  appSettings.updateCategory(index, catController.text);
                }
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Categories')),
          actions: [
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {})))),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: appSettings.categories.length,
            itemBuilder: (context, index) {
              final cat = appSettings.categories[index];
              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.category, color: Color(0xFF10B981)),
                  title: Text(appSettings.translate(cat)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                        onPressed: () => _showAddCategoryDialog(index: index, category: cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                        onPressed: () {
                          if (appSettings.categories.length > 1) {
                            showLocalizedDeleteDialog(
                              context: context,
                              isImportant: true,
                              itemName: cat,
                              onDeleteConfirmed: () {
                                appSettings.removeCategory(index);
                                setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddCategoryDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// 4. Fund Shopping Screen
class FundShoppingScreen extends StatefulWidget {
  const FundShoppingScreen({super.key});
  @override
  State<FundShoppingScreen> createState() => _FundShoppingScreenState();
}
class _FundShoppingScreenState extends State<FundShoppingScreen> {
  void _showAddShoppingDialog({int? index, ShoppingItem? item}) {
    final itemController = TextEditingController(text: item?.name ?? '');
    final amountController = TextEditingController(text: item != null ? item.amount.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'Add Shopping Item' : 'Edit Shopping Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: itemController, decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated Amount', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (itemController.text.isNotEmpty) {
                double amt = double.tryParse(amountController.text) ?? 0.0;
                if (index == null) {
                  appSettings.addShoppingItem(itemController.text, amt);
                } else {
                  appSettings.updateShoppingItem(index, itemController.text, amt);
                }
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Shopping')),
          actions: [
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {})))),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: appSettings.shoppingList.isEmpty
              ? const Center(child: Text('Your shopping list is empty', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: appSettings.shoppingList.length,
                  itemBuilder: (context, index) {
                    final item = appSettings.shoppingList[index];
                    return Card(
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: item.isChecked,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (val) {
                            appSettings.toggleShoppingCheck(index);
                            setState(() {});
                          },
                        ),
                        title: Text(
                          appSettings.translate(item.name),
                          style: TextStyle(decoration: item.isChecked ? TextDecoration.lineThrough : null),
                        ),
                        subtitle: Text('$curr ${appSettings.localizeNumber(item.amount)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                              onPressed: () => _showAddShoppingDialog(index: index, item: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                showLocalizedDeleteDialog(
                                  context: context,
                                  isImportant: false,
                                  itemName: item.name,
                                  onDeleteConfirmed: () {
                                    appSettings.removeShoppingItem(index);
                                    setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddShoppingDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// 5. Reminders Screen
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}
class _RemindersScreenState extends State<RemindersScreen> {
  void _showAddReminderDialog({int? index, ReminderModel? reminder}) {
    final titleC = TextEditingController(text: reminder?.title ?? '');
    final amountC = TextEditingController(text: reminder != null ? reminder.amount.toString() : '');
    String selectedDay = reminder?.dueDate ?? '1';
    List<String> daysList = List.generate(31, (i) => (i + 1).toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(index == null ? 'Add Bill Reminder' : 'Edit Bill Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Bill Title', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedDay,
                dropdownColor: Theme.of(context).cardColor,
                decoration: const InputDecoration(labelText: 'Due Date (Day of Month)', border: OutlineInputBorder()),
                items: daysList.map((d) => DropdownMenuItem(value: d, child: Text('Day $d'))).toList(),
                onChanged: (val) { if (val != null) setStateDialog(() => selectedDay = val); },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleC.text.isNotEmpty && amountC.text.isNotEmpty) {
                  double amt = double.tryParse(amountC.text) ?? 0.0;
                  if (index == null) {
                    appSettings.addReminder(titleC.text, amt, selectedDay);
                  } else {
                    appSettings.updateReminder(index, titleC.text, amt, selectedDay);
                  }
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('Save'),
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
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Reminder')),
          actions: [
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {})))),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: appSettings.reminders.isEmpty
              ? const Center(child: Text('No reminders found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: appSettings.reminders.length,
                  itemBuilder: (context, index) {
                    final rem = appSettings.reminders[index];
                    return Card(
                      color: Theme.of(context).cardColor,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.notifications_active, color: Color(0xFF10B981)),
                        title: Text(appSettings.translate(rem.title)),
                        subtitle: Text('Due Day: ${appSettings.localizeNumber(rem.dueDate)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$curr ${appSettings.localizeNumber(rem.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                            const SizedBox(width: 8),
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddReminderDialog(index: index, reminder: rem)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                              onPressed: () {
                                showLocalizedDeleteDialog(
                                  context: context,
                                  isImportant: false,
                                  itemName: rem.title,
                                  onDeleteConfirmed: () {
                                    appSettings.removeReminder(index);
                                    setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddReminderDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// 6. Repeated Transactions Screen
class RepeatedTransactionsScreen extends StatefulWidget {
  const RepeatedTransactionsScreen({super.key});
  @override
  State<RepeatedTransactionsScreen> createState() => _RepeatedTransactionsScreenState();
}
class _RepeatedTransactionsScreenState extends State<RepeatedTransactionsScreen> {
  void _showAddRepeatedDialog({int? index, RepeatedTransactionModel? repeated}) {
    final titleC = TextEditingController(text: repeated?.title ?? '');
    final amountC = TextEditingController(text: repeated != null ? repeated.amount.toString() : '');
    String selectedDay = repeated?.frequency ?? '1';
    List<String> daysList = List.generate(31, (i) => (i + 1).toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(index == null ? 'Add Repeated Transaction' : 'Edit Repeated Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedDay,
                dropdownColor: Theme.of(context).cardColor,
                decoration: const InputDecoration(labelText: 'Frequency (Day of Month)', border: OutlineInputBorder()),
                items: daysList.map((d) => DropdownMenuItem(value: d, child: Text('Day $d of every month'))).toList(),
                onChanged: (val) { if (val != null) setStateDialog(() => selectedDay = val); },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleC.text.isNotEmpty && amountC.text.isNotEmpty) {
                  double amt = double.tryParse(amountC.text) ?? 0.0;
                  if (index == null) {
                    appSettings.addRepeatedTransaction(titleC.text, amt, selectedDay);
                  } else {
                    appSettings.updateRepeatedTransaction(index, titleC.text, amt, selectedDay);
                  }
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('Save'),
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
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Repeat')),
          actions: [
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {})))),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: appSettings.repeatedTransactions.length,
            itemBuilder: (context, index) {
              final rep = appSettings.repeatedTransactions[index];
              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.repeat, color: Color(0xFF10B981)),
                  title: Text(appSettings.translate(rep.title)),
                  subtitle: Text('Day ${appSettings.localizeNumber(rep.frequency)} of every month'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$curr ${appSettings.localizeNumber(rep.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddRepeatedDialog(index: index, repeated: rep)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                        onPressed: () {
                          showLocalizedDeleteDialog(
                            context: context,
                            isImportant: false,
                            itemName: rep.title,
                            onDeleteConfirmed: () {
                              appSettings.removeRepeatedTransaction(index);
                              setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddRepeatedDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// 7. Savings Screen
class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});
  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}
class _SavingsScreenState extends State<SavingsScreen> {
  void _showAddSavingsDialog({int? index, SavingsModel? savings}) {
    final titleC = TextEditingController(text: savings?.title ?? '');
    final targetC = TextEditingController(text: savings != null ? savings.targetAmount.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'Add Savings Goal' : 'Edit Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Savings Title', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: targetC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.isNotEmpty && targetC.text.isNotEmpty) {
                double target = double.tryParse(targetC.text) ?? 0.0;
                if (index == null) {
                  appSettings.addSavings(titleC.text, target);
                } else {
                  appSettings.updateSavings(index, titleC.text, target);
                }
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Savings')),
          actions: [
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
            Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {})))),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: appSettings.savingsList.length,
            itemBuilder: (context, index) {
              final sav = appSettings.savingsList[index];
              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.savings, color: Color(0xFF10B981)),
                  title: Text(appSettings.translate(sav.title), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Saved: ${appSettings.localizeNumber(sav.currentAmount)} $curr'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Target: ${appSettings.localizeNumber(sav.targetAmount)} $curr', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20), onPressed: () => _showAddSavingsDialog(index: index, savings: sav)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                        onPressed: () {
                          showLocalizedDeleteDialog(
                            context: context,
                            isImportant: false,
                            itemName: sav.title,
                            onDeleteConfirmed: () {
                              appSettings.removeSavings(index);
                              setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddSavingsDialog(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// ----------------- App Drawer -----------------
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(appSettings.translate('Dashboard Analytics')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardAnalyticsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: Text(appSettings.translate('Goals')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: Text(appSettings.translate('Calculators')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CalculatorsHubScreen()));
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(appSettings.translate('About App')),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(appSettings.translate('About App')),
                    content: const Text('Account Book v1.0.0\nDeveloped for daily financial ledger & transaction management.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
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

// ----------------- Home Screen Content -----------------
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
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
    List<int> years = List.generate(110, (index) => 1990 + index);

    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(appSettings.getAppTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')),
                  );
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          InkWell(
                            onTap: () => appSettings.toggleHide('home_current_balance'),
                            child: Icon(
                              appSettings.isHidden('home_current_balance') ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appSettings.isHidden('home_current_balance') ? '********' : '${appSettings.localizeNumber(appSettings.getTotalBalance())} $curr', 
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(appSettings.translate('This Month')),
                        selected: appSettings.timeFilter == 'This Month',
                        selectedColor: const Color(0xFF10B981),
                        onSelected: (val) {
                          appSettings.setTimeFilter('This Month');
                          appSettings.setMonthYear(DateTime.now().month, DateTime.now().year);
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(appSettings.translate('Custom Months')),
                        selected: appSettings.timeFilter == 'Custom Months',
                        selectedColor: const Color(0xFF10B981),
                        onSelected: (val) {
                          appSettings.setTimeFilter('Custom Months');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(appSettings.translate('Custom Years')),
                        selected: appSettings.timeFilter == 'Custom Years',
                        selectedColor: const Color(0xFF10B981),
                        onSelected: (val) {
                          appSettings.setTimeFilter('Custom Years');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(appSettings.translate('Custom Range')),
                        selected: appSettings.timeFilter == 'Custom Range',
                        selectedColor: const Color(0xFF10B981),
                        onSelected: (val) {
                          appSettings.setTimeFilter('Custom Range');
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (appSettings.timeFilter == 'Custom Months')
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: appSettings.selectedMonthIndex,
                          dropdownColor: Theme.of(context).cardColor,
                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                          items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(appSettings.getLocalizedMonth(i + 1)))),
                          onChanged: (val) { if (val != null) { appSettings.setMonthYear(val, appSettings.selectedYear); setState(() {}); } },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: appSettings.selectedYear,
                          dropdownColor: Theme.of(context).cardColor,
                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                          items: years.map((y) => DropdownMenuItem(value: y, child: Text(appSettings.localizeNumber(y)))).toList(),
                          onChanged: (val) { if (val != null) { appSettings.setMonthYear(appSettings.selectedMonthIndex, val); setState(() {}); } },
                        ),
                      ),
                    ],
                  ),
                if (appSettings.timeFilter == 'Custom Years')
                  DropdownButtonFormField<int>(
                    value: appSettings.selectedYear,
                    dropdownColor: Theme.of(context).cardColor,
                    decoration: InputDecoration(labelText: appSettings.translate('Year'), border: const OutlineInputBorder()),
                    items: years.map((y) => DropdownMenuItem(value: y, child: Text(appSettings.localizeNumber(y)))).toList(),
                    onChanged: (val) { if (val != null) { appSettings.setMonthYear(appSettings.selectedMonthIndex, val); setState(() {}); } },
                  ),
                if (appSettings.timeFilter == 'Custom Range')
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showLocalizedDatePicker(
                              context: context,
                              initialDate: appSettings.customStartDate ?? DateTime.now(),
                              firstDate: DateTime(1990),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              appSettings.setCustomDateRange(picked, appSettings.customEndDate ?? picked);
                              setState(() {});
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: TextEditingController(text: appSettings.customStartDate != null ? appSettings.localizeNumber(appSettings.customStartDate.toString().substring(0, 10)) : appSettings.translate('Start Date')),
                              decoration: InputDecoration(border: const OutlineInputBorder(), labelText: appSettings.translate('Start Date'), suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showLocalizedDatePicker(
                              context: context,
                              initialDate: appSettings.customEndDate ?? DateTime.now(),
                              firstDate: DateTime(1990),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              appSettings.setCustomDateRange(appSettings.customStartDate ?? picked, picked);
                              setState(() {});
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: TextEditingController(text: appSettings.customEndDate != null ? appSettings.localizeNumber(appSettings.customEndDate.toString().substring(0, 10)) : appSettings.translate('End Date')),
                              decoration: InputDecoration(border: const OutlineInputBorder(), labelText: appSettings.translate('End Date'), suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appSettings.translate('Income'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              '${appSettings.localizeNumber(appSettings.getTotalIncome())} $curr', 
                              style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appSettings.translate('Expense'), style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              '${appSettings.localizeNumber(appSettings.getTotalExpense())} $curr', 
                              style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                              subtitle: Text('${appSettings.translate(txn.description)}\n${appSettings.localizeNumber(txn.date.toString().substring(0, 16))}'),
                              isThreeLine: true,
                              trailing: Text(
                                '${isIncome ? '+' : '-'} $curr ${appSettings.localizeNumber(txn.amount)}',
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

// ----------------- Loan & Debt Screen -----------------
class LoanDebtScreen extends StatefulWidget {
  const LoanDebtScreen({super.key});

  @override
  State<LoanDebtScreen> createState() => _LoanDebtScreenState();
}

class _LoanDebtScreenState extends State<LoanDebtScreen> {
  String selectedFilter = 'All';

  void _showAddEditLoanDialog(BuildContext context, {int? index, LoanItem? loan}) {
    String loanType = loan?.type ?? 'Given';
    final TextEditingController nameController = TextEditingController(text: loan?.personName ?? '');
    final TextEditingController amountController = TextEditingController(text: loan != null ? loan.amount.toString() : '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            return AlertDialog(
              title: Text(appSettings.translate(index == null ? 'Add New Loan / Debt' : 'Edit Loan / Debt')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Given' ? Colors.green : Theme.of(context).cardColor),
                          onPressed: () => setStateModal(() => loanType = 'Given'),
                          child: Text(appSettings.translate('Given'), style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Taken' ? Colors.red : Theme.of(context).cardColor),
                          onPressed: () => setStateModal(() => loanType = 'Taken'),
                          child: Text(appSettings.translate('Taken'), style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: nameController, decoration: InputDecoration(labelText: appSettings.translate('Person Name'), border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: appSettings.translate('Amount'), border: const OutlineInputBorder())),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      double amt = double.tryParse(amountController.text) ?? 0.0;
                      if (index == null) {
                        appSettings.addLoan(LoanItem(
                          id: DateTime.now().toString(),
                          personName: nameController.text,
                          amount: amt,
                          type: loanType,
                          date: DateTime.now(),
                        ));
                      } else {
                        appSettings.updateLoan(index, nameController.text, amt, loanType);
                      }
                      Navigator.pop(ctx);
                      setState(() {});
                    }
                  },
                  child: Text(appSettings.translate('Save')),
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

    var filteredLoans = appSettings.loans.where((loan) {
      if (selectedFilter == 'Given') return loan.type == 'Given' && !loan.isPaid;
      if (selectedFilter == 'Taken') return loan.type == 'Taken' && !loan.isPaid;
      if (selectedFilter == 'Paid') return loan.isPaid;
      return true;
    }).toList();

    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Loan & Debt')),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Download',
                onPressed: () {
                  final RenderBox box = ctx.findRenderObject() as RenderBox;
                  final offset = box.localToGlobal(Offset.zero);
                  showStandardDownloadMenu(context, offset);
                },
              ),
            ),
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort Loans',
                onPressed: () {
                  final RenderBox box = ctx.findRenderObject() as RenderBox;
                  final offset = box.localToGlobal(Offset.zero);
                  showStandardSortMenu(context, offset, (val) {
                    appSettings.sortLoans(val);
                    setState(() {});
                  });
                },
              ),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                ),
                child: Column(
                  children: [
                    Text(appSettings.translate('Net Balance'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(
                      '${appSettings.localizeNumber(appSettings.getNetBalance())} $curr', 
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.grey)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Row(children: [const Icon(Icons.arrow_downward, size: 14, color: Colors.green), const SizedBox(width: 4), Text(appSettings.translate('Given'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))]),
                            const SizedBox(height: 4),
                            Text('${appSettings.localizeNumber(appSettings.getTotalGiven())} $curr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.grey),
                        Column(
                          children: [
                            Row(children: [const Icon(Icons.arrow_upward, size: 14, color: Colors.redAccent), const SizedBox(width: 4), Text(appSettings.translate('Taken'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))]),
                            const SizedBox(height: 4),
                            Text('${appSettings.localizeNumber(appSettings.getTotalTaken())} $curr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: ['All', 'Given', 'Taken', 'Paid'].map((filter) {
                  bool isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(appSettings.translate(filter)),
                      selected: isSelected,
                      selectedColor: const Color(0xFF10B981),
                      backgroundColor: Theme.of(context).cardColor,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
                      onSelected: (val) => setState(() => selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(appSettings.translate('Loan List'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: filteredLoans.isEmpty
                    ? Center(child: Text(appSettings.translate('No loans found'), style: const TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: filteredLoans.length,
                        itemBuilder: (context, index) {
                          final loan = filteredLoans[index];
                          bool isGiven = loan.type == 'Given';

                          return Card(
                            color: Theme.of(context).cardColor,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (isGiven ? Colors.green : Colors.red).withOpacity(0.2),
                                child: Icon(isGiven ? Icons.arrow_upward : Icons.arrow_downward, color: isGiven ? Colors.green : Colors.red),
                              ),
                              title: Text(loan.personName, style: TextStyle(fontWeight: FontWeight.bold, decoration: loan.isPaid ? TextDecoration.lineThrough : null)),
                              subtitle: Text('${appSettings.translate(loan.type)} - ${appSettings.localizeNumber(loan.date.toString().substring(0, 10))}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('$curr ${appSettings.localizeNumber(loan.amount)}', style: TextStyle(color: isGiven ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold)),
                                  Checkbox(
                                    value: loan.isPaid,
                                    activeColor: const Color(0xFF10B981),
                                    onChanged: (val) {
                                      appSettings.toggleLoanStatus(loan.id);
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                    onPressed: () => _showAddEditLoanDialog(context, index: index, loan: loan),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      showLocalizedDeleteDialog(
                                        context: context,
                                        isImportant: true,
                                        itemName: loan.personName,
                                        onDeleteConfirmed: () {
                                          appSettings.removeLoan(index);
                                          setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddEditLoanDialog(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// ----------------- All Transactions Screen -----------------
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String searchQuery = '';
  String filterType = 'All';

  void _showAddEditTransactionDialog(BuildContext context, {int? index, TransactionItem? txn}) {
    String transactionType = txn?.type ?? 'Expense';
    String selectedCategory = txn?.category ?? appSettings.categories[0];
    String selectedAccount = txn?.account ?? appSettings.accounts.firstWhere((acc) => acc.isDefault, orElse: () => appSettings.accounts[0]).name;
    
    final TextEditingController amountController = TextEditingController(text: txn != null ? txn.amount.toString() : '');
    final TextEditingController descController = TextEditingController(text: txn?.description ?? '');

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
                    Text(appSettings.translate(index == null ? 'Add New Transaction' : 'Edit Transaction'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Income' ? Colors.green : Theme.of(context).cardColor),
                            onPressed: () => setStateModal(() => transactionType = 'Income'),
                            child: Text(appSettings.translate('Cash In')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Expense' ? Colors.red : Theme.of(context).cardColor),
                            onPressed: () => setStateModal(() => transactionType = 'Expense'),
                            child: Text(appSettings.translate('Cash Out')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedAccount,
                      dropdownColor: Theme.of(context).cardColor,
                      decoration: InputDecoration(labelText: appSettings.translate('Account'), border: const OutlineInputBorder()),
                      selectedItemBuilder: (BuildContext context) {
                        return appSettings.accounts.map<Widget>((acc) {
                          return Text(appSettings.translate(acc.name));
                        }).toList();
                      },
                      items: appSettings.accounts.map((acc) {
                        double accBal = appSettings.getAccountBalance(acc.name);
                        String popupHideKey = 'popup_acc_${acc.name}';
                        bool isHidden = appSettings.isHidden(popupHideKey);
                        String displayBal = isHidden ? '৳ *****' : '৳ ${appSettings.localizeNumber(accBal)}';

                        return DropdownMenuItem(
                          value: acc.name, 
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      appSettings.toggleHide(popupHideKey);
                                      setStateModal(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        isHidden ? Icons.visibility_off : Icons.visibility,
                                        size: 16,
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(displayBal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              Text(appSettings.translate(acc.name)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) { if (val != null) setStateModal(() => selectedAccount = val); },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: Theme.of(context).cardColor,
                      decoration: InputDecoration(labelText: appSettings.translate('Categories'), border: const OutlineInputBorder()),
                      items: appSettings.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(appSettings.translate(cat)))).toList(),
                      onChanged: (val) { if (val != null) setStateModal(() => selectedCategory = val); },
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: appSettings.translate('Amount'), border: const OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: descController, decoration: InputDecoration(labelText: appSettings.translate('Description'), border: const OutlineInputBorder())),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () {
                          if (amountController.text.isNotEmpty) {
                            double amount = double.tryParse(amountController.text) ?? 0.0;
                            if (index == null) {
                              appSettings.addTransaction(TransactionItem(
                                id: DateTime.now().toString(),
                                type: transactionType,
                                account: selectedAccount,
                                category: selectedCategory,
                                amount: amount,
                                description: descController.text,
                                date: DateTime.now(),
                              ));
                            } else {
                              appSettings.updateTransaction(index, TransactionItem(
                                id: txn!.id,
                                type: transactionType,
                                account: selectedAccount,
                                category: selectedCategory,
                                amount: amount,
                                description: descController.text,
                                date: txn.date,
                              ));
                            }
                            Navigator.pop(ctx);
                            setState(() {});
                          }
                        },
                        child: Text(appSettings.translate('Save'), style: const TextStyle(fontSize: 16)),
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['All', 'Income', 'Expense'].map((type) {
            return ListTile(
              title: Text(type),
              onTap: () {
                setState(() => filterType = type);
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

    var list = appSettings.transactions.where((txn) {
      bool matchesSearch = txn.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
          txn.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          txn.account.toLowerCase().contains(searchQuery.toLowerCase());
      if (filterType == 'Income') return matchesSearch && txn.type == 'Income';
      if (filterType == 'Expense') return matchesSearch && txn.type == 'Expense';
      return matchesSearch;
    }).toList();

    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('All Transactions')),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Download',
                onPressed: () {
                  final RenderBox box = ctx.findRenderObject() as RenderBox;
                  final offset = box.localToGlobal(Offset.zero);
                  showStandardDownloadMenu(context, offset);
                },
              ),
            ),
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort Transactions',
                onPressed: () {
                  final RenderBox box = ctx.findRenderObject() as RenderBox;
                  final offset = box.localToGlobal(Offset.zero);
                  showStandardSortMenu(context, offset, (val) {
                    appSettings.sortTransactions(val);
                    setState(() {});
                  });
                },
              ),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: appSettings.translate('Search (note, category)...'),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showFilterDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.filter_list, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('No transactions found', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final txn = list[index];
                          bool isIncome = txn.type == 'Income';

                          return Card(
                            color: Theme.of(context).cardColor,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.2),
                                child: Icon(isIncome ? Icons.add : Icons.remove, color: isIncome ? Colors.green : Colors.red),
                              ),
                              title: Text('${appSettings.translate(txn.category)} (${appSettings.translate(txn.account)})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${appSettings.translate(txn.description)}\n${appSettings.localizeNumber(txn.date.toString().substring(0, 16))}'),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${isIncome ? '+' : '-'} $curr ${appSettings.localizeNumber(txn.amount)}',
                                    style: TextStyle(color: isIncome ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                    onPressed: () => _showAddEditTransactionDialog(context, index: index, txn: txn),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      showLocalizedDeleteDialog(
                                        context: context,
                                        isImportant: true,
                                        itemName: txn.category,
                                        onDeleteConfirmed: () {
                                          appSettings.removeTransaction(index);
                                          setState(() {});
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showAddEditTransactionDialog(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// ----------------- Reports & Analysis Screen -----------------
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool isSortedAscending = true;
  String currentFilterMode = 'This Month';

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    double income = appSettings.getTotalIncome();
    double expense = appSettings.getTotalExpense();
    double budget = appSettings.monthlyBudget;
    double progress = budget > 0 ? (expense / budget).clamp(0.0, 1.0) : 0.0;

    List<int> years = List.generate(110, (index) => 1990 + index);

    Map<String, double> categoryExpenses = {};
    for (var txn in appSettings.getFilteredTransactions()) {
      if (txn.type == 'Expense') {
        categoryExpenses[txn.category] = (categoryExpenses[txn.category] ?? 0.0) + txn.amount;
      }
    }

    var categoryList = categoryExpenses.entries.toList();
    if (isSortedAscending) {
      categoryList.sort((a, b) => a.value.compareTo(b.value));
    } else {
      categoryList.sort((a, b) => b.value.compareTo(a.value));
    }

    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(appSettings.translate('Reports & Analysis')),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.download),
                tooltip: 'Download',
                onPressed: () {
                  final RenderBox box = ctx.findRenderObject() as RenderBox;
                  final offset = box.localToGlobal(Offset.zero);
                  showStandardDownloadMenu(context, offset);
                },
              ),
            ),
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort Categories',
                onPressed: () {
                  final RenderBox box = ctx.findRenderObject() as RenderBox;
                  final offset = box.localToGlobal(Offset.zero);
                  showStandardSortMenu(context, offset, (val) {
                    setState(() => isSortedAscending = val.contains('Small-Large') || val.contains('A-Z') || val.contains('Old-New'));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report Sorted by: $val')));
                  });
                },
              ),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(appSettings.translate('This Month')),
                      selected: currentFilterMode == 'This Month',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (val) {
                        setState(() {
                          currentFilterMode = 'This Month';
                          appSettings.setTimeFilter('Month');
                          appSettings.setMonthYear(DateTime.now().month, DateTime.now().year);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(appSettings.translate('Custom Months')),
                      selected: currentFilterMode == 'Custom Months',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (val) => setState(() => currentFilterMode = 'Custom Months'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(appSettings.translate('Custom Years')),
                      selected: currentFilterMode == 'Custom Years',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (val) => setState(() => currentFilterMode = 'Custom Years'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(appSettings.translate('Custom Range')),
                      selected: currentFilterMode == 'Custom Range',
                      selectedColor: const Color(0xFF10B981),
                      onSelected: (val) => setState(() {
                        currentFilterMode = 'Custom Range';
                        appSettings.setTimeFilter('Custom Range');
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (currentFilterMode == 'Custom Months' || currentFilterMode == 'This Month')
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: appSettings.selectedMonthIndex,
                        dropdownColor: Theme.of(context).cardColor,
                        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(appSettings.getLocalizedMonth(i + 1)))),
                        onChanged: (val) { if (val != null) setState(() => appSettings.setMonthYear(val, appSettings.selectedYear)); },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: appSettings.selectedYear,
                        dropdownColor: Theme.of(context).cardColor,
                        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                        items: years.map((y) => DropdownMenuItem(value: y, child: Text(appSettings.localizeNumber(y)))).toList(),
                        onChanged: (val) { if (val != null) setState(() => appSettings.setMonthYear(appSettings.selectedMonthIndex, val)); },
                      ),
                    ),
                  ],
                ),
              if (currentFilterMode == 'Custom Years')
                DropdownButtonFormField<int>(
                  value: appSettings.selectedYear,
                  dropdownColor: Theme.of(context).cardColor,
                  decoration: InputDecoration(labelText: appSettings.translate('Year'), border: const OutlineInputBorder()),
                  items: years.map((y) => DropdownMenuItem(value: y, child: Text(appSettings.localizeNumber(y)))).toList(),
                  onChanged: (val) { if (val != null) setState(() => appSettings.setMonthYear(appSettings.selectedMonthIndex, val)); },
                ),
              if (currentFilterMode == 'Custom Range')
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showLocalizedDatePicker(
                            context: context,
                            initialDate: appSettings.customStartDate ?? DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            appSettings.setCustomDateRange(picked, appSettings.customEndDate ?? picked);
                            setState(() {});
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: TextEditingController(text: appSettings.customStartDate != null ? appSettings.localizeNumber(appSettings.customStartDate.toString().substring(0, 10)) : appSettings.translate('Start Date')),
                            decoration: InputDecoration(border: const OutlineInputBorder(), labelText: appSettings.translate('Start Date'), suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showLocalizedDatePicker(
                            context: context,
                            initialDate: appSettings.customEndDate ?? DateTime.now(),
                            firstDate: DateTime(1990),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            appSettings.setCustomDateRange(appSettings.customStartDate ?? picked, picked);
                            setState(() {});
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: TextEditingController(text: appSettings.customEndDate != null ? appSettings.localizeNumber(appSettings.customEndDate.toString().substring(0, 10)) : appSettings.translate('End Date')),
                            decoration: InputDecoration(border: const OutlineInputBorder(), labelText: appSettings.translate('End Date'), suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appSettings.translate('Monthly Budget Overview'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('${appSettings.translate('Budget:')} ${appSettings.localizeNumber(budget)} $curr | ${appSettings.translate('Spent:')} ${appSettings.localizeNumber(expense)} $curr', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress, color: const Color(0xFF10B981), backgroundColor: Colors.white12),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${appSettings.translate('Total Income:')} ${appSettings.localizeNumber(income)} $curr', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        Text('${appSettings.translate('Total Expense:')} ${appSettings.localizeNumber(expense)} $curr', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appSettings.translate('Expense Categories'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton.icon(
                    onPressed: () => setState(() => isSortedAscending = !isSortedAscending),
                    icon: const Icon(Icons.sort, size: 16, color: Color(0xFF10B981)),
                    label: Text(isSortedAscending ? appSettings.translate('Sort: Low-High') : appSettings.translate('Sort: High-Low'), style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              categoryList.isEmpty
                  ? const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text('No expense categories found', style: TextStyle(color: Colors.grey))))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        final catEntry = categoryList[index];

                        return Card(
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.red[100], child: const Icon(Icons.category, color: Colors.redAccent)),
                            title: Text(appSettings.translate(catEntry.key), style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text('${appSettings.localizeNumber(catEntry.value)} $curr', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- Privacy & Security Screen -----------------
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  late TextEditingController _pinController;
  bool _obscurePin = true;

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
        appBar: AppBar(title: Text(appSettings.translate('Privacy & Security'))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(appSettings.translate('Security Options'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(appSettings.translate('Face Unlock')),
                    subtitle: Text(appSettings.translate('Scan & unlock with camera')),
                    value: _faceLock,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() { _faceLock = val; if (val) _noneLock = false; }),
                  ),
                  SwitchListTile(
                    title: Text(appSettings.translate('Fingerprint Sensor')),
                    subtitle: Text(appSettings.translate('Unlock using device fingerprint')),
                    value: _fingerprint,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() { _fingerprint = val; if (val) _noneLock = false; }),
                  ),
                  SwitchListTile(
                    title: Text(appSettings.translate('None (No Lock)')),
                    subtitle: Text(appSettings.translate('Bypass lock screen security')),
                    value: _noneLock,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() {
                      _noneLock = val;
                      if (val) { _faceLock = false; _fingerprint = false; _patternLock = false; _pinLock = false; }
                    }),
                  ),
                  SwitchListTile(
                    title: Text(appSettings.translate('Pattern Lock')),
                    subtitle: Text(appSettings.translate('Draw a secure pattern shape')),
                    value: _patternLock,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() { _patternLock = val; if (val) _noneLock = false; }),
                  ),
                  SwitchListTile(
                    title: Text(appSettings.translate('PIN Code Lock')),
                    subtitle: Text(appSettings.translate('Use a 4-digit numeric code')),
                    value: _pinLock,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() { _pinLock = val; if (val) _noneLock = false; }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_pinLock) ...[
              Text(appSettings.translate('Change PIN Code'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: _obscurePin,
                    decoration: InputDecoration(
                      labelText: appSettings.translate('4-Digit App PIN'),
                      border: const OutlineInputBorder(),
                      counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security settings updated successfully!')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be exactly 4 digits!')));
                  }
                },
                child: Text(appSettings.translate('Save Changes'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- Notification Settings Screen -----------------
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late bool daily;
  late bool budget;
  late bool loan;
  String selectedSound = 'Default';

  @override
  void initState() {
    super.initState();
    daily = appSettings.dailyReminder;
    budget = appSettings.budgetAlert;
    loan = appSettings.loanAlert;
    selectedSound = appSettings.notificationSound;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(appSettings.translate('Notification Settings'))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(appSettings.translate('Manage App Alerts & Reminders'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(appSettings.translate('Daily Transaction Reminder')),
                    subtitle: Text(appSettings.translate('Get reminded to record daily expenses')),
                    value: daily,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => daily = val),
                  ),
                  SwitchListTile(
                    title: Text(appSettings.translate('Budget Limit Alert')),
                    subtitle: Text(appSettings.translate('Notify when expenses reach near budget limit')),
                    value: budget,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => budget = val),
                  ),
                  SwitchListTile(
                    title: Text(appSettings.translate('Loan Payment Due Alert')),
                    subtitle: Text(appSettings.translate('Alert on upcoming loan settlement dates')),
                    value: loan,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => loan = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(appSettings.translate('Notification Sound & Alert Tone'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSound,
              dropdownColor: Theme.of(context).cardColor,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ['Default', 'App Chime', 'Custom from Device Memory'].map((s) => DropdownMenuItem(value: s, child: Text(appSettings.translate(s)))).toList(),
              onChanged: (val) { if (val != null) setState(() => selectedSound = val); },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  appSettings.toggleNotification('daily', daily);
                  appSettings.toggleNotification('budget', budget);
                  appSettings.toggleNotification('loan', loan);
                  appSettings.setNotificationSound(selectedSound);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings updated successfully!')));
                },
                child: Text(appSettings.translate('Save Changes'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
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
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameC = TextEditingController(text: appSettings.profileName);
    final emailC = TextEditingController(text: appSettings.profileEmail);
    String selectedGender = appSettings.profileGender;
    String birthDate = appSettings.profileBirthDate;
    final mobileC = TextEditingController(text: appSettings.profileMobile);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(appSettings.translate('Edit Profile')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameC, decoration: InputDecoration(labelText: appSettings.translate('Name'), border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: emailC, decoration: InputDecoration(labelText: appSettings.translate('Email'), border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ['Male', 'Female', 'Other'].contains(selectedGender) ? selectedGender : 'Male',
                  dropdownColor: Theme.of(context).cardColor,
                  decoration: InputDecoration(labelText: appSettings.translate('Gender'), border: const OutlineInputBorder()),
                  items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(appSettings.translate(g)))).toList(),
                  onChanged: (val) { if (val != null) setStateDialog(() => selectedGender = val); },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showLocalizedDatePicker(
                      context: context,
                      initialDate: DateTime(1995, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setStateDialog(() {
                        String rawDate = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                        birthDate = appSettings.localizeNumber(rawDate);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(text: appSettings.localizeNumber(birthDate)),
                      decoration: InputDecoration(labelText: appSettings.translate('Birth Date (DD-MM-YYYY)'), border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileC, 
                  keyboardType: TextInputType.phone, 
                  decoration: InputDecoration(labelText: appSettings.translate('Mobile Number'), border: const OutlineInputBorder())
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
            ElevatedButton(
              onPressed: () {
                appSettings.updateProfile(
                  name: nameC.text,
                  email: emailC.text,
                  gender: selectedGender,
                  birthDate: appSettings.localizeNumber(birthDate),
                  mobile: appSettings.localizeNumber(mobileC.text),
                );
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
              },
              child: Text(appSettings.translate('Save')),
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
        appBar: AppBar(title: Text(appSettings.translate('Profile & Settings'))),
        drawer: const AppDrawer(),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(16),
              ),
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
                  const SizedBox(height: 4),
                  Text(appSettings.profileEmail, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('${appSettings.translate('Gender')}: ${appSettings.translate(appSettings.profileGender)} | ${appSettings.translate('DOB')}: ${appSettings.localizeNumber(appSettings.profileBirthDate)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('${appSettings.translate('Mobile')}: ${appSettings.localizeNumber(appSettings.profileMobile)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black26,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => _showEditProfileDialog(context),
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(appSettings.translate('Edit Profile')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(appSettings.translate('Account'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                leading: const Icon(Icons.lock_outline, color: Color(0xFF10B981)),
                title: Text(appSettings.translate('Privacy & Security')),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySecurityScreen())),
              ),
            ),
            const SizedBox(height: 16),
            Text(appSettings.translate('Preferences'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                leading: const Icon(Icons.notifications_none, color: Color(0xFF10B981)),
                title: Text(appSettings.translate('Notification Settings')),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: Text(appSettings.translate('Sign Out'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinLockScreen()));
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text(appSettings.translate('Version 1.0.0'), style: const TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

// ----------------- Main Navigation -----------------
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
