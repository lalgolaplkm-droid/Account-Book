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
  String account;
  String type;
  DateTime date;
  bool isPaid;

  LoanItem({
    required this.id,
    required this.personName,
    required this.amount,
    required this.account,
    required this.type,
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'personName': personName,
    'amount': amount,
    'account': account,
    'type': type,
    'date': date.toIso8601String(),
    'isPaid': isPaid,
  };

  factory LoanItem.fromJson(Map<String, dynamic> json) => LoanItem(
    id: json['id'],
    personName: json['personName'],
    amount: json['amount'],
    account: json['account'] ?? 'Cash in Hand',
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

class GoalModel {
  String goalName;
  double targetAmount;
  String targetDate;
  GoalModel({required this.goalName, required this.targetAmount, required this.targetDate});

  Map<String, dynamic> toJson() => {'goalName': goalName, 'targetAmount': targetAmount, 'targetDate': targetDate};
  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(goalName: json['goalName'], targetAmount: json['targetAmount'], targetDate: json['targetDate']);
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
  ];

  List<LoanItem> loans = [];
  List<ShoppingItem> shoppingList = [];
  List<BudgetModel> budgets = [];
  List<SavingsModel> savingsList = [
    SavingsModel(title: 'Arufa Savings', targetAmount: 500000, currentAmount: 25000)
  ];
  List<GoalModel> goalsList = [
    GoalModel(goalName: 'Buy New Laptop', targetAmount: 80000, targetDate: '31-12-2026')
  ];
  List<RepeatedTransactionModel> repeatedTransactions = [];
  List<ReminderModel> reminders = [];

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    appPin = _prefs.getString('appPin') ?? '1234';
    _language = _prefs.getString('language') ?? 'English'; 
    String themeStr = _prefs.getString('themeMode') ?? 'dark';
    if (themeStr == 'light') _themeMode = ThemeMode.light;
    else if (themeStr == 'system') _themeMode = ThemeMode.system;
    else _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  // Getter added to fix GitHub Actions build error
  ThemeMode get themeMode => _themeMode;

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
        case 'Current Balance': return 'বর্তমান ব্যালেন্স';
        case 'Income': return 'আয়';
        case 'Expense': return 'ব্যয়';
        case 'Account': return 'হিসাব';
        case 'Loan': return 'লোন';
        case 'Transactions': return 'লেনদেন';
        case 'Report': return 'রিপোর্ট';
        case 'Profile': return 'প্রোফাইল';
        case 'Cancel': return 'বাতিল';
        case 'Save': return 'সংরক্ষণ';
        case 'Given': return 'প্রদত্ত';
        case 'Taken': return 'গৃহীত';
        case 'Add New Loan / Debt': return 'নতুন লোন বা দেনা যোগ করুন';
        case 'Person Name': return 'ব্যক্তির নাম';
        case 'Amount': return 'পরিমাণ';
        case 'Calculators': return 'ক্যালকুলেটর হাব';
        case 'Savings': return 'সেভিংস';
        case 'Goals': return 'লক্ষ্যমাত্রা (Goals)';
        default: return key;
      }
    }
    return key;
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void addTransaction(TransactionItem txn) {
    transactions.insert(0, txn);
    notifyListeners();
  }

  void addLoan(LoanItem loan) {
    loans.insert(0, loan);
    notifyListeners();
  }

  double getTotalBalance() {
    double total = 0;
    for (var txn in transactions) {
      if (txn.type == 'Income') total += txn.amount;
      if (txn.type == 'Expense') total -= txn.amount;
    }
    return total;
  }

  double getNetBalance() {
    double total = 0;
    for (var loan in loans) {
      if (!loan.isPaid) {
        if (loan.type == 'Given') total -= loan.amount;
        if (loan.type == 'Taken') total += loan.amount;
      }
    }
    return total;
  }

  double getAccountBalance(String accountName) {
    double balance = 0;
    for (var txn in transactions) {
      if (txn.account == accountName) {
        if (txn.type == 'Income') balance += txn.amount;
        if (txn.type == 'Expense') balance -= txn.amount;
      }
    }
    return balance;
  }
}

final appSettings = AppSettingsNotifier();

