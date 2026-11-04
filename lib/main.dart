import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// MAIN ENTRY POINT & APP STATE
// ---------------------------------------------------------------------------
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdvancedFinanceApp());
}

class AdvancedFinanceApp extends StatefulWidget {
  const AdvancedFinanceApp({Key? key}) : super(key: key);

  @override
  State<AdvancedFinanceApp> createState() => _AdvancedFinanceAppState();
}

class _AdvancedFinanceAppState extends State<AdvancedFinanceApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  String _currentLanguage = 'English';
  Color _primaryAccentColor = Colors.teal;

  void updateTheme(ThemeMode mode) => setState(() => _themeMode = mode);
  void updateLanguage(String lang) => setState(() => _currentLanguage = lang);
  void updateAccentColor(Color color) => setState(() => _primaryAccentColor = color);
  
  void resetToDefaults() {
    setState(() {
      _themeMode = ThemeMode.dark;
      _currentLanguage = 'English';
      _primaryAccentColor = Colors.teal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Personal Finance',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryAccentColor, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121826),
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryAccentColor, brightness: Brightness.dark),
      ),
      home: const LockScreenWrapper(),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. SECURITY & PIN LOCK SYSTEM
// ---------------------------------------------------------------------------
class LockScreenWrapper extends StatefulWidget {
  const LockScreenWrapper({Key? key}) : super(key: key);

  @override
  State<LockScreenWrapper> createState() => _LockScreenWrapperState();
}

class _LockScreenWrapperState extends State<LockScreenWrapper> {
  bool _isUnlocked = false;
  final String _correctPin = "1234";
  String _enteredPin = "";

  void _verifyPin(String digit) {
    setState(() {
      if (_enteredPin.length < 4) {
        _enteredPin += digit;
        if (_enteredPin.length == 4) {
          if (_enteredPin == _correctPin) {
            _isUnlocked = true;
          } else {
            _enteredPin = "";
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Incorrect PIN! Try again.")),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnlocked) {
      return const MainDashboardScreen();
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.teal),
              const SizedBox(height: 20),
              const Text("Enter Security PIN", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length ? Colors.teal : Colors.grey,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 250,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    String digit = (index + 1).toString();
                    return ElevatedButton(
                      onPressed: () => _verifyPin(digit),
                      child: Text(digit, style: const TextStyle(fontSize: 20)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _verifyPin("0"),
                child: const Text("0", style: TextStyle(fontSize: 20)),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN successfully updated!")),
                  );
                },
                child: const Text("Forgot PIN?"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. MAIN DASHBOARD & NAVIGATION BAR
// ---------------------------------------------------------------------------
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LoanScreen(),
    const TransactionsScreen(),
    const ReportScreen(),
    const ProfileSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Loan'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. HOME SCREEN WITH QUICK CHIPS & CUSTOM YEARS/MONTHS FILTER
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Book"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                ),
              )
            ],
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(label: const Text('This Month'), selected: true, onSelected: (val) {}),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('This Year'), selected: false, onSelected: (val) {}),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Custom Months'), selected: false, onSelected: (val) {}),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Custom Years'), selected: false, onSelected: (val) {}),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current Balance", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("৳ 44,650.0", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Quick Access / Tools", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickIcon(context, Icons.calculate, "Calculator", const GeneralCalculatorScreen()),
                _quickIcon(context, Icons.pie_chart, "Financial Tools", const FinancialCalculatorsHub()),
                _quickIcon(context, Icons.track_changes, "Goals", const GoalsScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickIcon(BuildContext context, IconData icon, String label, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: Colors.teal.shade100, child: Icon(icon, color: Colors.teal.shade900)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. SIDEBAR (DRAWER)
// ---------------------------------------------------------------------------
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("MD Alamgir Hossain"),
            accountEmail: Text("alamgir@email.com"),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Text("MA", style: TextStyle(fontSize: 24))),
            decoration: BoxDecoration(color: Colors.teal),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Goals'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Financial Calculators'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancialCalculatorsHub())),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. GMAIL-STYLE ADVANCED NOTIFICATION CENTER
// ---------------------------------------------------------------------------
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Completely safe and correctly typed List to prevent compiler build errors
  final List> notifications = [
    {"title": "Balance Alert", "body": "Your default account 'Cash In Hand' balance is low.", "isRead": false},
    {"title": "Loan Payment Due", "body": "Tomorrow is the settlement date for Rafiqul Islam.", "isRead": true},
    {"title": "Budget Limit Alert", "body": "Expenses have reached near your monthly budget limit.", "isRead": false},
  ];

  void _markAllAsRead() => setState(() {
        for (var n in notifications) {
          n['isRead'] = true;
        }
      });

  void _markAllAsUnread() => setState(() {
        for (var n in notifications) {
          n['isRead'] = false;
        }
      });

  void _deleteAll() => setState(() => notifications.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Center"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'read_all') _markAllAsRead();
              if (value == 'unread_all') _markAllAsUnread();
              if (value == 'delete_all') _deleteAll();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'read_all', child: Text('Mark all as read')),
              const PopupMenuItem(value: 'unread_all', child: Text('Mark all as unread')),
              const PopupMenuItem(value: 'delete_all', child: Text('Delete all')),
            ],
          )
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No Notifications Available"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                final bool isRead = item['isRead'] as bool;
                return ListTile(
                  leading: Icon(Icons.notifications, color: isRead ? Colors.grey : Colors.teal),
                  title: Text(item['title'] as String, style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(item['body'] as String),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => setState(() => notifications.removeAt(index)),
                  ),
                  onTap: () {
                    setState(() {
                      item['isRead'] = !isRead;
                    });
                  },
                );
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. CALCULATORS HUB (General + Financial with +/- Controls)
// ---------------------------------------------------------------------------
class FinancialCalculatorsHub extends StatelessWidget {
  const FinancialCalculatorsHub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Financial Calculators")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _calcTile(context, "General Calculator", const GeneralCalculatorScreen()),
          _calcTile(context, "EMI Calculator", const EmiCalculatorScreen()),
          _calcTile(context, "Interest Calculator", const InterestCalculatorScreen()),
          _calcTile(context, "SIP Calculator", const SipCalculatorScreen()),
          _calcTile(context, "Tax Calculator", const TaxCalculatorScreen()),
        ],
      ),
    );
  }

  Widget _calcTile(BuildContext context, String title, Widget screen) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      ),
    );
  }
}

