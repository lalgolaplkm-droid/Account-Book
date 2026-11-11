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
  String account;
  DateTime date;
  bool isPaid;

  LoanItem({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.account,
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'personName': personName,
    'amount': amount,
    'type': type,
    'account': account,
    'date': date.toIso8601String(),
    'isPaid': isPaid,
  };

  factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
    id: json['id'],
    personName: json['personName'],
    amount: json['amount'],
    type: json['type'],
    account: json['account'] ?? 'Cash in Hand',
    date: DateTime.parse(json['date']),
    isPaid: json['isPaid'],
  );
}

class ShoppingItem {
  String name;
  double amount;
  bool isChecked;
  ShoppingItem({required this.name, this.amount = 0.0, this.isChecked = false});
}

class BudgetModel {
  String category;
  double amount;
  BudgetModel({required this.category, required this.amount});
}

class SavingsModel {
  String title;
  double targetAmount;
  double currentAmount;
  bool isCompleted;
  SavingsModel({required this.title, required this.targetAmount, required this.currentAmount, this.isCompleted = false});
}

class GoalModel {
  String title;
  double targetAmount;
  double currentAmount;
  bool isCompleted;
  GoalModel({required this.title, required this.targetAmount, required this.currentAmount, this.isCompleted = false});
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
}

// ----------------- State Management -----------------
class AppSettingsNotifier extends ChangeNotifier {
  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.dark;
  String _language = 'English'; 
  String currency = '৳';
  String timeFilter = 'This Month';
  String appPin = '1234';

  String profileName = 'Md. Alamgir Hossain';
  String profileEmail = 'alamgir@email.com';
  String profileGender = 'Male';
  String profileBirthDate = '01-01-1995';
  String profileMobile = '018xxxxxxxx';
  String profileImagePath = '';

  // গ্লোবাল হাইড/আনহাইড স্টেট
  bool _isGlobalHidden = false;
  bool get isGlobalHidden => _isGlobalHidden;

  void toggleGlobalHide() {
    _isGlobalHidden = !_isGlobalHidden;
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
      personName: 'Rofiqul Islam',
      amount: 2000.0,
      type: 'Given',
      account: 'Cash in Hand',
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
    SavingsModel(title: 'Emergency Fund', targetAmount: 100000, currentAmount: 15000)
  ];

  List<GoalModel> goalsList = [
    GoalModel(title: 'Buy New Phone', targetAmount: 50000, currentAmount: 10000)
  ];

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    appPin = _prefs.getString('appPin') ?? '1234';
    _language = _prefs.getString('language') ?? 'English'; 
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
        case 'Total Income': return 'মোট আয়';
        case 'Total Expense': return 'মোট ব্যয়';
        case 'Quick Access': return 'কুইক এক্সেস';
        case 'Savings': return 'সেভিংস';
        case 'Goals': return 'লক্ষ্যসমূহ';
        case 'Account': return 'হিসাব';
        case 'Calculators': return 'ক্যালকুলেটর হাব';
        case 'Enter Your PIN': return 'আপনার পিন লিখুন';
        case 'Unlock': return 'আনলক করুন';
        case 'Forgot PIN?': return 'পিন ভুলে গেছেন?';
        case 'Cancel': return 'বাতিল';
        case 'Save': return 'সংরক্ষণ';
        case 'Add Account': return 'অ্যাকাউন্ট যোগ করুন';
        case 'Edit Account': return 'অ্যাকাউন্ট সম্পাদনা';
        case 'Account Name': return 'অ্যাকাউন্টের নাম';
        case 'Type': return 'ধরন';
        case 'Details / Account Number': return 'বিবরণ / অ্যাকাউন্ট নম্বর';
        case 'Add New Transaction': return 'নতুন লেনদেন যোগ করুন';
        case 'Description': return 'বিবরণ';
        case 'Amount': return 'পরিমাণ';
        case 'Person Name': return 'ব্যক্তির নাম';
        case 'Add New Loan / Debt': return 'নতুন লোন বা দেনা যোগ করুন';
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

  void updatePin(String newPin) {
    appPin = newPin;
    _saveToPrefs();
    notifyListeners();
  }

  void addTransaction(TransactionItem txn) {
    transactions.insert(0, txn);
    notifyListeners();
  }

