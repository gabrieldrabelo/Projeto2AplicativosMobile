import 'package:intl/intl.dart';

class FormatUtils {
  // Formata um valor para moeda (R$)
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
  
  // Formata uma data no formato dd/MM/yyyy
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  // Formata uma data e hora no formato dd/MM/yyyy HH:mm
  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
  
  // Formata um nu00famero com casas decimais
  static String formatNumber(double value, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPattern('pt_BR')
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }
  
  // Converte uma string para double, tratando formatau00e7u00e3o brasileira
  static double parseDouble(String value) {
    if (value.isEmpty) return 0.0;
    
    // Remove su00edmbolos de moeda e espau00e7os
    String cleanValue = value.replaceAll('R\$', '').trim();
    
    // Substitui vu00edrgula por ponto
    cleanValue = cleanValue.replaceAll('.', '').replaceAll(',', '.');
    
    return double.tryParse(cleanValue) ?? 0.0;
  }
}