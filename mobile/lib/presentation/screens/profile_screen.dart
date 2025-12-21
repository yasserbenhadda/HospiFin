import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=68'), // Mock avatar
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dr. Sophie Martin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'Chef de Service',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            
            GlassCard(
              opacity: 0.8,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: AppColors.primary),
                    title: const Text('Informations personnelles'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                    title: const Text('Notifications'),
                    trailing: Switch(value: true, onChanged: (val) {}, activeColor: AppColors.primary),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                    title: const Text('Mode Sombre'),
                    trailing: Switch(value: false, onChanged: (val) {}, activeColor: AppColors.primary),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                    title: const Text('Sécurité'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            
            const SizedBox(height: 24),
            // Login removed as requested
          ],
        ),
      ),
    );
  }
}
