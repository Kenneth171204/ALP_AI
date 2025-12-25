import 'package:flutter/material.dart';
import '../models/flood_model.dart';
import '../widgets/glass_card.dart';

class MitigationPage extends StatefulWidget {
  final FloodModel floodData;

  const MitigationPage({super.key, required this.floodData});

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

class _MitigationPageState extends State<MitigationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _checkedItems = {};

  // Variabel untuk menyimpan Judul & Ikon Tab yang dinamis
  late List<String> _tabTitles;
  late List<IconData> _tabIcons;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // === LOGIKA DINAMIS: MENENTUKAN JUDUL & IKON TAB BERDASARKAN RISIKO ===
    _setupTabs();
  }

  void _setupTabs() {
    if (widget.floodData.risk == "High") {
      // Skenario Bahaya: Fokus pada Keselamatan & Evakuasi
      _tabTitles = ["Siaga", "Evakuasi", "Pemulihan"];
      _tabIcons = [
        Icons.warning_amber_rounded, // Ikon Segitiga Tanda Seru
        Icons.run_circle_outlined,   // Ikon Orang Lari
        Icons.local_hospital_outlined // Ikon Kesehatan/RS
      ];
    } else if (widget.floodData.risk == "Medium") {
      // Skenario Waspada: Fokus pada Pencegahan & Monitor
      _tabTitles = ["Cegah", "Pantau", "Perawatan"];
      _tabIcons = [
        Icons.build_circle_outlined, // Ikon Obeng/Perbaikan
        Icons.visibility_outlined,   // Ikon Mata (Memantau)
        Icons.cleaning_services_outlined // Ikon Bersih-bersih
      ];
    } else {
      // Skenario Aman: Fokus pada Gaya Hidup & Lingkungan (Lebih santai)
      _tabTitles = ["Tips Harian", "Aktivitas", "Lingkungan"];
      _tabIcons = [
        Icons.wb_sunny_outlined,     // Ikon Matahari (Cerah)
        Icons.directions_walk,       // Ikon Orang Jalan Santai
        Icons.park_outlined          // Ikon Pohon/Taman
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Panduan Aktivitas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purpleAccent,
          indicatorWeight: 3,
          labelColor: Colors.purpleAccent,
          unselectedLabelColor: Colors.white54,
          dividerColor: Colors.transparent,
          // Menggunakan List Dinamis yang sudah kita set di _setupTabs
          tabs: [
            Tab(icon: Icon(_tabIcons[0]), text: _tabTitles[0]),
            Tab(icon: Icon(_tabIcons[1]), text: _tabTitles[1]),
            Tab(icon: Icon(_tabIcons[2]), text: _tabTitles[2]),
          ],
        ),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              // Kirim ikon yang sesuai ke list builder
              _buildChecklistTab(widget.floodData.beforeFlood, _tabIcons[0]),
              _buildChecklistTab(widget.floodData.duringFlood, _tabIcons[1]),
              _buildChecklistTab(widget.floodData.afterFlood, _tabIcons[2]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistTab(List<String> items, IconData sectionIcon) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final itemText = items[index];
        final isChecked = _checkedItems.contains(itemText);

        return GlassCard(
          padding: EdgeInsets.zero,
          child: CheckboxListTile(
            activeColor: Colors.purpleAccent,
            checkColor: Colors.white,
            secondary: Icon(
              sectionIcon, 
              // Warna ikon juga berubah: Ungu kalau belum, Hijau kalau sudah
              color: isChecked ? Colors.greenAccent : Colors.white54,
              size: 24,
            ),
            title: Text(
              itemText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white54, // Warna coretan
              ),
            ),
            subtitle: isChecked 
              ? const Text("Selesai ✓", style: TextStyle(color: Colors.greenAccent, fontSize: 12))
              : null,
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _checkedItems.add(itemText);
                } else {
                  _checkedItems.remove(itemText);
                }
              });
            },
          ),
        );
      },
    );
  }
}