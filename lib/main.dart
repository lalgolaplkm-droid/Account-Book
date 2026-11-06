import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_picker/image_picker.dart';

import 'dart:io';

​void main() async {

WidgetsFlutterBinding.ensureInitialized();

await appSettings.initPrefs();

runApp(const AccountBookApp());

}

​// ----------------- Data Models -----------------

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

amount: json['amount'],

description: json['description'],

date: DateTime.parse(json['date']),

);

}

​class LoanItem {

final String id;

String personName;

double amount;

String type; // 'Given' or 'Taken'

DateTime date;

bool isPaid;

String account; // Associated account for balance calculation

​LoanItem({

required this.id,

required this.personName,

required this.amount,

required this.type,

required this.date,

this.isPaid = false,

required this.account,

});

​Map<String, dynamic> toJson() => {

'id': id,

'personName': personName,

'amount': amount,

'type': type,

'date': date.toIso8601String(),

'isPaid': isPaid,

'account': account,

};

​factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(

id: json['id'],

personName: json['personName'],

amount: json['amount'],

type: json['type'],

date: DateTime.parse(json['date']),

isPaid: json['isPaid'],

account: json['account'] ?? 'Cash in Hand',

);

}

​class ShoppingItem {

String name;

double amount;

bool isChecked;

ShoppingItem({required this.name, this.amount = 0.0, this.isChecked = false});

​Map<String, dynamic> toJson() => {'name': name, 'amount': amount, 'isChecked': isChecked};

factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(

name: json['name'],

amount: json['amount'],

isChecked: json['isChecked'],

);

}

​class BudgetModel {

String category;

double amount;

BudgetModel({required this.category, required this.amount});

​Map<String, dynamic> toJson() => {'category': category, 'amount': amount};

factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(

category: json['category'],

amount: json['amount'],

);

}

​class SavingsModel {

String title;

double targetAmount;

double currentAmount;

bool isCompleted;

SavingsModel({

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

factory SavingsModel.fromJson(Map<String, dynamic> json) => SavingsModel(

title: json['title'],

targetAmount: json['targetAmount'],

currentAmount: json['currentAmount'],

isCompleted: json['isCompleted'],

);

}

​class AccountModel {

String name;

String type;

String details;

bool isDefault;

​AccountModel({

required this.name,

required this.type,

required this.details,

this.isDefault = false,

});

​Map<String, dynamic> toJson() => {'name': name, 'type': type, 'details': details, 'isDefault': isDefault};

factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(

name: json['name'],

type: json['type'],

details: json['details'],

isDefault: json['isDefault'],

);

}

​class RepeatedTransactionModel {

String title;

double amount;

String frequency;

RepeatedTransactionModel({required this.title, required this.amount, required this.frequency});

​Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'frequency': frequency};

factory RepeatedTransactionModel.fromJson(Map<String, dynamic> json) => RepeatedTransactionModel(

title: json['title'],

amount: json['amount'],

frequency: json['frequency'],

);

}

​class ReminderModel {

String title;

double amount;

String dueDate;

ReminderModel({required this.title, required this.amount, required this.dueDate});

​Map<String, dynamic> toJson() => {'title': title, 'amount': amount, 'dueDate': dueDate};

factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(

title: json['title'],

amount: json['amount'],

dueDate: json['dueDate'],

);

}

​// ----------------- State Management Notifier -----------------

class AppSettingsNotifier extends ChangeNotifier {

late SharedPreferences _prefs;

​ThemeMode _themeMode = ThemeMode.dark;

String _language = 'English'; // English, Arabic, Bangla

String currency = '৳';

String timeFilter = 'Month';

String appPin = '1234';

​String profileName = 'MD ALAMGIR HOSSAIN';

String profileEmail = 'alamgir@email.com';

String profileGender = 'Male';

String profileBirthDate = '01-01-1995';

String profileMobile = '018xxxxxxxx';

String profileImagePath = '';

​bool useFaceLock = false;

bool useFingerprint = false;

bool useNoneLock = false;

bool usePatternLock = false;

bool usePinLock = true;

​bool dailyReminder = true;

bool budgetAlert = true;

bool loanAlert = true;

String notificationSound = 'Default';

​int selectedMonthIndex = DateTime.now().month;

int selectedYear = DateTime.now().year;

​DateTime? customStartDate;

DateTime? customEndDate;

​List<String> categories = ['Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport'];

​List<AccountModel> accounts = [

AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', isDefault: false),

AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', isDefault: true),

AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', isDefault: false),

AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', isDefault: false),

AccountModel(name: 'UCB Bank', type: 'Bank', details: 'A/C: ...4589', isDefault: false),

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

isPaid: false,

account: 'Cash in Hand',

),

];

​List<ShoppingItem> shoppingList = [

ShoppingItem(name: 'Cooking Oil', amount: 150.0, isChecked: true),

ShoppingItem(name: 'Rice (5 kg)', amount: 450.0, isChecked: false),

];

​List<BudgetModel> budgets = [

BudgetModel(category: 'Tea & Snacks', amount: 5000.0),

BudgetModel(category: 'Transport', amount: 3000.0),

];

​List<SavingsModel> savingsList = [

SavingsModel(title: 'Emergency Savings', targetAmount: 50000, currentAmount: 15000),

SavingsModel(title: 'New Bike Goal', targetAmount: 150000, currentAmount: 45000),

];

​List<RepeatedTransactionModel> repeatedTransactions = [

RepeatedTransactionModel(title: 'House Rent', amount: 8000, frequency: '1'),

RepeatedTransactionModel(title: 'WiFi Bill', amount: 1000, frequency: '10'),

];

​List<ReminderModel> reminders = [

ReminderModel(title: 'Electricity Bill', amount: 1200, dueDate: '15'),

];

​Future<void> initPrefs() async {

_prefs = await SharedPreferences.getInstance();

appPin = _prefs.getString('appPin') ?? '1234';

_language = _prefs.getString('language') ?? 'English';

String themeStr = _prefs.getString('themeMode') ?? 'dark';

if (themeStr == 'light') {

_themeMode = ThemeMode.light;

} else if (themeStr == 'system') {

_themeMode = ThemeMode.system;

} else {

_themeMode = ThemeMode.dark;

}

​profileName = _prefs.getString('profileName') ?? 'MD ALAMGIR HOSSAIN';

profileEmail = _prefs.getString('profileEmail') ?? 'alamgir@email.com';

profileGender = _prefs.getString('profileGender') ?? 'Male';

profileBirthDate = _prefs.getString('profileBirthDate') ?? '01-01-1995';

profileMobile = _prefs.getString('profileMobile') ?? '018xxxxxxxx';

profileImagePath = _prefs.getString('profileImagePath') ?? '';

​// Sort initial lists alphabetically

_sortAllLists();

notifyListeners();

}

​void _sortAllLists() {

categories.sort((a, b) => translate(a).compareTo(translate(b)));

accounts.sort((a, b) => translate(a.name).compareTo(translate(b.name)));

budgets.sort((a, b) => translate(a.category).compareTo(translate(b.category)));

savingsList.sort((a, b) => a.title.compareTo(b.title));

shoppingList.sort((a, b) => a.name.compareTo(b.name));

repeatedTransactions.sort((a, b) => a.title.compareTo(b.title));

reminders.sort((a, b) => a.title.compareTo(b.title));

}

​Future<void> _saveToPrefs() async {

await _prefs.setString('appPin', appPin);

await _prefs.setString('language', _language);

await _prefs.setString(

'themeMode',

_themeMode == ThemeMode.light

? 'light'

: (_themeMode == ThemeMode.system ? 'system' : 'dark'));

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

case 'Grocery': return 'بقالة';

case 'Others': return 'أخرى';

case 'Salary': return 'راتب';

case 'Tea & Snacks': return 'شاي ووجبات خفيفة';

case 'Transport': return 'مواصلات';

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

_sortAllLists();

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

​void addLoan(LoanItem loan) {

loans.insert(0, loan);

notifyListeners();

}

​void updateLoan(int index, String personName, double amount, String type, String account) {

loans[index].personName = personName;

loans[index].amount = amount;

loans[index].type = type;

loans[index].account = account;

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

​double getTotalBalance() {

double totalInc = 0;

double totalExp = 0;

for (var txn in transactions) {

if (txn.type == 'Income') totalInc += txn.amount;

if (txn.type == 'Expense') totalExp += txn.amount;

}

return totalInc - totalExp;

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

isDefault: accounts.isEmpty,

));

accounts.sort((a, b) => translate(a.name).compareTo(translate(b.name)));

notifyListeners();

}

}

