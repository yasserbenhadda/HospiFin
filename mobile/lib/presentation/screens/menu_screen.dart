import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'consumables_screen.dart';
import 'medical_acts_screen.dart';
import 'medications_screen.dart';
import 'personnel_screen.dart';
import 'stays_screen.dart';
// Patients screen is purposefully omitted from the menu

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Navigation',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            
            // --- Menu Items ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      label: 'Séjours',
                      icon: Icons.calendar_today_outlined,
                      destination: const StaysScreen(),
                    ),
                    _buildMenuItem(
                      context,
                      label: 'Actes médicaux',
                      icon: Icons.monitor_heart_outlined,
                      destination: const MedicalActsScreen(),
                    ),
                    _buildMenuItem(
                      context,
                      label: 'Médicaments',
                      icon: Icons.link,
                      destination: const MedicationsScreen(),
                    ),
                    _buildMenuItem(
                      context,
                      label: 'Consommations',
                      icon: Icons.shopping_cart_outlined,
                      destination: const ConsumablesScreen(),
                    ),
                    _buildMenuItem(
                      context,
                      label: 'Personnel',
                      icon: Icons.people_outline,
                      destination: const PersonnelScreen(),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // --- Highlighted Item (Paramètres) ---
                    // The screenshot shows this item selected/highlighted
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE), // Light Blue bg
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.short_text, color: Color(0xFF0F172A)), // Hamburger-ish icon
                        title: Text(
                          'Paramètres',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A), // Dark text
                          ),
                        ),
                        onTap: () {
                          // Action for settings
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required String label, required IconData icon, required Widget destination}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF475569), size: 22),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF334155),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
      },
    );
  }
}
