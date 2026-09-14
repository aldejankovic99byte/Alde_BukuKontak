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

// ================= MODEL KONTAK =================
class Kontak {
  String nama;
  String email;
  String telepon;
  String? kategori;
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

  final StreamController<String> _searchController = StreamController<String>.broadcast();
  String _kataKunciPencarian = ''; // Menyimpan kata kunci pencarian terakhir

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.close();
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
      _searchController.add(_kataKunciPencarian); // Refresh pencarian
    }
  }

  // FITUR UPDATE/EDIT: Fungsi untuk membuka halaman edit
  Future<void> _bukaEditKontak(Kontak kontak) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HalamanEditKontak(kontak: kontak)),
    );

    if (result == true) {
      setState(() {}); 
      _searchController.add(_kataKunciPencarian); // Refresh daftar agar perubahan langsung terlihat
    }
  }

  void _toggleFavorit(Kontak kontak) {
    setState(() {
      kontak.favorit = !kontak.favorit;
    });
  }

  // FITUR DELETE: Fungsi untuk menampilkan dialog konfirmasi sebelum menghapus
  void _konfirmasiHapusKontak(Kontak kontak) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus kontak ${kontak.nama}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Memilih Batal, kontak tidak dihapus
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                setState(() {
                  _daftarKontak.remove(kontak); // Memilih Hapus, menghapus kontak dari daftar
                });
                _searchController.add(_kataKunciPencarian); // Refresh daftar pencarian
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
          // Tab 1: Kontak (dengan StreamBuilder untuk Pencarian)
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
                    _kataKunciPencarian = teks; // Simpan kata kunci saat ini
                    _searchController.add(teks); 
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<String>(
                  stream: _searchController.stream,
                  builder: (context, snapshot) {
                    String kataKunci = (snapshot.data ?? '').toLowerCase();

                    final daftarHasilCari = _daftarKontak.where((k) {
                      final matchNama = k.nama.toLowerCase().contains(kataKunci);
                      final matchKategori = (k.kategori ?? '').toLowerCase().contains(kataKunci);
                      return matchNama || matchKategori;
                    }).toList();

                    return _buildDaftarKontak(daftarHasilCari, tampilkanAksi: true);
                  },
                ),
              ),
            ],
          ),
          // Tab 2: Favorit
          _buildDaftarKontak(favoritList, tampilkanAksi: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[100],
        onPressed: _bukaTambahKontak,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }

  Widget _buildDaftarKontak(List<Kontak> data, {required bool tampilkanAksi}) {
    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada kontak ditemukan'));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final kontak = data[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              kontak.nama.isNotEmpty ? kontak.nama[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(kontak.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              // Menampilkan tombol Edit dan Hapus jika di tab Kontak
              if (tampilkanAksi) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () => _bukaEditKontak(kontak),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _konfirmasiHapusKontak(kontak),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ================= HALAMAN EDIT KONTAK (FITUR BARU) =================
class HalamanEditKontak extends StatefulWidget {
  final Kontak kontak; // Menerima data kontak yang akan di-edit

  const HalamanEditKontak({super.key, required this.kontak});

  @override
  State<HalamanEditKontak> createState() => _HalamanEditKontakState();
}

class _HalamanEditKontakState extends State<HalamanEditKontak> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaController;
  late TextEditingController emailController;
  late TextEditingController noHpController;
  late TextEditingController kategoriController;

  @override
  void initState() {
    super.initState();
    // Mengisi form dengan data lama yang sudah tersimpan
    namaController = TextEditingController(text: widget.kontak.nama);
    emailController = TextEditingController(text: widget.kontak.email);
    noHpController = TextEditingController(text: widget.kontak.telepon);
    kategoriController = TextEditingController(text: widget.kontak.kategori ?? '');
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    kategoriController.dispose();
    super.dispose();
  }

  void _simpanPerubahan() {
    if (_formKey.currentState!.validate()) {
      String? katInput = kategoriController.text.trim();
      if (katInput.isEmpty) katInput = null;

      // Memperbarui objek kontak lama dengan data baru dari form
      widget.kontak.nama = namaController.text.trim();
      widget.kontak.email = emailController.text.trim();
      widget.kontak.telepon = noHpController.text.trim();
      widget.kontak.kategori = katInput;

      // Kembali ke halaman sebelumnya dan memberi tanda true (berhasil)
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Kontak'),
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
                    if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
                    if (!value.contains('@')) return 'Email harus menggunakan karakter @';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No Handphone'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nomor handphone tidak boleh kosong';
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Nomor handphone hanya boleh berupa angka';
                    if (value.length < 10) return 'Nomor handphone minimal 10 digit';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: kategoriController,
                  decoration: const InputDecoration(labelText: 'Kategori (Opsional, contoh: Teman)'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _simpanPerubahan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[900],
                  ),
                  child: const Text('Simpan Perubahan'), // Tombol Simpan Perubahan
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= HAL halaman TAMBAH KONTAK =================
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
                    if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
                    if (!value.contains('@')) return 'Email harus menggunakan karakter @';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No Handphone'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nomor handphone tidak boleh kosong';
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Nomor handphone hanya boleh berupa angka';
                    if (value.length < 10) return 'Nomor handphone minimal 10 digit';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: kategoriController,
                  decoration: const InputDecoration(labelText: 'Kategori (Opsional, contoh: Teman)'),
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