​void updateAccount(int index, String name, String type, String details) {

accounts[index].name = name;

accounts[index].type = type;

accounts[index].details = details;

accounts.sort((a, b) => translate(a.name).compareTo(translate(b.name)));

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

accounts.sort((a, b) => translate(a.name).compareTo(translate(b.name)));

notifyListeners();

return true;

}

return false;

}

​void addBudget(String category, double amount) {

budgets.add(BudgetModel(category: category, amount: amount));

budgets.sort((a, b) => translate(a.category).compareTo(translate(b.category)));

notifyListeners();

}

​void updateBudget(int index, String category, double amount) {

budgets[index] = BudgetModel(category: category, amount: amount);

budgets.sort((a, b) => translate(a.category).compareTo(translate(b.category)));

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

categories.sort((a, b) => translate(a).compareTo(translate(b)));

notifyListeners();

}

}

​void updateCategory(int index, String newCat) {

if (newCat.isNotEmpty) {

categories[index] = newCat;

categories.sort((a, b) => translate(a).compareTo(translate(b)));

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

transactions.insert(

0,

TransactionItem(

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

​// ----------------- Main Entry App -----------------

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

content: Text(lang == 'Bangla'

? 'এখানে আপনার বর্তমান হিসাবের সংক্ষিপ্ত প্রিভিউ দেখানো হচ্ছে।'

: (lang == 'Arabic' ? 'هذا معاينة موجزة لحسابك الحالي.' : 'Here is a preview of your financial summary.')),

actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],

),

);

} else {

String formatType = value.toUpperCase();

ScaffoldMessenger.of(context).showSnackBar(

SnackBar(

content: Text('Report downloading as $formatType... Saved to device memory.'),

behavior: SnackBarBehavior.floating,

),

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

​// ----------------- Pin & Lock Screen -----------------

class PinLockScreen extends StatefulWidget {

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

const SnackBar(content: Text('Wrong PIN!')),

);

}

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

setState(() {});

},

),

ListTile(

title: const Text('Bangla (বাংলা)'),

onTap: () {

appSettings.setLanguage('Bangla');

Navigator.pop(ctx);

setState(() {});

},

),

ListTile(

title: const Text('English'),

onTap: () {

appSettings.setLanguage('English');

Navigator.pop(ctx);

setState(() {});

},

),

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

const Text('Enter your registered Email, Birth Date (DD-MM-YYYY), or Mobile Number to verify your identity.',

style: TextStyle(fontSize: 13, color: Colors.grey)),

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

bool isValidUser = input == appSettings.profileEmail ||

input == appSettings.profileBirthDate ||

