import 'package:flutter/material.dart';
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
  String _language = 'English';
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
  ];

  List<BudgetModel> budgets = [
    BudgetModel(category: 'Food & Hotel', amount: 5000.0),
  ];

  List<SavingsModel> savingsList = [
    SavingsModel(title: 'Arufa Savings', targetAmount: 500000, currentAmount: 25000)
  ];

  List<RepeatedTransactionModel> repeatedTransactions = [
    RepeatedTransactionModel(title: 'House Rent', amount: 8000, frequency: '1st of every month'),
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
    }
    notifyListeners();
  }

  void sortTransactions(String criteria) {
    if (criteria.contains('New-Old')) {
      transactions.sort((a, b) => b.date.compareTo(a.date));
    } else if (criteria.contains('Old-New')) {
      transactions.sort((a, b) => a.date.compareTo(b.date));
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
      accounts.add(AccountModel(name: name, type: type, details: details, isDefault: false));
      notifyListeners();
    }
  }

  void updateAccount(int index, String name, String type, String details) {
    accounts[index].name = name;
    accounts[index].type = type;
    accounts[index].details = details;
    notifyListeners();
  }

  void setDefaultAccount(int index) {
    for (int i = 0; i < accounts.length; i++) {
      accounts[i].isDefault = (i == index);
    }
    notifyListeners();
  }

  void removeAccount(int index) {
    if (accounts.length > 1) {
      accounts.removeAt(index);
      notifyListeners();
    }
  }

  void addBudget(String category, double amount) {
    budgets.add(BudgetModel(category: category, amount: amount));
    notifyListeners();
  }

  void updateBudget(int index, String category, double amount) {
    budgets[index] = BudgetModel(category: category, amount: amount);
    notifyListeners();
  }

  void removeBudget(int index) {
    budgets.removeAt(index);
    notifyListeners();
  }

  void addSavings(String title, double target) {
    savingsList.add(SavingsModel(title: title, targetAmount: target, currentAmount: 0));
    notifyListeners();
  }

  void updateSavings(int index, String title, double targetAmount) {
    savingsList[index].title = title;
    savingsList[index].targetAmount = targetAmount;
    notifyListeners();
  }

  void removeSavings(int index) {
    savingsList.removeAt(index);
    notifyListeners();
  }

  void addCategory(String cat) {
    if (cat.isNotEmpty && !categories.contains(cat)) {
      categories.add(cat);
      notifyListeners();
    }
  }

  void updateCategory(int index, String newCat) {
    if (newCat.isNotEmpty) {
      categories[index] = newCat;
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
    repeatedTransactions.add(RepeatedTransactionModel(title: title, amount: amount, frequency: frequency));
    notifyListeners();
  }

  void updateRepeatedTransaction(int index, String title, double amount, String frequency) {
    repeatedTransactions[index] = RepeatedTransactionModel(title: title, amount: amount, frequency: frequency);
    notifyListeners();
  }

  void removeRepeatedTransaction(int index) {
    repeatedTransactions.removeAt(index);
    notifyListeners();
  }

  void addShoppingItem(String name, double amount) {
    shoppingList.add(ShoppingItem(name: name, amount: amount));
    notifyListeners();
  }

  void updateShoppingItem(int index, String name, double amount) {
    shoppingList[index].name = name;
    shoppingList[index].amount = amount;
    notifyListeners();
  }

  void removeShoppingItem(int index) {
    shoppingList.removeAt(index);
    notifyListeners();
  }

  void toggleShoppingCheck(int index) {
    shoppingList[index].isChecked = !shoppingList[index].isChecked;
    notifyListeners();
  }

  void addReminder(String title, double amount, String dueDate) {
    reminders.add(ReminderModel(title: title, amount: amount, dueDate: dueDate));
    notifyListeners();
  }

  void updateReminder(int index, String title, double amount, String dueDate) {
    reminders[index] = ReminderModel(title: title, amount: amount, dueDate: dueDate);
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
          theme: ThemeData(brightness: Brightness.light, scaffoldBackgroundColor: const Color(0xFFF3F4F6)),
          darkTheme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0F172A)),
          home: const PinLockScreen(),
        );
      },
    );
  }
}

// ----------------- Helper UI Methods -----------------
void showStandardDownloadMenu(BuildContext context, Offset offset) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 20, 0),
    items: const [
      PopupMenuItem(value: 'preview', child: Text('Preview')),
      PopupMenuItem(value: 'pdf', child: Text('Download as PDF')),
      PopupMenuItem(value: 'excel', child: Text('Download as Excel')),
    ],
  );
}

void showStandardSortMenu(BuildContext context, Offset offset, Function(String) onSelected) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(offset.dx, offset.dy + 40, 20, 0),
    items: const [
      PopupMenuItem(value: 'Date New-Old', child: Text('Sort by Date (Newest to Oldest)')),
      PopupMenuItem(value: 'Date Old-New', child: Text('Sort by Date (Oldest to Newest)')),
    ],
  ).then((value) {
    if (value != null) onSelected(value);
  });
}

void showLocalizedDeleteDialog({
  required BuildContext context,
  required bool isImportant,
  required String itemName,
  required VoidCallback onDeleteConfirmed,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmation'),
      content: Text('Are you sure you want to delete "$itemName"?'),
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

// ----------------- Screens -----------------
class DashboardAnalyticsScreen extends StatelessWidget {
  const DashboardAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Analytics')),
      body: const Center(child: Text('Analytics Summary')),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF10B981)),
            accountName: Text(appSettings.profileName),
            accountEmail: Text(appSettings.profileEmail),
          ),
          ListTile(
            title: const Text('Dashboard Analytics'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardAnalyticsScreen())),
          ),
          ListTile(
            title: const Text('Categories'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen())),
          ),
          ListTile(
            title: const Text('Accounts'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountsScreen())),
          ),
        ],
      ),
    );
  }
}

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: ListView.builder(
        itemCount: appSettings.accounts.length,
        itemBuilder: (context, index) {
          final acc = appSettings.accounts[index];
          return ListTile(
            title: Text(acc.name),
            subtitle: Text(acc.type),
          );
        },
      ),
    );
  }
}

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: const Center(child: Text('Budget Screen')),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        itemCount: appSettings.categories.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(appSettings.categories[index]));
        },
      ),
    );
  }
}

class FundShoppingScreen extends StatelessWidget {
  const FundShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping')),
      body: const Center(child: Text('Shopping Screen')),
    );
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: const Center(child: Text('Reminders Screen')),
    );
  }
}

class RepeatedTransactionsScreen extends StatelessWidget {
  const RepeatedTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repeat')),
      body: const Center(child: Text('Repeat Screen')),
    );
  }
}

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: const Center(child: Text('Savings Screen')),
    );
  }
}

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
              const Text('Enter Your PIN (Default: 1234)', style: TextStyle(fontSize: 20, color: Colors.white)),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                onPressed: () => _verifyPin(context),
                child: const Text('Unlock', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Book')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Home Screen Content')),
    );
  }
}

class LoanDebtScreen extends StatelessWidget {
  const LoanDebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan & Debt')),
      body: const Center(child: Text('Loan Screen')),
    );
  }
}

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: const Center(child: Text('Transactions Screen')),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const Center(child: Text('Reports Screen')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}

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

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Account'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Loan'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
