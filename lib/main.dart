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
  String _currentLanguage = 'English'; // Default Language is English
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

  Widget _quickIcon(BuildContext context, IconData icon, String label
