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
  Locale _locale = const Locale('bn'); // ডিফল্ট বাংলা

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

// ==========================================
// ১. লক স্ক্রিন ও সিকিউরিটি মডিউল
// ==========================================
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

// ==========================================
// ২. মূল হোম স্ক্রিন ও নেভিগেশন ট্যাব
// ==========================================
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

// ==========================================
// ৩. হোম ট্যাব (ড্যাশবোর্ড ও টাইম ফিল্টার)
// ==========================================
class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("হিসাবের খাতা"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // কারেন্ট ব্যালেন্স (কোনো মাস ফিল্টার ছাড়া)
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
            const SizedBox(height: 16),
            // আয়-ব্যয় সেকশন বরাবর টাইম ফিল্টার (এই মাস)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("আয়-ব্যয় হিসাব", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Chip(label: Text("এই মাস (This Month)")),
              ],
            ),
            const SizedBox(height: 10),
            const Expanded(
              child: Center(
                child: Text("সাম্প্রতিক লেনদেনের তালিকা এখানে প্রদর্শিত হবে।"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ৪. লোন ও ডেবট ট্যাব
// ==========================================
class LoanTab extends StatelessWidget {
  const LoanTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("লোন ও ধার-দেনা")),
      body: const Center(child: Text("লোন লিস্ট ও ম্যানেজমেন্ট মডিউল")),
    );
  }
}

// ==========================================
// ৫. ট্রানজেকশন ট্যাব (লেনদেন)
// ==========================================
class TransactionTab extends StatelessWidget {
  const TransactionTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("সকল লেনদেন")),
      body: const Center(child: Text("লেনদেন ও ক্যালকুলেটর পপআপ মডিউল")),
    );
  }
}

// ==========================================
// ৬. রিপোর্ট ট্যাব
// ==========================================
class ReportTab extends StatelessWidget {
  const ReportTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("রিপোর্ট ও অ্যানালিটিক্স")),
      body: const Center(child: Text("রিপোর্ট প্রিভিউ ও ডাউনলোড মডিউল")),
    );
  }
}

// ==========================================
// ৭. প্রোফাইল ও সেটিংস ট্যাব
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("প্রোফাইল ও সেটিংস")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // প্রোফাইল কার্ড
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 35)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("MD ALAMGIR HOSSAIN", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("alamgir@email.com", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("প্রাইভেসি ও সিকিউরিটি (Privacy & Security)"),
            onplet: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text("নোটিফিকেশন সেটিংস"),
            onPressed: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("সাইন আউট", style: TextStyle(color: Colors.red)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ৮. নোটিফিকেশন সেন্টার স্ক্রিন
// ==========================================
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("নোটিফিকেশন")),
      body: const Center(child: Text("সকল নোটিফিকেশন এবং ফিল্টার")),
    );
  }
}
