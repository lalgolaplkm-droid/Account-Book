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
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
​// ==========================================
// 5. MAIN NAVIGATION & HOME DASHBOARD
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
backgroundColor: Theme.of(context).cardColor,
items: [
BottomNavigationBarItem(
icon: const Icon(Icons.home),
label: appSettings.translate('Account Book'),
),
BottomNavigationBarItem(
icon: const Icon(Icons.money),
label: appSettings.translate('Loan'),
),
BottomNavigationBarItem(
icon: const Icon(Icons.account_balance_wallet),
label: appSettings.translate('Accounts'),
),
BottomNavigationBarItem(
icon: const Icon(Icons.person),
label: appSettings.translate('Profile'),
),
],
),
);
},
);
}
}
​class HomeScreenContent extends StatelessWidget {
const HomeScreenContent({super.key});
​void _showAddTransactionDialog(BuildContext context) {
String transactionType = 'Expense';
String selectedCategory = appSettings.categories.first;
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
style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Income' ? Colors.green : const Color(0xFF1E293B)),
onPressed: () => setStateModal(() => transactionType = 'Income'),
child: const Text('Income (Cash In)'),
),
),
const SizedBox(width: 10),
Expanded(
child: ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: transactionType == 'Expense' ? Colors.red : const Color(0xFF1E293B)),
onPressed: () => setStateModal(() => transactionType = 'Expense'),
child: const Text('Expense (Cash Out)'),
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
TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description / Note', border: OutlineInputBorder())),
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
child: const Text('Save Transaction', style: TextStyle(fontSize: 16)),
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
Text('{appSettings.getTotalBalance()}$curr', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
Text('${appSettings.getTotalIncome()}$curr', style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
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
Text('${appSettings.getTotalExpense()}$curr', style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
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
'${isIncome ? '+' : '-'} curr{txn.amount}',
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
​// ==========================================
// 6. LOAN & DEBT MANAGEMENT SCREEN
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
Text('{appSettings.getTotalGiven()}$curr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
],
),
Column(
children: [
const Text('Total Taken', style: TextStyle(color: Colors.redAccent)),
Text('${appSettings.getTotalTaken()}$curr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
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
subtitle: Text('${l.type} - Account:{l.account}'),
trailing: Text('curr{l.amount}', style: TextStyle(color: l.type == 'Given' ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold)),
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
// 7. ACCOUNTS MANAGEMENT SCREEN
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
trailing: Text('{a.balance}{appSettings.currency}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
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
// 8. CALCULATORS HUB SCREEN
// ==========================================
​class CalculatorsHubScreen extends StatefulWidget {
const CalculatorsHubScreen({super.key});
​@override
State<CalculatorsHubScreen> createState() => _CalculatorsHubScreenState();
}
​class _CalculatorsHubScreenState extends State<CalculatorsHubScreen> {
String display = '0';
​@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Calculators Hub')),
body: Column(
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
),
);
}
}
​// ==========================================
// 9. NOTIFICATION CENTER & AUXILIARIES
// ==========================================
​class NotificationCenterScreen extends StatelessWidget {
const NotificationCenterScreen({super.key});
​@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Notifications')),
body: ListView.builder(
itemCount: appSettings.notifications.length,
itemBuilder: (context, index) {
final n = appSettings.notifications[index];
return ListTile(
leading: const Icon(Icons.notifications, color: Color(0xFF10B981)),
title: Text(n.title),
subtitle: Text(n.message),
);
},
),
);
}
}
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
body: const Center(child: Text('Shopping Checklist Screen')),
);
}
}
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
import 'package:flutter/material.dart';
​// ==========================================
// 10. ADVANCED REPORTS & ANALYTICS SCREEN
// ==========================================
​class ReportsAnalyticsScreen extends StatefulWidget {
const ReportsAnalyticsScreen({super.key});
​@override
State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}
​class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
String selectedRange = 'This Month';
String reportType = 'Overview';
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​return AnimatedBuilder(
animation: appSettings,
builder: (context, _) {
double income = appSettings.getTotalIncome();
double expense = appSettings.getTotalExpense();
double netSavings = income - expense;
​return Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Report')),
actions: [
Builder(
builder: (ctx) => IconButton(
icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
onPressed: () => showStandardDownloadMenu(
context,
(ctx.findRenderObject() as RenderBox).localToGlobal(Offset.zero),
),
),
),
],
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Date Filter Selector
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
DropdownButton<String>(
value: selectedRange,
items: ['Today', 'This Week', 'This Month', 'This Year', 'Custom Range']
.map((r) => DropdownMenuItem(value: r, child: Text(r)))
.toList(),
onChanged: (val) {
if (val != null) setState(() => selectedRange = val);
},
),
ElevatedButton.icon(
icon: const Icon(Icons.tune, size: 18),
label: const Text('Filter'),
onPressed: () {},
),
],
),
const SizedBox(height: 16),
​// Summary Analytics Card
Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Theme.of(context).cardColor,
borderRadius: BorderRadius.circular(16),
border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text('Net Cashflow', style: TextStyle(color: Colors.grey)),
Text('netSavingscurr',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: netSavings >= 0 ? Colors.green : Colors.red,
)),
],
),
const Divider(height: 20),
Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
Column(
children: [
const Text('Total Inflow', style: TextStyle(fontSize: 12, color: Colors.grey)),
const SizedBox(height: 4),
Text('+ incomecurr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
],
),
Column(
children: [
const Text('Total Outflow', style: TextStyle(fontSize: 12, color: Colors.grey)),
const SizedBox(height: 4),
Text('- expensecurr', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
],
),
],
),
],
),
),
const SizedBox(height: 24),
​// Category Breakdowns
const Text('Expense Breakdown by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
const SizedBox(height: 12),
appSettings.categories.isEmpty
? const Text('No category data available')
: ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: appSettings.categories.length,
itemBuilder: (context, index) {
final cat = appSettings.categories[index];
double catTotal = 0;
for (var t in appSettings.transactions) {
if (t.category == cat && t.type == 'Expense') catTotal += t.amount;
}
double percentage = expense > 0 ? (catTotal / expense) : 0.0;
​return Padding(
padding: const EdgeInsets.only(bottom: 12.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(appSettings.translate(cat), style: const TextStyle(fontWeight: FontWeight.w500)),
Text('$catTotal curr ({(percentage * 100).toStringAsFixed(1)}%)',
style: const TextStyle(color: Colors.grey, fontSize: 13)),
],
),
const SizedBox(height: 6),
LinearProgressIndicator(
value: percentage,
backgroundColor: Colors.grey.withOpacity(0.2),
color: const Color(0xFF10B981),
minHeight: 8,
borderRadius: BorderRadius.circular(4),
),
],
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
​// ==========================================
// 11. REPEATED TRANSACTIONS & SCHEDULER
// ==========================================
​class RepeatedTransactionsScreen extends StatefulWidget {
const RepeatedTransactionsScreen({super.key});
​@override
State<RepeatedTransactionsScreen> createState() => _RepeatedTransactionsScreenState();
}
​class _RepeatedTransactionsScreenState extends State<RepeatedTransactionsScreen> {
void _showAddEditRepeatedDialog({int? index, RepeatedTransactionModel? item}) {
final titleC = TextEditingController(text: item?.title ?? '');
final amountC = TextEditingController(text: item != null ? item.amount.toString() : '');
String freq = item?.frequency ?? '1st of every month';
​showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: Text(index == null ? 'Add Auto Recurring Item' : 'Edit Recurring Item'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Title (e.g. Rent, Internet)', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fixed Amount', border: OutlineInputBorder())),
const SizedBox(height: 10),
DropdownButtonFormField<String>(
value: freq,
decoration: const InputDecoration(labelText: 'Frequency', border: OutlineInputBorder()),
items: ['Daily', 'Weekly', '1st of every month', '10th of every month', 'Yearly']
.map((f) => DropdownMenuItem(value: f, child: Text(f)))
.toList(),
onChanged: (val) { if (val != null) freq = val; },
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
appSettings.repeatedTransactions.add(
RepeatedTransactionModel(title: titleC.text, amount: amt, frequency: freq),
);
} else {
appSettings.repeatedTransactions[index] =
RepeatedTransactionModel(title: titleC.text, amount: amt, frequency: freq);
}
appSettings.notifyListeners();
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
appBar: AppBar(title: const Text('Recurring Expenses & Bills')),
body: ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: appSettings.repeatedTransactions.length,
itemBuilder: (context, index) {
final item = appSettings.repeatedTransactions[index];
return Card(
margin: const EdgeInsets.only(bottom: 8),
child: ListTile(
leading: const Icon(Icons.repeat, color: Color(0xFF10B981)),
title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text('Frequency: {item.frequency}'),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
Text('{item.amount}${appSettings.currency}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
IconButton(
icon: const Icon(Icons.delete_outline, color: Colors.red),
onPressed: () {
appSettings.repeatedTransactions.removeAt(index);
appSettings.notifyListeners();
setState(() {});
},
),
],
),
),
);
},
),
floatingActionButton: FloatingActionButton(
backgroundColor: const Color(0xFF10B981),
onPressed: () => _showAddEditRepeatedDialog(),
child: const Icon(Icons.add, color: Colors.white),
),
),
);
}
}
​// ==========================================
// 12. REMINDERS & BILL TRACKER
// ==========================================
​class RemindersScreen extends StatefulWidget {
const RemindersScreen({super.key});
​@override
State<RemindersScreen> createState() => _RemindersScreenState();
}
​class _RemindersScreenState extends State<RemindersScreen> {
void _showAddReminderDialog() {
final titleC = TextEditingController();
final amountC = TextEditingController();
final dateC = TextEditingController(text: '15th of every month');
​showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Add Bill Reminder'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Bill Name', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Expected Amount', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: dateC, decoration: const InputDecoration(labelText: 'Due Date Note', border: OutlineInputBorder())),
],
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
ElevatedButton(
onPressed: () {
if (titleC.text.isNotEmpty) {
double amt = double.tryParse(amountC.text) ?? 0.0;
appSettings.addReminder(titleC.text, amt, dateC.text);
Navigator.pop(ctx);
setState(() {});
}
},
child: const Text('Save Reminder'),
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
appBar: AppBar(title: const Text('Bill Reminders')),
body: ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: appSettings.reminders.length,
itemBuilder: (context, index) {
final r = appSettings.reminders[index];
return Card(
margin: const EdgeInsets.only(bottom: 8),
child: ListTile(
leading: const Icon(Icons.notifications_active, color: Colors.orange),
title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text('Due: {r.dueDate}'),
trailing: Text('{r.amount}${appSettings.currency}', style: const TextStyle(fontWeight: FontWeight.bold)),
),
);
},
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