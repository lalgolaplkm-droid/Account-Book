import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AccountBookApp());
}

class AccountBookApp extends StatefulWidget {
  const AccountBookApp({Key? key}) : super(key: key);

  @override
  State<AccountBookApp> createState() => _AccountBookAppState();
}

class _AccountBookAppState extends State<AccountBookApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('bn');

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Account Book / হিসাবের খাতা',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      locale: _locale,
      home: const LockScreen(),
    );
  }
}

// লক স্ক্রিন ও পিন অথেন্টিকেশন
class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String pin = "";

  void _onKeyPadPress(String value) {
    setState(() {
      if (value == "C") {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else if (value == "OK") {
        if (pin == "1234" || pin.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ভুল পিন কোড! সঠিক পিন দিন (1234)")),
          );
          pin = "";
        }
      } else {
        if (pin.length < 4) pin += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                "Account Book / হিসাবের খাতা",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Text(
                pin.isEmpty ? "পিন কোড দিন (ডিফল্ট: 1234)" : "* " * pin.length,
                style: const TextStyle(fontSize: 24, letterSpacing: 4),
              ),
              const SizedBox(height: 32),
              // কিপ্যাড লেআউট
              for (var row in [
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                ["C", "0", "OK"]
              ])
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((val) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _onKeyPadPress(val),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Text(val, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// মূল হোম স্ক্রিন ড্যাশবোর্ড
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const LoanTab(),
    const TransactionTab(),
    const ReportTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "হিসাব"),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "লোন"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "লেনদেন"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "রিপোর্ট"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "প্রোফাইল"),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Book / হিসাবের খাতা"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // নোটিফিকেশন স্ক্রিন বা পপআপ কল করা যেতে পারে
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("বর্তমান ব্যালেন্স (Current Balance)", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text("৳ ৪৪,৬৫০.০", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("সাম্প্রতিক লেনদেন", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Expanded(
              child: Center(
                child: Text("কোনো সাম্প্রতিক লেনদেন পাওয়া যায়নি।"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoanTab extends StatelessWidget {
  const LoanTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("লোন স্ক্রিন")));
}

class TransactionTab extends StatelessWidget {
  const TransactionTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("লেনদেন স্ক্রিন")));
}

class ReportTab extends StatelessWidget {
  const ReportTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("রিপোর্ট স্ক্রিন")));
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("প্রোফাইল ও সেটিংস")));