input == appSettings.profileMobile;

​if (!isValidUser) {

ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(content: Text('Error: Information does not match!'), backgroundColor: Colors.red));

return;

}

​if (newPinController.text.length != 4 || newPinController.text != confirmPinController.text) {

ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(content: Text('Error: PIN must be 4 digits and match!'), backgroundColor: Colors.red));

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

backgroundColor: const Color(0xFF0F172A),

appBar: AppBar(

backgroundColor: Colors.transparent,

elevation: 0,

actions: [

IconButton(

icon: const Icon(Icons.language, color: Colors.white),

onPressed: () => _showLanguageSelector(context),

),

],

),

body: SafeArea(

child: Padding(

padding: const EdgeInsets.symmetric(horizontal: 24.0),

child: Column(

mainAxisAlignment: MainAxisAlignment.center,

children: [

const Icon(Icons.lock_rounded, size: 70, color: Color(0xFF10B981)),

const SizedBox(height: 16),

Text(appSettings.getAppTitle(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),

const SizedBox(height: 30),

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

child: Text(_pinController.text.length > index ? '•' : '',

style: const TextStyle(color: Colors.white, fontSize: 28)),

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

style: ElevatedButton.styleFrom(

padding: const EdgeInsets.symmetric(vertical: 16),

shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),

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

​// ----------------- App Drawer -----------------

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

title: const Text('English (Default)'),

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

content: const Text('Account Book v1.0.0\nDeveloped for personal & business transaction ledger.'),

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

​// ----------------- Home Screen Content -----------------

class HomeScreenContent extends StatelessWidget {

const HomeScreenContent({super.key});

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

style: ElevatedButton.styleFrom(

backgroundColor: transactionType == 'Income' ? Colors.green : Theme.of(context).cardColor),

onPressed: () => setStateModal(() => transactionType = 'Income'),

child: const Text('Cash In'),

),

),

const SizedBox(width: 10),

Expanded(

child: ElevatedButton(

style: ElevatedButton.styleFrom(

backgroundColor: transactionType == 'Expense' ? Colors.red : Theme.of(context).cardColor),

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

items: appSettings.accounts

.map((acc) => DropdownMenuItem(value: acc.name, child: Text(appSettings.translate(acc.name))))

.toList(),

onChanged: (val) {

if (val != null) setStateModal(() => selectedAccount = val);

},

),

const SizedBox(height: 12),

DropdownButtonFormField<String>(

value: selectedCategory,

dropdownColor: Theme.of(context).cardColor,

decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),

items: appSettings.categories

.map((cat) => DropdownMenuItem(value: cat, child: Text(appSettings.translate(cat))))

.toList(),

onChanged: (val) {

if (val != null) setStateModal(() => selectedCategory = val);

},

),

const SizedBox(height: 12),

TextField(

controller: amountController,

keyboardType: TextInputType.number,

decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),

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

List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

List<int> years = List.generate(110, (index) => 1990 + index);

​return AnimatedBuilder(

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

// Current Balance Card

Container(

padding: const EdgeInsets.all(18),

decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),

child: Column(

crossAxisAlignment: CrossAxisAlignment.start,

children: [

Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),

const SizedBox(height: 8),

Text('{appSettings.getTotalBalance()} $curr', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

],

),

),

const SizedBox(height: 16),

// Filter and Income/Expense Section

Container(

padding: const EdgeInsets.all(16),

decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),

child: Column(

children: [

Row(

mainAxisAlignment: MainAxisAlignment.spaceBetween,

children: [

const Text('Income & Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),

Row(

children: [

DropdownButton<int>(

value: appSettings.selectedMonthIndex,

dropdownColor: Theme.of(context).cardColor,

items: List.generate(

12, (index) => DropdownMenuItem(value: index + 1, child: Text(months[index], style: const TextStyle(fontSize: 12)))),

onChanged: (val) {

if (val != null) appSettings.setMonthYear(val, appSettings.selectedYear);

},

),

const SizedBox(width: 6),

DropdownButton<int>(

value: appSettings.selectedYear,

dropdownColor: Theme.of(context).cardColor,

items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString(), style: const TextStyle(fontSize: 12)))).toList(),

onChanged: (val) {

if (val != null) appSettings.setMonthYear(appSettings.selectedMonthIndex, val);

},

),

],

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

Text(appSettings.translate('Income'),

style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),

const SizedBox(height: 4),

Text('${appSettings.getTotalIncome()} $curr',

style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),

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

Text(appSettings.translate('Expense'),

style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),

const SizedBox(height: 4),

Text('${appSettings.getTotalExpense()} $curr',

style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),

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

title: Text('${appSettings.translate(txn.category)} ({appSettings.translate(txn.account)})'),

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

​// ----------------- Loan & Debt Screen -----------------

class LoanDebtScreen extends StatefulWidget {

const LoanDebtScreen({super.key});

​@override

State<LoanDebtScreen> createState() => _LoanDebtScreenState();

}

​class _LoanDebtScreenState extends State<LoanDebtScreen> {

String selectedFilter = 'All';

​void _showAddEditLoanDialog(BuildContext context, {int? index, LoanItem? loan}) {

String loanType = loan?.type ?? 'Given';

String selectedAccount = loan?.account ?? appSettings.accounts.firstWhere((a) => a.isDefault, orElse: () => appSettings.accounts[0]).name;

final TextEditingController nameController = TextEditingController(text: loan?.personName ?? '');

final TextEditingController amountController = TextEditingController(text: loan != null ? loan.amount.toString() : '');

​showDialog(

context: context,

builder: (ctx) {

return StatefulBuilder(

builder: (ctx, setStateModal) {

return AlertDialog(

title: Text(index == null ? 'Add New Loan / Debt' : 'Edit Loan / Debt'),

content: Column(

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

DropdownButtonFormField<String>(

value: selectedAccount,

dropdownColor: Theme.of(context).cardColor,

decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),

items: appSettings.accounts

.map((acc) => DropdownMenuItem(value: acc.name, child: Text(appSettings.translate(acc.name))))

.toList(),

onChanged: (val) {

if (val != null) setStateModal(() => selectedAccount = val);

},

),

const SizedBox(height: 12),

TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Person Name', border: OutlineInputBorder())),

const SizedBox(height: 12),

TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),

],

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

account: selectedAccount,

));

} else {

appSettings.updateLoan(index, nameController.text, amt, loanType, selectedAccount);

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

const Text('Net Balance', style: TextStyle(color: Colors.grey, fontSize: 14)),

const SizedBox(height: 6),

Text('{appSettings.getNetBalance()} $curr',

style: TextStyle(

fontSize: 30,

fontWeight: FontWeight.bold,

color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),

const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.grey)),

Row(

mainAxisAlignment: MainAxisAlignment.spaceAround,

children: [

Column(

children: [

const Row(children: [

Icon(Icons.arrow_downward, size: 14, color: Colors.green),

SizedBox(width: 4),

Text('Given', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))

]),

const SizedBox(height: 4),

Text('${appSettings.getTotalGiven()} $curr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),

],

),

Container(height: 30, width: 1, color: Colors.grey),

Column(

children: [

const Row(children: [

Icon(Icons.arrow_upward, size: 14, color: Colors.redAccent),

SizedBox(width: 4),

Text('Taken', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))

]),

const SizedBox(height: 4),

Text('${appSettings.getTotalTaken()} $curr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),

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

backgroundColor: Theme.of(context).cardColor,

labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),

onSelected: (val) => setState(() => selectedFilter = filter),

),

);

}).toList(),

),

const SizedBox(height: 16),

const Align(

alignment: Alignment.centerLeft,

child: Text('Loan List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

),

const SizedBox(height: 10),

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

title: Text(appSettings.translate(loan.personName),

style: TextStyle(fontWeight: FontWeight.bold, decoration: loan.isPaid ? TextDecoration.lineThrough : null)),

subtitle: Text('${loan.type} ({appSettings.translate(loan.account)}) - ${loan.date.toString().substring(0, 10)}'),

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

​// ----------------- All Transactions Screen -----------------

class AllTransactionsScreen extends StatefulWidget {

const AllTransactionsScreen({super.key});

​@override

State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();

}

​class _AllTransactionsScreenState extends State<AllTransactionsScreen> {

String searchQuery = '';

String filterType = 'All';

​void _showAddEditTransactionDialog(BuildContext context, {int? index, TransactionItem? txn}) {

String transactionType = txn?.type ?? 'Expense';

String selectedCategory = txn?.category ?? appSettings.categories[0];

String selectedAccount = txn?.account ?? appSettings.accounts.firstWhere((acc) => acc.isDefault, orElse: () => appSettings.accounts[0]).name;

​final TextEditingController amountController = TextEditingController(text: txn != null ? txn.amount.toString() : '');

final TextEditingController descController = TextEditingController(text: txn?.description ?? '');

​showModalBottomSheet(

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

Text(index == null ? 'Add New Transaction' : 'Edit Transaction', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

const SizedBox(height: 16),

Row(

children: [

Expanded(

child: ElevatedButton(

style: ElevatedButton.styleFrom(

backgroundColor: transactionType == 'Income' ? Colors.green : Theme.of(context).cardColor),

onPressed: () => setStateModal(() => transactionType = 'Income'),

child: const Text('Cash In'),

),

),

const SizedBox(width: 10),

Expanded(

child: ElevatedButton(

style: ElevatedButton.styleFrom(

backgroundColor: transactionType == 'Expense' ? Colors.red : Theme.of(context).cardColor),

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

items: appSettings.accounts

.map((acc) => DropdownMenuItem(value: acc.name, child: Text(appSettings.translate(acc.name))))

.toList(),

onChanged: (val) {

if (val != null) setStateModal(() => selectedAccount = val);

},

),

const SizedBox(height: 12),

DropdownButtonFormField<String>(

value: selectedCategory,

dropdownColor: Theme.of(context).cardColor,

decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),

items: appSettings.categories

.map((cat) => DropdownMenuItem(value: cat, child: Text(appSettings.translate(cat))))

.toList(),

onChanged: (val) {

if (val != null) setStateModal(() => selectedCategory = val);

},

),

const SizedBox(height: 12),

TextField(

controller: amountController,

keyboardType: TextInputType.number,

decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder())),

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

appSettings.updateTransaction(

index,

TransactionItem(

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

​void _showFilterDialog(BuildContext context) {

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

hintText: 'Search (note, category)...',

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

title: Text('{appSettings.translate(txn.category)} ({appSettings.translate(txn.account)})',

style: const TextStyle(fontWeight: FontWeight.bold)),

subtitle: Text(appSettings.translate(txn.description)),

trailing: Row(

mainAxisSize: MainAxisSize.min,

children: [

Text(

'${isIncome ? '+' : '-'} $curr ${txn.amount}',

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

​// ----------------- Reports Screen -----------------

class ReportsScreen extends StatefulWidget {

const ReportsScreen({super.key});

​@override

State<ReportsScreen> createState() => _ReportsScreenState();

}

​class _ReportsScreenState extends State<ReportsScreen> {

bool isSortedAscending = true;

String currentFilterMode = 'This Month';

​void _pickCustomDateRange(BuildContext context) async {

DateTimeRange? picked = await showDateRangePicker(

context: context,

firstDate: DateTime(1990),

lastDate: DateTime(2100),

);

if (picked != null) {

appSettings.setCustomDateRange(picked.start, picked.end);

setState(() => currentFilterMode = 'Custom Range');

}

}

​@override

Widget build(BuildContext context) {

String curr = appSettings.currency;

double income = appSettings.getTotalIncome();

double expense = appSettings.getTotalExpense();

double budget = appSettings.monthlyBudget;

double progress = budget > 0 ? (expense / budget).clamp(0.0, 1.0) : 0.0;

​List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

List<int> years = List.generate(110, (index) => 1990 + index);

​Map<String, double> categoryExpenses = {};

for (var txn in appSettings.getFilteredTransactions()) {

if (txn.type == 'Expense') {

categoryExpenses[txn.category] = (categoryExpenses[txn.category] ?? 0.0) + txn.amount;

}

}

​var categoryList = categoryExpenses.entries.toList();

if (isSortedAscending) {

categoryList.sort((a, b) => a.value.compareTo(b.value));

} else {

categoryList.sort((a, b) => b.value.compareTo(a.value));

}

​return AnimatedBuilder(

animation: appSettings,

builder: (context, _) => Scaffold(

appBar: AppBar(

title: const Text('Reports & Analysis'),

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

label: const Text('This Month'),

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

label: const Text('Custom Months'),

selected: currentFilterMode == 'Custom Months',

selectedColor: const Color(0xFF10B981),

onSelected: (val) => setState(() => currentFilterMode = 'Custom Months'),

),

const SizedBox(width: 8),

ChoiceChip(

label: const Text('Custom Years'),

selected: currentFilterMode == 'Custom Years',

selectedColor: const Color(0xFF10B981),

onSelected: (val) => setState(() => currentFilterMode = 'Custom Years'),

),

const SizedBox(width: 8),

ChoiceChip(

label: const Text('Custom Range'),

selected: currentFilterMode == 'Custom Range',

selectedColor: const Color(0xFF10B981),

onSelected: (val) => _pickCustomDateRange(context),

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

items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(months[i]))),

onChanged: (val) {

if (val != null) setState(() => appSettings.setMonthYear(val, appSettings.selectedYear));

},

),

),

const SizedBox(width: 12),

Expanded(

child: DropdownButtonFormField<int>(

value: appSettings.selectedYear,

dropdownColor: Theme.of(context).cardColor,

decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),

items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),

onChanged: (val) {

if (val != null) setState(() => appSettings.setMonthYear(appSettings.selectedMonthIndex, val));

},

),

),

],

),

if (currentFilterMode == 'Custom Years')

DropdownButtonFormField<int>(

value: appSettings.selectedYear,

dropdownColor: Theme.of(context).cardColor,

decoration: const InputDecoration(labelText: 'Select Year', border: OutlineInputBorder()),

items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),

onChanged: (val) {

if (val != null) setState(() => appSettings.setMonthYear(appSettings.selectedMonthIndex, val));

},

),

const SizedBox(height: 16),

Container(

padding: const EdgeInsets.all(16),

decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),

child: Column(

crossAxisAlignment: CrossAxisAlignment.start,

children: [

const Text('Monthly Budget Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

const SizedBox(height: 8),

Text('Budget: $budget $curr | Spent: $expense $curr', style: const TextStyle(color: Colors.grey, fontSize: 13)),

const SizedBox(height: 8),

LinearProgressIndicator(value: progress, color: const Color(0xFF10B981), backgroundColor: Colors.white12),

const SizedBox(height: 16),

Row(

mainAxisAlignment: MainAxisAlignment.spaceBetween,

children: [

Text('Total Income: $income $curr', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),

Text('Total Expense: $expense curr', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),

],

),

],

),

),

const SizedBox(height: 20),

Row(

mainAxisAlignment: MainAxisAlignment.spaceBetween,

children: [

const Text('Expense Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

TextButton.icon(

onPressed: () => setState(() => isSortedAscending = !isSortedAscending),

icon: const Icon(Icons.sort, size: 16, color: Color(0xFF10B981)),

label: Text(isSortedAscending ? 'Sort: Low-High' : 'Sort: High-Low', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),

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

leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.2), child: const Icon(Icons.category, color: Colors.redAccent)),

title: Text(appSettings.translate(catEntry.key), style: const TextStyle(fontWeight: FontWeight.bold)),

trailing: Text('{catEntry.value} $curr', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),

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

​// ----------------- Profile Screen -----------------

class ProfileScreen extends StatefulWidget {

const ProfileScreen({super.key});

​@override

State<ProfileScreen> createState() => _ProfileScreenState();

}

​class _ProfileScreenState extends State<ProfileScreen> {

final ImagePicker _picker = ImagePicker();

​void _showProfileImagePicker() {

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

​void _showEditProfileDialog(BuildContext context) {

final nameC = TextEditingController(text: appSettings.profileName);

final emailC = TextEditingController(text: appSettings.profileEmail);

String selectedGender = appSettings.profileGender;

String birthDate = appSettings.profileBirthDate;

final mobileC = TextEditingController(text: appSettings.profileMobile);

​showDialog(

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

value: ['Male', 'Female', 'Other'].contains(selectedGender) ? selectedGender : 'Male',

dropdownColor: Theme.of(context).cardColor,

decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),

items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),

onChanged: (val) {

if (val != null) setStateDialog(() => selectedGender = val);

},

),

const SizedBox(height: 12),

GestureDetector(

onTap: () async {

DateTime? pickedDate = await showDatePicker(

context: context,

initialDate: DateTime(1995, 1, 1),

firstDate: DateTime(1900),

lastDate: DateTime.now(),

);

if (pickedDate != null) {

setStateDialog(() {

birthDate =

"{pickedDate.day.toString().padLeft(2, '0')}-{pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";

});

}

},

child: AbsorbPointer(

child: TextField(

controller: TextEditingController(text: birthDate),

decoration: const InputDecoration(

labelText: 'Birth Date (DD-MM-YYYY)', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),

),

),

),

const SizedBox(height: 12),

TextField(controller: mobileC, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),

],

),

),

actions: [

TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),

ElevatedButton(

onPressed: () {

appSettings.updateProfile(

name: nameC.text,

email: emailC.text,

gender: selectedGender,

birthDate: birthDate,

mobile: mobileC.text,

);

Navigator.pop(ctx);

setState(() {});

ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));

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

Text('Gender: ${appSettings.profileGender} | DOB: ${appSettings.profileBirthDate}', style: const TextStyle(color: Colors.white70, fontSize: 11)),

const SizedBox(height: 4),

Text('Mobile: ${appSettings.profileMobile}', style: const TextStyle(color: Colors.white70, fontSize: 11)),

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

label: const Text('Edit Profile'),

),

],

),

),

const SizedBox(height: 20),

const Text('Account', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),

const SizedBox(height: 8),

Card(

color: Theme.of(context).cardColor,

child: ListTile(

leading: const Icon(Icons.lock_outline, color: Color(0xFF10B981)),

title: const Text('Privacy & Security'),

trailing: const Icon(Icons.chevron_right, color: Colors.grey),

onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacySecurityScreen())),

),

),

const SizedBox(height: 16),

const Text('Preferences', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),

const SizedBox(height: 8),

Card(

color: Theme.of(context).cardColor,

child: ListTile(

leading: const Icon(Icons.notifications_none, color: Color(0xFF10B981)),

title: const Text('Notification Settings'),

trailing: const Icon(Icons.chevron_right, color: Colors.grey),

onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),

),

),

const SizedBox(height: 16),

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

const SizedBox(height: 20),

const Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))),

],

),

),

);

}

}

