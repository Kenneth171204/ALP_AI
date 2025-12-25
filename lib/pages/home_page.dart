import 'package:flutter/material.dart';
import '../models/flood_model.dart';
import '../services/mock_flood_service.dart';
import '../services/mock_user_service.dart'; // Import Service User
import 'mitigation_page.dart';
import 'emergency_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Variabel State
  final TextEditingController _cityController = TextEditingController();
  final MockFloodService _floodService = MockFloodService();
  final MockUserService _userService = MockUserService(); // Panggil Service User
  
  FloodModel? _floodData;
  bool _isLoading = false;

  // 2. Fungsi Pencarian
  void _searchRisk(String query) async {
    if (query.isEmpty) return;
    
    // Tutup keyboard biar rapi
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _floodData = null;
    });

    // Update teks di controller agar sinkron
    _cityController.text = query; 

    // Panggil Service
    FloodModel result = await _floodService.getPrediction(query);

    setState(() {
      _floodData = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data avatar user saat ini dari Service
    final currentAvatar = _userService.avatarList[_userService.avatarIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("FloodAware", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        
        // === HILANGKAN TOMBOL BACK (PANAH KIRI) ===
        automaticallyImplyLeading: false, 
        // ==========================================
        
        // === ICON PROFILE DINAMIS (KANAN ATAS) ===
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigasi ke Profile Page
                // Menggunakan 'then' -> Saat kembali dari Profile, refresh Home Page
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const ProfilePage())
                ).then((_) {
                  setState(() {}); // Refresh UI agar avatar berubah jika baru diganti
                });
              },
              // Tampilan Icon Avatar Kecil
              child: Container(
                padding: const EdgeInsets.all(2), // Border tipis
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 18, // Ukuran kecil untuk AppBar
                  backgroundColor: currentAvatar['color'].withOpacity(0.2),
                  child: Icon(
                    currentAvatar['icon'], 
                    size: 20, 
                    color: currentAvatar['color'] // Warna asli icon (sesuai pilihan user)
                  ),
                ),
              ),
            ),
          )
        ],
        // =========================================
      ),
      
      // Tombol SOS Melayang
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyPage()));
        },
        backgroundColor: Colors.redAccent, 
        icon: const Icon(Icons.sos, color: Colors.white),
        label: const Text("DARURAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: Container(
        // Background Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E335A), // Ungu Gelap
              Color(0xFF1C1B33), // Hitam Kebiruan
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === SECTION 1: SEARCH BAR ===
                const Text(
                  "Cek Risiko Banjir",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari lokasi (mis: Jakarta)...",
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => _searchRisk(_cityController.text),
                    ),
                  ),
                  onSubmitted: (val) => _searchRisk(val),
                ),

                const SizedBox(height: 30),

                // === SECTION 2: AREA KONTEN ===
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                      : _floodData != null
                          ? _buildResultContent(_floodData!)
                          : _buildEmptyState(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET LOGIKA TAMPILAN ---

  Widget _buildResultContent(FloodModel data) {
    // 1. KASUS TYPO ("Mungkin maksud Anda...")
    if (data.risk == "Typo") {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 60, color: Colors.orangeAccent),
            const SizedBox(height: 20),
            const Text("Lokasi tidak ditemukan tepat.", style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Mungkin maksud Anda: ", style: TextStyle(color: Colors.white)),
                GestureDetector(
                  onTap: () {
                    // KLIK SARAN -> OTOMATIS SEARCH ULANG
                    if (data.suggestedCity != null) {
                      _searchRisk(data.suggestedCity!); 
                    }
                  },
                  child: Text(
                    "\"${data.suggestedCity}\"?", 
                    style: const TextStyle(
                      color: Colors.purpleAccent, 
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 2. KASUS TIDAK KETEMU SAMA SEKALI
    if (data.risk == "NotFound") {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.redAccent),
            SizedBox(height: 20),
            Text(
              "Lokasi tidak dikenal.", 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 10),
            Text(
              "Mohon cek kembali ejaan lokasi Anda.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    // 3. KASUS BERHASIL -> TAMPILKAN KARTU
    return SingleChildScrollView(child: _buildRiskCard(data));
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop_outlined, size: 80, color: Colors.white24),
          SizedBox(height: 10),
          Text("Masukkan kota untuk cek risiko", style: TextStyle(color: Colors.white30)),
        ],
      ),
    );
  }

  // === KARTU RISIKO DENGAN IKON CUACA DINAMIS ===
  Widget _buildRiskCard(FloodModel data) {
    List<Color> gradientColors;
    Color shadowColor;

    if (data.risk == "High") {
      gradientColors = [const Color(0xFFFF512F), const Color(0xFFDD2476)]; // Merah
      shadowColor = Colors.red;
    } else if (data.risk == "Medium") {
      gradientColors = [const Color(0xFFFF8008), const Color(0xFFFFC837)]; // Oranye
      shadowColor = Colors.orange;
    } else {
      gradientColors = [const Color(0xFF11998e), const Color(0xFF38ef7d)]; // Hijau
      shadowColor = Colors.green;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // 1. IKON CUACA DINAMIS (STACKED)
          _buildDynamicWeatherIcon(data.risk),
          
          const SizedBox(height: 20),

          // 2. TEXT STATUS
          const Text("STATUS RISIKO", style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12)),
          Text(
            data.risk.toUpperCase(),
            style: const TextStyle(
              fontSize: 48, 
              fontWeight: FontWeight.w900, 
              color: Colors.white,
              shadows: [Shadow(blurRadius: 20, color: Colors.black26)],
            ),
          ),
          
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              data.weather, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
            ),
          ),

          const Divider(color: Colors.white30, height: 40),
          
          // 3. TOMBOL MITIGASI
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MitigationPage(floodData: data)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: shadowColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 10),
                  Text("Lihat Panduan Mitigasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // === FUNGSI PEMBUAT IKON CUACA TUMPUK (STACKED ICONS) ===
  Widget _buildDynamicWeatherIcon(String risk) {
    double size = 100;

    if (risk == "High") {
      // HIGH: Awan Gelap + Petir
      return SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: 0, child: Icon(Icons.cloud, size: size, color: Colors.white38)),
            Positioned(top: 10, child: Icon(Icons.cloud, size: size * 0.9, color: Colors.white)),
            Positioned(bottom: 5, child: Icon(Icons.bolt, size: size * 0.6, color: Colors.yellowAccent)),
          ],
        ),
      );
    } else if (risk == "Medium") {
      // MEDIUM: Awan + Hujan Deras
      return SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: 0, child: Icon(Icons.cloud, size: size, color: Colors.white38)), 
            Positioned(top: 5, child: Icon(Icons.cloud, size: size * 0.9, color: Colors.white)),
            Positioned(
              bottom: 0, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.water_drop, size: 20, color: Colors.blueAccent),
                  Icon(Icons.water_drop, size: 20, color: Colors.lightBlueAccent),
                  Icon(Icons.water_drop, size: 20, color: Colors.blueAccent),
                ],
              )
            ), 
          ],
        ),
      );
    } else {
      // LOW: Matahari + Awan Kecil
      return SizedBox(
        height: size,
        width: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 0, top: 0,
              child: Icon(Icons.wb_sunny_rounded, size: size * 0.8, color: Colors.yellowAccent)
            ),
            Positioned(
              left: 0, bottom: 0,
              child: Icon(Icons.cloud, size: size * 0.7, color: Colors.white)
            ),
          ],
        ),
      );
    }
  }
}