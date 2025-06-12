import 'package:intl/intl.dart';


class FormatUtils {
  // Formatar moeda
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
  
  // Formatar data
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return isoDate;
    }
  }
  
  // Formatar data e hora
  static String formatDateTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(date);
    } catch (e) {
      return isoDate;
    }
  }
  
  // Formatar CPF
  static String formatCPF(String cpf) {
    // Remove caracteres nu00e3o numu00e9ricos
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cpf.length != 11) {
      return cpf;
    }
    
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }
  
  // Formatar CNPJ
  static String formatCNPJ(String cnpj) {
    // Remove caracteres nu00e3o numu00e9ricos
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cnpj.length != 14) {
      return cnpj;
    }
    
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }
  
  // Formatar CPF ou CNPJ
  static String formatCpfCnpj(String cpfCnpj) {
    // Remove caracteres nu00e3o numu00e9ricos
    cpfCnpj = cpfCnpj.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cpfCnpj.length <= 11) {
      return formatCPF(cpfCnpj);
    } else {
      return formatCNPJ(cpfCnpj);
    }
  }
  
  // Formatar telefone
  static String formatPhone(String phone) {
    // Remove caracteres nu00e3o numu00e9ricos
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (phone.length < 10) {
      return phone;
    }
    
    if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
    } else {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
    }
  }
  
  // Formatar CEP
  static String formatCEP(String cep) {
    // Remove caracteres nu00e3o numu00e9ricos
    cep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cep.length != 8) {
      return cep;
    }
    
    return '${cep.substring(0, 5)}-${cep.substring(5)}';
  }
  
  // Formatar nu00famero com casas decimais
  static String formatNumber(double value, {int decimalPlaces = 2}) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    formatter.minimumFractionDigits = decimalPlaces;
    formatter.maximumFractionDigits = decimalPlaces;
    return formatter.format(value);
  }
}