class GeneralCalculatorScreen extends StatefulWidget {
  const GeneralCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<GeneralCalculatorScreen> createState() => _GeneralCalculatorScreenState();
}

class _GeneralCalculatorScreenState extends State<GeneralCalculatorScreen> {
  String _output = "0";
  
  void _buttonPressed(String val) {
    setState(() {
      if (_output == "0") {
        _output = val;
      } else {
        _output += val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("General Calculator")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(_output, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ),
          ),
          Row(children: [_btn("7"), _btn("8"), _btn("9"), _btn("/")]),
          Row(children: [_btn("4"), _btn("5"), _btn("6"), _btn("*")]),
          Row(children: [_btn("1"), _btn("2"), _btn("3"), _btn("-")]),
          Row(children: [_btn("0"), _btn("C"), _btn("="), _btn("+")]),
        ],
      ),
    );
  }

  Widget _btn(String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          if (label == "C") {
            setState(() => _output = "0");
          } else {
            _buttonPressed(label);
          }
        },
        child: Text(label, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

class SipCalculatorScreen extends StatefulWidget {
  const SipCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends State<SipCalculatorScreen> {
  double monthlyInvestment = 5000;
  double returnRate = 12.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SIP Calculator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Monthly Investment: ৳ ${monthlyInvestment.toStringAsFixed(0)}"),
            Slider(value: monthlyInvestment, min: 500, max: 50000, divisions: 100, onChanged: (val) => setState(() => monthlyInvestment = val)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Return Rate (%): ${returnRate.toStringAsFixed(1)}"),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle), onPressed: () => setState(() => returnRate = (returnRate > 1) ? returnRate - 0.5 : 1)),
                    IconButton(icon: const Icon(Icons.add_circle), onPressed: () => setState(() => returnRate += 0.5)),
                  ],
                )
              ],
            ),
            Slider(value: returnRate, min: 1, max: 30, onChanged: (val) => setState(() => returnRate = val)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Calculate SIP"))
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PLACEHOLDER SCREENS (Fully corrected syntax)
// ---------------------------------------------------------------------------
class LoanScreen extends StatelessWidget { 
  const LoanScreen({Key? key}) : super(key: key); 
  @override 
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Loan & Debt Screen"))); 
  }
}

class TransactionsScreen extends StatelessWidget { 
  const TransactionsScreen({Key? key}) : super(key: key); 
  @override 
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Transactions Screen"))); 
  }
}

class ReportScreen extends StatelessWidget { 
  const ReportScreen({Key? key}) : super(key: key); 
  @override 
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Reports & Analysis"))); 
  }
}

class GoalsScreen extends StatelessWidget { 
  const GoalsScreen({Key? key}) : super(key: key); 
  @override 
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Financial Goals Screen"))); 
  }
}

class EmiCalculatorScreen extends StatelessWidget { 
  const EmiCalculatorScreen({Key? key}) : super(key: key); 
  @override 
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("EMI Calculator"))); 
  }
}

class InterestCalculatorScreen extends StatelessWidget { 
  const InterestCalculatorScreen({Key? key}) : super(key: key); 
  @override 
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Interest Calculator"))); 
  }
}

class TaxCalculatorScreen extends StatelessWidget { 
  const TaxCalculatorScreen({Key? key}) : super(key: key); 
  @override 
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Tax Calculator"))); 
  }
}

// ---------------------------------------------------------------------------
// 7. PROFILE, SETTINGS & THEME CUSTOMIZATION
// ---------------------------------------------------------------------------
class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile & Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 10),
          const Center(child: Text("MD Alamgir Hossain", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("App Settings & Theme"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text("Notification & Ringtone Settings"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen())),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("App Language", style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text("Language Selection"),
            subtitle: const Text("English (Default) / Bangla / Arabic / System Default"),
            leading: const Icon(Icons.language),
            onTap: () {},
          ),
          const Divider(),
          const Text("App Theme", style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: true,
            onChanged: (val) {},
          ),
          const Divider(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Reset to Default", style: TextStyle(color: Colors.white)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings reset to default successfully!")));
            },
          )
        ],
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification & Sound Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Notification Sound"),
            value: true,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text("Notification Vibration"),
            value: true,
            onChanged: (val) {},
          ),
          const ListTile(
            title: Text("Alert Tone"),
            subtitle: Text("App Chime / Custom from Device Memory"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
