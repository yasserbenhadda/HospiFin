import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/stay_model.dart';
import '../../data/models/patient_model.dart';
import '../../data/services/stay_service.dart';
import '../../data/services/patient_service.dart';
import '../widgets/custom_header.dart';

class StaysScreen extends StatefulWidget {
  const StaysScreen({super.key});

  @override
  State<StaysScreen> createState() => _StaysScreenState();
}

class _StaysScreenState extends State<StaysScreen> {
  final StayService _stayService = StayService();
  final PatientService _patientService = PatientService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  List<HospitalStay> _stays = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStays();
  }

  Future<void> _loadStays() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final stays = await _stayService.getStays();
      setState(() {
        _stays = stays;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stays: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur : $e';
      });
    }
  }

  Future<void> _deleteStay(HospitalStay stay) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer le séjour de ${stay.patientName} ?"),
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
        await _stayService.deleteStay(stay.id!);
        _loadStays();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Séjour supprimé")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de la suppression: $e")));
      }
    }
  }

  Future<void> _showStayDialog({HospitalStay? stay}) async {
    // Load patients for dropdown
    List<Patient> patients = [];
    try {
      patients = await _patientService.getPatients();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Impossible de charger les patients: $e")));
      return;
    }

    final isEditing = stay != null;
    final formKey = GlobalKey<FormState>();
    
    int? selectedPatientId = stay?.patientId;
    String service = stay?.service ?? 'Cardiologie';
    DateTime startDate = stay?.startDate ?? DateTime.now();
    DateTime endDate = stay?.endDate ?? DateTime.now().add(const Duration(days: 3));
    double cost = stay?.totalCost ?? 0.0;
    String status = stay?.status ?? 'En cours';

    final services = ['Cardiologie', 'Neurologie', 'Chirurgie', 'Pédiatrie', 'Urgences', 'Oncologie', 'Autre'];
    final statuses = ['Prévu', 'En cours', 'Terminé'];
    
    final costController = TextEditingController(text: cost == 0 ? '' : cost.toStringAsFixed(0));
    final startController = TextEditingController(text: _dateFormat.format(startDate));
    final endController = TextEditingController(text: _dateFormat.format(endDate));


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
                   Text(isEditing ? "Modifier le séjour" : "Nouveau séjour", 
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 24),

                  // 1. Patient
                  DropdownButtonFormField<int>(
                    value: selectedPatientId,
                    decoration: _inputDecoration("Patient"),
                    items: patients.map((p) => DropdownMenuItem(value: p.id, child: Text("${p.firstName} ${p.lastName}"))).toList(),
                    onChanged: (val) => setState(() => selectedPatientId = val),
                    validator: (val) => val == null ? 'Veuillez sélectionner un patient' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // 2. Service
                  DropdownButtonFormField<String>(
                    value: service,
                    decoration: _inputDecoration("Service"),
                    items: services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => service = val!),
                  ),
                  const SizedBox(height: 16),
                  
                  // 3. Cost
                  TextFormField(
                    controller: costController,
                    decoration: _inputDecoration("Coût Total (€)"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => cost = double.tryParse(val) ?? 0.0,
                  ),
                  const SizedBox(height: 16),
                  
                  // 4. Status
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: _inputDecoration("Statut"),
                    items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => status = val!),
                  ),
                  const SizedBox(height: 16),
                  
                  // 5. Start Date
                  _buildDatePicker(
                    context: context,
                    label: "Date de début",
                    controller: startController,
                    initialDate: startDate,
                    onDateSelected: (d) => setState(() { startDate = d; startController.text = _dateFormat.format(d); }),
                  ),
                  const SizedBox(height: 16),

                  // 6. End Date
                  _buildDatePicker(
                    context: context,
                    label: "Date de fin",
                    controller: endController,
                    initialDate: endDate,
                    onDateSelected: (d) => setState(() { endDate = d; endController.text = _dateFormat.format(d); }),
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
                            // Find patient name for placeholder if needed (though backend usually handles link, frontend lists might need it immediately)
                            String pName = "Patient";
                             try {
                                 pName = patients.firstWhere((p) => p.id == selectedPatientId).lastName;
                              } catch (_) {}

                            final newStay = HospitalStay(
                              id: stay?.id ?? 0,
                              patientId: selectedPatientId!,
                              patientName: pName,
                              service: service,
                              startDate: startDate,
                              endDate: endDate,
                              totalCost: cost,
                              status: status,
                              pathology: service,
                            );

                            try {
                              if (isEditing) {
                                await _stayService.updateStay(newStay);
                              } else {
                                await _stayService.createStay(newStay);
                              }
                              _loadStays();
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? "Séjour modifié" : "Séjour créé")));
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
                      )
                    ],
                  ),
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
      labelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold),
      floatingLabelStyle: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
      floatingLabelBehavior: FloatingLabelBehavior.always, // Ensures consistent border placement
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildDatePicker({required BuildContext context, required String label, required TextEditingController controller, required DateTime initialDate, required Function(DateTime) onDateSelected}) {
     return TextFormField(
        controller: controller,
        decoration: _inputDecoration(label).copyWith(
          suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
        ),
        readOnly: true,
        onTap: () async {
          final d = await showDatePicker(
            context: context, 
            initialDate: initialDate, 
            firstDate: DateTime(2020), 
            lastDate: DateTime(2030)
          );
          if (d != null) onDateSelected(d);
        },
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
                onPressed: _loadStays,
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
        title: 'Séjours hospitaliers',
        subtitle: 'Gestion des admissions',
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
                // Back button removed from here
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gestion des séjours", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("${_stays.length} séjours enregistrés", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showStayDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Nouveau séjour"),
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
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
               children: [
                 TextField(
                   decoration: InputDecoration(
                     prefixIcon: const Icon(Icons.search, color: Colors.grey),
                     hintText: "Rechercher par patient, ID ou service...",
                     filled: true,
                     fillColor: Colors.white,
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                     contentPadding: const EdgeInsets.symmetric(vertical: 0),
                   ),
                 ),
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(child: _buildFilterDropdown("Service")),
                     const SizedBox(width: 8),
                     Expanded(child: _buildFilterDropdown("Statut")),
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
                : (_stays.isEmpty 
                    ? const Center(child: Text("Aucun séjour trouvé")) 
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _stays.length,
                        itemBuilder: (context, index) {
                          return _buildStayCard(_stays[index], index + 1);
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

  Widget _buildStayCard(HospitalStay stay, int displayId) {
    Color statusColor = Colors.grey;
    Color statusBg = Colors.grey.shade100;
    
    if (stay.status == 'En cours') {
      statusColor = Colors.white;
      statusBg = Colors.black;
    } else if (stay.status == 'Terminé') {
      statusColor = Colors.black54;
      statusBg = Colors.grey.shade200;
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
          _buildInfoRow("ID", "S${stay.id.toString().padLeft(3, '0')}", isBold: false),
          _buildInfoRow("PATIENT", stay.patientName, isBold: true),
          _buildInfoRow("SERVICE", stay.service, isBold: true),
          _buildInfoRow("DATE DÉBUT", _dateFormat.format(stay.startDate), isBold: true),
          _buildInfoRow("DATE FIN", _dateFormat.format(stay.endDate), isBold: true),
          _buildInfoRow("COÛT TOTAL", _currencyFormat.format(stay.totalCost), isBold: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("STATUT", style: GoogleFonts.inter(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(stay.status, style: GoogleFonts.inter(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showStayDialog(stay: stay),
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
                  onPressed: () => _deleteStay(stay),
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
}
