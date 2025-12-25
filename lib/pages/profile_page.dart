import 'package:flutter/material.dart';
import '../services/mock_user_service.dart'; // Import Service User
import 'landing_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final MockUserService _userService = MockUserService(); // Panggil Service
  
  late TextEditingController _usernameController;
  final TextEditingController _passwordController = TextEditingController(); 
  final TextEditingController _confirmPasswordController = TextEditingController(); 

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Variable lokal untuk menampung pilihan sementara sebelum di-save
  late int _selectedAvatarIndex;

  @override
  void initState() {
    super.initState();
    // 1. Ambil data asli dari Service saat halaman dibuka
    _usernameController = TextEditingController(text: _userService.username);
    _selectedAvatarIndex = _userService.avatarIndex;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // 2. SIMPAN DATA KE SERVICE (Database Palsu)
      setState(() {
        _userService.username = _usernameController.text;
        _userService.avatarIndex = _selectedAvatarIndex;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Kembali ke Home
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LandingPage()), (route) => false);
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2E335A),
          title: const Text("Hapus Akun?", style: TextStyle(color: Colors.white)),
          content: const Text("Tindakan ini tidak dapat dibatalkan.", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(child: const Text("Batal", style: TextStyle(color: Colors.white54)), onPressed: () => Navigator.of(context).pop()),
            TextButton(child: const Text("HAPUS", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)), onPressed: () { Navigator.of(context).pop(); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LandingPage()), (route) => false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akun berhasil dihapus."), backgroundColor: Colors.red)); }),
          ],
        );
      },
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1B33),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            children: [
              const Text("Pilih Avatar Lucu", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 15, mainAxisSpacing: 15),
                  // Gunakan list dari Service agar konsisten
                  itemCount: _userService.avatarList.length, 
                  itemBuilder: (context, index) {
                    final avatar = _userService.avatarList[index];
                    final isSelected = _selectedAvatarIndex == index;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() { _selectedAvatarIndex = index; }); // Update tampilan lokal
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.white, width: 3) : null, color: avatar['color'].withOpacity(0.2)),
                        child: Icon(avatar['icon'], color: avatar['color'], size: 30),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil detail avatar berdasarkan index yang sedang dipilih
    final currentAvatar = _userService.avatarList[_selectedAvatarIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2E335A), Color(0xFF1C1B33)])),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showAvatarPicker,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.purpleAccent, width: 3), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 20)]),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: currentAvatar['color'].withOpacity(0.2),
                          child: Icon(currentAvatar['icon'], size: 60, color: currentAvatar['color']),
                        ),
                      ),
                      Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle), child: const Icon(Icons.edit, color: Colors.white, size: 20)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                const Text("Ketuk avatar untuk mengganti", style: TextStyle(color: Colors.white30, fontSize: 12)),
                const SizedBox(height: 30),

                // USERNAME
                TextFormField(controller: _usernameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Username", null), validator: (value) => value!.isEmpty ? "Username tidak boleh kosong" : null),
                const SizedBox(height: 20),
                
                // PASSWORD FIELDS
                TextFormField(controller: _passwordController, obscureText: !_isPasswordVisible, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Password Baru (Opsional)", IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible))), validator: (value) { if (value != null && value.isNotEmpty && value.length < 5) return "Password minimal 5 karakter"; return null; }),
                const SizedBox(height: 20),
                TextFormField(controller: _confirmPasswordController, obscureText: !_isConfirmPasswordVisible, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Konfirmasi Password Baru", IconButton(icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70), onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible))), validator: (value) { if (_passwordController.text.isNotEmpty) { if (value == null || value.isEmpty) return "Konfirmasi password wajib diisi"; if (value != _passwordController.text) return "Password tidak sama!"; } return null; }),
                
                const SizedBox(height: 40),
                SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _saveProfile, style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5), child: const Text("SIMPAN PERUBAHAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 55, child: OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text("KELUAR (LOGOUT)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(foregroundColor: Colors.orangeAccent, side: const BorderSide(color: Colors.orangeAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))),
                const SizedBox(height: 20),
                TextButton.icon(onPressed: _deleteAccount, icon: const Icon(Icons.delete_forever, size: 20), label: const Text("Hapus Akun Saya", style: TextStyle(fontWeight: FontWeight.bold)), style: TextButton.styleFrom(foregroundColor: Colors.redAccent)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, Widget? suffixIcon) {
    return InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), suffixIcon: suffixIcon);
  }
}