​// ----------------- Calculators Hub Screen -----------------

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

TextButton(

onPressed: () => setState(() => selectedCalcIndex = 0),

child: Text('General', style: TextStyle(color: selectedCalcIndex == 0 ? const Color(0xFF10B981) : Colors.grey))),

TextButton(

onPressed: () => setState(() => selectedCalcIndex = 1),

child: Text('Loan / EMI', style: TextStyle(color: selectedCalcIndex == 1 ? const Color(0xFF10B981) : Colors.grey))),

TextButton(

onPressed: () => setState(() => selectedCalcIndex = 2),

child: Text('SIP / Interest', style: TextStyle(color: selectedCalcIndex == 2 ? const Color(0xFF10B981) : Colors.grey))),

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

Text('Principal Amount: ${loanAmount.toStringAsFixed(0)}'),

Row(

children: [

IconButton(

icon: const Icon(Icons.remove_circle, color: Colors.red),

onPressed: () => setState(() => loanAmount = (loanAmount - 5000).clamp(1000, 10000000))),

IconButton(

icon: const Icon(Icons.add_circle, color: Colors.green),

onPressed: () => setState(() => loanAmount = (loanAmount + 5000).clamp(1000, 10000000))),

],

)

],

),

Slider(

value: loanAmount.clamp(1000, 1000000),

min: 1000,

max: 1000000,

divisions: 100,

activeColor: const Color(0xFF10B981),

onChanged: (v) => setState(() => loanAmount = v)),

