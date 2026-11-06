import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
​void main() async {
WidgetsFlutterBinding.ensureInitialized();
await appSettings.initPrefs();
runApp(const AccountBookApp());
}
​// ==========================================
// 1. MODELS SECTION
// ==========================================
​class TransactionItem {
final String id;
final String type;
String account;
String category;
double amount;
String description;
DateTime date;
​TransactionItem({
required this.id,
required this.type,
required this.account,
required this.category,
required this.amount,
required this.description,
required this.date,
});
​Map<String, dynamic> toJson() => {
'id': id,
'type': type,
'account': account,
'category': category,
'amount': amount,
'description': description,
'date': date.toIso8601String(),
};
​factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
id: json['id'],
type: json['type'],
account: json['account'],
category: json['category'],
amount: json['amount'],
description: json['description'],
date: DateTime.parse(json['date']),
);
}
​class LoanItem {
final String id;
String personName;
double amount;
String type; // Given / Taken
DateTime date;
DateTime? returnDate;
String description;
String account;
bool isPaid;
​LoanItem({
required this.id,
required this.personName,
required this.amount,
required this.type,
required this.date,
this.returnDate,
this.description = '',
this.account = 'Cash in Hand',
this.isPaid = false,
});
​Map<String, dynamic> toJson() => {
'id': id,
'personName': personName,
'amount': amount,
'type': type,
'date': date.toIso8601String(),
'returnDate': returnDate?.toIso8601String(),
'description': description,
'account': account,
'isPaid': isPaid,
};
​factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
id: json['id'],
personName: json['personName'],
amount: json['amount'],
type: json['type'],
date: DateTime.parse(json['date']),
returnDate: json['returnDate'] != null ? DateTime.parse(json['returnDate']) : null,
description: json['description'] ?? '',
account: json['account'] ?? 'Cash in Hand',
isPaid: json['isPaid'] ?? false,
);
}
​class ShoppingItem {
String name;
double amount;
bool isChecked;
​ShoppingItem({
required this.name,
this.amount = 0.0,
this.isChecked = false,
});
​Map<String, dynamic> toJson() => {
'name': name,
'amount': amount,
'isChecked': isChecked,
};
​factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
name: json['name'],
amount: json['amount'],
isChecked: json['isChecked'],
);
}
​class BudgetModel {
String category;
double amount;
​BudgetModel({
required this.category,
required this.amount,
});
​Map<String, dynamic> toJson() => {
'category': category,
'amount': amount,
};
​factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
category: json['category'],
amount: json['amount'],
);
}
​class SavingsModel {
String title;
double targetAmount;
double currentAmount;
bool isCompleted;
​SavingsModel({
required this.title,
required this.targetAmount,
required this.currentAmount,
this.isCompleted = false,
});
​Map<String, dynamic> toJson() => {
'title': title,
'targetAmount': targetAmount,
'currentAmount': currentAmount,
'isCompleted': isCompleted,
};
​factory SavingsModel.fromJson(Map<String, dynamic> json) => SavingsModel(
title: json['title'],
targetAmount: json['targetAmount'],
currentAmount: json['currentAmount'],
isCompleted: json['isCompleted'] ?? false,
);
}
​class AccountModel {
String name;
String type; // Bank, Cash, Mobile Banking, Others
String details;
double balance;
bool isDefault;
​AccountModel({
required this.name,
required this.type,
required this.details,
this.balance = 0.0,
this.isDefault = false,
});
​Map<String, dynamic> toJson() => {
'name': name,
'type': type,
'details': details,
'balance': balance,
'isDefault': isDefault,
};
​factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
name: json['name'],
type: json['type'],
details: json['details'],
balance: (json['balance'] ?? 0.0).toDouble(),
isDefault: json['isDefault'] ?? false,
);
}
​class RepeatedTransactionModel {
String title;
double amount;
String frequency;
​RepeatedTransactionModel({
required this.title,
required this.amount,
required this.frequency,
});
​Map<String, dynamic> toJson() => {
'title': title,
'amount': amount,
'frequency': frequency,
};
​factory RepeatedTransactionModel.fromJson(Map<String, dynamic> json) => RepeatedTransactionModel(
title: json['title'],
amount: json['amount'],
frequency: json['frequency'],
);
}
​class ReminderModel {
String title;
double amount;
String dueDate;
​ReminderModel({
required this.title,
required this.amount,
required this.dueDate,
});
​Map<String, dynamic> toJson() => {
'title': title,
'amount': amount,
'dueDate': dueDate,
};
​factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
title: json['title'],
amount: json['amount'],
dueDate: json['dueDate'],
);
}
​class AppNotification {
final String id;
final String title;
final String message;
final DateTime timestamp;
final String category; // loan, reminder, alert, system
bool isRead;
​AppNotification({
required this.id,
required this.title,
required this.message,
required this.timestamp,
required this.category,
this.isRead = false,
});
}
​// ==========================================
// 2. STATE MANAGEMENT & LOCALIZATION
// ==========================================
​class AppSettingsNotifier extends ChangeNotifier {
late SharedPreferences _prefs;
​ThemeMode _themeMode = ThemeMode.dark;
String _language = 'English'; // English, Bangla, Arabic
String currency = '৳';
String timeFilter = 'This Month'; // This Month, Custom Months, Custom Years, Custom Range
String appPin = '1234';
​// Profile fields
String profileName = 'MD ALAMGIR HOSSAIN';
String profileEmail = 'alamgir@email.com';
String profileGender = 'Male';
String profileBirthDate = '01-01-1995';
String profileMobile = '018xxxxxxxx';
String profileImagePath = '';
​// Security Lock Options
bool useFaceLock = false;
bool useFingerprint = false;
bool useNoneLock = false;
bool usePatternLock = false;
bool usePinLock = true;
​// Notifications
bool dailyReminder = true;
bool budgetAlert = true;
bool loanAlert = true;
String notificationSound = 'Default';
​// Selected Date Filters
int selectedMonthIndex = DateTime.now().month;
int selectedYear = DateTime.now().year;
DateTime? customStartDate;
DateTime? customEndDate;
​List<String> categories = ['Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport', 'Food & Hotel'];
​List<AccountModel> accounts = [
AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', balance: 5000.0, isDefault: false),
AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', balance: 12500.0, isDefault: true),
AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', balance: 35000.0, isDefault: false),
AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', balance: 2000.0, isDefault: false),
AccountModel(name: 'UCB Bank', type: 'Bank', details: 'A/C: ...4589', balance: 18000.0, isDefault: false),
];
​String defaultCategory = 'Others';
double monthlyBudget = 15000.0;
​List<TransactionItem> transactions = [
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
​List<LoanItem> loans = [
LoanItem(
id: '101',
personName: 'Rafiqul Islam',
amount: 2000.0,
type: 'Given',
date: DateTime.now(),
description: 'Emergency loan',
account: 'Cash in Hand',
isPaid: false,
),
];
​List<ShoppingItem> shoppingList = [
ShoppingItem(name: 'Cooking Oil', amount: 150.0, isChecked: true),
ShoppingItem(name: 'Rice (5 kg)', amount: 450.0, isChecked: false),
];
​List<BudgetModel> budgets = [
BudgetModel(category: 'Food & Hotel', amount: 5000.0),
BudgetModel(category: 'Transport', amount: 3000.0),
];
​List<SavingsModel> savingsList = [
SavingsModel(title: 'Emergency Fund', targetAmount: 500000, currentAmount: 25000)
];
​List<RepeatedTransactionModel> repeatedTransactions = [
RepeatedTransactionModel(title: 'House Rent', amount: 8000, frequency: '1st of every month'),
RepeatedTransactionModel(title: 'WiFi Bill', amount: 1000, frequency: '10th of every month'),
];
​List<ReminderModel> reminders = [
ReminderModel(title: 'Electricity Bill', amount: 1200, dueDate: '15th of every month'),
];
​List<AppNotification> notifications = [
AppNotification(
id: '1',
title: 'Welcome to Account Book',
message: 'Your personal digital ledger is ready to use.',
timestamp: DateTime.now().subtract(const Duration(hours: 2)),
category: 'system',
isRead: false,
),
AppNotification(
id: '2',
title: 'Loan Due Alert',
message: 'Rafiqul Islam loan payment target is approaching.',
timestamp: DateTime.now().subtract(const Duration(days: 1)),
category: 'loan',
isRead: true,
),
];
​Future<void> initPrefs() async {
_prefs = await SharedPreferences.getInstance();
appPin = _prefs.getString('appPin') ?? '1234';
_language = _prefs.getString('language') ?? 'English';
String themeStr = _prefs.getString('themeMode') ?? 'dark';
if (themeStr == 'light') _themeMode = ThemeMode.light;
else if (themeStr == 'system') _themeMode = ThemeMode.system;
else _themeMode = ThemeMode.dark;
​profileName = _prefs.getString('profileName') ?? 'MD ALAMGIR HOSSAIN';
profileEmail = _prefs.getString('profileEmail') ?? 'alamgir@email.com';
profileGender = _prefs.getString('profileGender') ?? 'Male';
profileBirthDate = _prefs.getString('profileBirthDate') ?? '01-01-1995';
profileMobile = _prefs.getString('profileMobile') ?? '018xxxxxxxx';
profileImagePath = _prefs.getString('profileImagePath') ?? '';
​// Sort Categories and Accounts Alphabetically by default
categories.sort();
sortAccountsSequence();
notifyListeners();
}
​void sortAccountsSequence() {
Map<String, int> typeOrder = {
'Bank': 1,
'Cash': 2,
'Mobile Banking': 3,
'Others': 4,
};
accounts.sort((a, b) {
int orderA = typeOrder[a.type] ?? 99;
int orderB = typeOrder[b.type] ?? 99;
if (orderA != orderB) return orderA.compareTo(orderB);
return a.name.compareTo(b.name);
});
}
​Future<void> _saveToPrefs() async {
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
​ThemeMode get themeMode => _themeMode;
String get language => _language;
​String getAppTitle() {
if (_language == 'Bangla') return 'হিসাবের খাতা';
if (_language == 'Arabic') return 'دفتر الحسابات';
return 'Account Book';
}
​// Real-Time Global Translation Engine
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
case 'Notifications': return 'নোটিফিকেশন';
case 'All': return 'সব';
case 'Unread': return 'অপঠিত';
case 'Read': return 'পঠিত';
case 'Alerts': return 'সতর্কতা';
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
case 'Grocery': return 'بقالة';
case 'Others': return 'أخرى';
case 'Salary': return 'راتب';
case 'Tea & Snacks': return 'شاي ووجبات خفيفة';
case 'Transport': return 'مواصلات';
case 'Food & Hotel': return 'طعام وفنادق';
case 'Bikash': return 'ب বিকাশ';
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
case 'Notifications': return 'الإشعارات';
case 'All': return 'الكل';
case 'Unread': return 'غير مقروء';
case 'Read': return 'مقروء';
case 'Alerts': return 'التنبيهات';
default: return key;
}
}
return key;
}
​void setTheme(ThemeMode mode) {
_themeMode = mode;
_saveToPrefs();
notifyListeners();
}
​void setLanguage(String lang) {
_language = lang;
_saveToPrefs();
notifyListeners();
}
​void setTimeFilter(String filter) {
timeFilter = filter;
notifyListeners();
}
​void setMonthYear(int month, int year) {
selectedMonthIndex = month;
selectedYear = year;
notifyListeners();
}
​void setCustomDateRange(DateTime? start, DateTime? end) {
customStartDate = start;
customEndDate = end;
notifyListeners();
}
​void updatePin(String newPin) {
appPin = newPin;
_saveToPrefs();
notifyListeners();
}
​void updateProfile({
required String name,
required String email,
required String gender,
required String birthDate,
required String mobile,
String? imagePath,
}) {
profileName = name;
profileEmail = email;
profileGender = gender;
profileBirthDate = birthDate;
profileMobile = mobile;
if (imagePath != null) profileImagePath = imagePath;
_saveToPrefs();
notifyListeners();
}
​void updateSecurityToggles({
required bool face,
required bool fingerprint,
required bool none,
required bool pattern,
required bool pin,
}) {
useFaceLock = face;
useFingerprint = fingerprint;
useNoneLock = none;
usePatternLock = pattern;
usePinLock = pin;
if (none) {
useFaceLock = false;
useFingerprint = false;
usePatternLock = false;
usePinLock = false;
}
notifyListeners();
}
​// Notification Operations
void markAllNotificationsAsRead() {
for (var n in notifications) {
n.isRead = true;
}
notifyListeners();
}
​void deleteAllNotifications() {
notifications.clear();
notifyListeners();
}
​void deleteNotification(String id) {
notifications.removeWhere((n) => n.id == id);
notifyListeners();
}
​// Transactions & Financial Logic
void addTransaction(TransactionItem txn) {
transactions.insert(0, txn);
// Update corresponding account balance
for (var acc in accounts) {
if (acc.name == txn.account) {
if (txn.type == 'Income') {
acc.balance += txn.amount;
} else {
acc.balance -= txn.amount;
}
break;
}
}
notifyListeners();
}
​void updateTransaction(int index, TransactionItem txn) {
transactions[index] = txn;
notifyListeners();
}
​void removeTransaction(int index) {
transactions.removeAt(index);
notifyListeners();
}
​void addLoan(LoanItem loan, {bool updateAccountBalance = true}) {
loans.insert(0, loan);
if (updateAccountBalance) {
for (var acc in accounts) {
if (acc.name == loan.account) {
if (loan.type == 'Given') {
acc.balance -= loan.amount;
} else {
acc.balance += loan.amount;
}
break;
}
}
}
notifyListeners();
}
​void updateLoan(int index, LoanItem loan) {
loans[index] = loan;
notifyListeners();
}
​void removeLoan(int index) {
loans.removeAt(index);
notifyListeners();
}
​void toggleLoanStatus(String id) {
for (var loan in loans) {
if (loan.id == id) {
loan.isPaid = !loan.isPaid;
notifyListeners();
break;
}
}
}
​void sortLoans(String criteria) {
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
​void sortTransactions(String criteria) {
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
​List<TransactionItem> getFilteredTransactions() {
return transactions.where((txn) {
if (timeFilter == 'Custom Range' && customStartDate != null && customEndDate != null) {
return txn.date.isAfter(customStartDate!.subtract(const Duration(days: 1))) &&
txn.date.isBefore(customEndDate!.add(const Duration(days: 1)));
}
return txn.date.year == selectedYear && txn.date.month == selectedMonthIndex;
}).toList();
}
​double getTotalIncome() {
double total = 0;
for (var txn in getFilteredTransactions()) {
if (txn.type == 'Income') total += txn.amount;
}
return total;
}
​double getTotalExpense() {
double total = 0;
for (var txn in getFilteredTransactions()) {
if (txn.type == 'Expense') total += txn.amount;
}
return total;
}
​// Real-Time Total Current Balance across all accounts
double getTotalBalance() {
double total = 0;
for (var acc in accounts) {
total += acc.balance;
}
return total;
}
​double getTotalGiven() {
double total = 0;
for (var loan in loans) {
if (loan.type == 'Given' && !loan.isPaid) total += loan.amount;
}
return total;
}
​double getTotalTaken() {
double total = 0;
for (var loan in loans) {
if (loan.type == 'Taken' && !loan.isPaid) total += loan.amount;
}
return total;
}
​double getNetBalance() {
return getTotalGiven() - getTotalTaken();
}
​void addAccount(String name, String type, String details, double initialBalance) {
if (name.isNotEmpty) {
accounts.add(AccountModel(
name: name,
type: type,
details: details.isEmpty ? 'N/A' : details,
balance: initialBalance,
isDefault: accounts.isEmpty,
));
sortAccountsSequence();
notifyListeners();
}
}
​void updateAccount(int index, String name, String type, String details, double balance) {
accounts[index].name = name;
accounts[index].type = type;
accounts[index].details = details;
accounts[index].balance = balance;
sortAccountsSequence();
notifyListeners();
}
​void setDefaultAccount(int index) {
for (int i = 0; i < accounts.length; i++) {
accounts[i].isDefault = (i == index);
}
notifyListeners();
}
​bool removeAccount(int index) {
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
sortAccountsSequence();
notifyListeners();
return true;
}
return false;
}
​void addBudget(String category, double amount) {
budgets.add(BudgetModel(category: category, amount: amount));
budgets.sort((a, b) => a.category.compareTo(b.category));
notifyListeners();
}
​void updateBudget(int index, String category, double amount) {
budgets[index] = BudgetModel(category: category, amount: amount);
budgets.sort((a, b) => a.category.compareTo(b.category));
notifyListeners();
}
​void removeBudget(int index) {
budgets.removeAt(index);
notifyListeners();
}
​void addSavings(String title, double target) {
savingsList.add(SavingsModel(title: title, targetAmount: target, currentAmount: 0));
savingsList.sort((a, b) => a.title.compareTo(b.title));
notifyListeners();
}
​void updateSavings(int index, String title, double targetAmount) {
savingsList[index].title = title;
savingsList[index].targetAmount = targetAmount;
savingsList.sort((a, b) => a.title.compareTo(b.title));
notifyListeners();
}
​void removeSavings(int index) {
savingsList.removeAt(index);
notifyListeners();
}
​void addCategory(String cat) {
if (cat.isNotEmpty && !categories.contains(cat)) {
categories.add(cat);
categories.sort();
notifyListeners();
}
}
​void updateCategory(int index, String newCat) {
if (newCat.isNotEmpty) {
categories[index] = newCat;
categories.sort();
notifyListeners();
}
}
​void removeCategory(int index) {
if (categories.length > 1) {
categories.removeAt(index);
notifyListeners();
}
}
​void addShoppingItem(String name, double amount) {
if (name.isNotEmpty) {
shoppingList.add(ShoppingItem(name: name, amount: amount));
shoppingList.sort((a, b) => a.name.compareTo(b.name));
notifyListeners();
}
}
​void updateShoppingItem(int index, String name, double amount) {
if (name.isNotEmpty) {
shoppingList[index].name = name;
shoppingList[index].amount = amount;
shoppingList.sort((a, b) => a.name.compareTo(b.name));
notifyListeners();
}
}
​void removeShoppingItem(int index) {
shoppingList.removeAt(index);
notifyListeners();
}
​void toggleShoppingCheck(int index) {
shoppingList[index].isChecked = !shoppingList[index].isChecked;
if (shoppingList[index].isChecked && shoppingList[index].amount > 0) {
String defaultAcc = accounts.firstWhere((acc) => acc.isDefault, orElse: () => accounts[0]).name;
addTransaction(TransactionItem(
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
}
​final appSettings = AppSettingsNotifier();
​// ==========================================
// 3. MAIN APP & THEME ENGINE
// ==========================================
​class AccountBookApp extends StatelessWidget {
const AccountBookApp({super.key});
​@override
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
appBarTheme: const AppBarTheme(
backgroundColor: Colors.white,
foregroundColor: Colors.black,
elevation: 0.5,
),
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
appBarTheme: const AppBarTheme(
backgroundColor: Color(0xFF1E293B),
foregroundColor: Colors.white,
elevation: 0.5,
),
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
​// Global Export Helper
void showStandardDownloadMenu(BuildContext context, Offset offset) {
String lang = appSettings.language;
String previewText = lang == 'Bangla' ? 'প্রিভিউ' : (lang == 'Arabic' ? 'معاينة' : 'Preview');
String pdfText = lang == 'Bangla' ? 'পিডিএফ ডাউনলোড' : (lang == 'Arabic' ? 'تحميل كـ PDF' : 'Download as PDF');
String excelText = lang == 'Bangla' ? 'এক্সেল ডাউনলোড' : (lang == 'Arabic' ? 'تحميل كـ Excel' : 'Download as Excel');
​showMenu(
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
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Downloading $value report file... Progress notification sent.')),
);
}
});
}
​void showStandardSortMenu(BuildContext context, Offset offset, Function(String) onSelected) {
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
​void showLocalizedDeleteDialog({
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
​showDialog(
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
​// ==========================================
// 4. LOCK SCREEN & SECURITY
// ==========================================
​class PinLockScreen extends StatefulWidget {
const PinLockScreen({super.key});
​@override
State<PinLockScreen> createState() => _PinLockScreenState();
}
​class _PinLockScreenState extends State<PinLockScreen> {
final TextEditingController _pinController = TextEditingController();
​void _verifyPin(BuildContext context) {
if (_pinController.text == appSettings.appPin || appSettings.useNoneLock) {
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (context) => const MainHomeScreen()),
);
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Incorrect PIN! Please try again.')),
);
}
}
​void _showForgotPinDialog(BuildContext context) {
final TextEditingController identifierController = TextEditingController();
final TextEditingController newPinController = TextEditingController();
final TextEditingController confirmPinController = TextEditingController();
​showDialog(
context: context,
builder: (ctx) {
return AlertDialog(
title: const Text('Forgot PIN Reset'),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Text('Enter registered Email, DOB, or Mobile Number to reset PIN.', style: TextStyle(fontSize: 12, color: Colors.grey)),
const SizedBox(height: 12),
TextField(controller: identifierController, decoration: const InputDecoration(labelText: 'Email / DOB / Mobile', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: newPinController, keyboardType: TextInputType.number, maxLength: 4, decoration: const InputDecoration(labelText: 'New 4-Digit PIN', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: confirmPinController, keyboardType: TextInputType.number, maxLength: 4, decoration: const InputDecoration(labelText: 'Confirm 4-Digit PIN', border: OutlineInputBorder())),
],
),
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
ElevatedButton(
onPressed: () {
String input = identifierController.text.trim();
bool isValid = input == appSettings.profileEmail || input == appSettings.profileBirthDate || input == appSettings.profileMobile;
​if (!isValid) {
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Identity verification failed!'), backgroundColor: Colors.red));
return;
}
if (newPinController.text.length == 4 && newPinController.text == confirmPinController.text) {
appSettings.updatePin(newPinController.text);
Navigator.pop(ctx);
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN updated successfully!')));
}
},
child: const Text('Reset PIN'),
),
],
);
},
);
}
​void _showLanguageSelector(BuildContext context) {
showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Select Language'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
ListTile(
title: const Text('Arabic (العربية)'),
onTap: () {
appSettings.setLanguage('Arabic');
Navigator.pop(ctx);
},
),
ListTile(
title: const Text('Bangla (বাংলা)'),
onTap: () {
appSettings.setLanguage('Bangla');
Navigator.pop(ctx);
},
),
ListTile(
title: const Text('English'),
onTap: () {
appSettings.setLanguage('English');
Navigator.pop(ctx);
},
),
],
),
),
);
}
​@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF0F172A),
body: SafeArea(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24.0),
child: Column(
children: [
const SizedBox(height: 16),
Align(
alignment: Alignment.topRight,
child: IconButton(
icon: const Icon(Icons.language, color: Colors.white),
onPressed: () => _showLanguageSelector(context),
),
),
const Spacer(),
const Icon(Icons.account_balance_wallet, size: 70, color: Color(0xFF10B981)),
const SizedBox(height: 12),
Text(
appSettings.getAppTitle(),
style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
),
const SizedBox(height: 40),
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
width: 240,
height: 55,
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
style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
onPressed: () => _verifyPin(context),
child: const Text('Unlock Ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
),
),
const SizedBox(height: 16),
TextButton(
onPressed: () => _showForgotPinDialog(context),
child: const Text('Forgot PIN?', style: TextStyle(color: Color(0xFF38BDF8))),
),
const Spacer(),
],
),
),
),
);
}
}
​// ==========================================
// 5. HOME SCREEN & DASHBOARD
// ==========================================
​class HomeScreenContent extends StatelessWidget {
const HomeScreenContent({super.key});
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​return AnimatedBuilder(
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
// Current Balance Card (Real-Time across all accounts, NO month/date filter)
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Theme.of(context).cardColor,
borderRadius: BorderRadius.circular(16),
boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
const SizedBox(height: 6),
Text('{appSettings.getTotalBalance()} $curr', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
const Divider(height: 24),
Row(
children: [
Expanded(
child: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(appSettings.translate('Income'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
const SizedBox(height: 4),
Text('${appSettings.getTotalIncome()} $curr', style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
],
),
),
),
const SizedBox(width: 12),
Expanded(
child: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(appSettings.translate('Expense'), style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
const SizedBox(height: 4),
Text('${appSettings.getTotalExpense()} $curr', style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
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
SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: [
_quickIcon(context, Icons.account_balance_wallet, appSettings.translate('Account'), const AccountsScreen()),
_quickIcon(context, Icons.track_changes, appSettings.translate('Budget'), const BudgetScreen()),
_quickIcon(context, Icons.category, appSettings.translate('Categories'), const CategoriesScreen()),
_quickIcon(context, Icons.shopping_cart, appSettings.translate('Shopping'), const FundShoppingScreen()),
_quickIcon(context, Icons.calculate, appSettings.translate('Calculators'), const CalculatorsHubScreen()),
],
),
),
const SizedBox(height: 24),
Text(appSettings.translate('Recent Transactions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),
appSettings.transactions.isEmpty
? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No transactions available')))
: ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: appSettings.transactions.length > 5 ? 5 : appSettings.transactions.length,
itemBuilder: (context, index) {
final txn = appSettings.transactions[index];
bool isIncome = txn.type == 'Income';
return Card(
margin: const EdgeInsets.only(bottom: 8),
child: ListTile(
leading: CircleAvatar(
backgroundColor: (isIncome ? Colors.green : Colors.red).withOpacity(0.15),
child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red),
),
title: Text('${appSettings.translate(txn.category)} ({appSettings.translate(txn.account)})', style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text(txn.description),
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
​Widget _quickIcon(BuildContext context, IconData icon, String label, Widget screen) {
return Padding(
padding: const EdgeInsets.only(right: 16.0),
child: InkWell(
onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
child: Column(
children: [
Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
child: Icon(icon, color: const Color(0xFF10B981), size: 24),
),
const SizedBox(height: 6),
Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
],
),
),
);
}
}
​// ==========================================
// 6. NOTIFICATION CENTER
// ==========================================
​class NotificationCenterScreen extends StatefulWidget {
const NotificationCenterScreen({super.key});
​@override
State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}
​class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
String selectedTab = 'All';
​@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) {
var list = appSettings.notifications.where((n) {
if (selectedTab == 'Unread') return !n.isRead;
if (selectedTab == 'Read') return n.isRead;
if (selectedTab == 'Loan') return n.category == 'loan';
if (selectedTab == 'Alerts') return n.category == 'alert';
return true;
}).toList();
​return Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Notifications')),
actions: [
PopupMenuButton<String>(
onSelected: (val) {
if (val == 'read_all') appSettings.markAllNotificationsAsRead();
if (val == 'delete_all') appSettings.deleteAllNotifications();
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
children: ['All', 'Unread', 'Read', 'Loan', 'Alerts'].map((tab) {
bool isSelected = selectedTab == tab;
return Padding(
padding: const EdgeInsets.only(right: 8.0),
child: ChoiceChip(
label: Text(appSettings.translate(tab)),
selected: isSelected,
selectedColor: const Color(0xFF10B981),
onSelected: (val) => setState(() => selectedTab = tab),
),
);
}).toList(),
),
),
Expanded(
child: list.isEmpty
? const Center(child: Text('No notifications found'))
: ListView.builder(
itemCount: list.length,
itemBuilder: (context, index) {
final n = list[index];
return Card(
margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
child: ListTile(
leading: Icon(
n.isRead ? Icons.notifications_none : Icons.notifications_active,
color: n.isRead ? Colors.grey : const Color(0xFF10B981),
),
title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
subtitle: Text(n.message),
trailing: IconButton(
icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
onPressed: () => appSettings.deleteNotification(n.id),
),
),
);
},
),
),
],
),
);
},
);
}
}
​// ==========================================
// 7. LOAN & DEBT SCREEN
// ==========================================
​class LoanDebtScreen extends StatefulWidget {
const LoanDebtScreen({super.key});
​@override
State<LoanDebtScreen> createState() => _LoanDebtScreenState();
}
​class _LoanDebtScreenState extends State<LoanDebtScreen> {
String selectedFilter = 'All';
​void _showAddEditLoanDialog(BuildContext context, {int? index, LoanItem? loan}) {
String loanType = loan?.type ?? 'Given';
String selectedAccount = loan?.account ?? appSettings.accounts.first.name;
final nameC = TextEditingController(text: loan?.personName ?? '');
final amountC = TextEditingController(text: loan != null ? loan.amount.toString() : '');
final descC = TextEditingController(text: loan?.description ?? '');
bool updateBalance = true;
​showDialog(
context: context,
builder: (ctx) => StatefulBuilder(
builder: (ctx, setStateModal) => AlertDialog(
title: Text(index == null ? 'Add Loan / Debt' : 'Edit Loan / Debt'),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Row(
children: [
Expanded(
child: ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Given' ? Colors.green : Theme.of(context).cardColor),
onPressed: () => setStateModal(() => loanType = 'Given'),
child: const Text('Given'),
),
),
const SizedBox(width: 8),
Expanded(
child: ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Taken' ? Colors.red : Theme.of(context).cardColor),
onPressed: () => setStateModal(() => loanType = 'Taken'),
child: const Text('Taken'),
),
),
],
),
const SizedBox(height: 12),
TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Person Name', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
const SizedBox(height: 10),
DropdownButtonFormField<String>(
value: selectedAccount,
decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
items: appSettings.accounts.map((a) => DropdownMenuItem(value: a.name, child: Text(a.name))).toList(),
onChanged: (val) { if (val != null) setStateModal(() => selectedAccount = val); },
),
const SizedBox(height: 10),
TextField(controller: descC, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
CheckboxListTile(
title: const Text('Update Account Balance?'),
value: updateBalance,
onChanged: (val) => setStateModal(() => updateBalance = val ?? true),
),
],
),
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
ElevatedButton(
onPressed: () {
if (nameC.text.isNotEmpty && amountC.text.isNotEmpty) {
double amt = double.tryParse(amountC.text) ?? 0.0;
if (index == null) {
appSettings.addLoan(
LoanItem(
id: DateTime.now().toString(),
personName: nameC.text,
amount: amt,
type: loanType,
date: DateTime.now(),
description: descC.text,
account: selectedAccount,
),
updateAccountBalance: updateBalance,
);
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
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​return AnimatedBuilder(
animation: appSettings,
builder: (context, _) {
var filteredLoans = appSettings.loans.where((l) {
if (selectedFilter == 'Given') return l.type == 'Given' && !l.isPaid;
if (selectedFilter == 'Taken') return l.type == 'Taken' && !l.isPaid;
if (selectedFilter == 'Paid') return l.isPaid;
return true;
}).toList();
​return Scaffold(
appBar: AppBar(
title: const Text('Loan & Debt Ledger'),
actions: [
Builder(
builder: (ctx) => IconButton(
icon: const Icon(Icons.download),
onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)),
),
),
],
),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
Column(
children: [
const Text('Total Given', style: TextStyle(color: Colors.green)),
Text('${appSettings.getTotalGiven()} curr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
],
),
Column(
children: [
const Text('Total Taken', style: TextStyle(color: Colors.redAccent)),
Text('{appSettings.getTotalTaken()} curr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
],
),
],
),
),
const SizedBox(height: 12),
Expanded(
child: ListView.builder(
itemCount: filteredLoans.length,
itemBuilder: (context, index) {
final l = filteredLoans[index];
return Card(
child: ListTile(
title: Text(l.personName, style: TextStyle(decoration: l.isPaid ? TextDecoration.lineThrough : null)),
subtitle: Text('{l.type} - Account: ${l.account}'),
trailing: Text('$curr ${l.amount}', style: TextStyle(color: l.type == 'Given' ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold)),
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
);
},
);
}
}
​// ==========================================
// 8. CALCULATORS HUB
// ==========================================
​class CalculatorsHubScreen extends StatefulWidget {
const CalculatorsHubScreen({super.key});
​@override
State<CalculatorsHubScreen> createState() => _CalculatorsHubScreenState();
}
​class _CalculatorsHubScreenState extends State<CalculatorsHubScreen> {
int calcIndex = 0;
String display = '0';
double loanAmount = 100000;
double interestRate = 10;
double tenure = 12;
​@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Calculators Hub')),
body: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
TextButton(onPressed: () => setState(() => calcIndex = 0), child: Text('General', style: TextStyle(color: calcIndex == 0 ? const Color(0xFF10B981) : Colors.grey))),
TextButton(onPressed: () => setState(() => calcIndex = 1), child: Text('EMI Calculator', style: TextStyle(color: calcIndex == 1 ? const Color(0xFF10B981) : Colors.grey))),
],
),
Expanded(
child: calcIndex == 0 ? _generalCalc() : _emiCalc(),
),
],
),
);
}
​Widget _generalCalc() {
return Column(
children: [
Expanded(
child: Container(
alignment: Alignment.bottomRight,
padding: const EdgeInsets.all(24),
child: Text(display, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
),
),
GridView.count(
shrinkWrap: true,
crossAxisCount: 4,
children: ['7','8','9','/','4','5','6','*','1','2','3','-','C','0','=','+'].map((btn) {
return InkWell(
onTap: () {
setState(() {
if (btn == 'C') display = '0';
else if (display == '0') display = btn;
else display += btn;
});
},
child: Container(
margin: const EdgeInsets.all(6),
decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
child: Center(child: Text(btn, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
),
);
}).toList(),
),
],
);
}
​Widget _emiCalc() {
return Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Loan Amount: $loanAmount'),
Row(
children: [
IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => loanAmount = (loanAmount - 1000).clamp(0, 10000000))),
IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => setState(() => loanAmount += 1000)),
],
),
],
),
],
),
);
}
}
​// ==========================================
// 9. ACCOUNTS SCREEN
// ==========================================
​class AccountsScreen extends StatefulWidget {
const AccountsScreen({super.key});
​@override
State<AccountsScreen> createState() => _AccountsScreenState();
}
​class _AccountsScreenState extends State<AccountsScreen> {
void _showAccountDialog({int? index, AccountModel? acc}) {
final nameC = TextEditingController(text: acc?.name ?? '');
final typeC = TextEditingController(text: acc?.type ?? 'Bank');
final detC = TextEditingController(text: acc?.details ?? '');
final balC = TextEditingController(text: acc != null ? acc.balance.toString() : '0.0');
​showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: Text(index == null ? 'Add Account' : 'Edit Account'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Account Name', border: OutlineInputBorder())),
const SizedBox(height: 8),
DropdownButtonFormField<String>(
value: ['Bank', 'Cash', 'Mobile Banking', 'Others'].contains(typeC.text) ? typeC.text : 'Bank',
decoration: const InputDecoration(labelText: 'Type Sequence', border: OutlineInputBorder()),
items: ['Bank', 'Cash', 'Mobile Banking', 'Others'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
onChanged: (v) { if (v != null) typeC.text = v; },
),
const SizedBox(height: 8),
TextField(controller: detC, decoration: const InputDecoration(labelText: 'Details', border: OutlineInputBorder())),
const SizedBox(height: 8),
TextField(controller: balC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Balance', border: OutlineInputBorder())),
],
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
ElevatedButton(
onPressed: () {
if (nameC.text.isNotEmpty) {
double b = double.tryParse(balC.text) ?? 0.0;
if (index == null) {
appSettings.addAccount(nameC.text, typeC.text, detC.text, b);
} else {
appSettings.updateAccount(index, nameC.text, typeC.text, detC.text, b);
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
​@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(title: const Text('Accounts Management')),
body: ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: appSettings.accounts.length,
itemBuilder: (context, index) {
final a = appSettings.accounts[index];
return Card(
child: ListTile(
title: Text('{a.name} ({a.type})'),
subtitle: Text(a.details),
trailing: Text('${a.balance} ${appSettings.currency}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
onTap: () => _showAccountDialog(index: index, acc: a),
),
);
},
),
floatingActionButton: FloatingActionButton(
backgroundColor: const Color(0xFF10B981),
onPressed: () => _showAccountDialog(),
child: const Icon(Icons.add, color: Colors.white),
),
),
);
}
}
​// ==========================================
// 10. BUDGET & CATEGORIES
// ==========================================
​class BudgetScreen extends StatelessWidget {
const BudgetScreen({super.key});
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Budget Targets')),
body: const Center(child: Text('Budget List & Threshold Alerts')),
);
}
}
​class CategoriesScreen extends StatelessWidget {
const CategoriesScreen({super.key});
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Categories')),
body: ListView.builder(
itemCount: appSettings.categories.length,
itemBuilder: (context, index) => ListTile(
title: Text(appSettings.categories[index]),
),
),
);
}
}
​class FundShoppingScreen extends StatelessWidget {
const FundShoppingScreen({super.key});
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Shopping Checklist')),
body: const Center(child: Text('Shopping items persistence')),
);
}
}
​// ==========================================
// 11. PROFILE & APP DRAWER
// ==========================================
​class AppDrawer extends StatelessWidget {
const AppDrawer({super.key});
​@override
Widget build(BuildContext context) {
return Drawer(
child: ListView(
children: [
UserAccountsDrawerHeader(
decoration: const BoxDecoration(color: Color(0xFF10B981)),
accountName: Text(appSettings.profileName),
accountEmail: Text(appSettings.profileEmail),
),
ListTile(
leading: const Icon(Icons.person),
title: const Text('Profile & Security'),
onTap: () {
Navigator.pop(context);
Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
},
),
],
),
);
}
}
​class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});
​@override
State<ProfileScreen> createState() => _ProfileScreenState();
}
​class _ProfileScreenState extends State<ProfileScreen> {
final ImagePicker _picker = ImagePicker();
​void _pickImage(ImageSource src) async {
final XFile? img = await _picker.pickImage(source: src);
if (img != null) {
appSettings.updateProfile(
name: appSettings.profileName,
email: appSettings.profileEmail,
gender: appSettings.profileGender,
birthDate: appSettings.profileBirthDate,
mobile: appSettings.profileMobile,
imagePath: img.path,
);
setState(() {});
}
}
​@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Profile & Security')),
body: ListView(
padding: const EdgeInsets.all(16),
children: [
Center(
child: Stack(
children: [
CircleAvatar(
radius: 40,
backgroundImage: appSettings.profileImagePath.isNotEmpty ? FileImage(File(appSettings.profileImagePath)) : null,
child: appSettings.profileImagePath.isEmpty ? const Icon(Icons.person, size: 40) : null,
),
Positioned(
bottom: 0,
right: 0,
child: IconButton(
icon: const Icon(Icons.camera_alt, color: Color(0xFF10B981)),
onPressed: () => _pickImage(ImageSource.gallery),
),
),
],
),
),
const SizedBox(height: 20),
Text('Name: ${appSettings.profileName}', style: const TextStyle(fontSize: 16)),
Text('Email: ${appSettings.profileEmail}', style: const TextStyle(fontSize: 16)),
],
),
);
}
}
​// ==========================================
// 12. MAIN NAVIGATION CONTAINER
// ==========================================
​class MainHomeScreen extends StatefulWidget {
const MainHomeScreen({super.key});
​@override
State<MainHomeScreen> createState() => _MainHomeScreenState();
}
​class _MainHomeScreenState extends State<MainHomeScreen> {
int _currentIndex = 0;
​final List<Widget> _pages = [
const HomeScreenContent(),
const LoanDebtScreen(),
const AccountsScreen(),
const ProfileScreen(),
];
​@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) {
return Scaffold(
body: _pages[_currentIndex],
bottomNavigationBar: BottomNavigationBar(
currentIndex: _currentIndex,
onTap: (index) => setState(() => _currentIndex = index),
type: BottomNavigationBarType.fixed,
selectedItemColor: const Color(0xFF10B981),
unselectedItemColor: Colors.grey,
items: [
BottomNavigationBarItem(icon: const Icon(Icons.home), label: appSettings.translate('Account')),
BottomNavigationBarItem(icon: const Icon(Icons.money), label: appSettings.translate('Loan')),
BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet), label: appSettings.translate('Accounts')),
BottomNavigationBarItem(icon: const Icon(Icons.person), label: appSettings.translate('Profile')),
],
),
);
},
);
}
}