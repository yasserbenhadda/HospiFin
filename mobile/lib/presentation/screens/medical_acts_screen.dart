import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/medical_act_model.dart';
import '../../data/models/patient_model.dart';
import '../../data/services/medical_act_service.dart';
import '../widgets/custom_header.dart';
import '../../data/services/patient_service.dart';

class MedicalActsScreen extends StatefulWidget {
  const MedicalActsScreen({super.key});

  @override
  State<MedicalActsScreen> createState() => _MedicalActsScreenState();
}

class _MedicalActsScreenState extends State<MedicalActsScreen> {
  final MedicalActService _actService = MedicalActService();
  final PatientService _patientService = PatientService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  List<MedicalAct> _acts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActs();
  }

  Future<void> _loadActs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final acts = await _actService.getMedicalActs();
      setState(() {
        _acts = acts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medical acts: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur : $e';
      });
    }
  }

  Future<void> _deleteAct(MedicalAct act) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer cet acte de ${act.patientName} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Supprimer")
          ),
        ],
      ),
    );

    if (confirmed == true) {
       try {
        await _actService.deleteMedicalAct(act.id!);
        _loadActs();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Acte supprimé")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de la suppression: $e")));
      }
    }
  }

  Future<void> _showActDialog({MedicalAct? act}) async {
    // Load patients for dropdown
    List<Patient> patients = [];
    try {
      patients = await _patientService.getPatients();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Impossible de charger les patients: $e")));
      return;
    }

    final isEditing = act != null;
    final formKey = GlobalKey<FormState>();
    
    int? selectedPatientId = act?.patientId;
    String practitioner = act?.practitioner ?? '';
    DateTime date = act?.date ?? DateTime.now();
    double cost = act?.cost ?? 0.0;
    
    // Controllers
    final typeController = TextEditingController(text: act?.type ?? '');
    final practitionerController = TextEditingController(text: practitioner);
    final costController = TextEditingController(text: act != null ? cost.toStringAsFixed(0) : '');
    final dateController = TextEditingController(text: _dateFormat.format(date));


    // Default patient selection if editing and ID not found
    if (isEditing && selectedPatientId != null && !patients.any((p) => p.id == selectedPatientId)) {
       selectedPatientId = null; 
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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(isEditing ? "Modifier l'acte" : "Nouvel acte", 
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 24),

                  // 1. Type d'acte (Text Field)
                  TextFormField(
                    controller: typeController,
                    decoration: _inputDecoration("Type d'acte"),
                    validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. Date (Text Field Style)
                  TextFormField(
                    controller: dateController,
                    decoration: _inputDecoration("Date").copyWith(
                      suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context, 
                        initialDate: date, 
                        firstDate: DateTime(2020), 
                        lastDate: DateTime(2030)
                      );
                      if (d != null) {
                         setState(() {
                           date = d;
                           dateController.text = _dateFormat.format(d);
                         });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Patient (Dropdown)
                  DropdownButtonFormField<int>(
                    value: selectedPatientId,
                    decoration: _inputDecoration("Patient"),
                    items: patients.map((p) => DropdownMenuItem(value: p.id, child: Text("${p.firstName} ${p.lastName}"))).toList(),
                    onChanged: (val) => setState(() => selectedPatientId = val),
                    validator: (val) => val == null ? 'Veuillez sélectionner un patient' : null,
                  ),
                  const SizedBox(height: 16),

                  // 4. Praticien (Text Field)
                  TextFormField(
                    controller: practitionerController,
                    decoration: _inputDecoration("Praticien"),
                  ),
                  const SizedBox(height: 16),
                  
                  // 5. Coût (Text Field)
                  TextFormField(
                    controller: costController,
                    decoration: _inputDecoration("Coût (€)"),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),
                  
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
                            if (formKey.currentState!.validate()) {
                              String pName = "Patient";
                              try {
                                 pName = patients.firstWhere((p) => p.id == selectedPatientId).lastName;
                              } catch (_) {}

                              final newAct = MedicalAct(
                                id: act?.id ?? 0,
                                patientId: selectedPatientId!,
                                patientName: pName, 
                                type: typeController.text,
                                service: typeController.text, 
                                practitioner: practitionerController.text,
                                date: date,
                                cost: double.tryParse(costController.text) ?? 0.0,
                              );

                              try {
                                if (isEditing) {
                                  await _actService.updateMedicalAct(newAct);
                                } else {
                                  await _actService.createMedicalAct(newAct);
                                }
                                _loadActs();
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "Acte modifié" : "Acte créé")));
                                }
                              } catch (e) {
                                 if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
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
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold), // Dark bold label
      floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
      floatingLabelBehavior: FloatingLabelBehavior.always, // Ensures label sits on border like the image
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      filled: true,
      fillColor: Colors.white,
    );
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
                onPressed: _loadActs,
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
        title: 'Actes Médicaux',
        subtitle: 'Gestion des interventions',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Actes médicaux", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("${_acts.length} actes enregistrés", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showActDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Nouvel acte"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
               children: [
                 TextField(
                   decoration: InputDecoration(
                     prefixIcon: const Icon(Icons.search, color: Colors.grey),
                     hintText: "Rechercher par type, patient ou praticien...",
                     filled: true,
                     fillColor: Colors.white,
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                     contentPadding: const EdgeInsets.symmetric(vertical: 0),
                   ),
                 ),
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(child: _buildFilterDropdown("Type d'acte")),
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
                : (_acts.isEmpty
                   ? const Center(child: Text("Aucun acte médical trouvé"))
                   : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _acts.length,
                    itemBuilder: (context, index) {
                      return _buildActCard(_acts[index], index + 1);
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

  Widget _buildActCard(MedicalAct act, int displayId) {
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
          _buildInfoRow("ID", "A${act.id.toString().padLeft(3, '0')}", isBold: false),
          _buildInfoRow("TYPE D'ACTE", act.type, isBold: false, alignRight: true),
          _buildInfoRow("DATE", _dateFormat.format(act.date), isBold: true),
          _buildInfoRow("PATIENT", act.patientName, isBold: false, alignRight: true),
          _buildInfoRow("PRATICIEN", act.practitioner, isBold: false, alignRight: true),
          _buildInfoRow("COÛT", _currencyFormat.format(act.cost), isBold: true),
          
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 16, color: Colors.black87),
                  label: const Text("Voir", style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showActDialog(act: act),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF1E3A8A)),
                  label: const Text("Modifier", style: TextStyle(color: Color(0xFF1E3A8A))),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteAct(act),
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

  Widget _buildInfoRow(String label, String value, {bool isBold = false, bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, 
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 12, 
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal, 
                color: Colors.black
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
