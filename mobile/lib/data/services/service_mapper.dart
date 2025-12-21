class ServiceMapper {
  static const String chirurgie = 'Chirurgie';
  static const String cardiologie = 'Cardiologie';
  static const String urgences = 'Urgences';
  static const String maternite = 'Maternité';
  static const String radiologie = 'Radiologie';
  static const String other = 'Autre';

  static String getServiceFromText(String text) {
    if (text.isEmpty) return other;
    
    final lower = text.toLowerCase();
    
    if (lower.contains('chirurg') || lower.contains('ortho') || lower.contains('opér') || lower.contains('anest')) {
      return chirurgie;
    }
    if (lower.contains('cardio') || lower.contains('coeur') || lower.contains('vasc')) {
      return cardiologie;
    }
    if (lower.contains('urgence') || lower.contains('sos') || lower.contains('trauma')) {
      return urgences;
    }
    if (lower.contains('matern') || lower.contains('nnais') || lower.contains('accouchement') || lower.contains('femme')) {
      return maternite;
    }
    if (lower.contains('radio') || lower.contains('irm') || lower.contains('scan') || lower.contains('echo')) {
      return radiologie;
    }
    
    return other;
  }
}
