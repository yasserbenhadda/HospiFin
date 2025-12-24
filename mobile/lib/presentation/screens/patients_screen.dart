import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/patient_service.dart';
import '../../data/models/patient_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PatientService _patientService = PatientService();
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterPatients);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final patients = await _patientService.getPatients();
      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion : Impossible de charger les patients.\nDétail: $e';
      });
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        final name = '${p.firstName} ${p.lastName}'.toLowerCase();
        final id = p.id.toString().toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    });
  }

  // --- Derived Data Helpers (Mocking Missing Fields) ---
  String _getGender(Patient p) {
    if (p.ssn.length >= 13) {
      final firstDigit = p.ssn.substring(0, 1);
      if (firstDigit == '1') return 'Masculin';
      if (firstDigit == '2') return 'Féminin';
    }
    final name = p.firstName.toLowerCase();
    if (name.endsWith('a') || name.endsWith('e')) return 'Féminin';
    return 'Masculin';
  }

  String _getInsurance(Patient p) {
    final insurances = ['Sécurité Sociale', 'Mutuelle MGEN', 'Allianz', 'AXA Santé', 'Harmonie Mutuelle'];
    return insurances[p.id % insurances.length];
  }

  String _getPhone(Patient p) {
    return '+33 6 ${10 + p.id} ${20 + p.id} ${30 + p.id} ${40 + p.id}';
  }
  
  String _formatId(int id) {
     return 'P${id.toString().padLeft(3, '0')}';
  }

  Future<void> _showPatientDialog({Patient? patient}) async {
    final isEditing = patient != null;
    final formKey = GlobalKey<FormState>();
    
    // Controllers
    final fNameController = TextEditingController(text: patient?.firstName ?? '');
    final lNameController = TextEditingController(text: patient?.lastName ?? '');
    final ssnController = TextEditingController(text: patient?.ssn ?? '');
    DateTime? birthDate = patient?.birthDate;
    
    await showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder to update DatePicker text
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFFEFF3F8), // High Contrast
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
                         Text(isEditing ? "Modifier le patient" : "Nouveau patient", 
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        const SizedBox(height: 24),

                        _buildStyledTextField(controller: fNameController, label: 'Prénom'),
                        const SizedBox(height: 16),
                        _buildStyledTextField(controller: lNameController, label: 'Nom'),
                        const SizedBox(height: 16),
                        _buildStyledTextField(controller: ssnController, label: 'Numéro Sécu (SSN)', isNumber: true),
                        const SizedBox(height: 16),
                        
                        // Date Picker Tile
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("Date de naissance", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                          subtitle: Text(
                            birthDate != null ? _dateFormat.format(birthDate!) : "Sélectionner une date",
                            style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF1E293B))
                          ),
                          trailing: const Icon(Icons.calendar_today, color: Color(0xFF64748B)),
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context, 
                              initialDate: birthDate ?? DateTime(1990), 
                              firstDate: DateTime(1900), 
                              lastDate: DateTime.now()
                            );
                            if (d != null) {
                              setState(() => birthDate = d);
                            }
                          },
                        ),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), 
                              child: Text("Annuler", style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w600))
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final data = {
                                    'firstName': fNameController.text,
                                    'lastName': lNameController.text,
                                    'ssn': ssnController.text,
                                    'birthDate': birthDate?.toIso8601String(),
                                  };
                                  
                                  // Close dialog first
                                  
                                  try {
                                    if (isEditing) {
                                      await _patientService.updatePatient(patient!.id, data);
                                    } else {
                                      await _patientService.createPatient(data);
                                    }
                                    if (mounted) Navigator.pop(context);
                                    _loadData();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(isEditing ? "Patient modifié" : "Patient créé"))
                                      );
                                    }
                                  } catch (e) {
                                     if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
                                     }
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
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      }
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
      validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
    );
  }

  void _confirmDelete(Patient patient) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le patient ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${patient.fullName} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _patientService.deletePatient(patient.id);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient supprimé')));
                }
              } catch (e) {
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger les données',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomHeader(
        title: 'Patients',
        subtitle: 'Gestion des dossiers',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                   '${_allPatients.length} patients enregistrés',
                   style: GoogleFonts.inter(
                     fontSize: 14,
                     color: const Color(0xFF64748B),
                   ),
                 ),
                 // Button kept below
                 // ...
                  ElevatedButton.icon(
                    onPressed: () => _showPatientDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Nouveau patient', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // --- Controls ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    hintText: 'Rechercher par nom ou ID...',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _buildDropdown('Assurance')),
                   const SizedBox(width: 12),
                   _buildIconButton(Icons.filter_list),
                   const SizedBox(width: 12),
                   _buildIconButton(Icons.download_rounded),
                ],
              ),
              const SizedBox(height: 24),

              // --- List ---
              if (_filteredPatients.isEmpty)
                 Center(child: Text("Aucun patient trouvé", style: GoogleFonts.inter(color: Colors.grey)))
              else
                 ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredPatients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildPatientCard(_filteredPatients[index]),
                 ),
            ],
          ),
        ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF64748B), size: 20),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    final gender = _getGender(patient);
    final insurance = _getInsurance(patient);
    final phone = _getPhone(patient);
    final id = _formatId(patient.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
           // Top Row: ID and Name
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text('ID', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    Text(id, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A))),
                 ],
               ),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                    Text('NOM COMPLET', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    Text(patient.fullName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                 ],
               ),
             ],
           ),
           const Divider(height: 32, color: Color(0xFFF1F5F9)),
           
           // Fields Grid
           _buildFieldRow('DATE DE NAISSANCE', patient.birthDate != null ? _dateFormat.format(patient.birthDate!) : 'N/A', 'GENRE', gender, isPill: true),
           const SizedBox(height: 16),
           _buildFieldRow('ASSURANCE', insurance, 'TÉLÉPHONE', phone),
           
           const SizedBox(height: 24),
           
           // Actions
           Row(
             children: [
               Expanded(
                 child: OutlinedButton.icon(
                   onPressed: () => _showPatientDialog(patient: patient),
                   icon: const Icon(Icons.edit_outlined, size: 16),
                   label: const Text('Modifier'),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: const Color(0xFF334155),
                     side: const BorderSide(color: Color(0xFFCBD5E1)),
                     padding: const EdgeInsets.symmetric(vertical: 14),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: OutlinedButton.icon(
                   onPressed: () => _confirmDelete(patient),
                   icon: const Icon(Icons.delete_outline, size: 16),
                   label: const Text('Supprimer'),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: const Color(0xFFEF4444),
                     side: const BorderSide(color: Color(0xFFFECACA)),
                     padding: const EdgeInsets.symmetric(vertical: 14),
                     backgroundColor: const Color(0xFFFEF2F2),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                 ),
               ),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label1, String val1, String label2, String val2, {bool isPill = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label1, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(val1, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF334155))),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label2, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            if (isPill)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(val2, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
              )
            else
              Text(val2, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF334155))),
          ],
        )
      ],
    );
  }
}
