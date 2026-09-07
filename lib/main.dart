import 'dart:async';
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HalamanBeranda(),
    );
  }
}

// ================= MODEL KONTAK (TUGAS 4) =================
class Kontak {
  String nama;
  String email;
  String telepon;
  String? kategori; // Nullable
  bool favorit;

  Kontak({
    required this.nama,
    required this.email,
    required this.telepon,
    this.kategori,
    this.favorit = false,
  });
}

// ================= HALAMAN BERANDA =================
class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Kontak> _daftarKontak = [];

  // Tugas 6: StreamController untuk pencarian real-time
  final StreamController<String> _searchController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.close(); // Tugas 6: Mencegah memory leak
    super.dispose();
  }

  Future<void> _bukaTambahKontak() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HalamanTambahKontak()),
    );

    if (result != null && result is Kontak) {
      setState(() {
        _daftarKontak.add(result);
      });
      _searchController.add(''); // Refresh tampilan stream
    }
  }

  void _toggleFavorit(Kontak kontak) {
    setState(() {
      kontak.favorit = !kontak.favorit;
    });
  }

  void _hapusKontak(Kontak kontak) {
    setState(() {
      _daftarKontak.remove(kontak);
    });
    _searchController.add('');
  }

  @override
  Widget build(BuildContext context) {
    final favoritList = _daftarKontak.where((k) => k.favorit).toList();

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
              child: Text('BUKU KONTAK', style: TextStyle(color: Colors.white, fontSize: 24)),
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
              onTap: () {
                Navigator.pop(context);
                _bukaTambahKontak();
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
                  MaterialPageRoute(builder: (context) => const HalamanTentang()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tugas 6: Tab Kontak dengan TextField Pencarian Real-time & StreamBuilder
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Cari Nama / Kategori',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (teks) {
                    _searchController.add(teks); // Mengirim input ketikan ke Stream
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<String>(
                  stream: _searchController.stream,
                  builder: (context, snapshot) {
                    String kataKunci = (snapshot.data ?? '').toLowerCase();

                    // Filter list berdasarkan nama ATAU kategori (case-insensitive)
                    final daftarHasilCari = _daftarKontak.where((k) {
                      final matchNama = k.nama.toLowerCase().contains(kataKunci);
                      final matchKategori = (k.kategori ?? '').toLowerCase().contains(kataKunci);
                      return matchNama || matchKategori;
                    }).toList();

                    return _buildDaftarKontak(daftarHasilCari, tampilkanHapus: true);
                  },
                ),
              ),
            ],
          ),
          // Tab 2: Favorit
          _buildDaftarKontak(favoritList, tampilkanHapus: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[100],
        onPressed: _bukaTambahKontak,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  Widget _buildDaftarKontak(List<Kontak> data, {required bool tampilkanHapus}) {
    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada kontak ditemukan'));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final kontak = data[index];
        return ListTile(
          // Tugas 3: Avatar Inisial
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              kontak.nama.isNotEmpty ? kontak.nama[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(kontak.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
          // Tugas 4: Null-aware Operator (??)
          subtitle: Text(
            '${kontak.telepon} | ${kontak.email}\nKategori: ${kontak.kategori ?? 'Tanpa kategori'}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  kontak.favorit ? Icons.star : Icons.star_border,
                  color: kontak.favorit ? Colors.amber : Colors.grey,
                ),
                onPressed: () => _toggleFavorit(kontak),
              ),
              if (tampilkanHapus)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _hapusKontak(kontak),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ================= HALAMAN TAMBAH KONTAK (TUGAS 5) =================
class HalamanTambahKontak extends StatefulWidget {
  const HalamanTambahKontak({super.key});

  @override
  State<HalamanTambahKontak> createState() => _HalamanTambahKontakState();
}

class _HalamanTambahKontakState extends State<HalamanTambahKontak> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController kategoriController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    kategoriController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      String? katInput = kategoriController.text.trim();
      if (katInput.isEmpty) {
        katInput = null;
      }

      Navigator.pop(
        context,
        Kontak(
          nama: namaController.text.trim(),
          email: emailController.text.trim(),
          telepon: noHpController.text.trim(),
          kategori: katInput,
        ),
      );
    }
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email harus mengandung karakter @';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No Handphone'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'No Handphone wajib diisi';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'No Handphone hanya boleh berisi angka';
                    }
                    if (value.length < 10) {
                      return 'No Handphone minimal 10 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: kategoriController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (Opsional, contoh: Teman, Kerja)',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[50],
                    foregroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Simpan'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= HALAMAN TENTANG =================
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
            Text('Aldejan Kovic Putra Sulash', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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