const SizedBox(height: 16),

Row(

mainAxisAlignment: MainAxisAlignment.spaceBetween,

children: [

Text('Interest Rate (%): ${interestRate.toStringAsFixed(1)}'),

Row(

children: [

IconButton(

icon: const Icon(Icons.remove_circle, color: Colors.red),

onPressed: () => setState(() => interestRate = (interestRate - 0.5).clamp(1, 50))),

IconButton(

icon: const Icon(Icons.add_circle, color: Colors.green),

onPressed: () => setState(() => interestRate = (interestRate + 0.5).clamp(1, 50))),

],

)

],

),

Slider(

value: interestRate.clamp(1, 50),

min: 1,

max: 50,

divisions: 98,

activeColor: const Color(0xFF10B981),

onChanged: (v) => setState(() => interestRate = v)),

],

),

);

}

​Widget _buildSipCalculator() {

return const Padding(

padding: EdgeInsets.all(16),

child: Center(child: Text('SIP & Growth Calculator', style: TextStyle(color: Colors.grey))),

);

}

}

​// ----------------- Dashboard Analytics Screen -----------------

class DashboardAnalyticsScreen extends StatelessWidget {

const DashboardAnalyticsScreen({super.key});

​@override

Widget build(BuildContext context) {

String curr = appSettings.currency;

double income = appSettings.getTotalIncome();

double expense = appSettings.getTotalExpense();

double balance = appSettings.getTotalBalance();

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

Text('$balance $curr',

style: TextStyle(

fontSize: 20,

fontWeight: FontWeight.bold,

color: balance >= 0 ? const Color(0xFF10B981) : Colors.redAccent)),

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

​// ----------------- Interactive Screens -----------------

​// Accounts Screen

class AccountsScreen extends StatefulWidget {

const AccountsScreen({super.key});

@override

State<AccountsScreen> createState() => _AccountsScreenState();

}

​class _AccountsScreenState extends State<AccountsScreen> {

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

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.download),

onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.sort),

onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),

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

