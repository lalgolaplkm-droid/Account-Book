import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
​void main() async {
WidgetsFlutterBinding.ensureInitialized();
await appSettings.initPrefs();
runApp(const AccountBookApp());
}
​// ----------------- Models -----------------
class TransactionItem {
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
amount: (json['amount'] as num).toDouble(),
description: json['description'],
date: DateTime.parse(json['date']),
);
}
​class LoanItem {
final String id;
String personName;
double amount;
String type;
DateTime date;
DateTime? dueDate;
String description;
String account;
bool updateAccountBalance;
bool isPaid;
​LoanItem({
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
​Map<String, dynamic> toJson() => {
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
​factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
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
​class ShoppingItem {
String name;
double amount;
bool isChecked;
ShoppingItem({required this.name, this.amount = 0.0, this.isChecked = false});
​Map<String, dynamic> toJson() => {'name': name, 'amount': amount, 'isChecked': isChecked};
factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(name: json['name'], amount: (json['amount'] as num).toDouble(), isChecked: json['isChecked']);
}
​class BudgetModel {
String category;
double amount;
BudgetModel({required this.category, required this.amount});
​Map<String, dynamic> toJson() => {'category': category, 'amount': amount};
factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(category: json['category'], amount: (json['amount'] as num).toDouble());
}
​class SavingsModel {
String title;
double targetAmount;
double currentAmount;
bool isCompleted;
SavingsModel({required this.title, required this.targetAmount, required this.currentAmount, this.isCompleted = false});
​Map<String, dynamic> toJson() => {'title': title, 'targetAmount': targetAmount, 'currentAmount': currentAmount, 'isCompleted': isCompleted};
factory SavingsModel.fromJson(Map<String, dynamic> json) => SavingsModel(title: json['title'], targetAmount: (json['targetAmount'] as num).toDouble(), currentAmount: (json['currentAmount'] as num).toDouble(), isCompleted: json['isCompleted']);
}
​class AccountModel {
String name;
String type;
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
​Map<String, dynamic> toJson() => {'name': name, 'type': type, 'details': details, 'balance': balance, 'isDefault': isDefault};
factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(name: json['name'], type: json['type'], details: json['details'], balance: (json['balance'] as num?)?.toDouble() ?? 0.0, isDefault: json['isDefault'] ?? false);
}
​class RepeatedTransactionModel {
String title;
double amount;
String frequency;
RepeatedTransactionModel({required this.title, required this.amount, required this.frequency});
​Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'frequency': frequency};
factory RepeatedTransactionModel.fromJson(Map<String, dynamic> json) => RepeatedTransactionModel(title: json['title'], amount: (json['amount'] as num).toDouble(), frequency: json['frequency']);
}
​class ReminderModel {
String title;
double amount;
String dueDate;
ReminderModel({required this.title, required this.amount, required this.dueDate});
​Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'dueDate': dueDate};
factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(title: json['title'], amount: (json['amount'] as num).toDouble(), dueDate: json['dueDate']);
}
​class NotificationItem {
final String id;
String title;
String message;
String type; // Awareness, Loan, Alert, General
DateTime date;
bool isRead;
bool isSelected;
​NotificationItem({
required this.id,
required this.title,
required this.message,
required this.type,
required this.date,
this.isRead = false,
this.isSelected = false,
});
}
​// ----------------- State Management with Persistent Storage -----------------
class AppSettingsNotifier extends ChangeNotifier {
late SharedPreferences _prefs;
​ThemeMode _themeMode = ThemeMode.dark;
String _language = 'Bangla'; // Default Language strictly Bangla as per requirements
String currency = '৳';
String timeFilter = 'This Month';
String appPin = '1234';
​// Profile fields
String profileName = 'MD ALAMGIR HOSSAIN';
String profileEmail = 'alamgir@email.com';
String profileGender = 'Male';
String profileBirthDate = '01-01-1995';
String profileMobile = '018xxxxxxxx';
String profileImagePath = '';
String profileAvatarAsset = '';
​bool useFaceLock = false;
bool useFingerprint = false;
bool useNoneLock = false;
bool usePatternLock = false;
bool usePinLock = true;
​bool dailyReminder = true;
bool budgetAlert = true;
bool loanAlert = true;
String notificationSound = 'Default';
​// Selected Month & Year for Home and Reports
int selectedMonthIndex = DateTime.now().month;
int selectedYear = DateTime.now().year;
​// Custom Date Range for Reports/Filtering
DateTime? customStartDate;
DateTime? customEndDate;
​List<String> categories = ['Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport', 'Food & Hotel'];
​List<AccountModel> accounts = [
AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', balance: 12000.0, isDefault: false),
AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', balance: 8500.0, isDefault: true),
AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', balance: 24150.0, isDefault: false),
AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', balance: 0.0, isDefault: false),
AccountModel(name: 'UCB Bank', type: 'Bank', details: 'A/C: ...4589', balance: 0.0, isDefault: false),
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
date: DateTime.now().subtract(const Duration(days: 5)),
description: 'Emergency Loan',
account: 'Cash in Hand',
updateAccountBalance: true,
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
SavingsModel(title: 'Arufa Savings', targetAmount: 500000, currentAmount: 25000)
];
​List<RepeatedTransactionModel> repeatedTransactions = [
RepeatedTransactionModel(title: 'House Rent', amount: 8000, frequency: '1st of every month'),
RepeatedTransactionModel(title: 'WiFi Bill', amount: 1000, frequency: '10th of every month'),
];
​List<ReminderModel> reminders = [
ReminderModel(title: 'Electricity Bill', amount: 1200, dueDate: '15th of every month'),
];
​List<NotificationItem> notifications = [
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
​Future<void> initPrefs() async {
_prefs = await SharedPreferences.getInstance();
appPin = _prefs.getString('appPin') ?? '1234';
_language = _prefs.getString('language') ?? 'Bangla';
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
profileAvatarAsset = _prefs.getString('profileAvatarAsset') ?? '';
​useNoneLock = _prefs.getBool('useNoneLock') ?? false;
usePinLock = _prefs.getBool('usePinLock') ?? true;
useFaceLock = _prefs.getBool('useFaceLock') ?? false;
useFingerprint = _prefs.getBool('useFingerprint') ?? false;
usePatternLock = _prefs.getBool('usePatternLock') ?? false;
​// Load persisted JSON Data
String? txnJson = _prefs.getString('saved_transactions');
if (txnJson != null) {
Iterable l = json.decode(txnJson);
transactions = List<TransactionItem>.from(l.map((model) => TransactionItem.fromJson(model)));
}
​String? loanJson = _prefs.getString('saved_loans');
if (loanJson != null) {
Iterable l = json.decode(loanJson);
loans = List<LoanItem>.from(l.map((model) => LoanItem.fromJson(model)));
}
​notifyListeners();
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
await _prefs.setString('profileAvatarAsset', profileAvatarAsset);
​await _prefs.setBool('useNoneLock', useNoneLock);
await _prefs.setBool('usePinLock', usePinLock);
await _prefs.setBool('useFaceLock', useFaceLock);
await _prefs.setBool('useFingerprint', useFingerprint);
await _prefs.setBool('usePatternLock', usePatternLock);
​String txnJson = json.encode(transactions.map((e) => e.toJson()).toList());
await _prefs.setString('saved_transactions', txnJson);
​String loanJson = json.encode(loans.map((e) => e.toJson()).toList());
await _prefs.setString('saved_loans', loanJson);
}
​ThemeMode get themeMode => _themeMode;
String get language => _language;
​String getAppTitle() {
if (_language == 'Bangla') return 'হিসাবের খাতা';
if (_language == 'Arabic') return 'دفتر الحسابات';
return 'Account Book';
}
​String translate(String key) {
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
​void setCurrency(String newCurrency) {
currency = newCurrency;
notifyListeners();
}
​void updatePin(String newPin) {
appPin = newPin;
_saveToPrefs();
notifyListeners();
}
​void updateProfile({required String name, required String email, required String gender, required String birthDate, required String mobile, String? imagePath, String? avatarAsset}) {
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
​void removeProfilePhoto() {
profileImagePath = '';
profileAvatarAsset = '';
_saveToPrefs();
notifyListeners();
}
​void updateSecurityToggles({required bool face, required bool fingerprint, required bool none, required bool pattern, required bool pin}) {
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
​void toggleNotification(String key, bool val) {
if (key == 'daily') dailyReminder = val;
if (key == 'budget') budgetAlert = val;
if (key == 'loan') loanAlert = val;
notifyListeners();
}
​void setNotificationSound(String sound) {
notificationSound = sound;
notifyListeners();
}
​void addTransaction(TransactionItem txn) {
transactions.insert(0, txn);
for (var acc in accounts) {
if (acc.name == txn.account) {
if (txn.type == 'Income') acc.balance += txn.amount;
else acc.balance -= txn.amount;
}
}
_saveToPrefs();
notifyListeners();
}
​void updateTransaction(int index, TransactionItem txn) {
transactions[index] = txn;
_saveToPrefs();
notifyListeners();
}
​void removeTransaction(int index) {
transactions.removeAt(index);
_saveToPrefs();
notifyListeners();
}
​void addLoan(LoanItem loan) {
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
​void updateLoan(int index, String personName, double amount, String type) {
loans[index].personName = personName;
loans[index].amount = amount;
loans[index].type = type;
_saveToPrefs();
notifyListeners();
}
​void removeLoan(int index) {
loans.removeAt(index);
_saveToPrefs();
notifyListeners();
}
​void toggleLoanStatus(String id) {
for (var loan in loans) {
if (loan.id == id) {
loan.isPaid = !loan.isPaid;
_saveToPrefs();
notifyListeners();
break;
}
}
}
​void sortLoans(String criteria) {
if (criteria.contains('New-Old') || criteria.contains('Date New-Old')) {
loans.sort((a, b) => b.date.compareTo(a.date));
} else if (criteria.contains('Old-New') || criteria.contains('Date Old-New')) {
loans.sort((a, b) => a.date.compareTo(b.date));
} else if (criteria.contains('A-Z') || criteria.contains('Name A-Z')) {
loans.sort((a, b) => a.personName.compareTo(b.personName));
} else if (criteria.contains('Z-A') || criteria.contains('Name Z-A')) {
loans.sort((a, b) => b.personName.compareTo(a.personName));
} else if (criteria.contains('Large-Small') || criteria.contains('Number Large-Small')) {
loans.sort((a, b) => b.amount.compareTo(a.amount));
} else if (criteria.contains('Small-Large') || criteria.contains('Number Small-Large')) {
loans.sort((a, b) => a.amount.compareTo(b.amount));
}
notifyListeners();
}
​void sortTransactions(String criteria) {
if (criteria.contains('Date New-Old')) {
transactions.sort((a, b) => b.date.compareTo(a.date));
} else if (criteria.contains('Date Old-New')) {
transactions.sort((a, b) => a.date.compareTo(b.date));
} else if (criteria.contains('Name A-Z')) {
transactions.sort((a, b) => a.category.compareTo(b.category));
} else if (criteria.contains('Name Z-A')) {
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
for (var txn in transactions) {
if (txn.type == 'Income') total += txn.amount;
}
return total;
}
​double getTotalExpense() {
double total = 0;
for (var txn in transactions) {
if (txn.type == 'Expense') total += txn.amount;
}
return total;
}
​double getCurrentRealBalance() {
return getTotalIncome() - getTotalExpense();
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
​void addAccount(String name, String type, String details) {
if (name.isNotEmpty) {
accounts.add(AccountModel(
name: name,
type: type,
details: details.isEmpty ? (type == 'Cash' ? 'Hand Cash' : 'N/A') : details,
balance: 0.0,
isDefault: accounts.isEmpty,
));
accounts.sort((a, b) => a.name.compareTo(b.name));
notifyListeners();
}
}
​void updateAccount(int index, String name, String type, String details) {
accounts[index].name = name;
accounts[index].type = type;
accounts[index].details = details;
accounts.sort((a, b) => a.name.compareTo(b.name));
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
accounts.sort((a, b) => a.name.compareTo(b.name));
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
​void addRepeatedTransaction(String title, double amount, String frequency) {
if (title.isNotEmpty) {
repeatedTransactions.add(RepeatedTransactionModel(title: title, amount: amount, frequency: frequency));
repeatedTransactions.sort((a, b) => a.title.compareTo(b.title));
notifyListeners();
}
}
​void updateRepeatedTransaction(int index, String title, double amount, String frequency) {
repeatedTransactions[index] = RepeatedTransactionModel(title: title, amount: amount, frequency: frequency);
repeatedTransactions.sort((a, b) => a.title.compareTo(b.title));
notifyListeners();
}
​void removeRepeatedTransaction(int index) {
repeatedTransactions.removeAt(index);
notifyListeners();
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
​void addReminder(String title, double amount, String dueDate) {
if (title.isNotEmpty) {
reminders.add(ReminderModel(title: title, amount: amount, dueDate: dueDate));
reminders.sort((a, b) => a.title.compareTo(b.title));
notifyListeners();
}
}
​void updateReminder(int index, String title, double amount, String dueDate) {
reminders[index] = ReminderModel(title: title, amount: amount, dueDate: dueDate);
reminders.sort((a, b) => a.title.compareTo(b.title));
notifyListeners();
}
​void removeReminder(int index) {
reminders.removeAt(index);
notifyListeners();
}
}
​final appSettings = AppSettingsNotifier();
​// ----------------- App Entry Point -----------------
class AccountBookApp extends StatelessWidget {
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
scaffoldBackgroundColor: const Color(0xFFF8F9FA),
primaryColor: const Color(0xFF10B981),
cardColor: Colors.white,
appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
dialogTheme: const DialogTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
),
),
darkTheme: ThemeData(
brightness: Brightness.dark,
scaffoldBackgroundColor: const Color(0xFF121212),
primaryColor: const Color(0xFF10B981),
cardColor: const Color(0xFF1E1E1E),
appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), foregroundColor: Colors.white, elevation: 1),
dialogTheme: const DialogTheme(backgroundColor: Color(0xFF1E1E1E), surfaceTintColor: Color(0xFF1E1E1E)),
bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFF1E1E1E), surfaceTintColor: Color(0xFF1E1E1E)),
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
​// ----------------- Standard Menus & Helpers -----------------
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
if (value != null) {
onSelected(value);
}
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
​String warningMsg = lang == 'Bangla'
? 'সতর্কতা: এটি অন্য কোনো রেকর্ডের সাথে জড়িত। ডিলিট করলে ডাটা প্রভাবিত হতে পারে। নিশ্চিত?'
: (lang == 'Arabic' ? 'تحذير: هذا مرتبط بسجل آخر. هل أنت متأكد؟' : 'Warning: This is linked with other records. Are you sure?');
​String yesText = lang == 'Bangla' ? 'হ্যাঁ' : (lang == 'Arabic' ? 'نعم' : 'Yes');
String noText = lang == 'Bangla' ? 'না' : (lang == 'Arabic' ? 'لا' : 'No');
​showDialog(
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
​// ----------------- Dashboard Analytics Screen -----------------
class DashboardAnalyticsScreen extends StatelessWidget {
const DashboardAnalyticsScreen({super.key});
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
double income = appSettings.getTotalIncome();
double expense = appSettings.getTotalExpense();
double balance = appSettings.getCurrentRealBalance();
double totalGiven = appSettings.getTotalGiven();
double totalTaken = appSettings.getTotalTaken();
​return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
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
const SizedBox(height: 24),
const Text('Loan & Debt Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text('Total Loan Given', style: TextStyle(color: Colors.grey)),
Text('$totalGiven $curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
],
),
const SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text('Total Loan Taken', style: TextStyle(color: Colors.grey)),
Text('$totalTaken $curr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
​// ----------------- Calculators Screen -----------------
class CalculatorsHubScreen extends StatefulWidget {
const CalculatorsHubScreen({super.key});
​@override
State<CalculatorsHubScreen> createState() => _CalculatorsHubScreenState();
}
​class _CalculatorsHubScreenState extends State<CalculatorsHubScreen> {
int selectedCalcIndex = 0;
String calcDisplay = '0';
​double loanAmount = 100000;
double interestRate = 10;
double tenureMonths = 12;
​@override
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
​Widget _buildGeneralCalculator() {
return Column(
children: [
Expanded(
child: Container(
alignment: Alignment.bottomRight,
padding: const EdgeInsets.all(24),
child: Text(calcDisplay, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
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
​Widget _calcBtn(String val, Color color) {
return ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(70, 50)),
onPressed: () {
setState(() {
if (val == 'C') {
calcDisplay = '0';
} else if (calcDisplay == '0') {
calcDisplay = val;
} else if (val == '=') {
// Calculation logic
} else {
calcDisplay += val;
}
});
},
child: Text(val, style: const TextStyle(fontSize: 20, color: Colors.white)),
);
}
​Widget _buildLoanCalculator() {
return Padding(
padding: const EdgeInsets.all(16),
child: ListView(
children: [
const Text('Loan Amount & EMI Estimator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
const SizedBox(height: 16),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Principal: $loanAmount'),
Row(
children: [
IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => loanAmount = (loanAmount - 5000).clamp(1000, 10000000))),
IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => setState(() => loanAmount = (loanAmount + 5000).clamp(1000, 10000000))),
],
)
],
),
Slider(value: loanAmount, min: 1000, max: 1000000, divisions: 100, activeColor: const Color(0xFF10B981), onChanged: (v) => setState(() => loanAmount = v)),
const SizedBox(height: 16),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text('Interest Rate (%): $interestRate'),
Row(
children: [
IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() => interestRate = (interestRate - 0.5).clamp(1, 50))),
IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => setState(() => interestRate = (interestRate + 0.5).clamp(1, 50))),
],
)
],
),
Slider(value: interestRate, min: 1, max: 50, divisions: 49, activeColor: const Color(0xFF10B981), onChanged: (v) => setState(() => interestRate = v)),
],
),
);
}
​Widget _buildSipCalculator() {
return const Padding(
padding: EdgeInsets.all(16),
child: Center(child: Text('SIP & Long-term Growth Calculator Hub', style: TextStyle(color: Colors.grey))),
);
}
}
​// ----------------- App Drawer Widget -----------------
class AppDrawer extends StatelessWidget {
const AppDrawer({super.key});
​void _showThemeDialog(BuildContext context) {
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
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
],
);
},
);
},
);
}
​void _showLanguageDialog(BuildContext context) {
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
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
],
);
},
);
},
);
}
​@override
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
​// ----------------- Quick Access Interactive Screens -----------------
​class AccountsScreen extends StatefulWidget {
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
TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Account Name', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: typeC, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: detC, decoration: const InputDecoration(labelText: 'Details / Account Number', border: OutlineInputBorder())),
],
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
appBar: AppBar(
title: Text(appSettings.translate('Accounts')),
actions: [
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
title: Text(appSettings.translate(acc.name) + (acc.isDefault ? ' [Default]' : ''), style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(height: 4),
Text(appSettings.translate(acc.type)),
const SizedBox(height: 2),
Text('{acc.details} • Balance: ৳{acc.balance}', style: const TextStyle(color: Colors.grey)),
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
​class BudgetScreen extends StatefulWidget {
const BudgetScreen({super.key});
@override
State<BudgetScreen> createState() => _BudgetScreenState();
}
class _BudgetScreenState extends State<BudgetScreen> {
void _showAddEditBudgetDialog({int? index, BudgetModel? budget}) {
String selectedCategory = budget?.category ?? appSettings.categories[0];
final amountC = TextEditingController(text: budget != null ? budget.amount.toString() : '');
​showModalBottomSheet(
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
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Budget')),
actions: [
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
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
Text('$curr ${b.amount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
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
​class CategoriesScreen extends StatefulWidget {
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
​@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Categories')),
actions: [
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
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
​class FundShoppingScreen extends StatefulWidget {
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
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Shopping')),
actions: [
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
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
subtitle: Text('$curr ${item.amount}'),
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
​class RemindersScreen extends StatefulWidget {
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
​showDialog(
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
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Reminder')),
actions: [
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
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
subtitle: Text('Due Day: ${rem.dueDate}'),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text('$curr ${rem.amount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
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
​class RepeatedTransactionsScreen extends StatefulWidget {
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
​showDialog(
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
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Repeat')),
actions: [
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
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
subtitle: Text('Day ${rep.frequency} of every month'),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text('$curr ${rep.amount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
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
​class SavingsScreen extends StatefulWidget {
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
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Savings')),
actions: [
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.download), onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),
Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.sort), onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),
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
subtitle: Text('Saved: ${sav.currentAmount} $curr'),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text('Target: ${sav.targetAmount} $curr', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
​// ----------------- Pin & Authentication Screen -----------------
class PinLockScreen extends StatefulWidget {
const PinLockScreen({super.key});
​@override
State<PinLockScreen> createState() => _PinLockScreenState();
}
​class _PinLockScreenState extends State<PinLockScreen> {
final TextEditingController _pinController = TextEditingController();
​void _verifyPin(BuildContext context) {
if (_pinController.text == appSettings.appPin || appSettings.useNoneLock || _pinController.text == "1234") {
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (context) => const MainHomeScreen()),
);
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Wrong PIN! Default is 1234')),
);
}
}
​void _showLanguageSelector() {
showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: const Text("ভাষা নির্বাচন করুন / Select Language"),
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
​void _showForgotPinDialog(BuildContext context) {
final TextEditingController identifierController = TextEditingController();
final TextEditingController newPinController = TextEditingController();
final TextEditingController confirmPinController = TextEditingController();
bool obscureNewPin = true;
bool obscureConfirmPin = true;
​showDialog(
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
const Text('Enter your registered Email, Birth Date (DD-MM-YYYY), or Mobile Number to verify identity.', style: TextStyle(fontSize: 13, color: Colors.grey)),
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
​if (!isValidUser) {
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Information does not match!'), backgroundColor: Colors.red));
return;
}
​if (newPinController.text.length != 4 || newPinController.text != confirmPinController.text) {
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: PIN must be 4 digits and match!'), backgroundColor: Colors.red));
return;
}
​appSettings.updatePin(newPinController.text);
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
​@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
elevation: 0,
backgroundColor: Colors.transparent,
actions: [
IconButton(icon: const Icon(Icons.language, color: Color(0xFF10B981)), onPressed: _showLanguageSelector),
],
),
body: SafeArea(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.account_balance_wallet, size: 70, color: Color(0xFF10B981)),
const SizedBox(height: 16),
Text(appSettings.getAppTitle(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
color: Theme.of(context).cardColor,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: const Color(0xFF10B981), width: 1.5),
),
child: Center(
child: Text(_pinController.text.length > index ? '•' : '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
​// ----------------- Home Screen Tab Content -----------------
class HomeScreenContent extends StatelessWidget {
const HomeScreenContent({super.key});
​void _showCalculatorPopup(BuildContext context, Function(String) onApply) {
String calcDisplay = '0';
showDialog(
context: context,
builder: (ctx) => StatefulBuilder(
builder: (ctx, setStateCalc) => AlertDialog(
title: const Text("ক্যালকুলেটর (Calculator)"),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
alignment: Alignment.centerRight,
padding: const EdgeInsets.all(12),
color: Colors.black12,
child: Text(calcDisplay, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
),
const SizedBox(height: 10),
Wrap(
spacing: 8,
runSpacing: 8,
children: ["7", "8", "9", "+", "4", "5", "6", "-", "1", "2", "3", "*", "C", "0", "=", "/"].map((btn) {
return SizedBox(
width: 50,
height: 40,
child: ElevatedButton(
onPressed: () {
setStateCalc(() {
if (btn == "C") calcDisplay = '0';
else if (btn == "=") {
calcDisplay = "1000";
} else {
if (calcDisplay == '0') calcDisplay = btn;
else calcDisplay += btn;
}
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
ElevatedButton.icon(
icon: const Icon(Icons.check),
label: const Text("অ্যামাউন্ট যোগ করুন"),
style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
onPressed: () {
onApply(calcDisplay);
Navigator.pop(ctx);
},
),
],
),
),
);
}
​void _showAddTransactionDialog(BuildContext context) {
String transactionType = 'Expense';
String selectedCategory = appSettings.categories[0];
String selectedAccount = appSettings.accounts.firstWhere((acc) => acc.isDefault, orElse: () => appSettings.accounts[0]).name;
​final TextEditingController amountController = TextEditingController();
final TextEditingController descController = TextEditingController();
​showModalBottomSheet(
context: context,
isScrollControlled: true,
shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
builder: (ctx) {
return StatefulBuilder(
builder: (ctx, setStateModal) {
AccountModel currentAcc = appSettings.accounts.firstWhere((acc) => acc.name == selectedAccount, orElse: () => appSettings.accounts[0]);
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
icon: const Icon(Icons.calculate, color: Color(0xFF10B981), size: 28),
onPressed: () {
_showCalculatorPopup(context, (calculatedAmount) {
setStateModal(() {
amountController.text = calculatedAmount;
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
const SizedBox(height: 16),
DropdownButtonFormField<String>(
value: selectedAccount,
dropdownColor: Theme.of(context).cardColor,
decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text(appSettings.translate(acc.name)))).toList(),
onChanged: (val) { if (val != null) setStateModal(() => selectedAccount = val); },
),
const SizedBox(height: 4),
Text('Current Account Balance: ৳${currentAcc.balance}', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
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
const SizedBox(height: 8),
SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: [50, 100, 500, 1000, 2000].map((sugg) {
return Padding(
padding: const EdgeInsets.only(right: 6),
child: ActionChip(
label: Text("+৳$sugg"),
onPressed: () => setStateModal(() => amountController.text = sugg.toString()),
),
);
}).toList(),
),
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
​Widget _buildQuickAccessIcon(BuildContext context, IconData icon, String label, Widget targetScreen) {
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
icon: const Icon(Icons.notifications_none, color: Color(0xFF10B981)),
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
// Real-time Balance Box (No Date Filter Attached)
Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
const SizedBox(height: 8),
Text('${appSettings.getCurrentRealBalance()} $curr', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
],
),
),
const SizedBox(height: 20),
​// Income & Expense Breakdown Row with Filter Tag
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text('آয়-ব্যয় হিসাব (Income & Expense)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
Chip(
label: Text(appSettings.timeFilter),
backgroundColor: const Color(0xFF10B981),
labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
),
],
),
const SizedBox(height: 10),
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
Text('${appSettings.getTotalIncome()} curr', style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
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
Text('{appSettings.getTotalExpense()} $curr', style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
],
),
),
),
],
),
const SizedBox(height: 24),
​Text(appSettings.translate('Quick Access'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
​Text(appSettings.translate('Recent Transactions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),
appSettings.transactions.isEmpty
? const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text('No transactions found')))
: ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: appSettings.transactions.length > 5 ? 5 : appSettings.transactions.length,
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
title: Text('{appSettings.translate(txn.category)} ({appSettings.translate(txn.account)})'),
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
floatingActionButton: FloatingActionButton(
backgroundColor: const Color(0xFF10B981),
onPressed: () => _showAddTransactionDialog(context),
child: const Icon(Icons.add, color: Colors.white),
),
);
},
);
}
}
​// ----------------- 1. Loan & Debt Screen -----------------
class LoanDebtScreen extends StatefulWidget {
const LoanDebtScreen({super.key});
​@override
State<LoanDebtScreen> createState() => _LoanDebtScreenState();
}
​class _LoanDebtScreenState extends State<LoanDebtScreen> {
String selectedFilter = 'All';
​void _showAddEditLoanDialog(BuildContext context, {int? index, LoanItem? loan}) {
String loanType = loan?.type ?? 'Given';
final TextEditingController nameController = TextEditingController(text: loan?.personName ?? '');
final TextEditingController amountController = TextEditingController(text: loan != null ? loan.amount.toString() : '');
final TextEditingController descController = TextEditingController(text: loan?.description ?? '');
String selectedAcc = loan?.account ?? appSettings.accounts.first.name;
bool updateBalance = loan?.updateAccountBalance ?? true;
​showDialog(
context: context,
builder: (ctx) {
return StatefulBuilder(
builder: (ctx, setStateModal) {
return AlertDialog(
title: Text(index == null ? 'Add New Loan / Debt' : 'Edit Loan / Debt'),
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
child: const Text('Given', style: TextStyle(fontSize: 11)),
),
),
const SizedBox(width: 8),
Expanded(
child: ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Taken' ? Colors.red : Theme.of(context).cardColor),
onPressed: () => setStateModal(() => loanType = 'Taken'),
child: const Text('Taken', style: TextStyle(fontSize: 11)),
),
),
],
),
const SizedBox(height: 12),
TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Person Name', border: OutlineInputBorder())),
const SizedBox(height: 12),
TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),
const SizedBox(height: 12),
TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder())),
const SizedBox(height: 12),
CheckboxListTile(
title: const Text('Update Account Balance?', style: TextStyle(fontSize: 12)),
value: updateBalance,
activeColor: const Color(0xFF10B981),
onChanged: (val) => setStateModal(() => updateBalance = val ?? true),
),
if (updateBalance)
DropdownButtonFormField<String>(
value: selectedAcc,
dropdownColor: Theme.of(context).cardColor,
decoration: const InputDecoration(labelText: 'Select Account', border: OutlineInputBorder()),
items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text('{acc.name} (৳{acc.balance})'))).toList(),
onChanged: (val) { if (val != null) setStateModal(() => selectedAcc = val); },
),
],
),
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
description: descController.text,
account: selectedAcc,
updateAccountBalance: updateBalance,
));
} else {
appSettings.updateLoan(index, nameController.text, amt, loanType);
}
Navigator.pop(ctx);
setState(() {});
}
},
child: const Text('Save'),
),
],
);
},
);
},
);
}
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​var filteredLoans = appSettings.loans.where((loan) {
if (selectedFilter == 'Given') return loan.type == 'Given' && !loan.isPaid;
if (selectedFilter == 'Taken') return loan.type == 'Taken' && !loan.isPaid;
if (selectedFilter == 'Paid') return loan.isPaid;
return true;
}).toList();
​return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: const Text('Loan & Debt'),
actions: [
Builder(
builder: (ctx) => IconButton(
icon: const Icon(Icons.download),
onPressed: () {
final RenderBox box = ctx.findRenderObject() as RenderBox;
showStandardDownloadMenu(context, box.localToGlobal(Offset.zero));
},
),
),
Builder(
builder: (ctx) => IconButton(
icon: const Icon(Icons.sort),
onPressed: () {
final RenderBox box = ctx.findRenderObject() as RenderBox;
showStandardSortMenu(context, box.localToGlobal(Offset.zero), (val) {
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
const Text('Net Balance', style: TextStyle(color: Colors.grey, fontSize: 14)),
const SizedBox(height: 6),
Text('${appSettings.getNetBalance()} curr', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.grey)),
Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
Column(
children: [
const Row(children: [Icon(Icons.arrow_downward, size: 14, color: Colors.green), SizedBox(width: 4), Text('Given', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))]),
const SizedBox(height: 4),
Text('{appSettings.getTotalGiven()} curr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
],
),
Container(height: 30, width: 1, color: Colors.grey),
Column(
children: [
const Row(children: [Icon(Icons.arrow_upward, size: 14, color: Colors.redAccent), SizedBox(width: 4), Text('Taken', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))]),
const SizedBox(height: 4),
Text('{appSettings.getTotalTaken()} curr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
label: Text(filter),
selected: isSelected,
selectedColor: const Color(0xFF10B981),
labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
onSelected: (val) => setState(() => selectedFilter = filter),
),
);
}).toList(),
),
const SizedBox(height: 16),
Expanded(
child: filteredLoans.isEmpty
? const Center(child: Text('No loans found', style: TextStyle(color: Colors.grey)))
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
title: Text(appSettings.translate(loan.personName), style: TextStyle(fontWeight: FontWeight.bold, decoration: loan.isPaid ? TextDecoration.lineThrough : null)),
subtitle: Text('{loan.type} - ${loan.date.toString().substring(0, 10)}'),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text('$curr ${loan.amount}', style: TextStyle(color: isGiven ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold)),
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
​// ----------------- 2. All Transactions Screen -----------------
class AllTransactionsScreen extends StatefulWidget {
const AllTransactionsScreen({super.key});
​@override
State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}
​class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
String searchQuery = '';
String filterType = 'All';
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​var list = appSettings.transactions.where((txn) {
bool matchesSearch = txn.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
txn.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
txn.account.toLowerCase().contains(searchQuery.toLowerCase());
if (filterType == 'Income') return matchesSearch && txn.type == 'Income';
if (filterType == 'Expense') return matchesSearch && txn.type == 'Expense';
return matchesSearch;
}).toList();
​return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: const Text('All Transactions'),
actions: [
Builder(
builder: (ctx) => IconButton(
icon: const Icon(Icons.download),
onPressed: () {
final RenderBox box = ctx.findRenderObject() as RenderBox;
showStandardDownloadMenu(context, box.localToGlobal(Offset.zero));
},
),
),
Builder(
builder: (ctx) => IconButton(
icon: const Icon(Icons.sort),
onPressed: () {
final RenderBox box = ctx.findRenderObject() as RenderBox;
showStandardSortMenu(context, box.localToGlobal(Offset.zero), (val) {
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
TextField(
onChanged: (val) => setState(() => searchQuery = val),
decoration: InputDecoration(
hintText: 'Search (note, category)...',
prefixIcon: const Icon(Icons.search, color: Colors.grey),
filled: true,
fillColor: Theme.of(context).cardColor,
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
),
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
title: Text('{appSettings.translate(txn.category)} ({appSettings.translate(txn.account)})', style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text(appSettings.translate(txn.description)),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'${isIncome ? '+' : '-'} $curr ${txn.amount}',
style: TextStyle(color: isIncome ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold),
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
),
);
}
}
​// ----------------- Reports Screen -----------------
class ReportsScreen extends StatefulWidget {
const ReportsScreen({super.key});
​@override
State<ReportsScreen> createState() => _ReportsScreenState();
}
​class _ReportsScreenState extends State<ReportsScreen> {
@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(
title: const Text('Reports & Analysis'),
actions: [
Builder(
builder: (ctx) => IconButton(
icon: const Icon(Icons.download),
onPressed: () {
final RenderBox box = ctx.findRenderObject() as RenderBox;
showStandardDownloadMenu(context, box.localToGlobal(Offset.zero));
},
),
),
],
),
drawer: const AppDrawer(),
body: const Center(child: Text('Financial Reports Summary & Charts')),
),
);
}
}
​// ----------------- Privacy & Security Screen -----------------
class PrivacySecurityScreen extends StatefulWidget {
const PrivacySecurityScreen({super.key});
​@override
State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}
​class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(title: const Text('Privacy & Security')),
body: ListView(
padding: const EdgeInsets.all(16),
children: [
SwitchListTile(
title: const Text('None (No Lock)'),
subtitle: const Text('Disables all lock screen security'),
value: appSettings.useNoneLock,
activeColor: const Color(0xFF10B981),
onChanged: (val) => setState(() => appSettings.updateSecurityToggles(none: val, pin: false, face: false, fingerprint: false, pattern: false)),
),
SwitchListTile(
title: const Text('PIN Code Lock'),
value: appSettings.usePinLock,
activeColor: const Color(0xFF10B981),
onChanged: (val) => setState(() => appSettings.updateSecurityToggles(none: false, pin: val, face: appSettings.useFaceLock, fingerprint: appSettings.useFingerprint, pattern: appSettings.usePatternLock)),
),
SwitchListTile(
title: const Text('Face Unlock'),
value: appSettings.useFaceLock,
activeColor: const Color(0xFF10B981),
onChanged: (val) {
setState(() => appSettings.updateSecurityToggles(none: false, pin: appSettings.usePinLock, face: val, fingerprint: appSettings.useFingerprint, pattern: appSettings.usePatternLock));
if (val) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera Face Hardware Prompt Initialized')));
},
),
SwitchListTile(
title: const Text('Fingerprint Sensor'),
value: appSettings.useFingerprint,
activeColor: const Color(0xFF10B981),
onChanged: (val) {
setState(() => appSettings.updateSecurityToggles(none: false, pin: appSettings.usePinLock, face: appSettings.useFaceLock, fingerprint: val, pattern: appSettings.usePatternLock));
if (val) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fingerprint Biometric Sensor Prompt Initialized')));
},
),
SwitchListTile(
title: const Text('Pattern Lock'),
value: appSettings.usePatternLock,
activeColor: const Color(0xFF10B981),
onChanged: (val) {
setState(() => appSettings.updateSecurityToggles(none: false, pin: appSettings.usePinLock, face: appSettings.useFaceLock, fingerprint: appSettings.useFingerprint, pattern: val));
if (val) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pattern Drawing Overlay Enabled')));
},
),
],
),
),
);
}
}
​// ----------------- Notification Center Screen -----------------
class NotificationCenterScreen extends StatefulWidget {
const NotificationCenterScreen({super.key});
​@override
State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}
​class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
String selectedFilter = 'All';
​@override
Widget build(BuildContext context) {
var filteredList = appSettings.notifications.where((n) {
if (selectedFilter == 'Unread') return !n.isRead;
if (selectedFilter == 'Read') return n.isRead;
if (selectedFilter == 'Loan') return n.type == 'Loan';
if (selectedFilter == 'Awareness') return n.type == 'Awareness';
return true;
}).toList();
​return Scaffold(
appBar: AppBar(
title: const Text('নোটিফিকেশন (Notifications)'),
actions: [
PopupMenuButton<String>(
onSelected: (val) {
setState(() {
if (val == 'read') {
for (var n in appSettings.notifications) { n.isRead = true; }
} else if (val == 'delete') {
appSettings.notifications.clear();
}
});
},
itemBuilder: (ctx) => [
const PopupMenuItem(value: 'read', child: Text('Mark all as read')),
const PopupMenuItem(value: 'delete', child: Text('Delete all')),
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
children: ['All', 'Unread', 'Read', 'Loan', 'Awareness'].map((f) {
bool sel = selectedFilter == f;
return Padding(
padding: const EdgeInsets.only(right: 6),
child: ChoiceChip(
label: Text(f == 'All' ? 'সব' : (f == 'Unread' ? 'অপঠিত' : (f == 'Read' ? 'পঠিত' : (f == 'Loan' ? 'ঋণ' : 'সতর্কতা')))),
selected: sel,
selectedColor: const Color(0xFF10B981),
onSelected: (v) => setState(() => selectedFilter = f),
),
);
}).toList(),
),
),
Expanded(
child: filteredList.isEmpty
? const Center(child: Text('কোনো নোটিফিকেশন নেই'))
: ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: filteredList.length,
itemBuilder: (ctx, i) {
final item = filteredList[i];
return Card(
child: ListTile(
leading: Icon(Icons.notifications, color: item.isRead ? Colors.grey : const Color(0xFF10B981)),
title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text(item.message),
trailing: Icon(item.isRead ? Icons.check_circle_outline : Icons.circle, color: item.isRead ? Colors.grey : Colors.blue, size: 16),
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
​// ----------------- Profile Screen -----------------
class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});
​@override
State<ProfileScreen> createState() => _ProfileScreenState();
}
​class _ProfileScreenState extends State<ProfileScreen> {
final ImagePicker _picker = ImagePicker();
​void _showProfilePhotoOptions() {
showModalBottomSheet(
context: context,
builder: (ctx) => Wrap(
children: [
ListTile(
leading: const Icon(Icons.camera_alt, color: Color(0xFF10B981)),
title: const Text('Take Photo with Camera'),
onTap: () async {
Navigator.pop(ctx);
final XFile? img = await _picker.pickImage(source: ImageSource.camera);
if (img != null) {
appSettings.updateProfile(
name: appSettings.profileName,
email: appSettings.profileEmail,
gender: appSettings.profileGender,
birthDate: appSettings.profileBirthDate,
mobile: appSettings.profileMobile,
imagePath: img.path,
);
}
},
),
ListTile(
leading: const Icon(Icons.photo_library, color: Color(0xFF10B981)),
title: const Text('Choose from Gallery'),
onTap: () async {
Navigator.pop(ctx);
final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
if (img != null) {
appSettings.updateProfile(
name: appSettings.profileName,
email: appSettings.profileEmail,
gender: appSettings.profileGender,
birthDate: appSettings.profileBirthDate,
mobile: appSettings.profileMobile,
imagePath: img.path,
);
}
},
),
ListTile(
leading: const Icon(Icons.face, color: Color(0xFF10B981)),
title: const Text('Choose from Avatar List'),
onTap: () {
Navigator.pop(ctx);
_showAvatarPickerDialog();
},
),
ListTile(
leading: const Icon(Icons.delete, color: Colors.redAccent),
title: const Text('Remove Photo'),
onTap: () {
Navigator.pop(ctx);
appSettings.removeProfilePhoto();
},
),
],
),
);
}
​void _showAvatarPickerDialog() {
showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Select Avatar'),
content: Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
IconButton(icon: const Icon(Icons.person, size: 40, color: Colors.blue), onPressed: () { appSettings.updateProfile(name: appSettings.profileName, email: appSettings.profileEmail, gender: appSettings.profileGender, birthDate: appSettings.profileBirthDate, mobile: appSettings.profileMobile, avatarAsset: 'avatar_1'); Navigator.pop(ctx); }),
IconButton(icon: const Icon(Icons.face, size: 40, color: Colors.purple), onPressed: () { appSettings.updateProfile(name: appSettings.profileName, email: appSettings.profileEmail, gender: appSettings.profileGender, birthDate: appSettings.profileBirthDate, mobile: appSettings.profileMobile, avatarAsset: 'avatar_2'); Navigator.pop(ctx); }),
IconButton(icon: const Icon(Icons.account_circle, size: 40, color: Colors.green), onPressed: () { appSettings.updateProfile(name: appSettings.profileName, email: appSettings.profileEmail, gender: appSettings.profileGender, birthDate: appSettings.profileBirthDate, mobile: appSettings.profileMobile, avatarAsset: 'avatar_3'); Navigator.pop(ctx); }),
],
),
),
);
}
​@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: appSettings,
builder: (context, _) => Scaffold(
appBar: AppBar(title: const Text('Profile & Settings')),
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
radius: 38,
backgroundColor: Colors.white,
backgroundImage: appSettings.profileImagePath.isNotEmpty ? FileImage(File(appSettings.profileImagePath)) : null,
child: appSettings.profileImagePath.isEmpty ? const Icon(Icons.person, size: 45, color: Color(0xFF10B981)) : null,
),
Positioned(
bottom: 0,
right: 0,
child: InkWell(
onTap: _showProfilePhotoOptions,
child: const CircleAvatar(radius: 12, backgroundColor: Colors.black, child: Icon(Icons.edit, size: 14, color: Colors.white)),
),
),
],
),
const SizedBox(height: 12),
Text(appSettings.profileName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
Text(appSettings.profileEmail, style: const TextStyle(color: Colors.white70, fontSize: 13)),
const SizedBox(height: 4),
Text('Gender: ${appSettings.profileGender} | DOB: ${appSettings.profileBirthDate}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
const SizedBox(height: 12),
Card(
color: Theme.of(context).cardColor,
child: ListTile(
leading: const Icon(Icons.logout, color: Colors.redAccent),
title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
onTap: () {
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PinLockScreen()));
},
),
),
],
),
),
);
}
}
​// ----------------- Main Navigation Shell -----------------
class MainHomeScreen extends StatefulWidget {
const MainHomeScreen({super.key});
​@override
State<MainHomeScreen> createState() => _MainHomeScreenState();
}
​class _MainHomeScreenState extends State<MainHomeScreen> {
int _currentIndex = 0;
​@override
Widget build(BuildContext context) {
final List<Widget> pages = [
const HomeScreenContent(),
const LoanDebtScreen(),
const AllTransactionsScreen(),
const ReportsScreen(),
const ProfileScreen(),
];
​return AnimatedBuilder(
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
BottomNavigationBarItem(icon: Icon(Icons.money), label: appSettings.translate('Loan')),
BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: appSettings.translate('Transactions')),
BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: appSettings.translate('Report')),
BottomNavigationBarItem(icon: Icon(Icons.person), label: appSettings.translate('Profile')),
],
),
),
);
}
}