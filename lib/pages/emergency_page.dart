import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import plugin telepon

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  // Fungsi untuk melakukan panggilan telepon
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    // Coba buka aplikasi telepon bawaan
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Gelap
      appBar: AppBar(
        title: const Text("Panggilan Darurat", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                "JANGAN PANIK!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Tekan tombol di bawah untuk menghubungi bantuan segera.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 50),

              // === TOMBOL SOS BESAR (BNPB/SAR) ===
              _buildSOSButton(
                label: "CALL BNPB (117)",
                color: Colors.red,
                icon: Icons.sos,
                onTap: () => _makePhoneCall("117"),
              ),

              const SizedBox(height: 20),

              // === TOMBOL AMBULANS ===
              _buildSOSButton(
                label: "AMBULANS (118)",
                color: Colors.orange, // Warna beda biar kontras
                icon: Icons.medical_services,
                onTap: () => _makePhoneCall("118"),
              ),
              
               const SizedBox(height: 20),
               
               // === TOMBOL POLISI ===
              _buildSOSButton(
                label: "POLISI (110)",
                color: Colors.blueAccent, 
                icon: Icons.local_police,
                onTap: () => _makePhoneCall("110"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Tombol SOS Kustom
  Widget _buildSOSButton({
    required String label, 
    required Color color, 
    required IconData icon, 
    required VoidCallback onTap
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 10,
          shadowColor: color.withOpacity(0.5),
        ),
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}