import 'package:flutter/material.dart';
import 'dart:ui'; // Needed for GlassCard blur
import '../models/flood_model.dart';

class MitigationPage extends StatefulWidget {
  // We use DailyForecast here because we come from the 5-day forecast list
  final DailyForecast floodData;

  const MitigationPage({super.key, required this.floodData});

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

class _MitigationPageState extends State<MitigationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _checkedItems = {};

  // Dynamic Titles & Icons based on Risk Level
  late List<String> _tabTitles;
  late List<IconData> _tabIcons;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupTabs();
  }

  void _setupTabs() {
    if (widget.floodData.risk == "High") {
      // DANGER SCENARIO: Focus on Safety & Evacuation
      _tabTitles = ["Siaga", "Evakuasi", "Pemulihan"];
      _tabIcons = [
        Icons.warning_amber_rounded, 
        Icons.run_circle_outlined,   
        Icons.local_hospital_outlined 
      ];
    } else if (widget.floodData.risk == "Medium") {
      // ALERT SCENARIO: Focus on Prevention & Monitoring
      _tabTitles = ["Cegah", "Pantau", "Perawatan"];
      _tabIcons = [
        Icons.build_circle_outlined, 
        Icons.visibility_outlined,   
        Icons.cleaning_services_outlined 
      ];
    } else {
      // CALM SCENARIO: Lifestyle & Environment
      _tabTitles = ["Tips Harian", "Aktivitas", "Lingkungan"];
      _tabIcons = [
        Icons.wb_sunny_outlined,     
        Icons.directions_walk,       
        Icons.park_outlined          
      ];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Panduan Aktivitas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purpleAccent,
          indicatorWeight: 3,
          labelColor: Colors.purpleAccent,
          unselectedLabelColor: Colors.white54,
          dividerColor: Colors.transparent,
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
              // Pass the specific list for each tab
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
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sectionIcon, size: 60, color: Colors.white24),
            const SizedBox(height: 10),
            const Text("Tidak ada langkah khusus.", style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            secondary: Icon(
              sectionIcon, 
              color: isChecked ? Colors.greenAccent : Colors.white54,
              size: 28,
            ),
            title: Text(
              itemText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white54,
                decorationThickness: 2,
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

// === INTERNAL GLASS CARD WIDGET ===
// (If you don't have this in a separate file, keep it here)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}