import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/patient_service.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final PatientService _patientService = PatientService();
  List<dynamic> _allPatients = [];
  List<dynamic> _filteredPatients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

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
      print('Error loading patients: $e'); // Added print for debugging
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
        final name = '${p['firstName']} ${p['lastName']}'.toLowerCase();
        final id = (p['id']?.toString() ?? '').toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    });
  }

  // --- Derived Data Helpers (Mocking Missing Fields) ---
  String _getGender(Map<String, dynamic> p) {
    if (p['ssn'] != null && p['ssn'].toString().length >= 13) {
      final firstDigit = p['ssn'].toString().substring(0, 1);
      if (firstDigit == '1') return 'Masculin';
      if (firstDigit == '2') return 'Féminin';
    }
    // Fallback based on name ending (rough heuristic) or random
    final name = p['firstName'].toString().toLowerCase();
    if (name.endsWith('a') || name.endsWith('e')) return 'Féminin';
    return 'Masculin';
  }

  String _getInsurance(Map<String, dynamic> p) {
    // Deterministic hash based on ID
    final id = p['id'] as int? ?? 0;
    final insurances = ['Sécurité Sociale', 'Mutuelle MGEN', 'Allianz', 'AXA Santé', 'Harmonie Mutuelle'];
    return insurances[id % insurances.length];
  }

  String _getPhone(Map<String, dynamic> p) {
    final id = p['id'] as int? ?? 0;
    return '+33 6 ${10 + id} ${20 + id} ${30 + id} ${40 + id}';
  }
  
  String _formatId(dynamic id) {
     return 'P${id.toString().padLeft(3, '0')}';
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
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestion des patients',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_allPatients.length} patients enregistrés',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showPatientDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Nouveau patient', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A), // Dark almost black
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // --- Controls (Search + Filters) ---
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
                   // Dropdown Simulation
                   Expanded(child: _buildDropdown('Assurance')),
                   const SizedBox(width: 12),
                   _buildIconButton(Icons.filter_list),
                   const SizedBox(width: 12),
                   _buildIconButton(Icons.download_rounded),
                ],
              ),
              const SizedBox(height: 24),

              // --- List ---
              if (_isLoading)
                 const Center(child: CircularProgressIndicator())
              else if (_filteredPatients.isEmpty)
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final gender = _getGender(patient);
    final insurance = _getInsurance(patient);
    final phone = _getPhone(patient);
    final id = _formatId(patient['id']);

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
                    Text('${patient['firstName']} ${patient['lastName']}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                 ],
               ),
             ],
           ),
           const Divider(height: 32, color: Color(0xFFF1F5F9)),
           
           // Fields Grid
           _buildFieldRow('DATE DE NAISSANCE', patient['birthDate'] ?? 'N/A', 'GENRE', gender, isPill: true),
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

  void _confirmDelete(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le patient ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${patient['firstName']} ${patient['lastName']} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _patientService.deletePatient(patient['id']);
                _loadData(); // Refresh
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient supprimé')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showPatientDialog({Map<String, dynamic>? patient}) {
    final isEdit = patient != null;
    final fNameController = TextEditingController(text: patient?['firstName'] ?? '');
    final lNameController = TextEditingController(text: patient?['lastName'] ?? '');
    final ssnController = TextEditingController(text: patient?['ssn'] ?? '');
    final birthDateController = TextEditingController(text: patient?['birthDate'] ?? '');

    showDialog(
      context: context,
      barrierColor: const Color(0xFF0F172A).withOpacity(0.5), // Dark overlay
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Header
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                     isEdit ? 'Modifier le patient' : 'Nouveau patient',
                     style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                   ),
                   IconButton(
                     onPressed: () => Navigator.of(ctx).pop(),
                     icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                     splashRadius: 20,
                   )
                 ],
               ),
               const SizedBox(height: 24),
               
               // Form Fields
               _buildDialogTextField(label: 'Prénom', controller: fNameController),
               const SizedBox(height: 16),
               _buildDialogTextField(label: 'Nom', controller: lNameController),
               const SizedBox(height: 16),
               _buildDialogTextField(label: 'Numéro Sécu (SSN)', controller: ssnController),
               const SizedBox(height: 16),
               _buildDialogTextField(label: 'Date de naissance (YYYY-MM-DD)', controller: birthDateController),
               
               const SizedBox(height: 32),
               
               // Actions
               Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      child: Text('Annuler', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final data = {
                          'firstName': fNameController.text,
                          'lastName': lNameController.text,
                          'ssn': ssnController.text,
                          'birthDate': birthDateController.text,
                        };
                        Navigator.of(ctx).pop();
                        try {
                          if (isEdit) {
                            await _patientService.updatePatient(patient['id'], data);
                          } else {
                            await _patientService.createPatient(data);
                          }
                          _loadData(); // Refresh list
                          if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text(isEdit ? 'Patient modifié avec succès' : 'Nouveau patient ajouté'),
                                 backgroundColor: const Color(0xFF10B981),
                                 behavior: SnackBarBehavior.floating,
                               ),
                             );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Enregistrer', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                 ],
               )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(color: const Color(0xFF0F172A)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
          ),
        ),
      ],
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
