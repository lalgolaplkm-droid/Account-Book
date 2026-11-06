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
// 1. DATA MODELS
// ==========================================
​class TransactionItem {
final String id;
final String type; // Income / Expense
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
amount: (json['amount'] as num).toDouble(),
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
amount: (json['amount'] as num).toDouble(),
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
amount: (json['amount'] as num).toDouble(),
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
targetAmount: (json['targetAmount'] as num).toDouble(),
currentAmount: (json['currentAmount'] as num).toDouble(),
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
balance: (json['balance'] as num).toDouble(),
isDefault: json['isDefault'] ?? false,
);
}
​class AppNotification {
final String id;
final String title;
final String message;
final DateTime timestamp;
final String category;
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
// 2. STATE MANAGEMENT ENGINE
// ==========================================
​class AppSettingsNotifier extends ChangeNotifier {
late SharedPreferences _prefs;
​ThemeMode _themeMode = ThemeMode.dark;
String _language = 'English';
String currency = '৳';
String timeFilter = 'This Month';
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
​int selectedMonthIndex = DateTime.now().month;
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
​List<AppNotification> notifications = [
AppNotification(
id: '1',
title: 'Welcome to Account Book',
message: 'Your personal digital ledger is ready.',
timestamp: DateTime.now().subtract(const Duration(hours: 2)),
category: 'system',
isRead: false,
),
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
​categories.sort();
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
​String translate(String key) {
if (_language == 'Bangla') {
switch (key) {
case 'Account Book': return 'হিসাবের খাতা';
case 'Categories': return 'ক্যাটাগরি সমূহ';
case 'Accounts': return 'অ্যাকাউন্ট সমূহ';
case 'Theme': return 'থিম';
case 'Language': return 'ভাষা';
case 'Current Balance': return 'বর্তমান ব্যালেন্স';
case 'Income': return 'আয়';
case 'Expense': return 'ব্যয়';
case 'Quick Access': return 'কুইক এক্সেস';
case 'Recent Transactions': return 'সাম্প্রতিক লেনদেন';
case 'Budget': return 'বাজেট';
case 'Savings': return 'সেভিংস';
case 'Shopping': return 'শপিং';
case 'Account': return 'হিসাব';
case 'Loan': return 'লোন';
case 'Profile': return 'প্রোফাইল';
case 'Calculators': return 'ক্যালকুলেটর হাব';
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
​void updatePin(String newPin) {
appPin = newPin;
_saveToPrefs();
notifyListeners();
}
​void addTransaction(TransactionItem txn) {
transactions.insert(0, txn);
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
​double getTotalBalance() {
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
}
​final appSettings = AppSettingsNotifier();
​// ==========================================
// 3. MAIN APP ROUTING & ENTRY
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
),
home: const PinLockScreen(),
);
},
);
}
}
​// ==========================================
// 4. PIN LOCK SCREEN
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
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('PIN Verified Successfully!')),
);
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Incorrect PIN! Please try again.')),
);
}
}
​@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF0F172A),
body: SafeArea(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.account_balance_wallet, size: 70, color: Color(0xFF10B981)),
const SizedBox(height: 12),
Text(
appSettings.getAppTitle(),
style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
),
const SizedBox(height: 40),
TextField(
controller: _pinController,
keyboardType: TextInputType.number,
maxLength: 4,
obscureText: true,
textAlign: TextAlign.center,
style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
decoration: const InputDecoration(
hintText: 'PIN',
hintStyle: TextStyle(color: Colors.grey, letterSpacing: 0),
enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981), width: 2)),
),
onChanged: (val) {
if (val.length == 4) _verifyPin(context);
},
),
const SizedBox(height: 20),
SizedBox(
width: double.infinity,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFF10B981),
padding: const EdgeInsets.symmetric(vertical: 14),
),
onPressed: () => _verifyPin(context),
child: const Text('Unlock App', style: TextStyle(color: Colors.white, fontSize: 16)),
),
),
],
),
),
),
);
}
}