  double getAccountBalance(String accountName) {
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

  void addLoan(LoanItem loan) {
    loans.insert(0, loan);
    notifyListeners();
  }

  double getTotalIncome() {
    double total = 0;
    for (var txn in transactions) {
      if (txn.type == 'Income') total += txn.amount;
    }
    return total;
  }

  double getTotalExpense() {
    double total = 0;
    for (var txn in transactions) {
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

  void addAccount(String name, String type, String details) {
    if (name.isNotEmpty) {
      accounts.add(AccountModel(name: name, type: type, details: details.isEmpty ? 'N/A' : details, isDefault: accounts.isEmpty));
      notifyListeners();
    }
  }

  void addSavings(String title, double target) {
    savingsList.add(SavingsModel(title: title, targetAmount: target, currentAmount: 0));
    notifyListeners();
  }

  void addGoal(String title, double target) {
    goalsList.add(GoalModel(title: title, targetAmount: target, currentAmount: 0));
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
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
            primaryColor: const Color(0xFF10B981),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF10B981),
            cardColor: const Color(0xFF1E293B),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E293B), foregroundColor: Colors.white),
          ),
          home: const PinLockScreen(),
        );
      },
    );
  }
}

// ----------------- Pin Screen -----------------
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _verifyPin(BuildContext context) {
    if (_pinController.text == appSettings.appPin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong PIN!'), backgroundColor: Colors.red));
      _pinController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_rounded, size: 60, color: Color(0xFF10B981)),
              const SizedBox(height: 16),
              Text(appSettings.getAppTitle(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              Text(appSettings.translate('Enter Your PIN'), style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
                onChanged: (val) {
                  if (val.length == 4) _verifyPin(context);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _verifyPin(context),
                child: Text(appSettings.translate('Unlock')),
              ),
            ],
          ),
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
  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    double currentBal = appSettings.getTotalBalance();

    return Scaffold(
      appBar: AppBar(
        title: Text(appSettings.getAppTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(appSettings.isGlobalHidden ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF10B981)),
            onPressed: () => appSettings.toggleGlobalHide(),
          ),
        ],
      ),
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
                  Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    appSettings.isGlobalHidden ? '********' : '${appSettings.localizeNumber(currentBal)} $curr', 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(appSettings.translate('Quick Access'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountsScreen())),
                  icon: const Icon(Icons.account_balance),
                  label: Text(appSettings.translate('Accounts')),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoanScreen())),
                  icon: const Icon(Icons.money),
                  label: const Text('Loan'),
                ),
              ],
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

  void _showAddTransactionModal(BuildContext context) {
    final amountC = TextEditingController();
    final descC = TextEditingController();
    String type = 'Income';
    String selectedAccount = appSettings.accounts.isNotEmpty ? appSettings.accounts[0].name : '';
    String selectedCategory = appSettings.categories[0];

    showModalBottomSheet(
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
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedAccount,
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Account'),
                  items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text(acc.name))).toList(),
                  onChanged: (val) => setStateModal(() => selectedAccount = val!),
                ),
                const SizedBox(height: 12),
                TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: appSettings.translate('Amount'), border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descC, decoration: InputDecoration(labelText: appSettings.translate('Description'), border: const OutlineInputBorder())),
                const SizedBox(height: 16),
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

// ----------------- Accounts Screen -----------------
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    return Scaffold(
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

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  appSettings.isGlobalHidden ? 'Current Balance: ********' : 'Current Balance: ${appSettings.localizeNumber(accBal)} $curr',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ----------------- Loan Screen -----------------
class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});
  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  void _showAddLoanDialog(BuildContext context) {
    final nameC = TextEditingController();
    final amountC = TextEditingController();
    String type = 'Given';
    String selectedAccount = appSettings.accounts.isNotEmpty ? appSettings.accounts[0].name : '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(appSettings.translate('Add New Loan / Debt')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: InputDecoration(labelText: appSettings.translate('Person Name'), border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: appSettings.translate('Amount'), border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedAccount,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Account'),
                items: appSettings.accounts.map((acc) => DropdownMenuItem(value: acc.name, child: Text(acc.name))).toList(),
                onChanged: (val) => setStateDialog(() => selectedAccount = val!),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    String curr = appSettings.currency;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan & Debt'),
        actions: [
          IconButton(
            icon: Icon(appSettings.isGlobalHidden ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF10B981)),
            onPressed: () => appSettings.toggleGlobalHide(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: appSettings.loans.length,
        itemBuilder: (context, index) {
          final loan = appSettings.loans[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text(loan.personName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Account: ${loan.account}'),
              trailing: Text(
                appSettings.isGlobalHidden ? '********' : '${appSettings.localizeNumber(loan.amount)} $curr',
                style: TextStyle(fontWeight: FontWeight.bold, color: loan.type == 'Given' ? Colors.green : Colors.red),
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

// ----------------- Main Navigation Container -----------------
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> pages = [
    const HomeScreenContent(),
    const AccountsScreen(),
    const LoanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Accounts'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Loan'),
        ],
      ),
    );
  }
}