title: Text(appSettings.translate(acc.name) + (acc.isDefault ? ' [Default]' : ''),

style: const TextStyle(fontWeight: FontWeight.bold)),

subtitle: Column(

crossAxisAlignment: CrossAxisAlignment.start,

children: [

const SizedBox(height: 4),

Text(appSettings.translate(acc.type)),

const SizedBox(height: 2),

Text(acc.details, style: const TextStyle(color: Colors.grey)),

],

),

isThreeLine: true,

trailing: Row(

mainAxisSize: MainAxisSize.min,

children: [

IconButton(

icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),

onPressed: () => _showAddEditDialog(index: index, account: acc)),

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

​// Budget Screen

class BudgetScreen extends StatefulWidget {

const BudgetScreen({super.key});

@override

State<BudgetScreen> createState() => _BudgetScreenState();

}

​class _BudgetScreenState extends State<BudgetScreen> {

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

onChanged: (val) {

if (val != null) setStateSheet(() => selectedCategory = val);

},

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

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.download),

onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.sort),

onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),

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

IconButton(

icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),

onPressed: () => _showAddEditBudgetDialog(index: index, budget: b)),

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

​// Categories Screen

class CategoriesScreen extends StatefulWidget {

const CategoriesScreen({super.key});

@override

State<CategoriesScreen> createState() => _CategoriesScreenState();

}

