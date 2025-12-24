import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/medication_service.dart';
import '../../data/services/patient_service.dart';
import '../../data/services/consumable_service.dart';
import '../../data/models/patient_model.dart';
import '../widgets/custom_header.dart'; // Added
import 'package:intl/intl.dart';

class ConsumablesScreen extends StatefulWidget {
  const ConsumablesScreen({super.key});

  @override
  State<ConsumablesScreen> createState() => _ConsumablesScreenState();
}

class _ConsumablesScreenState extends State<ConsumablesScreen> {
  final ConsumableService _service = ConsumableService();
  final MedicationService _medicationService = MedicationService();
  final PatientService _patientService = PatientService();
  
  List<dynamic> _consumables = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConsumables();
  }

  Future<void> _loadConsumables() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _service.getConsumables();
      setState(() {
        _consumables = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading consumables: $e');
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
                onPressed: _loadConsumables,
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
        title: 'Consommables',
        subtitle: 'Gestion des stocks',
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
                // Back button removed
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gestion des consommables", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("${_consumables.length} consommables", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
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
                     hintText: "Rechercher...",
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
                     Expanded(child: _buildFilterDropdown("Patient")),
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
                : (_consumables.isEmpty 
                    ? const Center(child: Text("Aucun consommable trouvé")) 
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _consumables.length,
                        itemBuilder: (context, index) {
                          return _buildConsumableCard(_consumables[index]);
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
          Text(label, style: GoogleFonts.inter(color: Colors.black54), overflow: TextOverflow.ellipsis),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
        ],
      ),
    );
  }

  Widget _buildConsumableCard(dynamic item) {
    String patientName = 'Non assigné';
    final patientData = item['patient'];
    if (patientData != null) {
      if (patientData is String) {
        patientName = patientData;
      } else if (patientData is Map<String, dynamic>) {
        patientName = patientData['name'] ?? patientData['firstName'] ?? 'Patient';
      } else {
        patientName = patientData.toString();
      }
    }
    
    // Parse Medication Name
    String medName = 'Inconnu';
    final medData = item['medication'];
    if (medData != null) {
      if (medData is Map<String, dynamic>) {
        medName = medData['name'] ?? 'Inconnu';
      } else if (medData is String) {
        medName = medData;
      }
    } else if (item['name'] != null) {
      medName = item['name'];
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
          _buildInfoRow("MÉDICAMENT", medName, isBold: true),
          _buildInfoRow("PATIENT", patientName, isBold: true),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("QUANTITÉ", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${item['quantity'] ?? 0}', style: GoogleFonts.inter(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
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
    final quantityController = TextEditingController(text: item?['quantity']?.toString());
    final totalCostController = TextEditingController(text: item?['totalCost']?.toString() ?? '');
    
    // Date Controller handling
    DateTime initialDate;
    if (item != null && item['date'] != null) {
      initialDate = DateTime.parse(item['date']);
    } else {
      initialDate = DateTime.now();
    }
    
    // Fetch dropdown data
    List<dynamic> medications = [];
    List<Patient> patients = []; // Correct type
    try {
      medications = await _medicationService.getMedications();
      patients = await _patientService.getPatients();
    } catch (e) {
      print("Error fetching dropdown data: $e");
    }

    // Determine initial values
    int? selectedMedicationId; 
    int? selectedPatientId;

    if (item != null) {
      if (item['medication'] is Map) selectedMedicationId = item['medication']['id'];
      if (item['patient'] is Map) selectedPatientId = item['patient']['id'];
    }
    
    // Ensure selected IDs still exist in fetched lists
    if (isEdit) {
      if (medications.isNotEmpty && selectedMedicationId == null) selectedMedicationId = medications.firstOrNull?['id'];
      if (patients.isNotEmpty && selectedPatientId == null) selectedPatientId = patients.firstOrNull?.id;
    }


    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
        backgroundColor: const Color(0xFFEFF3F8), // Matches design background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? "Modifier la consommation" : "Nouvelle consommation", 
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                const SizedBox(height: 24),
                
                // Medication Dropdown
                _buildStyledDropdown(
                  label: "Médicament",
                  value: selectedMedicationId,
                  hint: "Sélectionner un médicament",
                  items: medications.map<DropdownMenuItem<int>>((m) {
                    return DropdownMenuItem<int>(
                      value: m['id'],
                      child: Text(m['name']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedMedicationId = val),
                ),
                const SizedBox(height: 16),
                
                _buildStyledTextField(controller: quantityController, label: "Quantité", isNumber: true),
                const SizedBox(height: 16),
                
                // Date Picker Tile
                ListTile(
                   contentPadding: EdgeInsets.zero,
                   title: Text("Date", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                   subtitle: Text(DateFormat('yyyy-MM-dd').format(initialDate), style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E293B))),
                   trailing: const Icon(Icons.calendar_today, color: Color(0xFF64748B)),
                   onTap: () async {
                      final d = await showDatePicker(
                        context: context, 
                        initialDate: initialDate, 
                        firstDate: DateTime(2020), 
                        lastDate: DateTime(2030)
                      );
                      if (d != null) setState(() => initialDate = d);
                   },
                ),
                const SizedBox(height: 16),
                
                // Patient Dropdown (FIXED: Uses Patient object properties)
                _buildStyledDropdown(
                  label: "Patient",
                  value: selectedPatientId,
                  hint: "Sélectionner un patient",
                  items: patients.map<DropdownMenuItem<int>>((p) {
                    return DropdownMenuItem<int>(
                      value: p.id,
                      child: Text(p.fullName), // Using getter from model
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedPatientId = val),
                ),
                const SizedBox(height: 16),
                
                _buildStyledTextField(controller: totalCostController, label: "Coût Total (€)", isNumber: true),

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
                            'quantity': int.tryParse(quantityController.text) ?? 0,
                            'date': DateFormat('yyyy-MM-dd').format(initialDate),
                            'patient': {'id': selectedPatientId}, 
                            'medication': {'id': selectedMedicationId},
                            'totalCost': double.tryParse(totalCostController.text) ?? 0.0,
                          };

                          if (isEdit) {
                            await _service.updateConsumable(item['id'], data);
                          } else {
                            await _service.createConsumable(data);
                          }
                          if (mounted) Navigator.pop(context);
                          _loadConsumables();
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
      ),
    );
  }

  Widget _buildStyledTextField({required TextEditingController controller, required String label, bool isNumber = false, String? hint}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold),
        floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Consistent styling
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildStyledDropdown({required String label, required int? value, required List<DropdownMenuItem<int>> items, required Function(int?) onChanged, String? hint}) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold),
        floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Consistent styling
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5)),
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
        content: const Text("Êtes-vous sûr de vouloir supprimer ce consommable ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && id is int) {
      try {
        await _service.deleteConsumable(id);
        _loadConsumables();
        if (width.mounted) {
          ScaffoldMessenger.of(width).showSnackBar(const SnackBar(content: Text("Consommable supprimé avec succès")));
        }
      } catch (e) {
        if (width.mounted) {
          ScaffoldMessenger.of(width).showSnackBar(SnackBar(content: Text("Erreur lors de la suppression: $e"), backgroundColor: Colors.red));
        }
      }
    }
  }
}
