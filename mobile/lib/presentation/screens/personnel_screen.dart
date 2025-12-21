import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/personnel_service.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  final PersonnelService _service = PersonnelService();
  late Future<List<dynamic>> _dataFull;

  @override
  void initState() {
    super.initState();
    _dataFull = _service.getPersonnel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel Médical'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFull,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.background,
                         child: Icon(Icons.person, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Nom',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            item['role'] ?? 'Poste',
                            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['service'] ?? 'Service',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
