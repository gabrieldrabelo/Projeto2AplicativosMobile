import 'package:intl/intl.dart';

class FormatUtils {
  // Formatação de moeda
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }
  
  // Formatação de data
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }
  
  // Formatação de data e hora
  static String formatDateTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }
  
  // Formatação de número com casas decimais
  static String formatNumber(double value, {int decimalPlaces = 2}) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    formatter.minimumFractionDigits = decimalPlaces;
    formatter.maximumFractionDigits = decimalPlaces;
    return formatter.format(value);
  }
  
  // Formatação de porcentagem
  static String formatPercent(double value) {
    final formatter = NumberFormat.percentPattern('pt_BR');
    return formatter.format(value / 100);
  }
  
  // Formatação de telefone
  static String formatPhone(String phone) {
    if (phone.length == 11) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
    } else if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
    }
    return phone;
  }
  
  // Formatação de CPF
  static String formatCPF(String cpf) {
    if (cpf.length == 11) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    }
    return cpf;
  }
  
  // Formatação de CNPJ
  static String formatCNPJ(String cnpj) {
    if (cnpj.length == 14) {
      return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
    }
    return cnpj;
  }
}