// ----------------- Global Account Dropdown Widget with Eye Icon -----------------
Widget buildGlobalAccountDropdown({
  required BuildContext context,
  required String selectedAccount,
  required Function(String) onChanged,
  required Function() onStateRefresh,
}) {
  bool isGlobalHidden = appSettings.isHidden('dropdown_global_account_hide');

  return DropdownButtonFormField<String>(
    value: selectedAccount,
    dropdownColor: Theme.of(context).cardColor,
    decoration: InputDecoration(
      labelText: appSettings.translate('Account'),
      border: const OutlineInputBorder(),
      suffixIcon: InkWell(
        onTap: () {
          appSettings.toggleHide('dropdown_global_account_hide');
          onStateRefresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            isGlobalHidden ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: const Color(0xFF10B981),
          ),
        ),
      ),
    ),
    items: appSettings.accounts.map((acc) {
      double accBal = appSettings.getAccountBalance(acc.name);
      String displayBal = isGlobalHidden ? '৳ *****' : '৳ ${appSettings.localizeNumber(accBal)}';

      return DropdownMenuItem(
        value: acc.name,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(appSettings.translate(acc.name), style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(displayBal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }).toList(),
    onChanged: (val) {
      if (val != null) onChanged(val);
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong PIN!'), backgroundColor: Colors.red),
      );
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 60, color: Color(0xFF10B981)),
              const SizedBox(height: 20),
              Text(appSettings.translate('Enter Your PIN'), style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
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
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.getAppTitle())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () => appSettings.toggleHide('home_current_balance'),
                        child: Icon(
                          appSettings.isHidden('home_current_balance') ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appSettings.isHidden('home_current_balance') ? '৳ ********' : '${appSettings.localizeNumber(appSettings.getTotalBalance())} ${appSettings.currency}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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

// ----------------- Loan & Debt Screen -----------------
class LoanDebtScreen extends StatefulWidget {
  const LoanDebtScreen({super.key});

  @override
  State<LoanDebtScreen> createState() => _LoanDebtScreenState();
}

class _LoanDebtScreenState extends State<LoanDebtScreen> {
  void _showAddEditLoanDialog(BuildContext context) {
    String loanType = 'Given';
    String selectedAccount = appSettings.accounts.first.name;
    final nameC = TextEditingController();
    final amountC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            return AlertDialog(
              title: Text(appSettings.translate('Add New Loan / Debt')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Given' ? Colors.green : Colors.grey),
                          onPressed: () => setStateModal(() => loanType = 'Given'),
                          child: Text(appSettings.translate('Given')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: loanType == 'Taken' ? Colors.red : Colors.grey),
                          onPressed: () => setStateModal(() => loanType = 'Taken'),
                          child: Text(appSettings.translate('Taken')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  buildGlobalAccountDropdown(
                    context: context,
                    selectedAccount: selectedAccount,
                    onChanged: (val) => setStateModal(() => selectedAccount = val),
                    onStateRefresh: () => setStateModal(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: nameC, decoration: InputDecoration(labelText: appSettings.translate('Person Name'), border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: appSettings.translate('Amount'), border: const OutlineInputBorder())),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text(appSettings.translate('Cancel'))),
                    ElevatedButton(
                      onPressed: () {
                        if (nameC.text.isNotEmpty && amountC.text.isNotEmpty) {
                          appSettings.addLoan(LoanItem(
                            id: DateTime.now().toString(),
                            personName: nameC.text,
                            amount: double.tryParse(amountC.text) ?? 0,
                            account: selectedAccount,
                            type: loanType,
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
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Loan'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appSettings.translate('Current Balance'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () => appSettings.toggleHide('loan_current_balance'),
                        child: Icon(appSettings.isHidden('loan_current_balance') ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appSettings.isHidden('loan_current_balance') ? '৳ *****' : '${appSettings.localizeNumber(appSettings.getNetBalance())} ${appSettings.currency}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
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
  }
}

// ----------------- Calculators Hub Screen -----------------
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
    return Scaffold(
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
              ],
            ),
          ),
          Expanded(
            child: selectedCalcIndex == 0 ? _buildGeneralCalculator() : _buildLoanCalculator(),
          ),
        ],
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
      ],
    );
  }

  Widget _buildLoanCalculator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Loan Amount: ${appSettings.localizeNumber(loanAmount)}'),
          Slider(value: loanAmount, min: 1000, max: 1000000, onChanged: (v) => setState(() => loanAmount = v)),
        ],
      ),
    );
  }
}

// ----------------- Savings Screen -----------------
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Savings'))),
      body: ListView.builder(
        itemCount: appSettings.savingsList.length,
        itemBuilder: (context, index) {
          final sav = appSettings.savingsList[index];
          return ListTile(
            title: Text(sav.title),
            subtitle: Text('Target: ${sav.targetAmount}'),
          );
        },
      ),
    );
  }
}

// ----------------- Goals Screen -----------------
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appSettings.translate('Goals'))),
      body: ListView.builder(
        itemCount: appSettings.goalsList.length,
        itemBuilder: (context, index) {
          final goal = appSettings.goalsList[index];
          return ListTile(
            title: Text(goal.goalName),
            subtitle: Text('Target: ${goal.targetAmount} by ${goal.targetDate}'),
          );
        },
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
      const Center(child: Text('Transactions Screen')),
      const Center(child: Text('Reports Screen')),
      const Center(child: Text('Profile Screen')),
    ];

    return Scaffold(
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
    );
  }
}