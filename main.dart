import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() {
  runApp(const TawasolApp());
}

class TawasolApp extends StatelessWidget {
  const TawasolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تواصل - Tawasol',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B141A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF202C33)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A884),
          brightness: Brightness.dark,
        ),
      ),
      home: const ContactsScreen(),
    );
  }
}

// شاشة سحب ومزامنة جهات الاتصال الحقيقية من الموبايل
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRealContacts();
  }

  // مزامنة أرقام وأسماء الموبايل الحقيقية تلقائياً
  Future<void> _fetchRealContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تواصل (${_contacts.length} جهة اتصال)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _fetchRealContacts,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? const Center(child: Text('لم يتم العثور على جهات اتصال أو لم يتم منح الإذن'))
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : 'بدون رقم';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF00A884),
                        child: Text(
                          contact.displayName.isNotEmpty ? contact.displayName[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(contact.displayName),
                      subtitle: Text(phone),
                      trailing: const Icon(Icons.chat, color: Color(0xFF00A884)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomScreen(contactName: contact.displayName),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// شاشة الدردشة
class ChatRoomScreen extends StatefulWidget {
  final String contactName;
  const ChatRoomScreen({super.key, required this.contactName});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<String> _messages = ["أهلاً بك في تطبيق تواصل!"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFF00A884)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveVideoCallScreen(userName: widget.contactName),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005C4B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_messages[i], style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      filled: true,
                      fillColor: const Color(0xFF2A3942),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00A884)),
                  onPressed: () {
                    if (_msgController.text.isNotEmpty) {
                      setState(() {
                        _messages.add(_msgController.text);
                        _msgController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// شاشة مكالمة الفيديو والتحكم في الجودة
class LiveVideoCallScreen extends StatefulWidget {
  final String userName;
  const LiveVideoCallScreen({super.key, required this.userName});

  @override
  State<LiveVideoCallScreen> createState() => _LiveVideoCallScreenState();
}

class _LiveVideoCallScreenState extends State<LiveVideoCallScreen> {
  String selectedQuality = 'HD 1080p (عالية)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'مكالمة جارية مع ${widget.userName}',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: [
                const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  'الجودة الحالية: $selectedQuality',
                  style: const TextStyle(color: Color(0xFF00A884), fontSize: 16),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color
