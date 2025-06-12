class ValidationUtils {
  // Valida se um CPF u00e9 vu00e1lido
  static bool isValidCPF(String cpf) {
    // Remove caracteres nu00e3o numeu00e9ricos
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    
    // Verifica se tem 11 du00edgitos
    if (cpf.length != 11) return false;
    
    // Verifica se todos os du00edgitos su00e3o iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;
    
    // Calcula o primeiro du00edgito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int digito1 = 11 - (soma % 11);
    if (digito1 > 9) digito1 = 0;
    
    // Verifica o primeiro du00edgito verificador
    if (int.parse(cpf[9]) != digito1) return false;
    
    // Calcula o segundo du00edgito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int digito2 = 11 - (soma % 11);
    if (digito2 > 9) digito2 = 0;
    
    // Verifica o segundo du00edgito verificador
    return int.parse(cpf[10]) == digito2;
  }
  
  // Valida se um CNPJ u00e9 vu00e1lido
  static bool isValidCNPJ(String cnpj) {
    // Remove caracteres nu00e3o numeu00e9ricos
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');
    
    // Verifica se tem 14 du00edgitos
    if (cnpj.length != 14) return false;
    
    // Verifica se todos os du00edgitos su00e3o iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;
    
    // Calcula o primeiro du00edgito verificador
    int soma = 0;
    int peso = 5;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(cnpj[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    int digito1 = 11 - (soma % 11);
    if (digito1 > 9) digito1 = 0;
    
    // Verifica o primeiro du00edgito verificador
    if (int.parse(cnpj[12]) != digito1) return false;
    
    // Calcula o segundo du00edgito verificador
    soma = 0;
    peso = 6;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(cnpj[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    int digito2 = 11 - (soma % 11);
    if (digito2 > 9) digito2 = 0;
    
    // Verifica o segundo du00edgito verificador
    return int.parse(cnpj[13]) == digito2;
  }
  
  // Valida se um email u00e9 vu00e1lido
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    
    return emailRegex.hasMatch(email);
  }
  
  // Valida se um telefone u00e9 vu00e1lido
  static bool isValidPhone(String phone) {
    // Remove caracteres nu00e3o numeu00e9ricos
    phone = phone.replaceAll(RegExp(r'\D'), '');
    
    // Verifica se tem entre 10 e 11 du00edgitos (com ou sem DDD)
    return phone.length >= 10 && phone.length <= 11;
  }
  
  // Valida se um CEP u00e9 vu00e1lido
  static bool isValidZipCode(String zipCode) {
    // Remove caracteres nu00e3o numeu00e9ricos
    zipCode = zipCode.replaceAll(RegExp(r'\D'), '');
    
    // Verifica se tem 8 du00edgitos
    return zipCode.length == 8;
  }
}