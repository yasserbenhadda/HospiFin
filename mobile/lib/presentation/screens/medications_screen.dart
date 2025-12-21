import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/medication_service.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final MedicationService _service = MedicationService();
  late Future<List<dynamic>> _dataFull;

  @override
  void initState() {
    super.initState();
    _dataFull = _service.getMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médicaments'),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medication, color: AppColors.info),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'Médicament',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Unit: ${item['unit']}',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (item['stock'] ?? 0) < 100 ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Stock: ${item['stock']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (item['stock'] ?? 0) < 100 ? AppColors.error : AppColors.success,
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