​class _CategoriesScreenState extends State<CategoriesScreen> {

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

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.download),

onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.sort),

onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),

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

​// Savings & Goals Screen (Tabbed Interface)

class SavingsScreen extends StatefulWidget {

const SavingsScreen({super.key});

@override

State<SavingsScreen> createState() => _SavingsScreenState();

}

​class _SavingsScreenState extends State<SavingsScreen> {

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

return DefaultTabController(

length: 2,

child: AnimatedBuilder(

animation: appSettings,

builder: (context, _) => Scaffold(

appBar: AppBar(

title: Text(appSettings.translate('Savings')),

bottom: const TabBar(

indicatorColor: Color(0xFF10B981),

tabs: [

Tab(text: 'Savings Schemes'),

Tab(text: 'Target Goals'),

],

),

actions: [

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.download),

onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.sort),

onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),

],

),

body: TabBarView(

children: [

// Savings Schemes Tab

Padding(

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

Text('Target: {sav.targetAmount} $curr', style: const TextStyle(color: Colors.grey, fontSize: 12)),

const SizedBox(width: 8),

IconButton(

icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),

onPressed: () => _showAddSavingsDialog(index: index, savings: sav)),

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

// Target Goals Tab

Padding(

padding: const EdgeInsets.all(16.0),

child: ListView.builder(

itemCount: appSettings.savingsList.length,

itemBuilder: (context, index) {

final sav = appSettings.savingsList[index];

double progress = (sav.currentAmount / sav.targetAmount).clamp(0.0, 1.0);

return Card(

color: Theme.of(context).cardColor,

margin: const EdgeInsets.only(bottom: 12),

child: Padding(

padding: const EdgeInsets.all(16.0),

child: Column(

crossAxisAlignment: CrossAxisAlignment.start,

children: [

Row(

mainAxisAlignment: MainAxisAlignment.spaceBetween,

children: [

Text(sav.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),

],

),

const SizedBox(height: 8),

LinearProgressIndicator(value: progress, color: const Color(0xFF10B981), backgroundColor: Colors.white12),

const SizedBox(height: 8),

Text('{sav.currentAmount} / ${sav.targetAmount} $curr', style: const TextStyle(color: Colors.grey, fontSize: 12)),

],

),

),

);

},

),

),

],

),

floatingActionButton: FloatingActionButton(

backgroundColor: const Color(0xFF10B981),

onPressed: () => _showAddSavingsDialog(),

child: const Icon(Icons.add, color: Colors.white),

),

),

),

);

}

}

​// Shopping Screen

class FundShoppingScreen extends StatefulWidget {

const FundShoppingScreen({super.key});

@override

State<FundShoppingScreen> createState() => _FundShoppingScreenState();

}

​class _FundShoppingScreenState extends State<FundShoppingScreen> {

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

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.download),

onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.sort),

onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),

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

​// Reminders Screen

class RemindersScreen extends StatefulWidget {

const RemindersScreen({super.key});

@override

State<RemindersScreen> createState() => _RemindersScreenState();

}

​class _RemindersScreenState extends State<RemindersScreen> {

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

onChanged: (val) {

if (val != null) setStateDialog(() => selectedDay = val);

},

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

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.download),

onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.sort),

onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),

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

IconButton(

icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),

onPressed: () => _showAddReminderDialog(index: index, reminder: rem)),

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

​// Repeated Transactions Screen

class RepeatedTransactionsScreen extends StatefulWidget {

const RepeatedTransactionsScreen({super.key});

@override

State<RepeatedTransactionsScreen> createState() => _RepeatedTransactionsScreenState();

}

​class _RepeatedTransactionsScreenState extends State<RepeatedTransactionsScreen> {

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

onChanged: (val) {

if (val != null) setStateDialog(() => selectedDay = val);

},

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

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.download),

onPressed: () => showStandardDownloadMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero)))),

Builder(

builder: (ctx) => IconButton(

icon: const Icon(Icons.sort),

onPressed: () => showStandardSortMenu(context, (ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero), (val) {}))),

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

IconButton(

icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),

onPressed: () => _showAddRepeatedDialog(index: index, repeated: rep)),

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

​// Security Screen

class PrivacySecurityScreen extends StatefulWidget {

const PrivacySecurityScreen({super.key});

​@override

State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();

}

