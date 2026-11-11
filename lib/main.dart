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
// 1. MODELS
// ==========================================
​class TransactionItem {
final String id;
final String type; // 'Income' or 'Expense'
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
String account; // Connected Account
DateTime date;
bool isPaid;
​LoanItem({
required this.id,
required this.personName,
required this.amount,
required this.type,
required this.account,
required this.date,
this.isPaid = false,
});
​Map<String, dynamic> toJson() => {
'id': id,
'personName': personName,
'amount': amount,
'type': type,
'account': account,
'date': date.toIso8601String(),
'isPaid': isPaid,
};
​factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
id: json['id'],
personName: json['personName'],
amount: json['amount'],
type: json['type'],
account: json['account'] ?? 'Cash in Hand',
date: DateTime.parse(json['date']),
isPaid: json['isPaid'],
);
}
​class ShoppingItem {
String name;
double amount;
bool isChecked;
ShoppingItem({required this.name, this.amount = 0.0, this.isChecked = false});
}
​class BudgetModel {
String category;
double amount;
BudgetModel({required this.category, required this.amount});
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
}
​class GoalModel {
String title;
double targetAmount;
double currentAmount;
bool isCompleted;
GoalModel({
required this.title,
required this.targetAmount,
required this.currentAmount,
this.isCompleted = false,
});
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
}
​class RepeatedTransactionModel {
String title;
double amount;
String frequency;
RepeatedTransactionModel({required this.title, required this.amount, required this.frequency});
}
​class ReminderModel {
String title;
double amount;
String dueDate;
ReminderModel({required this.title, required this.amount, required this.dueDate});
}
​// ==========================================
// 2. STATE MANAGEMENT & NOTIFIER
// ==========================================
​class AppSettingsNotifier extends ChangeNotifier {
late SharedPreferences _prefs;
​ThemeMode _themeMode = ThemeMode.dark;
String _language = 'English';
String currency = '৳';
String timeFilter = 'This Month';
String appPin = '1234';
​String profileName = 'Md. Alamgir Hossain';
String profileEmail = 'alamgir@email.com';
String profileGender = 'Male';
String profileBirthDate = '01-01-1995';
String profileMobile = '018xxxxxxxx';
String profileImagePath = '';
​// Single Global Eye Control for privacy across the entire app
bool _isGlobalHidden = false;
bool get isGlobalHidden => _isGlobalHidden;
​void toggleGlobalHide() {
_isGlobalHidden = !_isGlobalHidden;
notifyListeners();
}
​int selectedMonthIndex = DateTime.now().month;
int selectedYear = DateTime.now().year;
​DateTime? customStartDate;
DateTime? customEndDate;
​List<String> categories = ['Grocery', 'Others', 'Salary', 'Tea & Snacks', 'Transport', 'Food & Hotel'];
​List<AccountModel> accounts = [
AccountModel(name: 'Bikash', type: 'Mobile Banking', details: '018xxxxxxxx', isDefault: false),
AccountModel(name: 'Cash in Hand', type: 'Cash', details: 'Main pocket cash', isDefault: true),
AccountModel(name: 'Dutch-Bangla Bank', type: 'Bank', details: 'A/C: ...1234', isDefault: false),
AccountModel(name: 'Nagad', type: 'Mobile Banking', details: '017xxxxxxxx', isDefault: false),
AccountModel(name: 'UCB Bank', type: 'Bank', details: 'A/C: ...4589', isDefault: false),
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
personName: 'Rofiqul Islam',
amount: 2000.0,
type: 'Given',
account: 'Cash in Hand',
date: DateTime.now(),
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
SavingsModel(title: 'Emergency Fund', targetAmount: 100000, currentAmount: 15000)
];
​List<GoalModel> goalsList = [
GoalModel(title: 'Buy New Phone', targetAmount: 50000, currentAmount: 10000)
];
​List<RepeatedTransactionModel> repeatedTransactions = [
RepeatedTransactionModel(title: 'House Rent', amount: 8000, frequency: '1st of every month'),
RepeatedTransactionModel(title: 'WiFi Bill', amount: 1000, frequency: '10th of every month'),
];
​List<ReminderModel> reminders = [
ReminderModel(title: 'Electricity Bill', amount: 1200, dueDate: '15th of every month'),
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
​profileName = _prefs.getString('profileName') ?? 'Md. Alamgir Hossain';
profileEmail = _prefs.getString('profileEmail') ?? 'alamgir@email.com';
profileGender = _prefs.getString('profileGender') ?? 'Male';
profileBirthDate = _prefs.getString('profileBirthDate') ?? '01-01-1995';
profileMobile = _prefs.getString('profileMobile') ?? '018xxxxxxxx';
profileImagePath = _prefs.getString('profileImagePath') ?? '';
notifyListeners();
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
​String localizeNumber(dynamic number) {
String str = number.toString();
if (_language != 'Bangla') return str;
const EnglishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
const BanglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
for (int i = 0; i < EnglishDigits.length; i++) {
str = str.replaceAll(EnglishDigits[i], BanglaDigits[i]);
}
return str;
}
​String getLocalizedMonth(int monthIndex) {
List<String> engMonths = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
List<String> banMonths = ['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
List<String> arbMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
​if (monthIndex < 1 || monthIndex > 12) return engMonths[0];
if (_language == 'Bangla') return banMonths[monthIndex - 1];
if (_language == 'Arabic') return arbMonths[monthIndex - 1];
return engMonths[monthIndex - 1];
}
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
case 'Goals': return 'লক্ষ্যসমূহ';
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
case 'Calculators': return 'ক্যালকুলেটর হাব';
case 'Enter Your PIN': return 'আপনার পিন লিখুন';
case 'Unlock': return 'আনলক করুন';
case 'Forgot PIN?': return 'পিন ভুলে গেছেন?';
case 'This Month': return 'চলতি মাস';
case 'Custom Months': return 'কাস্টম মাস';
case 'Custom Years': return 'কাস্টম বছর';
case 'Custom Range': return 'কাস্টম রেঞ্জ';
case 'Financial Overview Summary': return 'আর্থিক সারসংক্ষেপ';
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
case 'Cancel': return 'বাতিল';
case 'Save': return 'সংরক্ষণ';
case 'Add Account': return 'অ্যাকাউন্ট যোগ করুন';
case 'Edit Account': return 'অ্যাকাউন্ট সম্পাদনা';
case 'Account Name': return 'অ্যাকাউন্টের নাম';
case 'Type': return 'ধরন';
case 'Details / Account Number': return 'বিবরণ / অ্যাকাউন্ট নম্বর';
case 'Add New Transaction': return 'নতুন লেনদেন যোগ করুন';
case 'Cash In': return 'আয় (Cash In)';
case 'Cash Out': return 'ব্যয় (Cash Out)';
case 'Description': return 'বিবরণ';
case 'Amount': return 'পরিমাণ';
case 'Person Name': return 'ব্যক্তির নাম';
case 'Add New Loan / Debt': return 'নতুন লোন বা দেনা যোগ করুন';
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
​void updateProfile({required String name, required String email, required String gender, required String birthDate, required String mobile, String? imagePath}) {
profileName = name;
profileEmail = email;
profileGender = gender;
profileBirthDate = birthDate;
profileMobile = mobile;
if (imagePath != null) profileImagePath = imagePath;
_saveToPrefs();
notifyListeners();
}
​void addTransaction(TransactionItem txn) {
transactions.insert(0, txn);
notifyListeners();
}
​void removeTransaction(int index) {
transactions.removeAt(index);
notifyListeners();
}
​double getAccountBalance(String accountName) {
double balance = 0;
for (var txn in transactions) {
if (txn.account == accountName) {
if (txn.type == 'Income') balance += txn.amount;
else if (txn.type == 'Expense') balance -= txn.amount;
}
}
for (var loan in loans) {
if (!loan.isPaid && loan.account == accountName) {
if (loan.type == 'Given') balance -= loan.amount;
else if (loan.type == 'Taken') balance += loan.amount;
}
}
return balance;
}
​void addLoan(LoanItem loan) {
loans.insert(0, loan);
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
​List<TransactionItem> getFilteredTransactions() {
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
double total = 0;
for (var txn in transactions) {
if (txn.type == 'Income') total += txn.amount;
if (txn.type == 'Expense') total -= txn.amount;
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
​void addAccount(String name, String type, String details) {
if (name.isNotEmpty) {
accounts.add(AccountModel(name: name, type: type, details: details.isEmpty ? 'N/A' : details, isDefault: accounts.isEmpty));
notifyListeners();
}
}
​void updateAccount(int index, String name, String type, String details) {
accounts[index].name = name;
accounts[index].type = type;
accounts[index].details = details;
notifyListeners();
}
​void removeAccount(int index) {
if (accounts.length > 1) {
accounts.removeAt(index);
notifyListeners();
}
}
​void addSavings(String title, double target) {
savingsList.add(SavingsModel(title: title, targetAmount: target, currentAmount: 0));
notifyListeners();
}
​void updateSavings(int index, String title, double targetAmount) {
savingsList[index].title = title;
savingsList[index].targetAmount = targetAmount;
notifyListeners();
}
​void removeSavings(int index) {
savingsList.removeAt(index);
notifyListeners();
}
​void addGoal(String title, double target) {
goalsList.add(GoalModel(title: title, targetAmount: target, currentAmount: 0));
notifyListeners();
}
​void updateGoal(int index, String title, double targetAmount) {
goalsList[index].title = title;
goalsList[index].targetAmount = targetAmount;
notifyListeners();
}
​void removeGoal(int index) {
goalsList.removeAt(index);
notifyListeners();
}
​void addCategory(String cat) {
if (cat.isNotEmpty && !categories.contains(cat)) {
categories.add(cat);
notifyListeners();
}
}
​void removeCategory(int index) {
if (categories.length > 1) {
categories.removeAt(index);
notifyListeners();
}
}
}
​final appSettings = AppSettingsNotifier();
​// ==========================================
// 3. MAIN APP INITIALIZATION
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
appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
),
),
darkTheme: ThemeData(
brightness: Brightness.dark,
scaffoldBackgroundColor: const Color(0xFF0F172A),
primaryColor: const Color(0xFF10B981),
cardColor: const Color(0xFF1E293B),
appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white, elevation: 1),
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
if (_pinController.text == appSettings.appPin) {
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHomeScreen()));
} else {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Wrong PIN! Please try again.'), backgroundColor: Colors.red),
);
_pinController.clear();
setState(() {});
}
}
​@override
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
const SizedBox(height: 60),
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
style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
),
const SizedBox(height: 32),
Text(appSettings.translate('Enter Your PIN'), style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
const SizedBox(height: 24),
SizedBox(
width: 200,
child: TextField(
controller: _pinController,
keyboardType: TextInputType.number,
maxLength: 4,
obscureText: true,
textAlign: TextAlign.center,
style: const TextStyle(color: Colors.white, fontSize: 28, letterSpacing: 10),
decoration: const InputDecoration(
counterText: '',
enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981), width: 2)),
focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981), width: 3)),
),
onChanged: (val) {
if (val.length == 4) _verifyPin(context);
},
),
),
const SizedBox(height: 32),
SizedBox(
width: double.infinity,
child: ElevatedButton(
style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
onPressed: () => _verifyPin(context),
child: Text(appSettings.translate('Unlock'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
),
),
],
),
),
),
),
),
);
}
}
​// ==========================================
// 5. DRAWER MENU
// ==========================================
​class AppDrawer extends StatelessWidget {
const AppDrawer({super.key});
​@override
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
child: Text(appSettings.profileName.isNotEmpty ? appSettings.profileName[0] : 'U', style: const TextStyle(fontSize: 24, color: Color(0xFF10B981))),
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
const Divider(),
ListTile(
leading: const Icon(Icons.language),
title: Text(appSettings.translate('Language')),
onTap: () {
Navigator.pop(context);
_showLanguageDialog(context);
},
),
],
),
);
}
​void _showLanguageDialog(BuildContext context) {
showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: Text(appSettings.translate('Language')),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
RadioListTile<String>(
title: const Text('English'),
value: 'English',
groupValue: appSettings.language,
activeColor: const Color(0xFF10B981),
onChanged: (val) {
if (val != null) {
appSettings.setLanguage(val);
Navigator.pop(ctx);
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
Navigator.pop(ctx);
}
},
),
],
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
],
),
);
}
}
​// ==========================================
// 6. HOME SCREEN CONTENT
// ==========================================
​class HomeScreenContent extends StatefulWidget {
const HomeScreenContent({super.key});
​@override
State<HomeScreenContent> createState() => _HomeScreenContentState();
}
​class _HomeScreenContentState extends State<HomeScreenContent> {
@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
double currentBal = appSettings.getTotalBalance();
​return Scaffold(
appBar: AppBar(
title: Text(appSettings.getAppTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
actions: [
// Single Global Eye Icon
IconButton(
icon: Icon(
appSettings.isGlobalHidden ? Icons.visibility_off : Icons.visibility,
color: const Color(0xFF10B981),
),
onPressed: () => appSettings.toggleGlobalHide(),
),
],
),
drawer: const AppDrawer(),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Standardized Current Balance Card
Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Theme.of(context).cardColor,
borderRadius: BorderRadius.circular(16),
border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
const SizedBox(height: 8),
Text(
appSettings.isGlobalHidden ? '' : '${appSettings.localizeNumber(currentBal)} curr',
style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
),
],
),
),
const SizedBox(height: 24),
Text(appSettings.translate('Quick Access'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
const SizedBox(height: 12),
Row(
children: [
Expanded(
child: InkWell(
onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountsScreen())),
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
child: Column(
children: [
const Icon(Icons.account_balance, color: Color(0xFF10B981), size: 30),
const SizedBox(height: 8),
Text(appSettings.translate('Accounts'), style: const TextStyle(fontWeight: FontWeight.bold)),
],
),
),
),
),
const SizedBox(width: 12),
Expanded(
child: InkWell(
onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoanScreen())),
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
child: Column(
children: [
const Icon(Icons.money, color: Colors.orangeAccent, size: 30),
const SizedBox(height: 8),
Text(appSettings.translate('Loan'), style: const TextStyle(fontWeight: FontWeight.bold)),
],
),
),
),
),
],
),
const SizedBox(height: 24),
Text(appSettings.translate('Recent Transactions'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
const SizedBox(height: 12),
ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: appSettings.transactions.length,
itemBuilder: (context, index) {
final txn = appSettings.transactions[index];
return Card(
margin: const EdgeInsets.only(bottom: 8),
child: ListTile(
leading: CircleAvatar(
backgroundColor: txn.type == 'Income' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
child: Icon(
txn.type == 'Income' ? Icons.arrow_downward : Icons.arrow_upward,
color: txn.type == 'Income' ? Colors.green : Colors.red,
),
),
title: Text(txn.category, style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text('{txn.account} • ${txn.description}'),
trailing: Text(
appSettings.isGlobalHidden
? ''
: '{txn.type == 'Income' ? '+' : '-'}{appSettings.localizeNumber(txn.amount)} $curr',
style: TextStyle(
fontWeight: FontWeight.bold,
color: txn.type == 'Income' ? Colors.green : Colors.red,
),
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
onPressed: () => _showAddTransactionModal(context),
child: const Icon(Icons.add, color: Colors.white),
),
);
}
​void _showAddTransactionModal(BuildContext context) {
final amountC = TextEditingController();
final descC = TextEditingController();
String type = 'Expense';
String selectedAccount = appSettings.accounts.isNotEmpty ? appSettings.accounts[0].name : '';
String selectedCategory = appSettings.categories.isNotEmpty ? appSettings.categories[0] : 'Others';
​showModalBottomSheet(
context: context,
isScrollControlled: true,
builder: (ctx) => StatefulBuilder(
builder: (ctx, setStateModal) => Padding(
padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(appSettings.translate('Add New Transaction'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 16),
Row(
children: [
Expanded(
child: ChoiceChip(
label: Center(child: Text(appSettings.translate('Cash Out'))),
selected: type == 'Expense',
selectedColor: Colors.redAccent,
onSelected: (val) => setStateModal(() => type = 'Expense'),
),
),
const SizedBox(width: 8),
Expanded(
child: ChoiceChip(
label: Center(child: Text(appSettings.translate('Cash In'))),
selected: type == 'Income',
selectedColor: Colors.green,
onSelected: (val) => setStateModal(() => type = 'Income'),
),
),
],
),
const SizedBox(height: 12),
// Account Dropdown: Displays Name Only
DropdownButtonFormField<String>(
value: selectedAccount,
decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Account'),
items: appSettings.accounts.map((acc) {
return DropdownMenuItem(
value: acc.name,
child: Text(acc.name),
);
}).toList(),
onChanged: (val) => setStateModal(() => selectedAccount = val!),
),
const SizedBox(height: 12),
DropdownButtonFormField<String>(
value: selectedCategory,
decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Category'),
items: appSettings.categories.map((cat) {
return DropdownMenuItem(value: cat, child: Text(appSettings.translate(cat)));
}).toList(),
onChanged: (val) => setStateModal(() => selectedCategory = val!),
),
const SizedBox(height: 12),
TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: appSettings.translate('Amount'), border: const OutlineInputBorder())),
const SizedBox(height: 12),
TextField(controller: descC, decoration: InputDecoration(labelText: appSettings.translate('Description'), border: const OutlineInputBorder())),
const SizedBox(height: 20),
Row(
mainAxisAlignment: MainAxisAlignment.end,
children: [
TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
const SizedBox(width: 8),
ElevatedButton(
onPressed: () {
if (amountC.text.isNotEmpty) {
appSettings.addTransaction(TransactionItem(
id: DateTime.now().toString(),
type: type,
account: selectedAccount,
category: selectedCategory,
amount: double.tryParse(amountC.text) ?? 0.0,
description: descC.text,
date: DateTime.now(),
));
Navigator.pop(ctx);
setState(() {});
}
},
child: Text(appSettings.translate('Save')),
),
],
),
const SizedBox(height: 16),
],
),
),
),
),
);
}
}
​// ==========================================
// 7. ACCOUNTS SCREEN
// ==========================================
​class AccountsScreen extends StatefulWidget {
const AccountsScreen({super.key});
​@override
State<AccountsScreen> createState() => _AccountsScreenState();
}
​class _AccountsScreenState extends State<AccountsScreen> {
void _showAddEditDialog({int? index, AccountModel? account}) {
final nameC = TextEditingController(text: account?.name ?? '');
final typeC = TextEditingController(text: account?.type ?? 'Bank');
final detC = TextEditingController(text: account?.details ?? '');
​showDialog(
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
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​return Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Accounts')),
actions: [
IconButton(
icon: Icon(appSettings.isGlobalHidden ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF10B981)),
onPressed: () => appSettings.toggleGlobalHide(),
),
],
),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: ListView.builder(
itemCount: appSettings.accounts.length,
itemBuilder: (context, index) {
final acc = appSettings.accounts[index];
double accBal = appSettings.getAccountBalance(acc.name);
​return Card(
margin: const EdgeInsets.only(bottom: 10),
child: ListTile(
leading: CircleAvatar(
backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
child: const Icon(Icons.account_balance_wallet, color: Color(0xFF10B981)),
),
title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(acc.type),
Text(
appSettings.isGlobalHidden ? 'Current Balance: ********' : 'Current Balance: ${appSettings.localizeNumber(accBal)} $curr',
style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
),
],
),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => _showAddEditDialog(index: index, account: acc)),
IconButton(
icon: const Icon(Icons.delete, color: Colors.redAccent),
onPressed: () {
appSettings.removeAccount(index);
setState(() {});
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
);
}
}
​// ==========================================
// 8. GOALS SCREEN
// ==========================================
​class GoalsScreen extends StatefulWidget {
const GoalsScreen({super.key});
​@override
State<GoalsScreen> createState() => _GoalsScreenState();
}
​class _GoalsScreenState extends State<GoalsScreen> {
void _showAddGoalDialog({int? index, GoalModel? goal}) {
final titleC = TextEditingController(text: goal?.title ?? '');
final targetC = TextEditingController(text: goal != null ? goal.targetAmount.toString() : '');
​showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: Text(index == null ? 'Add Goal' : 'Edit Goal'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Goal Title', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: targetC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder())),
],
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
ElevatedButton(
onPressed: () {
if (titleC.text.isNotEmpty && targetC.text.isNotEmpty) {
double target = double.tryParse(targetC.text) ?? 0.0;
if (index == null) {
appSettings.addGoal(titleC.text, target);
} else {
appSettings.updateGoal(index, titleC.text, target);
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
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​return Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Goals')),
actions: [
IconButton(
icon: Icon(appSettings.isGlobalHidden ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF10B981)),
onPressed: () => appSettings.toggleGlobalHide(),
),
],
),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: ListView.builder(
itemCount: appSettings.goalsList.length,
itemBuilder: (context, index) {
final goal = appSettings.goalsList[index];
return Card(
margin: const EdgeInsets.only(bottom: 8),
child: ListTile(
leading: const Icon(Icons.track_changes, color: Color(0xFF10B981)),
title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text(
appSettings.isGlobalHidden ? 'Current Balance: ********' : 'Current Balance: ${appSettings.localizeNumber(goal.currentAmount)} $curr',
),
trailing: Text(
appSettings.isGlobalHidden ? 'Target: ********' : 'Target: ${appSettings.localizeNumber(goal.targetAmount)} $curr',
style: const TextStyle(color: Colors.grey),
),
),
);
},
),
),
floatingActionButton: FloatingActionButton(
backgroundColor: const Color(0xFF10B981),
onPressed: () => _showAddGoalDialog(),
child: const Icon(Icons.add, color: Colors.white),
),
);
}
}
​// ==========================================
// 9. SAVINGS SCREEN
// ==========================================
​class SavingsScreen extends StatefulWidget {
const SavingsScreen({super.key});
​@override
State<SavingsScreen> createState() => _SavingsScreenState();
}
​class _SavingsScreenState extends State<SavingsScreen> {
void _showAddSavingsDialog({int? index, SavingsModel? savings}) {
final titleC = TextEditingController(text: savings?.title ?? '');
final targetC = TextEditingController(text: savings != null ? savings.targetAmount.toString() : '');
​showDialog(
context: context,
builder: (ctx) => AlertDialog(
title: Text(index == null ? 'Add Savings' : 'Edit Savings'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Savings Title', border: OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: targetC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder())),
],
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
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
child: Text(appSettings.translate('Save')),
),
],
),
);
}
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​return Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Savings')),
actions: [
IconButton(
icon: Icon(appSettings.isGlobalHidden ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF10B981)),
onPressed: () => appSettings.toggleGlobalHide(),
),
],
),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: ListView.builder(
itemCount: appSettings.savingsList.length,
itemBuilder: (context, index) {
final sav = appSettings.savingsList[index];
return Card(
margin: const EdgeInsets.only(bottom: 8),
child: ListTile(
leading: const Icon(Icons.savings, color: Color(0xFF10B981)),
title: Text(sav.title, style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text(
appSettings.isGlobalHidden ? 'Current Balance: ********' : 'Current Balance: ${appSettings.localizeNumber(sav.currentAmount)} $curr',
),
trailing: Text(
appSettings.isGlobalHidden ? 'Target: ********' : 'Target: ${appSettings.localizeNumber(sav.targetAmount)} $curr',
style: const TextStyle(color: Colors.grey),
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
);
}
}
​// ==========================================
// 10. LOAN SCREEN (WITH ACCOUNT CONNECTIVITY)
// ==========================================
​class LoanScreen extends StatefulWidget {
const LoanScreen({super.key});
​@override
State<LoanScreen> createState() => _LoanScreenState();
}
​class _LoanScreenState extends State<LoanScreen> {
void _showAddLoanDialog(BuildContext context) {
final nameC = TextEditingController();
final amountC = TextEditingController();
String type = 'Given';
String selectedAccount = appSettings.accounts.isNotEmpty ? appSettings.accounts[0].name : '';
​showDialog(
context: context,
builder: (ctx) => StatefulBuilder(
builder: (ctx, setStateDialog) => AlertDialog(
title: Text(appSettings.translate('Add New Loan / Debt')),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Row(
children: [
Expanded(
child: ChoiceChip(
label: Center(child: Text(appSettings.translate('Given'))),
selected: type == 'Given',
selectedColor: Colors.orangeAccent,
onSelected: (val) => setStateDialog(() => type = 'Given'),
),
),
const SizedBox(width: 8),
Expanded(
child: ChoiceChip(
label: Center(child: Text(appSettings.translate('Taken'))),
selected: type == 'Taken',
selectedColor: Colors.blueAccent,
onSelected: (val) => setStateDialog(() => type = 'Taken'),
),
),
],
),
const SizedBox(height: 12),
TextField(controller: nameC, decoration: InputDecoration(labelText: appSettings.translate('Person Name'), border: const OutlineInputBorder())),
const SizedBox(height: 10),
TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: appSettings.translate('Amount'), border: const OutlineInputBorder())),
const SizedBox(height: 10),
// Account Connection Dropdown
DropdownButtonFormField<String>(
value: selectedAccount,
decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Connected Account'),
items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text(acc.name))).toList(),
onChanged: (val) => setStateDialog(() => selectedAccount = val!),
),
],
),
),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
ElevatedButton(
onPressed: () {
if (nameC.text.isNotEmpty && amountC.text.isNotEmpty) {
appSettings.addLoan(LoanItem(
id: DateTime.now().toString(),
personName: nameC.text,
amount: double.tryParse(amountC.text) ?? 0.0,
type: type,
account: selectedAccount,
date: DateTime.now(),
));
Navigator.pop(ctx);
setState(() {});
}
},
child: Text(appSettings.translate('Save')),
),
],
),
),
);
}
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​return Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Loan & Debt Overview')),
actions: [
IconButton(
icon: Icon(appSettings.isGlobalHidden ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF10B981)),
onPressed: () => appSettings.toggleGlobalHide(),
),
],
),
body: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: appSettings.loans.length,
itemBuilder: (context, index) {
final loan = appSettings.loans[index];
return Card(
margin: const EdgeInsets.only(bottom: 8),
child: ListTile(
title: Text(loan.personName, style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text('Account: ${loan.account} • Type: {loan.type}'),
trailing: Text(
appSettings.isGlobalHidden ? '********' : '{appSettings.localizeNumber(loan.amount)} $curr',
style: TextStyle(fontWeight: FontWeight.bold, color: loan.type == 'Given' ? Colors.orange : Colors.blue),
),
),
);
},
),
floatingActionButton: FloatingActionButton(
backgroundColor: const Color(0xFF10B981),
onPressed: () => _showAddLoanDialog(context),
child: const Icon(Icons.add, color: Colors.white),
),
);
}
}
​// ==========================================
// 11. DASHBOARD ANALYTICS SCREEN
// ==========================================
​class DashboardAnalyticsScreen extends StatelessWidget {
const DashboardAnalyticsScreen({super.key});
​@override
Widget build(BuildContext context) {
String curr = appSettings.currency;
​return Scaffold(
appBar: AppBar(
title: Text(appSettings.translate('Dashboard Analytics')),
actions: [
IconButton(
icon: Icon(appSettings.isGlobalHidden ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF10B981)),
onPressed: () => appSettings.toggleGlobalHide(),
),
],
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
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
Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey)),
Text(
appSettings.isGlobalHidden ? '' : '${appSettings.localizeNumber(appSettings.getTotalBalance())} $curr',
style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
),
],
),
const Divider(height: 24),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(appSettings.translate('Total Income'), style: const TextStyle(color: Colors.grey)),
Text(
appSettings.isGlobalHidden ? '' : '${appSettings.localizeNumber(appSettings.getTotalIncome())} curr',
style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
),
],
),
const SizedBox(height: 8),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(appSettings.translate('Total Expense'), style: const TextStyle(color: Colors.grey)),
Text(
appSettings.isGlobalHidden ? '********' : '{appSettings.localizeNumber(appSettings.getTotalExpense())} $curr',
style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
),
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
​// ==========================================
// 12. CALCULATORS HUB SCREEN
// ==========================================
​class CalculatorsHubScreen extends StatefulWidget {
const CalculatorsHubScreen({super.key});
​@override
State<CalculatorsHubScreen> createState() => _CalculatorsHubScreenState();
}
​class _CalculatorsHubScreenState extends State<CalculatorsHubScreen> {
String calcDisplay = '0';
​Widget _calcBtn(String val, Color color) {
return ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(60, 50)),
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
child: Text(val, style: const TextStyle(fontSize: 18, color: Colors.white)),
);
}
​@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text(appSettings.translate('Calculators'))),
body: Column(
children: [
Expanded(
child: Container(
alignment: Alignment.bottomRight,
padding: const EdgeInsets.all(24),
child: Text(calcDisplay, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
),
),
Container(
padding: const EdgeInsets.all(12),
color: Theme.of(context).cardColor,
child: Column(
children: [
Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_calcBtn('C', Colors.red), _calcBtn('(', Colors.grey), _calcBtn(')', Colors.grey), _calcBtn('/', Colors.orange)]),
const SizedBox(height: 8),
Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_calcBtn('7', Colors.blueGrey), _calcBtn('8', Colors.blueGrey), _calcBtn('9', Colors.blueGrey), _calcBtn('*', Colors.orange)]),
const SizedBox(height: 8),
Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_calcBtn('4', Colors.blueGrey), _calcBtn('5', Colors.blueGrey), _calcBtn('6', Colors.blueGrey), _calcBtn('-', Colors.orange)]),
const SizedBox(height: 8),
Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_calcBtn('1', Colors.blueGrey), _calcBtn('2', Colors.blueGrey), _calcBtn('3', Colors.blueGrey), _calcBtn('+', Colors.orange)]),
const SizedBox(height: 8),
Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_calcBtn('0', Colors.blueGrey), _calcBtn('.', Colors.blueGrey), _calcBtn('=', const Color(0xFF10B981))]),
],
),
),
],
),
);
}
}
​// ==========================================
// 13. CATEGORIES SCREEN
// ==========================================
​class CategoriesScreen extends StatelessWidget {
const CategoriesScreen({super.key});
​@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text(appSettings.translate('Categories'))),
body: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: appSettings.categories.length,
itemBuilder: (context, index) {
final cat = appSettings.categories[index];
return Card(
child: ListTile(
title: Text(appSettings.translate(cat)),
leading: const Icon(Icons.category, color: Color(0xFF10B981)),
),
);
},
),
);
}
}
​// ==========================================
// 14. MAIN NAVIGATION CONTAINER
// ==========================================
​class MainHomeScreen extends StatefulWidget {
const MainHomeScreen({super.key});
​@override
State<MainHomeScreen> createState() => _MainHomeScreenState();
}
​class _MainHomeScreenState extends State<MainHomeScreen> {
int _currentIndex = 0;
​final List<Widget> pages = [
const HomeScreenContent(),
const AccountsScreen(),
const GoalsScreen(),
const SavingsScreen(),
];
​@override
Widget build(BuildContext context) {
return Scaffold(
body: pages[_currentIndex],
bottomNavigationBar: BottomNavigationBar(
currentIndex: _currentIndex,
onTap: (index) => setState(() => _currentIndex = index),
type: BottomNavigationBarType.fixed,
selectedItemColor: const Color(0xFF10B981),
unselectedItemColor: Colors.grey,
items: [
BottomNavigationBarItem(icon: const Icon(Icons.home), label: appSettings.translate('Account')),
BottomNavigationBarItem(icon: const Icon(Icons.account_balance), label: appSettings.translate('Accounts')),
BottomNavigationBarItem(icon: const Icon(Icons.track_changes), label: appSettings.translate('Goals')),
BottomNavigationBarItem(icon: const Icon(Icons.savings), label: appSettings.translate('Savings')),
],
),
);
}
}