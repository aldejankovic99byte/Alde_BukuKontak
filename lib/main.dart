import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Kontak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HalamanBeranda(),
    );
  }
}

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> kontak = [];
  List<Map<String, String>> favorit = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BUKU KONTAK'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Kontak'),
            Tab(icon: Icon(Icons.star), text: 'Favorit'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'BUKU KONTAK',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Kontak'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Kontak'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HalamanTambahKontak(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    kontak.add(result);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorit'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HalamanTentang(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          kontak.isEmpty
              ? const Center(child: Text('Belum ada kontak'))
              : ListView.builder(
                  itemCount: kontak.length,
                  itemBuilder: (context, index) {
                    // Ambil nama spesifik pada indeks saat ini
                    String namaKontak = kontak[index]['nama']!;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          namaKontak.isNotEmpty
                              ? namaKontak[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(namaKontak),
                      subtitle: Text(
                        '${kontak[index]['email']!}\n${kontak[index]['noHp']!}',
                      ),
                    );
                  },
                ),
          favorit.isEmpty
              ? const Center(child: Text('Belum ada kontak favorit'))
              : ListView.builder(
                  itemCount: favorit.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(favorit[index]['nama']!),
                      subtitle: Text(
                        '${favorit[index]['email']!}\n${favorit[index]['noHp']!}',
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[100],
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HalamanTambahKontak(),
            ),
          );
          if (result != null) {
            setState(() {
              kontak.add(result);
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}

class HalamanTambahKontak extends StatefulWidget {
  const HalamanTambahKontak({super.key});

  @override
  State<HalamanTambahKontak> createState() => _HalamanTambahKontakState();
}

class _HalamanTambahKontakState extends State<HalamanTambahKontak> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kontak'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: noHpController,
              decoration: const InputDecoration(labelText: 'No Handphone'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'nama': namaController.text,
                  'email': emailController.text,
                  'noHp': noHpController.text,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[50],
                foregroundColor: Colors.deepPurple,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class HalamanTentang extends StatelessWidget {
  const HalamanTentang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/profil.jpg'),
            ),
            SizedBox(height: 20),
            Text(
              'Aldejan Kovic Putra Sulash',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('XII RPL B', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('SMK Negeri 5 Surakarta', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
