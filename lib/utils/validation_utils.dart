class ValidationUtils {
  // Validação de email
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  // Validação de CPF
  static bool isValidCPF(String cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 11 dígitos
    if (cpf.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;
    
    // Validação do primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;
    
    if (int.parse(cpf[9]) != firstDigit) return false;
    
    // Validação do segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;
    
    return int.parse(cpf[10]) == secondDigit;
  }

  // Validação de CNPJ
  static bool isValidCNPJ(String cnpj) {
    // Remove caracteres não numéricos
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 14 dígitos
    if (cnpj.length != 14) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;
    
    // Validação do primeiro dígito verificador
    List<int> weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weights1[i];
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;
    
    if (int.parse(cnpj[12]) != firstDigit) return false;
    
    // Validação do segundo dígito verificador
    List<int> weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weights2[i];
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;
    
    return int.parse(cnpj[13]) == secondDigit;
  }

  // Validação de telefone brasileiro
  static bool isValidPhone(String phone) {
    // Remove caracteres não numéricos
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 10 ou 11 dígitos (com DDD)
    if (phone.length != 10 && phone.length != 11) return false;
    
    // Verifica se o DDD é válido (11 a 99)
    int ddd = int.parse(phone.substring(0, 2));
    if (ddd < 11 || ddd > 99) return false;
    
    return true;
  }

  // Validação de CEP
  static bool isValidCEP(String cep) {
    // Remove caracteres não numéricos
    cep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 8 dígitos
    return cep.length == 8;
  }

  // Validação de campo obrigatório
  static bool isRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // Validação de comprimento mínimo
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  // Validação de comprimento máximo
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }

  // Validação de URL
  static bool isValidURL(String url) {
  try {
    final uri = Uri.parse(url);
    return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  } catch (e) {
    return false;
  }
}

  // Validação de senha forte
  static bool isStrongPassword(String password) {
    // Pelo menos 8 caracteres, uma letra maiúscula, uma minúscula, um número e um caractere especial
    final passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  // Validação de número
  static bool isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  // Validação de número inteiro
  static bool isInteger(String value) {
    return int.tryParse(value) != null;
  }

  // Validação de valor positivo
  static bool isPositive(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0;
  }
}