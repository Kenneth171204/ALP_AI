import 'package:flutter/material.dart';
import '../models/flood_model.dart';
import '../services/user_service.dart'; // Import Service User
import '../services/api_flood_service.dart'; 
import 'mitigation_page.dart';
import 'emergency_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final MockUserService _userService = MockUserService();
  final ApiFloodService _floodService = ApiFloodService(); 
  
  FloodModel? _floodData;
  bool _isLoading = false;

  void _searchRisk(String query) async {
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _floodData = null;
    });

    FloodModel result = await _floodService.getPrediction(query);

    setState(() {
      _floodData = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentAvatar = _userService.avatarList[_userService.avatarIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("FloodAware", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const ProfilePage())
                ).then((_) {
                  setState(() {});
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 18, 
                  backgroundColor: currentAvatar['color'].withOpacity(0.2),
                  child: Icon(currentAvatar['icon'], size: 20, color: currentAvatar['color']),
                ),
              ),
            ),
          )
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyPage()));
        },
        backgroundColor: Colors.redAccent, 
        icon: const Icon(Icons.sos, color: Colors.white),
        label: const Text("DARURAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SEARCH BAR
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

                const SizedBox(height: 20),

                // CONTENT
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

  Widget _buildResultContent(FloodModel data) {
    if (data.risk == "NotFound" || data.risk == "Error") {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.redAccent),
            SizedBox(height: 20),
            Text("Lokasi tidak ditemukan.", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER CITY
          Center(
            child: Text(data.cityName, 
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)
            )
          ),
          
          const SizedBox(height: 20),
          
          // 2. MAIN CARD (TODAY)
          const Text("HARI INI", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          if (data.current != null) _buildMainCard(data.current!),

          const SizedBox(height: 30),

          // 3. NEXT 4 DAYS (Horizontal List)
          if (data.forecast.isNotEmpty) ...[
            const Text("4 HARI KEDEPAN", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.forecast.length,
                itemBuilder: (context, index) {
                  return _buildSmallCard(data.forecast[index]);
                },
              ),
            ),
          ]
        ],
      ),
    );
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

  // === BIG CARD (TODAY) ===
  Widget _buildMainCard(DailyForecast data) {
    List<Color> gradientColors;
    if (data.risk == "High") {
      gradientColors = [const Color(0xFFFF512F), const Color(0xFFDD2476)];
    } else if (data.risk == "Medium") {
      gradientColors = [const Color(0xFFFF8008), const Color(0xFFFFC837)];
    } else {
      gradientColors = [const Color(0xFF11998e), const Color(0xFF38ef7d)];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          _buildDynamicWeatherIcon(data.risk, size: 100),
          const SizedBox(height: 10),
          Text(data.risk.toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
          Text("${data.weather}, ${data.temp}°C", style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.shield_outlined),
            label: const Text("Panduan Mitigasi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, 
              foregroundColor: gradientColors[1],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
            ),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => MitigationPage(floodData: data)));
            },
          )
        ],
      ),
    );
  }

  // === SMALL CARD (FORECAST) ===
  Widget _buildSmallCard(DailyForecast data) {
    Color bg = data.risk == "High" ? Colors.red.withOpacity(0.8) 
             : data.risk == "Medium" ? Colors.orange.withOpacity(0.8) 
             : const Color(0xFF11998e).withOpacity(0.5);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MitigationPage(floodData: data)));
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(data.date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 10),
            _buildDynamicWeatherIcon(data.risk, size: 40),
            const SizedBox(height: 10),
            Text("${data.temp}°C", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(data.risk, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicWeatherIcon(String risk, {double size = 100}) {
    if (risk == "High") {
      return Icon(Icons.bolt, size: size, color: Colors.yellowAccent);
    } else if (risk == "Medium") {
      return Icon(Icons.water_drop, size: size, color: Colors.lightBlueAccent);
    } else {
      return Icon(Icons.wb_sunny_rounded, size: size, color: Colors.orangeAccent);
    }
  }
}