​class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {

late TextEditingController _pinController;

bool _obscurePin = true;

​bool _faceLock = false;

bool _fingerprint = false;

bool _noneLock = false;

bool _patternLock = false;

bool _pinLock = true;

​@override

void initState() {

super.initState();

_pinController = TextEditingController(text: appSettings.appPin);

_faceLock = appSettings.useFaceLock;

_fingerprint = appSettings.useFingerprint;

_noneLock = appSettings.useNoneLock;

_patternLock = appSettings.usePatternLock;

_pinLock = appSettings.usePinLock;

}

​@override

Widget build(BuildContext context) {

return AnimatedBuilder(

animation: appSettings,

builder: (context, _) => Scaffold(

appBar: AppBar(title: const Text('Privacy & Security')),

body: ListView(

padding: const EdgeInsets.all(16),

children: [

const Text('Security Options (Alphabetically Sorted)', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),

const SizedBox(height: 10),

Card(

color: Theme.of(context).cardColor,

child: Column(

children: [

SwitchListTile(

title: const Text('Face Unlock'),

subtitle: const Text('Scan & unlock with camera'),

value: _faceLock,

activeColor: const Color(0xFF10B981),

onChanged: (val) => setState(() {

_faceLock = val;

if (val) _noneLock = false;

}),

),

SwitchListTile(

title: const Text('Fingerprint Sensor'),

subtitle: const Text('Unlock using device fingerprint'),

value: _fingerprint,

activeColor: const Color(0xFF10B981),

onChanged: (val) => setState(() {

_fingerprint = val;

if (val) _noneLock = false;

}),

),

SwitchListTile(

title: const Text('None (No Lock)'),

subtitle: const Text('Bypass lock screen security'),

value: _noneLock,

activeColor: const Color(0xFF10B981),

onChanged: (val) => setState(() {

_noneLock = val;

if (val) {

_faceLock = false;

_fingerprint = false;

_patternLock = false;

_pinLock = false;

}

}),

),

SwitchListTile(

title: const Text('Pattern Lock'),

subtitle: const Text('Draw a secure pattern shape'),

value: _patternLock,

activeColor: const Color(0xFF10B981),

onChanged: (val) => setState(() {

_patternLock = val;

if (val) _noneLock = false;

}),

),

SwitchListTile(

title: const Text('PIN Code Lock'),

subtitle: const Text('Use a 4-digit numeric code'),

value: _pinLock,

activeColor: const Color(0xFF10B981),

onChanged: (val) => setState(() {

_pinLock = val;

if (val) _noneLock = false;

}),

),

],

),

),

const SizedBox(height: 20),

if (_pinLock) ...[

const Text('Change PIN Code', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),

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

labelText: '4-Digit App PIN',

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

style: ElevatedButton.styleFrom(

padding: const EdgeInsets.symmetric(vertical: 16),

shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),

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

child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

),

),

],

),

),

);

}

}

​// Notification Settings Screen

class NotificationSettingsScreen extends StatefulWidget {

const NotificationSettingsScreen({super.key});

​@override

State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();

}

​class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {

late bool daily;

late bool budget;

late bool loan;

String selectedSound = 'Default';

​@override

void initState() {

super.initState();

daily = appSettings.dailyReminder;

budget = appSettings.budgetAlert;

loan = appSettings.loanAlert;

selectedSound = appSettings.notificationSound;

}

​@override

Widget build(BuildContext context) {

return AnimatedBuilder(

animation: appSettings,

builder: (context, _) => Scaffold(

appBar: AppBar(title: const Text('Notification Settings')),

body: ListView(

padding: const EdgeInsets.all(16),

children: [

const Text('Manage App Alerts & Reminders', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),

const SizedBox(height: 10),

Card(

color: Theme.of(context).cardColor,

child: Column(

children: [

SwitchListTile(

title: const Text('Daily Transaction Reminder'),

subtitle: const Text('Get reminded to record daily expenses'),

value: daily,

activeColor: const Color(0xFF10B981),

onChanged: (val) => setState(() => daily = val),

),

SwitchListTile(

title: const Text('Budget Limit Alert'),

subtitle: const Text('Notify when expenses reach near budget limit'),

value: budget,

activeColor: const Color(0xFF10B981),

onChanged: (val) => setState(() => budget = val),

),

SwitchListTile(

title: const Text('Loan Payment Due Alert'),

subtitle: const Text('Alert on upcoming loan settlement dates'),

value: loan,

activeColor: const Color(0xFF10B981),

onChanged: (val) => setState(() => loan = val),

),

],

),

),

const SizedBox(height: 20),

const Text('Notification Sound & Alert Tone', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),

const SizedBox(height: 8),

DropdownButtonFormField<String>(

value: selectedSound,

dropdownColor: Theme.of(context).cardColor,

decoration: const InputDecoration(border: OutlineInputBorder()),

items: ['Default', 'App Chime', 'Custom from Device Memory'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),

onChanged: (val) {

if (val != null) setState(() => selectedSound = val);

},

),

const SizedBox(height: 30),

SizedBox(

width: double.infinity,

child: ElevatedButton(

style: ElevatedButton.styleFrom(

padding: const EdgeInsets.symmetric(vertical: 16),

shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),

onPressed: () {

appSettings.toggleNotification('daily', daily);

appSettings.toggleNotification('budget', budget);

appSettings.toggleNotification('loan', loan);

appSettings.setNotificationSound(selectedSound);

Navigator.pop(context);

ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings updated successfully!')));

},

child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

),

),

],

),

),

);

}

}

​// Main Navigation Container

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

