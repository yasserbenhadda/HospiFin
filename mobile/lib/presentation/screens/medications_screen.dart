import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/medication_service.dart';
import '../widgets/custom_header.dart'; // Added

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final MedicationService _service = MedicationService();
  
  List<dynamic> _medications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _service.getMedications();
      setState(() {
        _medications = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medications: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur"), backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
              ElevatedButton(
                onPressed: _loadMedications,
                child: const Text("Réessayer"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: const CustomHeader(
        title: 'Médicaments',
        subtitle: 'Gestion de la pharmacie',
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gestion des médicaments", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      Text("${_medications.length} médicaments enregistrés", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showEditDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text("Nouveau", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
               children: [
                 TextField(
                   decoration: InputDecoration(
                     prefixIcon: const Icon(Icons.search, color: Colors.grey),
                     hintText: "Rechercher un médicament...",
                     filled: true,
                     fillColor: Colors.white,
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                     contentPadding: const EdgeInsets.symmetric(vertical: 0),
                   ),
                 ),
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(child: _buildFilterDropdown("Type")),
                     const SizedBox(width: 8),
                     Expanded(child: _buildFilterDropdown("Stock")),
                     const SizedBox(width: 8),
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                       child: const Icon(Icons.filter_list, color: Colors.black54),
                     ),
                     const SizedBox(width: 8),
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                       child: const Icon(Icons.download, color: Colors.black54),
                     ),
                   ],
                 )
               ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : (_medications.isEmpty 
                    ? const Center(child: Text("Aucun médicament trouvé")) 
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _medications.length,
                        itemBuilder: (context, index) {
                          return _buildMedicationCard(_medications[index]);
                        },
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.black54)),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(dynamic item) {
    // Determine stock status/color
    final stock = item['stock'] ?? 0;
    Color stockColor = AppColors.success;
    Color stockBg = AppColors.success.withOpacity(0.1);
    String stockText = 'En Stock';
    
    if (stock < 50) {
      stockColor = AppColors.error;
      stockBg = AppColors.error.withOpacity(0.1);
      stockText = 'Stock Faible';
    } else if (stock < 200) {
      stockColor = AppColors.warning;
      stockBg = AppColors.warning.withOpacity(0.1);
      stockText = 'Stock Moyen';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow("ID", item['id']?.toString() ?? 'N/A', isBold: false),
          _buildInfoRow("NOM", item['name'] ?? 'Inconnu', isBold: true),
          _buildInfoRow("UNITÉ", item['unit'] ?? '-', isBold: true),
          _buildInfoRow("QUANTITÉ", stock.toString(), isBold: true),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ÉTAT STOCK", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(stockText, style: GoogleFonts.inter(color: stockColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditDialog(item: item),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1E3A8A)),
                  label: const Text("Modifier", style: TextStyle(color: Color(0xFF1E3A8A))),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(width: context, id: item['id']),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  label: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                   style: OutlinedButton.styleFrom(
                     side: const BorderSide(color: Color(0xFFFFF0F0)),
                     backgroundColor: const Color(0xFFFFF8F8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }



  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal, color: Colors.black)),
        ],
      ),
    );
  }

  // --- Actions ---

  Future<void> _showEditDialog({Map<String, dynamic>? item}) async {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?['name']);
    final categoryController = TextEditingController(text: item?['category'] ?? '');
    final costController = TextEditingController(text: item?['unitCost']?.toString() ?? '');
    final stockController = TextEditingController(text: item?['stock']?.toString());
    final unitController = TextEditingController(text: item?['unit']);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFEFF3F8), // High Contrast Background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(isEdit ? "Modifier le médicament" : "Nouveau médicament", 
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 24),
                _buildStyledTextField(controller: nameController, label: "Nom"),
                const SizedBox(height: 16),
                _buildStyledTextField(controller: categoryController, label: "Catégorie"),
                const SizedBox(height: 16),
                _buildStyledTextField(controller: costController, label: "Coût Unitaire (€)", isNumber: true),
                const SizedBox(height: 16),
                _buildStyledTextField(controller: stockController, label: "Stock", isNumber: true),
                const SizedBox(height: 16),
                _buildStyledTextField(controller: unitController, label: "Unité"),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Annuler", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final data = {
                            'name': nameController.text,
                            'category': categoryController.text,
                            'unitCost': double.tryParse(costController.text) ?? 0.0,
                            'stock': int.tryParse(stockController.text) ?? 0,
                            'unit': unitController.text,
                          };

                          if (isEdit) {
                            await _service.updateMedication(item['id'], data);
                          } else {
                            await _service.createMedication(data);
                          }
                          if (mounted) Navigator.pop(context);
                          _loadMedications();
                          if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? "Modifié avec succès" : "Créé avec succès")));
                          }
                        } catch (e) {
                          print(e);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Une erreur est survenue"), backgroundColor: Colors.red));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text("Enregistrer", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField({required TextEditingController controller, required String label, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold),
        floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Consistent High Contrast Style
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Future<void> _confirmDelete({required BuildContext width, required dynamic id}) async {
    final confirmed = await showDialog<bool>(
      context: width,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Êtes-vous sûr de vouloir supprimer ce médicament ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && id is int) {
      try {
        await _service.deleteMedication(id);
        _loadMedications();
        if (width.mounted) {
          ScaffoldMessenger.of(width).showSnackBar(const SnackBar(content: Text("Médicament supprimé avec succès")));
        }
      } catch (e) {
        if (width.mounted) {
          ScaffoldMessenger.of(width).showSnackBar(SnackBar(content: Text("Erreur lors de la suppression: $e"), backgroundColor: Colors.red));
        }
      }
    }
  }
}
